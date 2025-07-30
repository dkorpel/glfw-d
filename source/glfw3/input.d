/// Translated from C to D
module glfw3.input;

nothrow:
extern(C): __gshared:

import core.stdc.config: c_long, c_ulong;

//========================================================================
// GLFW 3.3 - www.glfw.org
//------------------------------------------------------------------------
// Copyright (c) 2002-2006 Marcus Geelnard
// Copyright (c) 2006-2019 Camilla Löwy <elmindreda@glfw.org>
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
// Please use C89 style variable declarations in this file because VS 2010
//========================================================================

import glfw3.internal;

import core.stdc.assert_;
import core.stdc.math;
import core.stdc.stdlib;
import core.stdc.string;

// Internal key state used for sticky keys
enum _GLFW_STICK = 3;

// Internal constants for gamepad mapping source types
enum _GLFW_JOYSTICK_AXIS =     1;
enum _GLFW_JOYSTICK_BUTTON =   2;
enum _GLFW_JOYSTICK_HATBIT =   3;

// Finds a mapping based on joystick GUID
//
private _GLFWmapping* findMapping(const(char)* guid) {
    int i;

    for (i = 0;  i < _glfw.mappingCount;  i++)
    {
        if (strcmp(_glfw.mappings[i].guid.ptr, guid) == 0)
            return _glfw.mappings + i;
    }

    return null;
}

// Checks whether a gamepad mapping element is present in the hardware
//
private GLFWbool isValidElementForJoystick(const(_GLFWmapelement)* e, const(_GLFWjoystick)* js) {
    if (e.type == _GLFW_JOYSTICK_HATBIT && (e.index >> 4) >= js.hatCount)
        return GLFW_FALSE;
    else if (e.type == _GLFW_JOYSTICK_BUTTON && e.index >= js.buttonCount)
        return GLFW_FALSE;
    else if (e.type == _GLFW_JOYSTICK_AXIS && e.index >= js.axisCount)
        return GLFW_FALSE;

    return GLFW_TRUE;
}

// Finds a mapping based on joystick GUID and verifies element indices
//
private _GLFWmapping* findValidMapping(const(_GLFWjoystick)* js) {
    _GLFWmapping* mapping = findMapping(js.guid.ptr);
    if (mapping)
    {
        int i;

        for (i = 0;  i <= GLFW_GAMEPAD_BUTTON_LAST;  i++)
        {
            if (!isValidElementForJoystick(mapping.buttons.ptr + i, js))
            {
                _glfwInputError(GLFW_INVALID_VALUE,
                                "Invalid button in gamepad mapping %s (%s)",
                                mapping.guid.ptr,
                                mapping.name.ptr);
                return null;
            }
        }

        for (i = 0;  i <= GLFW_GAMEPAD_AXIS_LAST;  i++)
        {
            if (!isValidElementForJoystick(mapping.axes.ptr + i, js))
            {
                _glfwInputError(GLFW_INVALID_VALUE,
                                "Invalid axis in gamepad mapping %s (%s)",
                                mapping.guid.ptr,
                                mapping.name.ptr);
                return null;
            }
        }
    }

    return mapping;
}

// Parses an SDL_GameControllerDB line and adds it to the mapping list
//
private GLFWbool parseMapping(_GLFWmapping* mapping, const(char)* string) {
    const(char)* c = string;
    size_t i;size_t length;
    static struct Field {
        const(char)* name;
        _GLFWmapelement* element;
    }
    Field[22] fields = [
        Field("platform",      null),
        Field("a",             mapping.buttons.ptr + GLFW_GAMEPAD_BUTTON_A),
        Field("b",             mapping.buttons.ptr + GLFW_GAMEPAD_BUTTON_B),
        Field("x",             mapping.buttons.ptr + GLFW_GAMEPAD_BUTTON_X),
        Field("y",             mapping.buttons.ptr + GLFW_GAMEPAD_BUTTON_Y),
        Field("back",          mapping.buttons.ptr + GLFW_GAMEPAD_BUTTON_BACK),
        Field("start",         mapping.buttons.ptr + GLFW_GAMEPAD_BUTTON_START),
        Field("guide",         mapping.buttons.ptr + GLFW_GAMEPAD_BUTTON_GUIDE),
        Field("leftshoulder",  mapping.buttons.ptr + GLFW_GAMEPAD_BUTTON_LEFT_BUMPER),
        Field("rightshoulder", mapping.buttons.ptr + GLFW_GAMEPAD_BUTTON_RIGHT_BUMPER),
        Field("leftstick",     mapping.buttons.ptr + GLFW_GAMEPAD_BUTTON_LEFT_THUMB),
        Field("rightstick",    mapping.buttons.ptr + GLFW_GAMEPAD_BUTTON_RIGHT_THUMB),
        Field("dpup",          mapping.buttons.ptr + GLFW_GAMEPAD_BUTTON_DPAD_UP),
        Field("dpright",       mapping.buttons.ptr + GLFW_GAMEPAD_BUTTON_DPAD_RIGHT),
        Field("dpdown",        mapping.buttons.ptr + GLFW_GAMEPAD_BUTTON_DPAD_DOWN),
        Field("dpleft",        mapping.buttons.ptr + GLFW_GAMEPAD_BUTTON_DPAD_LEFT),
        Field("lefttrigger",   mapping.axes.ptr + GLFW_GAMEPAD_AXIS_LEFT_TRIGGER),
        Field("righttrigger",  mapping.axes.ptr + GLFW_GAMEPAD_AXIS_RIGHT_TRIGGER),
        Field("leftx",         mapping.axes.ptr + GLFW_GAMEPAD_AXIS_LEFT_X),
        Field("lefty",         mapping.axes.ptr + GLFW_GAMEPAD_AXIS_LEFT_Y),
        Field("rightx",        mapping.axes.ptr + GLFW_GAMEPAD_AXIS_RIGHT_X),
        Field("righty",        mapping.axes.ptr + GLFW_GAMEPAD_AXIS_RIGHT_Y),
    ];

    length = strcspn(c, ",");
    if (length != 32 || c[length] != ',')
    {
        _glfwInputError(GLFW_INVALID_VALUE, null);
        return GLFW_FALSE;
    }

    memcpy(mapping.guid.ptr, c, length);
    c += length + 1;

    length = strcspn(c, ",");
    if (length >= typeof(mapping.name).sizeof || c[length] != ',')
    {
        _glfwInputError(GLFW_INVALID_VALUE, null);
        return GLFW_FALSE;
    }

    memcpy(mapping.name.ptr, c, length);
    c += length + 1;

    while (*c)
    {
        // TODO: Implement output modifiers
        if (*c == '+' || *c == '-')
            return GLFW_FALSE;

        for (i = 0;  i < fields.sizeof / typeof(fields[0]).sizeof;  i++)
        {
            length = strlen(fields[i].name);
            if (strncmp(c, fields[i].name, length) != 0 || c[length] != ':')
                continue;

            c += length + 1;

            if (fields[i].element)
            {
                _GLFWmapelement* e = fields[i].element;
                byte minimum = -1;
                byte maximum = 1;

                if (*c == '+')
                {
                    minimum = 0;
                    c += 1;
                }
                else if (*c == '-')
                {
                    maximum = 0;
                    c += 1;
                }

                if (*c == 'a')
                    e.type = _GLFW_JOYSTICK_AXIS;
                else if (*c == 'b')
                    e.type = _GLFW_JOYSTICK_BUTTON;
                else if (*c == 'h')
                    e.type = _GLFW_JOYSTICK_HATBIT;
                else
                    break;

                if (e.type == _GLFW_JOYSTICK_HATBIT)
                {
                    const c_ulong hat = strtoul(c + 1, &c, 10);
                    const c_ulong bit = strtoul(c + 1, &c, 10);
                    e.index = cast(ubyte) ((hat << 4) | bit);
                }
                else
                    e.index = cast(ubyte) strtoul(c + 1, &c, 10);

                if (e.type == _GLFW_JOYSTICK_AXIS)
                {
                    e.axisScale = 2 / (maximum - minimum);
                    e.axisOffset = cast(byte) -(maximum + minimum);

                    if (*c == '~')
                    {
                        e.axisScale = cast(byte) -cast(int)e.axisScale;
                        e.axisOffset = cast(byte) -cast(int)e.axisOffset;
                    }
                }
            }
            else
            {
                length = strlen(_GLFW_PLATFORM_MAPPING_NAME);
                if (strncmp(c, _GLFW_PLATFORM_MAPPING_NAME, length) != 0)
                    return GLFW_FALSE;
            }

            break;
        }

        c += strcspn(c, ",");
        c += strspn(c, ",");
    }

    for (i = 0;  i < 32;  i++)
    {
        if (mapping.guid[i] >= 'A' && mapping.guid[i] <= 'F')
            mapping.guid[i] += 'a' - 'A';
    }

    _glfwPlatformUpdateGamepadGUID(mapping.guid.ptr);
    return GLFW_TRUE;
}


//////////////////////////////////////////////////////////////////////////
//////                         GLFW event API                       //////
//////////////////////////////////////////////////////////////////////////

// Notifies shared code of a physical key event
//
void _glfwInputKey(_GLFWwindow* window, int key, int scancode, int action, int mods) {
    if (key >= 0 && key <= GLFW_KEY_LAST)
    {
        GLFWbool repeated = GLFW_FALSE;

        if (action == GLFW_RELEASE && window.keys[key] == GLFW_RELEASE)
            return;

        if (action == GLFW_PRESS && window.keys[key] == GLFW_PRESS)
            repeated = GLFW_TRUE;

        if (action == GLFW_RELEASE && window.stickyKeys)
            window.keys[key] = _GLFW_STICK;
        else
            window.keys[key] = cast(char) action;

        if (repeated)
            action = GLFW_REPEAT;
    }

    if (!window.lockKeyMods)
        mods &= ~(GLFW_MOD_CAPS_LOCK | GLFW_MOD_NUM_LOCK);

    if (window.callbacks.key)
        window.callbacks.key(cast(GLFWwindow*) window, key, scancode, action, mods);
}

// Notifies shared code of a Unicode codepoint input event
// The 'plain' parameter determines whether to emit a regular character event
//
void _glfwInputChar(_GLFWwindow* window, uint codepoint, int mods, GLFWbool plain) {
    if (codepoint < 32 || (codepoint > 126 && codepoint < 160))
        return;

    if (!window.lockKeyMods)
        mods &= ~(GLFW_MOD_CAPS_LOCK | GLFW_MOD_NUM_LOCK);

    if (window.callbacks.charmods)
        window.callbacks.charmods(cast(GLFWwindow*) window, codepoint, mods);

    if (plain)
    {
        if (window.callbacks.character)
            window.callbacks.character(cast(GLFWwindow*) window, codepoint);
    }
}

// Notifies shared code of a scroll event
//
void _glfwInputScroll(_GLFWwindow* window, double xoffset, double yoffset) {
    if (window.callbacks.scroll)
        window.callbacks.scroll(cast(GLFWwindow*) window, xoffset, yoffset);
}

// Notifies shared code of a mouse button click event
//
void _glfwInputMouseClick(_GLFWwindow* window, int button, int action, int mods) {
    if (button < 0 || button > GLFW_MOUSE_BUTTON_LAST)
        return;

    if (!window.lockKeyMods)
        mods &= ~(GLFW_MOD_CAPS_LOCK | GLFW_MOD_NUM_LOCK);

    if (action == GLFW_RELEASE && window.stickyMouseButtons)
        window.mouseButtons[button] = _GLFW_STICK;
    else
        window.mouseButtons[button] = cast(char) action;

    if (window.callbacks.mouseButton)
        window.callbacks.mouseButton(cast(GLFWwindow*) window, button, action, mods);
}

// Notifies shared code of a cursor motion event
// The position is specified in content area relative screen coordinates
//
void _glfwInputCursorPos(_GLFWwindow* window, double xpos, double ypos) {
    if (window.virtualCursorPosX == xpos && window.virtualCursorPosY == ypos)
        return;

    window.virtualCursorPosX = xpos;
    window.virtualCursorPosY = ypos;

    if (window.callbacks.cursorPos)
        window.callbacks.cursorPos(cast(GLFWwindow*) window, xpos, ypos);
}

// Notifies shared code of a cursor enter/leave event
//
void _glfwInputCursorEnter(_GLFWwindow* window, GLFWbool entered) {
    if (window.callbacks.cursorEnter)
        window.callbacks.cursorEnter(cast(GLFWwindow*) window, entered);
}

// Notifies shared code of files or directories dropped on a window
//
void _glfwInputDrop(_GLFWwindow* window, int count, const(char)** paths) {
    if (window.callbacks.drop)
        window.callbacks.drop(cast(GLFWwindow*) window, count, paths);
}

// Notifies shared code of a joystick connection or disconnection
//
void _glfwInputJoystick(_GLFWjoystick* js, int event) {
    const(int) jid = cast(int) (js - _glfw.joysticks.ptr);

    if (_glfw.callbacks.joystick)
        _glfw.callbacks.joystick(jid, event);
}

// Notifies shared code of the new value of a joystick axis
//
void _glfwInputJoystickAxis(_GLFWjoystick* js, int axis, float value) {
    js.axes[axis] = value;
}

// Notifies shared code of the new value of a joystick button
//
void _glfwInputJoystickButton(_GLFWjoystick* js, int button, char value) {
    js.buttons[button] = value;
}

// Notifies shared code of the new value of a joystick hat
//
void _glfwInputJoystickHat(_GLFWjoystick* js, int hat, char value) {
    const(int) base = js.buttonCount + hat * 4;

    js.buttons[base + 0] = (value & 0x01) ? GLFW_PRESS : GLFW_RELEASE;
    js.buttons[base + 1] = (value & 0x02) ? GLFW_PRESS : GLFW_RELEASE;
    js.buttons[base + 2] = (value & 0x04) ? GLFW_PRESS : GLFW_RELEASE;
    js.buttons[base + 3] = (value & 0x08) ? GLFW_PRESS : GLFW_RELEASE;

    js.hats[hat] = value;
}


//////////////////////////////////////////////////////////////////////////
//////                       GLFW internal API                      //////
//////////////////////////////////////////////////////////////////////////

// Returns an available joystick object with arrays and name allocated
//
_GLFWjoystick* _glfwAllocJoystick(const(char)* name, const(char)* guid, int axisCount, int buttonCount, int hatCount) {
    int jid;
    _GLFWjoystick* js;

    for (jid = 0;  jid <= GLFW_JOYSTICK_LAST;  jid++)
    {
        if (!_glfw.joysticks[jid].present)
            break;
    }

    if (jid > GLFW_JOYSTICK_LAST)
        return null;

    js = _glfw.joysticks.ptr + jid;
    js.present     = GLFW_TRUE;
    js.name        = _glfw_strdup(name);
    js.axes        = cast(float*) calloc(axisCount, float.sizeof);
    js.buttons     = cast(ubyte*) calloc(buttonCount + cast(size_t) hatCount * 4, 1);
    js.hats        = cast(ubyte*) calloc(hatCount, 1);
    js.axisCount   = axisCount;
    js.buttonCount = buttonCount;
    js.hatCount    = hatCount;

    strncpy(js.guid.ptr, guid, js.guid.length - 1);
    js.mapping = findValidMapping(js);

    return js;
}

// Frees arrays and name and flags the joystick object as unused
//
void _glfwFreeJoystick(_GLFWjoystick* js) {
    free(js.name);
    free(js.axes);
    free(js.buttons);
    free(js.hats);
    memset(js, 0, _GLFWjoystick.sizeof);
}

// Center the cursor in the content area of the specified window
//
void _glfwCenterCursorInContentArea(_GLFWwindow* window) {
    int width;int height;

    _glfwPlatformGetWindowSize(window, &width, &height);
    _glfwPlatformSetCursorPos(window, width / 2.0, height / 2.0);
}


//////////////////////////////////////////////////////////////////////////
//////                        GLFW public API                       //////
//////////////////////////////////////////////////////////////////////////

int glfwGetInputMode(GLFWwindow* handle, int mode) {
    _GLFWwindow* window = cast(_GLFWwindow*) handle;
    assert(window != null);

    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"0");

    switch (mode)
    {
        case GLFW_CURSOR:
            return window.cursorMode;
        case GLFW_STICKY_KEYS:
            return window.stickyKeys;
        case GLFW_STICKY_MOUSE_BUTTONS:
            return window.stickyMouseButtons;
        case GLFW_LOCK_KEY_MODS:
            return window.lockKeyMods;
        case GLFW_RAW_MOUSE_MOTION:
            return window.rawMouseMotion;
        default: break;
    }

    _glfwInputError(GLFW_INVALID_ENUM, "Invalid input mode 0x%08X", mode);
    return 0;
}

void glfwSetInputMode(GLFWwindow* handle, int mode, int value) {
    _GLFWwindow* window = cast(_GLFWwindow*) handle;
    assert(window != null);

    mixin(_GLFW_REQUIRE_INIT);

    if (mode == GLFW_CURSOR)
    {
        if (value != GLFW_CURSOR_NORMAL &&
            value != GLFW_CURSOR_HIDDEN &&
            value != GLFW_CURSOR_DISABLED)
        {
            _glfwInputError(GLFW_INVALID_ENUM,
                            "Invalid cursor mode 0x%08X",
                            value);
            return;
        }

        if (window.cursorMode == value)
            return;

        window.cursorMode = value;

        _glfwPlatformGetCursorPos(window,
                                  &window.virtualCursorPosX,
                                  &window.virtualCursorPosY);
        _glfwPlatformSetCursorMode(window, value);
    }
    else if (mode == GLFW_STICKY_KEYS)
    {
        value = value ? GLFW_TRUE : GLFW_FALSE;
        if (window.stickyKeys == value)
            return;

        if (!value)
        {
            int i;

            // Release all sticky keys
            for (i = 0;  i <= GLFW_KEY_LAST;  i++)
            {
                if (window.keys[i] == _GLFW_STICK)
                    window.keys[i] = GLFW_RELEASE;
            }
        }

        window.stickyKeys = value;
    }
    else if (mode == GLFW_STICKY_MOUSE_BUTTONS)
    {
        value = value ? GLFW_TRUE : GLFW_FALSE;
        if (window.stickyMouseButtons == value)
            return;

        if (!value)
        {
            int i;

            // Release all sticky mouse buttons
            for (i = 0;  i <= GLFW_MOUSE_BUTTON_LAST;  i++)
            {
                if (window.mouseButtons[i] == _GLFW_STICK)
                    window.mouseButtons[i] = GLFW_RELEASE;
            }
        }

        window.stickyMouseButtons = value;
    }
    else if (mode == GLFW_LOCK_KEY_MODS)
    {
        window.lockKeyMods = value ? GLFW_TRUE : GLFW_FALSE;
    }
    else if (mode == GLFW_RAW_MOUSE_MOTION)
    {
        if (!_glfwPlatformRawMouseMotionSupported())
        {
            _glfwInputError(GLFW_PLATFORM_ERROR,
                            "Raw mouse motion is not supported on this system");
            return;
        }

        value = value ? GLFW_TRUE : GLFW_FALSE;
        if (window.rawMouseMotion == value)
            return;

        window.rawMouseMotion = value;
        _glfwPlatformSetRawMouseMotion(window, value);
    }
    else
        _glfwInputError(GLFW_INVALID_ENUM, "Invalid input mode 0x%08X", mode);
}

int glfwRawMouseMotionSupported() {
    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"GLFW_FALSE");
    return _glfwPlatformRawMouseMotionSupported();
}

const(char)* glfwGetKeyName(int key, int scancode) {
    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"null");

    if (key != GLFW_KEY_UNKNOWN)
    {
        if (key != GLFW_KEY_KP_EQUAL &&
            (key < GLFW_KEY_KP_0 || key > GLFW_KEY_KP_ADD) &&
            (key < GLFW_KEY_APOSTROPHE || key > GLFW_KEY_WORLD_2))
        {
            return null;
        }

        scancode = _glfwPlatformGetKeyScancode(key);
    }

    return _glfwPlatformGetScancodeName(scancode);
}

int glfwGetKeyScancode(int key) {
    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"-1");

    if (key < GLFW_KEY_SPACE || key > GLFW_KEY_LAST)
    {
        _glfwInputError(GLFW_INVALID_ENUM, "Invalid key %i", key);
        return GLFW_RELEASE;
    }

    return _glfwPlatformGetKeyScancode(key);
}

int glfwGetKey(GLFWwindow* handle, int key) {
    _GLFWwindow* window = cast(_GLFWwindow*) handle;
    assert(window != null);

    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"GLFW_RELEASE");

    if (key < GLFW_KEY_SPACE || key > GLFW_KEY_LAST)
    {
        _glfwInputError(GLFW_INVALID_ENUM, "Invalid key %i", key);
        return GLFW_RELEASE;
    }

    if (window.keys[key] == _GLFW_STICK)
    {
        // Sticky mode: release key now
        window.keys[key] = GLFW_RELEASE;
        return GLFW_PRESS;
    }

    return cast(int) window.keys[key];
}

int glfwGetMouseButton(GLFWwindow* handle, int button) {
    _GLFWwindow* window = cast(_GLFWwindow*) handle;
    assert(window != null);

    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"GLFW_RELEASE");

    if (button < GLFW_MOUSE_BUTTON_1 || button > GLFW_MOUSE_BUTTON_LAST)
    {
        _glfwInputError(GLFW_INVALID_ENUM, "Invalid mouse button %i", button);
        return GLFW_RELEASE;
    }

    if (window.mouseButtons[button] == _GLFW_STICK)
    {
        // Sticky mode: release mouse button now
        window.mouseButtons[button] = GLFW_RELEASE;
        return GLFW_PRESS;
    }

    return cast(int) window.mouseButtons[button];
}

void glfwGetCursorPos(GLFWwindow* handle, double* xpos, double* ypos) {
    _GLFWwindow* window = cast(_GLFWwindow*) handle;
    assert(window != null);

    if (xpos)
        *xpos = 0;
    if (ypos)
        *ypos = 0;

    mixin(_GLFW_REQUIRE_INIT);

    if (window.cursorMode == GLFW_CURSOR_DISABLED)
    {
        if (xpos)
            *xpos = window.virtualCursorPosX;
        if (ypos)
            *ypos = window.virtualCursorPosY;
    }
    else
        _glfwPlatformGetCursorPos(window, xpos, ypos);
}

void glfwSetCursorPos(GLFWwindow* handle, double xpos, double ypos) {
    _GLFWwindow* window = cast(_GLFWwindow*) handle;
    assert(window != null);

    mixin(_GLFW_REQUIRE_INIT);

    if (xpos != xpos || xpos < -double.max || xpos > double.max ||
        ypos != ypos || ypos < -double.max || ypos > double.max)
    {
        _glfwInputError(GLFW_INVALID_VALUE,
                        "Invalid cursor position %f %f",
                        xpos, ypos);
        return;
    }

    if (!_glfwPlatformWindowFocused(window))
        return;

    if (window.cursorMode == GLFW_CURSOR_DISABLED)
    {
        // Only update the accumulated position if the cursor is disabled
        window.virtualCursorPosX = xpos;
        window.virtualCursorPosY = ypos;
    }
    else
    {
        // Update system cursor position
        _glfwPlatformSetCursorPos(window, xpos, ypos);
    }
}

GLFWcursor* glfwCreateCursor(const(GLFWimage)* image, int xhot, int yhot) {
    _GLFWcursor* cursor;

    assert(image != null);

    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"null");

    cursor = cast(_GLFWcursor*) calloc(1, _GLFWcursor.sizeof);
    cursor.next = _glfw.cursorListHead;
    _glfw.cursorListHead = cursor;

    if (!_glfwPlatformCreateCursor(cursor, image, xhot, yhot))
    {
        glfwDestroyCursor(cast(GLFWcursor*) cursor);
        return null;
    }

    return cast(GLFWcursor*) cursor;
}

GLFWcursor* glfwCreateStandardCursor(int shape) {
    _GLFWcursor* cursor;

    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"null");

    if (shape != GLFW_ARROW_CURSOR &&
        shape != GLFW_IBEAM_CURSOR &&
        shape != GLFW_CROSSHAIR_CURSOR &&
        shape != GLFW_HAND_CURSOR &&
        shape != GLFW_HRESIZE_CURSOR &&
        shape != GLFW_VRESIZE_CURSOR)
    {
        _glfwInputError(GLFW_INVALID_ENUM, "Invalid standard cursor 0x%08X", shape);
        return null;
    }

    cursor = cast(_GLFWcursor*) calloc(1, _GLFWcursor.sizeof);
    cursor.next = _glfw.cursorListHead;
    _glfw.cursorListHead = cursor;

    if (!_glfwPlatformCreateStandardCursor(cursor, shape))
    {
        glfwDestroyCursor(cast(GLFWcursor*) cursor);
        return null;
    }

    return cast(GLFWcursor*) cursor;
}

void glfwDestroyCursor(GLFWcursor* handle) {
    _GLFWcursor* cursor = cast(_GLFWcursor*) handle;

    mixin(_GLFW_REQUIRE_INIT);

    if (cursor == null)
        return;

    // Make sure the cursor is not being used by any window
    {
        _GLFWwindow* window;

        for (window = _glfw.windowListHead;  window;  window = window.next)
        {
            if (window.cursor == cursor)
                glfwSetCursor(cast(GLFWwindow*) window, null);
        }
    }

    _glfwPlatformDestroyCursor(cursor);

    // Unlink cursor from global linked list
    {
        _GLFWcursor** prev = &_glfw.cursorListHead;

        while (*prev != cursor)
            prev = &((*prev).next);

        *prev = cursor.next;
    }

    free(cursor);
}

void glfwSetCursor(GLFWwindow* windowHandle, GLFWcursor* cursorHandle) {
    _GLFWwindow* window = cast(_GLFWwindow*) windowHandle;
    _GLFWcursor* cursor = cast(_GLFWcursor*) cursorHandle;
    assert(window != null);

    mixin(_GLFW_REQUIRE_INIT);

    window.cursor = cursor;

    _glfwPlatformSetCursor(window, cursor);
}

GLFWkeyfun glfwSetKeyCallback(GLFWwindow* handle, GLFWkeyfun cbfun) {
    _GLFWwindow* window = cast(_GLFWwindow*) handle;
    assert(window != null);

    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"null");
    _GLFW_SWAP_POINTERS(window.callbacks.key, cbfun);
    return cbfun;
}

GLFWcharfun glfwSetCharCallback(GLFWwindow* handle, GLFWcharfun cbfun) {
    _GLFWwindow* window = cast(_GLFWwindow*) handle;
    assert(window != null);

    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"null");
    _GLFW_SWAP_POINTERS(window.callbacks.character, cbfun);
    return cbfun;
}

GLFWcharmodsfun glfwSetCharModsCallback(GLFWwindow* handle, GLFWcharmodsfun cbfun) {
    _GLFWwindow* window = cast(_GLFWwindow*) handle;
    assert(window != null);

    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"null");
    _GLFW_SWAP_POINTERS(window.callbacks.charmods, cbfun);
    return cbfun;
}

GLFWmousebuttonfun glfwSetMouseButtonCallback(GLFWwindow* handle, GLFWmousebuttonfun cbfun) {
    _GLFWwindow* window = cast(_GLFWwindow*) handle;
    assert(window != null);

    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"null");
    _GLFW_SWAP_POINTERS(window.callbacks.mouseButton, cbfun);
    return cbfun;
}

GLFWcursorposfun glfwSetCursorPosCallback(GLFWwindow* handle, GLFWcursorposfun cbfun) {
    _GLFWwindow* window = cast(_GLFWwindow*) handle;
    assert(window != null);

    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"null");
    _GLFW_SWAP_POINTERS(window.callbacks.cursorPos, cbfun);
    return cbfun;
}

GLFWcursorenterfun glfwSetCursorEnterCallback(GLFWwindow* handle, GLFWcursorenterfun cbfun) {
    _GLFWwindow* window = cast(_GLFWwindow*) handle;
    assert(window != null);

    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"null");
    _GLFW_SWAP_POINTERS(window.callbacks.cursorEnter, cbfun);
    return cbfun;
}

GLFWscrollfun glfwSetScrollCallback(GLFWwindow* handle, GLFWscrollfun cbfun) {
    _GLFWwindow* window = cast(_GLFWwindow*) handle;
    assert(window != null);

    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"null");
    _GLFW_SWAP_POINTERS(window.callbacks.scroll, cbfun);
    return cbfun;
}

GLFWdropfun glfwSetDropCallback(GLFWwindow* handle, GLFWdropfun cbfun) {
    _GLFWwindow* window = cast(_GLFWwindow*) handle;
    assert(window != null);

    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"null");
    _GLFW_SWAP_POINTERS(window.callbacks.drop, cbfun);
    return cbfun;
}

int glfwJoystickPresent(int jid) {
    _GLFWjoystick* js;

    assert(jid >= GLFW_JOYSTICK_1);
    assert(jid <= GLFW_JOYSTICK_LAST);

    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"GLFW_FALSE");

    if (jid < 0 || jid > GLFW_JOYSTICK_LAST)
    {
        _glfwInputError(GLFW_INVALID_ENUM, "Invalid joystick ID %i", jid);
        return GLFW_FALSE;
    }

    js = _glfw.joysticks.ptr + jid;
    if (!js.present)
        return GLFW_FALSE;

    return _glfwPlatformPollJoystick(js, _GLFW_POLL_PRESENCE);
}

const(float)* glfwGetJoystickAxes(int jid, int* count) {
    _GLFWjoystick* js;

    assert(jid >= GLFW_JOYSTICK_1);
    assert(jid <= GLFW_JOYSTICK_LAST);
    assert(count != null);

    *count = 0;

    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"null");

    if (jid < 0 || jid > GLFW_JOYSTICK_LAST)
    {
        _glfwInputError(GLFW_INVALID_ENUM, "Invalid joystick ID %i", jid);
        return null;
    }

    js = _glfw.joysticks.ptr + jid;
    if (!js.present)
        return null;

    if (!_glfwPlatformPollJoystick(js, _GLFW_POLL_AXES))
        return null;

    *count = js.axisCount;
    return js.axes;
}

const(ubyte)* glfwGetJoystickButtons(int jid, int* count) {
    _GLFWjoystick* js;

    assert(jid >= GLFW_JOYSTICK_1);
    assert(jid <= GLFW_JOYSTICK_LAST);
    assert(count != null);

    *count = 0;

    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"null");

    if (jid < 0 || jid > GLFW_JOYSTICK_LAST)
    {
        _glfwInputError(GLFW_INVALID_ENUM, "Invalid joystick ID %i", jid);
        return null;
    }

    js = _glfw.joysticks.ptr + jid;
    if (!js.present)
        return null;

    if (!_glfwPlatformPollJoystick(js, _GLFW_POLL_BUTTONS))
        return null;

    if (_glfw.hints.init.hatButtons)
        *count = js.buttonCount + js.hatCount * 4;
    else
        *count = js.buttonCount;

    return js.buttons;
}

const(ubyte)* glfwGetJoystickHats(int jid, int* count) {
    _GLFWjoystick* js;

    assert(jid >= GLFW_JOYSTICK_1);
    assert(jid <= GLFW_JOYSTICK_LAST);
    assert(count != null);

    *count = 0;

    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"null");

    if (jid < 0 || jid > GLFW_JOYSTICK_LAST)
    {
        _glfwInputError(GLFW_INVALID_ENUM, "Invalid joystick ID %i", jid);
        return null;
    }

    js = _glfw.joysticks.ptr + jid;
    if (!js.present)
        return null;

    if (!_glfwPlatformPollJoystick(js, _GLFW_POLL_BUTTONS))
        return null;

    *count = js.hatCount;
    return js.hats;
}

const(char)* glfwGetJoystickName(int jid) {
    _GLFWjoystick* js;

    assert(jid >= GLFW_JOYSTICK_1);
    assert(jid <= GLFW_JOYSTICK_LAST);

    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"null");

    if (jid < 0 || jid > GLFW_JOYSTICK_LAST)
    {
        _glfwInputError(GLFW_INVALID_ENUM, "Invalid joystick ID %i", jid);
        return null;
    }

    js = _glfw.joysticks.ptr + jid;
    if (!js.present)
        return null;

    if (!_glfwPlatformPollJoystick(js, _GLFW_POLL_PRESENCE))
        return null;

    return js.name;
}

const(char)* glfwGetJoystickGUID(int jid) {
    _GLFWjoystick* js;

    assert(jid >= GLFW_JOYSTICK_1);
    assert(jid <= GLFW_JOYSTICK_LAST);

    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"null");

    if (jid < 0 || jid > GLFW_JOYSTICK_LAST)
    {
        _glfwInputError(GLFW_INVALID_ENUM, "Invalid joystick ID %i", jid);
        return null;
    }

    js = _glfw.joysticks.ptr + jid;
    if (!js.present)
        return null;

    if (!_glfwPlatformPollJoystick(js, _GLFW_POLL_PRESENCE))
        return null;

    return js.guid.ptr;
}

void glfwSetJoystickUserPointer(int jid, void* pointer) {
    _GLFWjoystick* js;

    assert(jid >= GLFW_JOYSTICK_1);
    assert(jid <= GLFW_JOYSTICK_LAST);

    mixin(_GLFW_REQUIRE_INIT);

    js = _glfw.joysticks.ptr + jid;
    if (!js.present)
        return;

    js.userPointer = pointer;
}

void* glfwGetJoystickUserPointer(int jid) {
    _GLFWjoystick* js;

    assert(jid >= GLFW_JOYSTICK_1);
    assert(jid <= GLFW_JOYSTICK_LAST);

    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"null");

    js = _glfw.joysticks.ptr + jid;
    if (!js.present)
        return null;

    return js.userPointer;
}

GLFWjoystickfun glfwSetJoystickCallback(GLFWjoystickfun cbfun) {
    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"null");
    _GLFW_SWAP_POINTERS(_glfw.callbacks.joystick, cbfun);
    return cbfun;
}

int glfwUpdateGamepadMappings(const(char)* string) {
    int jid;
    const(char)* c = string;

    assert(string != null);

    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"GLFW_FALSE");

    while (*c)
    {
        if ((*c >= '0' && *c <= '9') ||
            (*c >= 'a' && *c <= 'f') ||
            (*c >= 'A' && *c <= 'F'))
        {
            char[1024] line;

            const(size_t) length = strcspn(c, "\r\n");
            if (length < typeof(line).sizeof)
            {
                _GLFWmapping mapping = _GLFWmapping.init;

                memcpy(line.ptr, c, length);
                line[length] = '\0';

                if (parseMapping(&mapping, line.ptr))
                {
                    _GLFWmapping* previous = findMapping(mapping.guid.ptr);
                    if (previous)
                        *previous = mapping;
                    else
                    {
                        _glfw.mappingCount++;
                        _glfw.mappings =
                            cast(_GLFWmapping*) realloc(_glfw.mappings,
                                    _GLFWmapping.sizeof * _glfw.mappingCount);
                        _glfw.mappings[_glfw.mappingCount - 1] = mapping;
                    }
                }
            }

            c += length;
        }
        else
        {
            c += strcspn(c, "\r\n");
            c += strspn(c, "\r\n");
        }
    }

    for (jid = 0;  jid <= GLFW_JOYSTICK_LAST;  jid++)
    {
        _GLFWjoystick* js = _glfw.joysticks.ptr + jid;
        if (js.present)
            js.mapping = findValidMapping(js);
    }

    return GLFW_TRUE;
}

int glfwJoystickIsGamepad(int jid) {
    _GLFWjoystick* js;

    assert(jid >= GLFW_JOYSTICK_1);
    assert(jid <= GLFW_JOYSTICK_LAST);

    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"GLFW_FALSE");

    if (jid < 0 || jid > GLFW_JOYSTICK_LAST)
    {
        _glfwInputError(GLFW_INVALID_ENUM, "Invalid joystick ID %i", jid);
        return GLFW_FALSE;
    }

    js = _glfw.joysticks.ptr + jid;
    if (!js.present)
        return GLFW_FALSE;

    if (!_glfwPlatformPollJoystick(js, _GLFW_POLL_PRESENCE))
        return GLFW_FALSE;

    return js.mapping != null;
}

const(char)* glfwGetGamepadName(int jid) {
    _GLFWjoystick* js;

    assert(jid >= GLFW_JOYSTICK_1);
    assert(jid <= GLFW_JOYSTICK_LAST);

    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"null");

    if (jid < 0 || jid > GLFW_JOYSTICK_LAST)
    {
        _glfwInputError(GLFW_INVALID_ENUM, "Invalid joystick ID %i", jid);
        return null;
    }

    js = _glfw.joysticks.ptr + jid;
    if (!js.present)
        return null;

    if (!_glfwPlatformPollJoystick(js, _GLFW_POLL_PRESENCE))
        return null;

    if (!js.mapping)
        return null;

    return js.mapping.name.ptr;
}

int glfwGetGamepadState(int jid, GLFWgamepadstate* state) {
    int i;
    _GLFWjoystick* js;

    assert(jid >= GLFW_JOYSTICK_1);
    assert(jid <= GLFW_JOYSTICK_LAST);
    assert(state != null);

    memset(state, 0, GLFWgamepadstate.sizeof);

    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"GLFW_FALSE");

    if (jid < 0 || jid > GLFW_JOYSTICK_LAST)
    {
        _glfwInputError(GLFW_INVALID_ENUM, "Invalid joystick ID %i", jid);
        return GLFW_FALSE;
    }

    js = _glfw.joysticks.ptr + jid;
    if (!js.present)
        return GLFW_FALSE;

    if (!_glfwPlatformPollJoystick(js, _GLFW_POLL_ALL))
        return GLFW_FALSE;

    if (!js.mapping)
        return GLFW_FALSE;

    for (i = 0;  i <= GLFW_GAMEPAD_BUTTON_LAST;  i++)
    {
        const(_GLFWmapelement)* e = js.mapping.buttons.ptr + i;
        if (e.type == _GLFW_JOYSTICK_AXIS)
        {
            const(float) value = js.axes[e.index] * e.axisScale + e.axisOffset;
            // HACK: This should be baked into the value transform
            // TODO: Bake into transform when implementing output modifiers
            if (e.axisOffset < 0 || (e.axisOffset == 0 && e.axisScale > 0))
            {
                if (value >= 0.0f)
                    state.buttons[i] = GLFW_PRESS;
            }
            else
            {
                if (value <= 0.0f)
                    state.buttons[i] = GLFW_PRESS;
            }
        }
        else if (e.type == _GLFW_JOYSTICK_HATBIT)
        {
            const(uint) hat = e.index >> 4;
            const(uint) bit = e.index & 0xf;
            if (js.hats[hat] & bit)
                state.buttons[i] = GLFW_PRESS;
        }
        else if (e.type == _GLFW_JOYSTICK_BUTTON)
            state.buttons[i] = js.buttons[e.index];
    }

    for (i = 0;  i <= GLFW_GAMEPAD_AXIS_LAST;  i++)
    {
        const(_GLFWmapelement)* e = js.mapping.axes.ptr + i;
        if (e.type == _GLFW_JOYSTICK_AXIS)
        {
            const(float) value = js.axes[e.index] * e.axisScale + e.axisOffset;
            state.axes[i] = _glfw_fminf(_glfw_fmaxf(value, -1.0f), 1.0f);
        }
        else if (e.type == _GLFW_JOYSTICK_HATBIT)
        {
            const(uint) hat = e.index >> 4;
            const(uint) bit = e.index & 0xf;
            if (js.hats[hat] & bit)
                state.axes[i] = 1.0f;
            else
                state.axes[i] = -1.0f;
        }
        else if (e.type == _GLFW_JOYSTICK_BUTTON)
            state.axes[i] = js.buttons[e.index] * 2.0f - 1.0f;
    }

    return GLFW_TRUE;
}

int glfwSetJoystickRumble(int jid, float slowMotorIntensity, float fastMotorIntensity)
{
    _GLFWjoystick* js;

    assert(jid >= GLFW_JOYSTICK_1);
    assert(jid <= GLFW_JOYSTICK_LAST);

    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"GLFW_FALSE");

    if (jid < 0 || jid > GLFW_JOYSTICK_LAST)
    {
        _glfwInputError(GLFW_INVALID_ENUM, "Invalid joystick ID %i", jid);
        return GLFW_FALSE;
    }

    js = _glfw.joysticks.ptr + jid;
    if (!js.present)
        return GLFW_FALSE;

    slowMotorIntensity = slowMotorIntensity < 0.0f ? 0.0f : slowMotorIntensity;
    slowMotorIntensity = slowMotorIntensity > 1.0f ? 1.0f : slowMotorIntensity;

    fastMotorIntensity = fastMotorIntensity < 0.0f ? 0.0f : fastMotorIntensity;
    fastMotorIntensity = fastMotorIntensity > 1.0f ? 1.0f : fastMotorIntensity;

    return _glfwPlatformSetJoystickRumble(js, slowMotorIntensity, fastMotorIntensity);
}

void glfwSetClipboardString(GLFWwindow* handle, const(char)* string) {
    assert(string != null);

    mixin(_GLFW_REQUIRE_INIT);
    _glfwPlatformSetClipboardString(string);
}

const(char)* glfwGetClipboardString(GLFWwindow* handle) {
    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"null");
    return _glfwPlatformGetClipboardString();
}

double glfwGetTime() {
    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"0.0");
    return cast(double) (_glfwPlatformGetTimerValue() - _glfw.timer.offset) /
        _glfwPlatformGetTimerFrequency();
}

void glfwSetTime(double time) {
    mixin(_GLFW_REQUIRE_INIT);

    if (time != time || time < 0.0 || time > 18446744073.0)
    {
        _glfwInputError(GLFW_INVALID_VALUE, "Invalid time %f", time);
        return;
    }

    _glfw.timer.offset = _glfwPlatformGetTimerValue() -
        cast(ulong) (time * _glfwPlatformGetTimerFrequency());
}

ulong glfwGetTimerValue() {
    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"0");
    return _glfwPlatformGetTimerValue();
}

ulong glfwGetTimerFrequency() {
    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"0");
    return _glfwPlatformGetTimerFrequency();
}
