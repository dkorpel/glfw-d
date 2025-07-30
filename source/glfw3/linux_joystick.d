/// Translated from C to D
module glfw3.linux_joystick;

nothrow:
extern(C): __gshared:
version(linux):

//========================================================================
// GLFW 3.3 Linux - www.glfw.org
//------------------------------------------------------------------------
// Copyright (c) 2002-2006 Marcus Geelnard
// Copyright (c) 2006-2017 Camilla Löwy <elmindreda@glfw.org>
//
// This software is provided 'as-is', without any express or implied
// warranty. In no event will the authors be held liable for any damages
// arising from the use of this software.
//
// Permission is granted to anyone to use this software for any purpose,
// including commercial applications, and to alter it and redistribute it
// freely, subject to the following restrictions:
//
// 1. The origin of this software must not be misrepresented; you must not
//    claim that you wrote the original software. If you use this software
//    in a product, an acknowledgment in the product documentation would
//    be appreciated but is not required.
//
// 2. Altered source versions must be plainly marked as such, and must not
//    be misrepresented as being the original software.
//
// 3. This notice may not be removed or altered from any source
//    distribution.
//
//========================================================================
// It is fine to use C99 in this file because it will not be built with VS
//========================================================================

import glfw3.internal;

import core.sys.posix.sys.types;
import core.sys.posix.sys.stat;
import core.sys.linux.sys.inotify;
import core.sys.posix.fcntl;
import core.stdc.errno;
import core.sys.posix.dirent;
import core.stdc.stdio;
import core.stdc.stdlib;
import core.stdc.string;
import core.sys.posix.unistd;

public import glfw3.linuxinput;
import core.stdc.limits;

import core.sys.posix.sys.ioctl: ioctl;

mixin template _GLFW_PLATFORM_JOYSTICK_STATE() {        _GLFWjoystickLinux linjs; }
mixin template _GLFW_PLATFORM_LIBRARY_JOYSTICK_STATE() {_GLFWlibraryLinux  linjs; }

enum _GLFW_PLATFORM_MAPPING_NAME = "Linux";

// Linux-specific joystick data
//
struct _GLFWjoystickLinux {
    int fd;
    char[PATH_MAX] path = '\0';
    int[KEY_CNT - BTN_MISC] keyMap;
    int[ABS_CNT] absMap;
    input_absinfo[ABS_CNT] absInfo;
    int[2][4] hats;
    bool hasRumble = false;
    ff_effect rumble;
}

// Linux-specific joystick API data
//
struct _GLFWlibraryLinux {
    int inotify;
    int watch;
    version(none) {
        regex_t regex;
    }
    GLFWbool dropped;
}

version(none) { // < v2.6.39 kernel headers
    // Workaround for CentOS-6, which is supported till 2020-11-30, but still on v2.6.32
    enum SYN_DROPPED = 3;
}

// Apply an EV_KEY event to the specified joystick
//
private void handleKeyEvent(_GLFWjoystick* js, int code, int value) {
    _glfwInputJoystickButton(js,
                             js.linjs.keyMap[code - BTN_MISC],
                             value ? GLFW_PRESS : GLFW_RELEASE);
}

// Apply an EV_ABS event to the specified joystick
//
private void handleAbsEvent(_GLFWjoystick* js, int code, int value) {
    const(int) index = js.linjs.absMap[code];

    if (code >= ABS_HAT0X && code <= ABS_HAT3Y)
    {
        static const(char)[3][3] stateMap = [
            [ GLFW_HAT_CENTERED, GLFW_HAT_UP,       GLFW_HAT_DOWN ],
            [ GLFW_HAT_LEFT,     GLFW_HAT_LEFT_UP,  GLFW_HAT_LEFT_DOWN ],
            [ GLFW_HAT_RIGHT,    GLFW_HAT_RIGHT_UP, GLFW_HAT_RIGHT_DOWN ],
        ];

        const(int) hat = (code - ABS_HAT0X) / 2;
        const(int) axis = (code - ABS_HAT0X) % 2;
        int* state = js.linjs.hats[hat].ptr;

        // NOTE: Looking at several input drivers, it seems all hat events use
        //       -1 for left / up, 0 for centered and 1 for right / down
        if (value == 0)
            state[axis] = 0;
        else if (value < 0)
            state[axis] = 1;
        else if (value > 0)
            state[axis] = 2;

        _glfwInputJoystickHat(js, index, stateMap[state[0]][state[1]]);
    }
    else
    {
        input_absinfo* info = &js.linjs.absInfo[code];
        float normalized = value;

        const(int) range = info.maximum - info.minimum;
        if (range)
        {
            // Normalize to 0.0 -> 1.0
            normalized = (normalized - info.minimum) / range;
            // Normalize to -1.0 -> 1.0
            normalized = normalized * 2.0f - 1.0f;
        }

        _glfwInputJoystickAxis(js, index, normalized);
    }
}

// Poll state of absolute axes
//
private void pollAbsState(_GLFWjoystick* js) {
    for (int code = 0;  code < ABS_CNT;  code++)
    {
        if (js.linjs.absMap[code] < 0)
            continue;

        input_absinfo* info = &js.linjs.absInfo[code];

        if (ioctl(js.linjs.fd, EVIOCGABS(code), info) < 0)
            continue;

        handleAbsEvent(js, code, info.value);
    }
}

// #define isBitSet(bit, arr) (arr[(bit) / 8] & (1 << ((bit) % 8)))
// enum string isBitSet(string bit, string arr) = ` (`~arr~`[(`~bit~`) / 8] & (1 << ((`~bit~`) % 8)))`;
private bool isBitSet(int bit, scope const ubyte[] arr) {return cast(bool) (arr[bit / 8] & (1 << (bit % 8)));}

private void initJoystickForceFeedback(_GLFWjoystickLinux *linjs)
{
    linjs.hasRumble = false;

    ubyte[(FF_CNT + 7) / 8] ffBits = 0;
    if (ioctl(linjs.fd, EVIOCGBIT!(typeof(ffBits))(EV_FF), ffBits.ptr) < 0)
    {
        return;
    }

    if (isBitSet(FF_RUMBLE, ffBits))
    {
        linjs.rumble.type =      FF_RUMBLE;
        linjs.rumble.id =        -1;
        linjs.rumble.direction = 0;
        linjs.rumble.trigger = ff_trigger(/*.button*/ 0, /*.interval*/ 0);
        linjs.rumble.replay = ff_replay(/*length*/ 2000, /*delay*/ 0);
        linjs.rumble.u.rumble = ff_rumble_effect(/*strong_magnitude*/ 0, /*weak_magnitude*/ 0); // xinput rumble lasts ~2 seconds

        linjs.hasRumble = (ioctl(linjs.fd, EVIOCSFF, &linjs.rumble) >= 0);
    }
}

// Attempt to open the specified joystick device
//
private GLFWbool openJoystickDevice(const(char)* path) {
    for (int jid = 0;  jid <= GLFW_JOYSTICK_LAST;  jid++)
    {
        if (!_glfw.joysticks[jid].present)
            continue;
        if (strcmp(_glfw.joysticks[jid].linjs.path.ptr, path) == 0)
            return GLFW_FALSE;
    }

    _GLFWjoystickLinux linjs = _GLFWjoystickLinux(0);
    linjs.fd = open(path, O_RDWR | O_NONBLOCK);
    if (linjs.fd == -1)
        return GLFW_FALSE;

    ubyte[(EV_CNT + 7) / 8] evBits = 0;
    ubyte[(KEY_CNT + 7) / 8] keyBits = 0;
    ubyte[(ABS_CNT + 7) / 8] absBits = 0;
    input_id id;

    if (ioctl(linjs.fd, EVIOCGBIT!(typeof(evBits) )(     0), evBits.ptr) < 0 ||
        ioctl(linjs.fd, EVIOCGBIT!(typeof(keyBits))(EV_KEY), keyBits.ptr) < 0 ||
        ioctl(linjs.fd, EVIOCGBIT!(typeof(absBits))(EV_ABS), absBits.ptr) < 0 ||
        ioctl(linjs.fd, EVIOCGID, &id) < 0)
    {
        _glfwInputError(GLFW_PLATFORM_ERROR,
                        "Linux: Failed to query input device: %s",
                        strerror(errno));
        close(linjs.fd);
        return GLFW_FALSE;
    }

    // Ensure this device supports the events expected of a joystick
    if (!isBitSet(EV_KEY, evBits) && !isBitSet(EV_ABS, evBits))
    {
        close(linjs.fd);
        return GLFW_FALSE;
    }

    char[256] name = "";

    if (ioctl(linjs.fd, EVIOCGNAME!(typeof(name))(), name.ptr) < 0)
        strncpy(name.ptr, "Unknown", name.length);

    char[33] guid = "";

    // Generate a joystick GUID that matches the SDL 2.0.5+ one
    if (id.vendor && id.product && id.version_)
    {
        sprintf(guid.ptr, "%02x%02x0000%02x%02x0000%02x%02x0000%02x%02x0000",
                id.bustype & 0xff, id.bustype >> 8,
                id.vendor & 0xff,  id.vendor >> 8,
                id.product & 0xff, id.product >> 8,
                id.version_ & 0xff, id.version_ >> 8);
    }
    else
    {
        sprintf(guid.ptr, "%02x%02x0000%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x00",
                id.bustype & 0xff, id.bustype >> 8,
                name[0], name[1], name[2], name[3],
                name[4], name[5], name[6], name[7],
                name[8], name[9], name[10]);
    }

    int axisCount = 0;int buttonCount = 0;int hatCount = 0;

    for (int code = BTN_MISC;  code < KEY_CNT;  code++)
    {
        if (!isBitSet(code, keyBits))
            continue;

        linjs.keyMap[code - BTN_MISC] = buttonCount;
        buttonCount++;
    }

    for (int code = 0;  code < ABS_CNT;  code++)
    {
        linjs.absMap[code] = -1;
        if (!isBitSet(code, absBits))
            continue;

        if (code >= ABS_HAT0X && code <= ABS_HAT3Y)
        {
            linjs.absMap[code] = hatCount;
            hatCount++;
            // Skip the Y axis
            code++;
        }
        else
        {
            if (ioctl(linjs.fd, EVIOCGABS(code), &linjs.absInfo[code]) < 0)
                continue;

            linjs.absMap[code] = axisCount;
            axisCount++;
        }
    }

    initJoystickForceFeedback(&linjs);

    _GLFWjoystick* js = _glfwAllocJoystick(name.ptr, guid.ptr, axisCount, buttonCount, hatCount);
    if (!js)
    {
        close(linjs.fd);
        return GLFW_FALSE;
    }

    strncpy(linjs.path.ptr, path, linjs.path.length - 1);
    memcpy(&js.linjs, &linjs, linjs.sizeof); // #twab: wrong size, linjs.path.length

    pollAbsState(js);

    _glfwInputJoystick(js, GLFW_CONNECTED);
    return GLFW_TRUE;
}

// Frees all resources associated with the specified joystick
//
private void closeJoystick(_GLFWjoystick* js) {
    close(js.linjs.fd);
    _glfwFreeJoystick(js);
    _glfwInputJoystick(js, GLFW_DISCONNECTED);
}

// Lexically compare joysticks by name; used by qsort
//
private int compareJoysticks(const(void)* fp, const(void)* sp) {
    auto fj = cast(const(_GLFWjoystick)*) fp;
    auto sj = cast(const(_GLFWjoystick)*) sp;
    return strcmp(fj.linjs.path.ptr, sj.linjs.path.ptr);
}


//////////////////////////////////////////////////////////////////////////
//////                       GLFW internal API                      //////
//////////////////////////////////////////////////////////////////////////

/// Returns: `true` if `str` matches the regex `^event[0-9]\\+$`
private extern(D) bool isEventFile(const(char)* str) {
    import core.stdc.string: strlen;
    const len = strlen(str);
    if (len < "event0".length) {
        return false;
    }
    if (str[0..5] != "event") {
        return false;
    }
    foreach(i; 5..len) {
        if (str[i] < '0' || str[i] > '9') {
            return false;
        }
    }
    return true;
}

@("is event file") unittest {
    assert(isEventFile("event0"));
    assert(isEventFile("event1234567890"));
    assert(!isEventFile("event"));
    assert(!isEventFile("even0"));
    assert(!isEventFile("event0A"));
}

// Initialize joystick interface
//
GLFWbool _glfwInitJoysticksLinux() {
    const(char)* dirname = "/dev/input";

    _glfw.linjs.inotify = inotify_init1(IN_NONBLOCK | IN_CLOEXEC);
    if (_glfw.linjs.inotify > 0)
    {
        // HACK: Register for IN_ATTRIB to get notified when udev is done
        //       This works well in practice but the true way is libudev

        _glfw.linjs.watch = inotify_add_watch(_glfw.linjs.inotify,
                                              dirname,
                                              IN_CREATE | IN_ATTRIB | IN_DELETE);
    }

    // Continue without device connection notifications if inotify fails
    version(none) {
        // remove regex dependency
        if (regcomp(&_glfw.linjs.regex, "^event[0-9]\\+$", 0) != 0)
        {
            _glfwInputError(GLFW_PLATFORM_ERROR, "Linux: Failed to compile regex");
            return GLFW_FALSE;
        }
    }

    int count = 0;

    DIR* dir = opendir(dirname);
    if (dir)
    {
        dirent* entry;

        while (true)
        {
            entry = readdir(dir);
            if (!entry) {
                break;
            }

            version(none) {
                regmatch_t match;
                if (regexec(&_glfw.linjs.regex, entry.d_name, 1, &match, 0) != 0)
                    continue;
            } else {
                // remove regex dependency
                if (!isEventFile(entry.d_name.ptr)) {
                    continue;
                }
            }

            char[PATH_MAX] path;

            snprintf(path.ptr, path.length, "%s/%s", dirname, entry.d_name.ptr);

            if (openJoystickDevice(path.ptr))
                count++;
        }

        closedir(dir);
    }

    // Continue with no joysticks if enumeration fails

    qsort(_glfw.joysticks.ptr, count, _GLFWjoystick.sizeof, &compareJoysticks);
    return GLFW_TRUE;
}

// Close all opened joystick handles
//
void _glfwTerminateJoysticksLinux() {
    int jid;

    for (jid = 0;  jid <= GLFW_JOYSTICK_LAST;  jid++)
    {
        _GLFWjoystick* js = _glfw.joysticks.ptr + jid;
        if (js.present)
            closeJoystick(js);
    }

    version(none) {
        regfree(&_glfw.linjs.regex);
    }

    if (_glfw.linjs.inotify > 0)
    {
        if (_glfw.linjs.watch > 0)
            inotify_rm_watch(_glfw.linjs.inotify, _glfw.linjs.watch);

        close(_glfw.linjs.inotify);
    }
}

void _glfwDetectJoystickConnectionLinux() {
    if (_glfw.linjs.inotify <= 0)
        return;

    ssize_t offset = 0;
    char[16384] buffer;
    const(ssize_t) size = read(_glfw.linjs.inotify, buffer.ptr, typeof(buffer).sizeof);

    while (size > offset)
    {
        const(inotify_event)* e = cast(inotify_event*) (buffer.ptr + offset);

        offset += typeof(cast(inotify_event) + e.len).sizeof;

        version(none) {
            regmatch_t match;
            if (regexec(&_glfw.linjs.regex, e.name, 1, &match, 0) != 0)
                continue;
        } else {
            if (!isEventFile(e.name.ptr)) {
                continue;
            }
        }

        char[PATH_MAX] path;
        snprintf(path.ptr, path.length, "/dev/input/%s", e.name.ptr);

        if (e.mask & (IN_CREATE | IN_ATTRIB))
            openJoystickDevice(path.ptr);
        else if (e.mask & IN_DELETE)
        {
            for (int jid = 0;  jid <= GLFW_JOYSTICK_LAST;  jid++)
            {
                if (strcmp(_glfw.joysticks[jid].linjs.path.ptr, path.ptr) == 0)
                {
                    closeJoystick(_glfw.joysticks.ptr + jid);
                    break;
                }
            }
        }
    }
}


//////////////////////////////////////////////////////////////////////////
//////                       GLFW platform API                      //////
//////////////////////////////////////////////////////////////////////////

int _glfwPlatformPollJoystick(_GLFWjoystick* js, int mode) {
    // Read all queued events (non-blocking)
    for (;;)
    {
        input_event e;

        errno = 0;
        if (read(js.linjs.fd, &e, typeof(e).sizeof) < 0)
        {
            // Reset the joystick slot if the device was disconnected
            if (errno == ENODEV)
                closeJoystick(js);

            break;
        }

        if (e.type == EV_SYN)
        {
            if (e.code == SYN_DROPPED)
                _glfw.linjs.dropped = GLFW_TRUE;
            else if (e.code == SYN_REPORT)
            {
                _glfw.linjs.dropped = GLFW_FALSE;
                pollAbsState(js);
            }
        }

        if (_glfw.linjs.dropped)
            continue;

        if (e.type == EV_KEY)
            handleKeyEvent(js, e.code, e.value);
        else if (e.type == EV_ABS)
            handleAbsEvent(js, e.code, e.value);
    }

    return js.present;
}

void _glfwPlatformUpdateGamepadGUID(char* guid) {
}

int _glfwPlatformSetJoystickRumble(_GLFWjoystick* js, float slowMotorIntensity, float fastMotorIntensity)
{
    _GLFWjoystickLinux *linjs = &js.linjs;

    if (!js.linjs.hasRumble)
        return GLFW_FALSE;

    js.linjs.rumble.u.rumble = ff_rumble_effect(
        /*strong_magnitude*/ cast(ushort) (65_535 * slowMotorIntensity),
        /*weak_magnitude*/   cast(ushort) (65_535 * fastMotorIntensity)
    );

    input_event play;
    play.type = EV_FF;
    play.code = linjs.rumble.id;
    play.value = 1;

    if (ioctl(linjs.fd, EVIOCSFF, &linjs.rumble) < 0) {
        return GLFW_FALSE;
    }
    if (write(linjs.fd, &play, play.sizeof) < 0) {
        return GLFW_FALSE;
    }

    return GLFW_TRUE;
}
