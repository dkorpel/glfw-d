/// Translated from C to D
module glfw3.x11_window;

nothrow:
extern(C): __gshared:
version(linux):

//========================================================================
// GLFW 3.3 X11 - www.glfw.org
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
// It is fine to use C99 in this file because it will not be built with VS
//========================================================================

import glfw3.internal;

version(none) {
    import x11.cursorfont;
    import x11.Xmd;
    import x11.extensions.XI2; // XIMaskLen
    import x11.XKBlib;
}

import core.sys.posix.sys.select;

import core.stdc.config: c_ulong, c_long;
import core.sys.posix.unistd: getpid;

import core.stdc.string;
import core.stdc.stdio;
import core.stdc.stdlib;
import core.stdc.limits;
import core.stdc.errno;
import core.stdc.assert_;

// Action for EWMH client messages
enum _NET_WM_STATE_REMOVE =        0;
enum _NET_WM_STATE_ADD =           1;
enum _NET_WM_STATE_TOGGLE =        2;

// Additional mouse button names for XButtonEvent
enum Button6 =            6;
enum Button7 =            7;

// Motif WM hints flags
enum MWM_HINTS_DECORATIONS =   2;
enum MWM_DECOR_ALL =           1;

enum _GLFW_XDND_VERSION = 5;


// Wait for data to arrive using select
// This avoids blocking other threads via the per-display Xlib lock that also
// covers GLX functions
//
private GLFWbool waitForEvent(double* timeout) {
    fd_set fds;
    const(int) fd = ConnectionNumber(_glfw.x11.display);
    int count = fd + 1;

version(linux) {
    if (_glfw.linjs.inotify > fd)
        count = _glfw.linjs.inotify + 1;
}
    for (;;)
    {
        FD_ZERO(&fds);
        FD_SET(fd, &fds);
version(linux) {
        if (_glfw.linjs.inotify > 0)
            FD_SET(_glfw.linjs.inotify, &fds);
}

        if (timeout)
        {
            const(int) seconds = cast(int) *timeout;
            const(int) microseconds = cast(int) ((*timeout - seconds) * 1e6);
            timeval tv = timeval(seconds, microseconds);
            const(ulong) base = _glfwPlatformGetTimerValue();

            const(int) result = select(count, &fds, null, null, &tv);
            const(int) error = errno;

            *timeout -= (_glfwPlatformGetTimerValue() - base) /
                cast(double) _glfwPlatformGetTimerFrequency();

            if (result > 0)
                return GLFW_TRUE;
            if ((result == -1 && error == EINTR) || *timeout <= 0.0)
                return GLFW_FALSE;
        }
        else if (select(count, &fds, null, null, null) != -1 || errno != EINTR)
            return GLFW_TRUE;
    }
}

// Waits until a VisibilityNotify event arrives for the specified window or the
// timeout period elapses (ICCCM section 4.2.2)
//
private GLFWbool waitForVisibilityNotify(_GLFWwindow* window) {
    XEvent dummy;
    double timeout = 0.1;

    while (!XCheckTypedWindowEvent(_glfw.x11.display,
                                   window.x11.handle,
                                   VisibilityNotify,
                                   &dummy))
    {
        if (!waitForEvent(&timeout))
            return GLFW_FALSE;
    }

    return GLFW_TRUE;
}

// Returns whether the window is iconified
//
private int getWindowState(_GLFWwindow* window) {
    int result = WithdrawnState;
    struct _State {
        CARD32 state;
        Window icon;
    }_State* state = null;

    if (_glfwGetWindowPropertyX11(window.x11.handle,
                                  _glfw.x11.WM_STATE,
                                  _glfw.x11.WM_STATE,
                                  cast(ubyte**) &state) >= 2)
    {
        result = cast(int) state.state;
    }

    if (state)
        XFree(state);

    return result;
}

// Returns whether the event is a selection event
//
private Bool isSelectionEvent(Display* display, XEvent* event, XPointer pointer) {
    if (event.xany.window != _glfw.x11.helperWindowHandle)
        return False;

    return event.type == SelectionRequest ||
           event.type == SelectionNotify ||
           event.type == SelectionClear;
}

// Returns whether it is a _NET_FRAME_EXTENTS event for the specified window
//
private Bool isFrameExtentsEvent(Display* display, XEvent* event, XPointer pointer) {
    _GLFWwindow* window = cast(_GLFWwindow*) pointer;
    return event.type == PropertyNotify &&
           event.xproperty.state == PropertyNewValue &&
           event.xproperty.window == window.x11.handle &&
           event.xproperty.atom == _glfw.x11.NET_FRAME_EXTENTS;
}

// Returns whether it is a property event for the specified selection transfer
//
private Bool isSelPropNewValueNotify(Display* display, XEvent* event, XPointer pointer) {
    XEvent* notification = cast(XEvent*) pointer;
    return event.type == PropertyNotify &&
           event.xproperty.state == PropertyNewValue &&
           event.xproperty.window == notification.xselection.requestor &&
           event.xproperty.atom == notification.xselection.property;
}

// Translates an X event modifier state mask
//
private int translateState(int state) {
    int mods = 0;

    if (state & ShiftMask)
        mods |= GLFW_MOD_SHIFT;
    if (state & ControlMask)
        mods |= GLFW_MOD_CONTROL;
    if (state & Mod1Mask)
        mods |= GLFW_MOD_ALT;
    if (state & Mod4Mask)
        mods |= GLFW_MOD_SUPER;
    if (state & LockMask)
        mods |= GLFW_MOD_CAPS_LOCK;
    if (state & Mod2Mask)
        mods |= GLFW_MOD_NUM_LOCK;

    return mods;
}

// Translates an X11 key code to a GLFW key token
//
private int translateKey(int scancode) {
    // Use the pre-filled LUT (see createKeyTables() in x11_init.c)
    if (scancode < 0 || scancode > 255)
        return GLFW_KEY_UNKNOWN;

    return _glfw.x11.keycodes[scancode];
}

// Sends an EWMH or ICCCM event to the window manager
//
private extern(D) void sendEventToWM(_GLFWwindow* window, Atom type, int a, int b, int c, int d, int e) {
    XEvent event = XEvent(ClientMessage);
    event.xclient.window = window.x11.handle;
    event.xclient.format = 32; // Data is 32-bit longs
    event.xclient.message_type = type;
    event.xclient.data.l[0] = a;
    event.xclient.data.l[1] = b;
    event.xclient.data.l[2] = c;
    event.xclient.data.l[3] = d;
    event.xclient.data.l[4] = e;

    XSendEvent(_glfw.x11.display, _glfw.x11.root,
               False,
               SubstructureNotifyMask | SubstructureRedirectMask,
               &event);
}

// Updates the normal hints according to the window settings
//
private extern(D) void updateNormalHints(_GLFWwindow* window, int width, int height) {
    XSizeHints* hints = XAllocSizeHints();

    if (!window.monitor)
    {
        if (window.resizable)
        {
            if (window.minwidth != GLFW_DONT_CARE &&
                window.minheight != GLFW_DONT_CARE)
            {
                hints.flags |= PMinSize;
                hints.min_width = window.minwidth;
                hints.min_height = window.minheight;
            }

            if (window.maxwidth != GLFW_DONT_CARE &&
                window.maxheight != GLFW_DONT_CARE)
            {
                hints.flags |= PMaxSize;
                hints.max_width = window.maxwidth;
                hints.max_height = window.maxheight;
            }

            if (window.numer != GLFW_DONT_CARE &&
                window.denom != GLFW_DONT_CARE)
            {
                hints.flags |= PAspect;
                hints.min_aspect.x = hints.max_aspect.x = window.numer;
                hints.min_aspect.y = hints.max_aspect.y = window.denom;
            }
        }
        else
        {
            hints.flags |= (PMinSize | PMaxSize);
            hints.min_width  = hints.max_width  = width;
            hints.min_height = hints.max_height = height;
        }
    }

    hints.flags |= PWinGravity;
    hints.win_gravity = StaticGravity;

    XSetWMNormalHints(_glfw.x11.display, window.x11.handle, hints);
    XFree(hints);
}

// Updates the full screen status of the window
//
private extern(D) void updateWindowMode(_GLFWwindow* window) {
    if (window.monitor)
    {
        if (_glfw.x11.xinerama.available &&
            _glfw.x11.NET_WM_FULLSCREEN_MONITORS)
        {
            sendEventToWM(window,
                          _glfw.x11.NET_WM_FULLSCREEN_MONITORS,
                          window.monitor.x11.index,
                          window.monitor.x11.index,
                          window.monitor.x11.index,
                          window.monitor.x11.index,
                          0);
        }

        if (_glfw.x11.NET_WM_STATE && _glfw.x11.NET_WM_STATE_FULLSCREEN)
        {
            sendEventToWM(window,
                          _glfw.x11.NET_WM_STATE,
                          _NET_WM_STATE_ADD,
                          cast(int) _glfw.x11.NET_WM_STATE_FULLSCREEN,
                          0, 1, 0);
        }
        else
        {
            // This is the butcher's way of removing window decorations
            // Setting the override-redirect attribute on a window makes the
            // window manager ignore the window completely (ICCCM, section 4)
            // The good thing is that this makes undecorated full screen windows
            // easy to do; the bad thing is that we have to do everything
            // manually and some things (like iconify/restore) won't work at
            // all, as those are tasks usually performed by the window manager

            XSetWindowAttributes attributes;
            attributes.override_redirect = True;
            XChangeWindowAttributes(_glfw.x11.display,
                                    window.x11.handle,
                                    CWOverrideRedirect,
                                    &attributes);

            window.x11.overrideRedirect = GLFW_TRUE;
        }

        // Enable compositor bypass
        if (!window.x11.transparent)
        {
            c_ulong value = 1;

            XChangeProperty(_glfw.x11.display,  window.x11.handle,
                            _glfw.x11.NET_WM_BYPASS_COMPOSITOR, XA_CARDINAL, 32,
                            PropModeReplace, cast(ubyte*) &value, 1);
        }
    }
    else
    {
        if (_glfw.x11.xinerama.available &&
            _glfw.x11.NET_WM_FULLSCREEN_MONITORS)
        {
            XDeleteProperty(_glfw.x11.display, window.x11.handle,
                            _glfw.x11.NET_WM_FULLSCREEN_MONITORS);
        }

        if (_glfw.x11.NET_WM_STATE && _glfw.x11.NET_WM_STATE_FULLSCREEN)
        {
            sendEventToWM(window,
                          _glfw.x11.NET_WM_STATE,
                          _NET_WM_STATE_REMOVE,
                          cast(int) _glfw.x11.NET_WM_STATE_FULLSCREEN,
                          0, 1, 0);
        }
        else
        {
            XSetWindowAttributes attributes;
            attributes.override_redirect = False;
            XChangeWindowAttributes(_glfw.x11.display,
                                    window.x11.handle,
                                    CWOverrideRedirect,
                                    &attributes);

            window.x11.overrideRedirect = GLFW_FALSE;
        }

        // Disable compositor bypass
        if (!window.x11.transparent)
        {
            XDeleteProperty(_glfw.x11.display, window.x11.handle,
                            _glfw.x11.NET_WM_BYPASS_COMPOSITOR);
        }
    }
}

// Splits and translates a text/uri-list into separate file paths
// NOTE: This function destroys the provided string
//
private char** parseUriList(char* text, int* count) {
    const(char)* prefix = "file://";
    char** paths = null;
    char* line;

    *count = 0;

    while (true)
    {
        line = strtok(text, "\r\n");
        if (!line) break;

        text = null;

        if (line[0] == '#')
            continue;

        if (strncmp(line, prefix, strlen(prefix)) == 0)
        {
            line += strlen(prefix);
            // TODO: Validate hostname
            while (*line != '/')
                line++;
        }

        (*count)++;

        char* path = cast(char*) calloc(strlen(line) + 1, 1);
        paths = cast(char**) realloc(paths, *count * (char*).sizeof);
        paths[*count - 1] = path;

        while (*line)
        {
            if (line[0] == '%' && line[1] && line[2])
            {
                const(char)[3] digits = [ line[1], line[2], '\0' ];
                *path = cast(char) strtol(digits.ptr, null, 16);
                line += 2;
            }
            else
                *path = *line;

            path++;
            line++;
        }
    }

    return paths;
}

// Encode a Unicode code point to a UTF-8 stream
// Based on cutef8 by Jeff Bezanson (Public Domain)
//
private size_t encodeUTF8(char* s, uint ch) {
    size_t count = 0;

    if (ch < 0x80)
        s[count++] = cast(char) ch;
    else if (ch < 0x800)
    {
        s[count++] = cast(char) (ch >> 6) | 0xc0;
        s[count++] = cast(char) (ch & 0x3f) | 0x80;
    }
    else if (ch < 0x10000)
    {
        s[count++] = cast(char) (ch >> 12) | 0xe0;
        s[count++] = cast(char) ((ch >> 6) & 0x3f) | 0x80;
        s[count++] = cast(char) (ch & 0x3f) | 0x80;
    }
    else if (ch < 0x110000)
    {
        s[count++] = cast(char) (ch >> 18) | 0xf0;
        s[count++] = cast(char) ((ch >> 12) & 0x3f) | 0x80;
        s[count++] = cast(char) ((ch >> 6) & 0x3f) | 0x80;
        s[count++] = cast(char) (ch & 0x3f) | 0x80;
    }

    return count;
}

// Decode a Unicode code point from a UTF-8 stream
// Based on cutef8 by Jeff Bezanson (Public Domain)
//
version(X_HAVE_UTF8_STRING) {
private uint decodeUTF8(const(char)** s) {
    uint ch = 0;uint count = 0;
    static const(uint)* offsets = [
        0x00000000u, 0x00003080u, 0x000e2080u,
        0x03c82080u, 0xfa082080u, 0x82082080u
    ];

    do
    {
        ch = (ch << 6) + cast(ubyte) **s;
        (*s)++;
        count++;
    } while ((**s & 0xc0) == 0x80);

    assert(count <= 6);
    return ch - offsets[count - 1];
}
} /*X_HAVE_UTF8_STRING*/

// Convert the specified Latin-1 string to UTF-8
//
private char* convertLatin1toUTF8(const(char)* source) {
    size_t size = 1;
    const(char)* sp;

    for (sp = source;  *sp;  sp++)
        size += (*sp & 0x80) ? 2 : 1;

    char* target = cast(char*) calloc(size, 1);
    char* tp = target;

    for (sp = source;  *sp;  sp++)
        tp += encodeUTF8(tp, *sp);

    return target;
}

// Updates the cursor image according to its cursor mode
//
private extern(D) void updateCursorImage(_GLFWwindow* window) {
    if (window.cursorMode == GLFW_CURSOR_NORMAL)
    {
        if (window.cursor)
        {
            XDefineCursor(_glfw.x11.display, window.x11.handle,
                          window.cursor.x11.handle);
        }
        else
            XUndefineCursor(_glfw.x11.display, window.x11.handle);
    }
    else
    {
        XDefineCursor(_glfw.x11.display, window.x11.handle,
                      _glfw.x11.hiddenCursorHandle);
    }
}

// Enable XI2 raw mouse motion events
//
private extern(D) void enableRawMouseMotion(_GLFWwindow* window) {
    XIEventMask em;
    ubyte[XIMaskLen(XI_RawMotion)] mask = 0;

    em.deviceid = XIAllMasterDevices;
    em.mask_len = mask.length;
    em.mask = mask.ptr;
    //XISetMask(mask, XI_RawMotion);
    em.mask[XI_RawMotion>>3] |=  (1 << (XI_RawMotion & 7));

    _glfw.x11.xi.SelectEvents(_glfw.x11.display, _glfw.x11.root, &em, 1);
}

// Disable XI2 raw mouse motion events
//
private extern(D) void disableRawMouseMotion(_GLFWwindow* window) {
    XIEventMask em;
    ubyte[1] mask = [0];

    em.deviceid = XIAllMasterDevices;
    em.mask_len = mask.length;
    em.mask = mask.ptr;

    _glfw.x11.xi.SelectEvents(_glfw.x11.display, _glfw.x11.root, &em, 1);
}

// Apply disabled cursor mode to a focused window
//
private extern(D) void disableCursor(_GLFWwindow* window) {
    if (window.rawMouseMotion)
        enableRawMouseMotion(window);

    _glfw.x11.disabledCursorWindow = window;
    _glfwPlatformGetCursorPos(window,
                              &_glfw.x11.restoreCursorPosX,
                              &_glfw.x11.restoreCursorPosY);
    updateCursorImage(window);
    _glfwCenterCursorInContentArea(window);
    XGrabPointer(_glfw.x11.display, window.x11.handle, True,
                 ButtonPressMask | ButtonReleaseMask | PointerMotionMask,
                 GrabModeAsync, GrabModeAsync,
                 window.x11.handle,
                 _glfw.x11.hiddenCursorHandle,
                 CurrentTime);
}

// Exit disabled cursor mode for the specified window
//
private extern(D) void enableCursor(_GLFWwindow* window) {
    if (window.rawMouseMotion)
        disableRawMouseMotion(window);

    _glfw.x11.disabledCursorWindow = null;
    XUngrabPointer(_glfw.x11.display, CurrentTime);
    _glfwPlatformSetCursorPos(window,
                              _glfw.x11.restoreCursorPosX,
                              _glfw.x11.restoreCursorPosY);
    updateCursorImage(window);
}

// Create the X11 window (and its colormap)
//
private GLFWbool createNativeWindow(_GLFWwindow* window, const(_GLFWwndconfig)* wndconfig, Visual* visual, int depth) {
    int width = wndconfig.width;
    int height = wndconfig.height;

    if (wndconfig.scaleToMonitor)
    {
        width  = cast(int) (width * _glfw.x11.contentScaleX);
        height = cast(int) (height * _glfw.x11.contentScaleY);
    }

    // Create a colormap based on the visual used by the current context
    window.x11.colormap = XCreateColormap(_glfw.x11.display,
                                           _glfw.x11.root,
                                           visual,
                                           AllocNone);

    window.x11.transparent = _glfwIsVisualTransparentX11(visual);

    XSetWindowAttributes wa = XSetWindowAttributes(0);
    wa.colormap = window.x11.colormap;
    wa.event_mask = StructureNotifyMask | KeyPressMask | KeyReleaseMask |
                    PointerMotionMask | ButtonPressMask | ButtonReleaseMask |
                    ExposureMask | FocusChangeMask | VisibilityChangeMask |
                    EnterWindowMask | LeaveWindowMask | PropertyChangeMask;

    _glfwGrabErrorHandlerX11();

    window.x11.parent = _glfw.x11.root;
    window.x11.handle = XCreateWindow(_glfw.x11.display,
                                       _glfw.x11.root,
                                       0, 0,   // Position
                                       width, height,
                                       0,      // Border width
                                       depth,  // Color depth
                                       InputOutput,
                                       visual,
                                       CWBorderPixel | CWColormap | CWEventMask,
                                       &wa);

    _glfwReleaseErrorHandlerX11();

    if (!window.x11.handle)
    {
        _glfwInputErrorX11(GLFW_PLATFORM_ERROR,
                           "X11: Failed to create window");
        return GLFW_FALSE;
    }

    XSaveContext(_glfw.x11.display,
                 window.x11.handle,
                 _glfw.x11.context,
                 cast(XPointer) window);

    if (!wndconfig.decorated)
        _glfwPlatformSetWindowDecorated(window, GLFW_FALSE);

    if (_glfw.x11.NET_WM_STATE && !window.monitor)
    {
        Atom[3] states;
        int count = 0;

        if (wndconfig.floating)
        {
            if (_glfw.x11.NET_WM_STATE_ABOVE)
                states[count++] = _glfw.x11.NET_WM_STATE_ABOVE;
        }

        if (wndconfig.maximized)
        {
            if (_glfw.x11.NET_WM_STATE_MAXIMIZED_VERT &&
                _glfw.x11.NET_WM_STATE_MAXIMIZED_HORZ)
            {
                states[count++] = _glfw.x11.NET_WM_STATE_MAXIMIZED_VERT;
                states[count++] = _glfw.x11.NET_WM_STATE_MAXIMIZED_HORZ;
                window.x11.maximized = GLFW_TRUE;
            }
        }

        if (count)
        {
            XChangeProperty(_glfw.x11.display, window.x11.handle,
                            _glfw.x11.NET_WM_STATE, XA_ATOM, 32,
                            PropModeReplace, cast(ubyte*) states, count);
        }
    }

    // Declare the WM protocols supported by GLFW
    {
        Atom[2] protocols = [
            _glfw.x11.WM_DELETE_WINDOW,
            _glfw.x11.NET_WM_PING
        ];

        XSetWMProtocols(_glfw.x11.display, window.x11.handle,
                        protocols.ptr, protocols.length);
    }

    // Declare our PID
    {
        const(int) pid = getpid();

        XChangeProperty(_glfw.x11.display,  window.x11.handle,
                        _glfw.x11.NET_WM_PID, XA_CARDINAL, 32,
                        PropModeReplace,
                        cast(ubyte*) &pid, 1);
    }

    if (_glfw.x11.NET_WM_WINDOW_TYPE && _glfw.x11.NET_WM_WINDOW_TYPE_NORMAL)
    {
        Atom type = _glfw.x11.NET_WM_WINDOW_TYPE_NORMAL;
        XChangeProperty(_glfw.x11.display,  window.x11.handle,
                        _glfw.x11.NET_WM_WINDOW_TYPE, XA_ATOM, 32,
                        PropModeReplace, cast(ubyte*) &type, 1);
    }

    // Set ICCCM WM_HINTS property
    {
        XWMHints* hints = XAllocWMHints();
        if (!hints)
        {
            _glfwInputError(GLFW_OUT_OF_MEMORY,
                            "X11: Failed to allocate WM hints");
            return GLFW_FALSE;
        }

        hints.flags = StateHint;
        hints.initial_state = NormalState;

        XSetWMHints(_glfw.x11.display, window.x11.handle, hints);
        XFree(hints);
    }

    updateNormalHints(window, width, height);

    // Set ICCCM WM_CLASS property
    {
        XClassHint* hint = XAllocClassHint();

        if (strlen(wndconfig.x11.instanceName.ptr) &&
            strlen(wndconfig.x11.className.ptr))
        {
            hint.res_name = cast(char*) wndconfig.x11.instanceName;
            hint.res_class = cast(char*) wndconfig.x11.className;
        }
        else
        {
            const(char)* resourceName = getenv("RESOURCE_NAME");
            if (resourceName && strlen(resourceName))
                hint.res_name = cast(char*) resourceName;
            else if (strlen(wndconfig.title))
                hint.res_name = cast(char*) wndconfig.title;
            else
                hint.res_name = cast(char*) "glfw-application";

            if (strlen(wndconfig.title))
                hint.res_class = cast(char*) wndconfig.title;
            else
                hint.res_class = cast(char*) "GLFW-Application";
        }

        XSetClassHint(_glfw.x11.display, window.x11.handle, hint);
        XFree(hint);
    }

    // Announce support for Xdnd (drag and drop)
    {
        const(Atom) version_ = _GLFW_XDND_VERSION;
        XChangeProperty(_glfw.x11.display, window.x11.handle,
                        _glfw.x11.XdndAware, XA_ATOM, 32,
                        PropModeReplace, cast(ubyte*) &version_, 1);
    }

    _glfwPlatformSetWindowTitle(window, wndconfig.title);

    if (_glfw.x11.im)
    {
        window.x11.ic = XCreateIC(_glfw.x11.im,
                                   XNInputStyle,
                                   XIMPreeditNothing | XIMStatusNothing,
                                   XNClientWindow,
                                   window.x11.handle,
                                   XNFocusWindow,
                                   window.x11.handle,
                                   null);
    }

    if (window.x11.ic)
    {
        uint filter = 0;
        if (XGetICValues(window.x11.ic, XNFilterEvents, &filter, null) == null)
            XSelectInput(_glfw.x11.display, window.x11.handle, wa.event_mask | filter);
    }

    _glfwPlatformGetWindowPos(window, &window.x11.xpos, &window.x11.ypos);
    _glfwPlatformGetWindowSize(window, &window.x11.width, &window.x11.height);

    return GLFW_TRUE;
}

// Set the specified property to the selection converted to the requested target
//
private Atom writeTargetToProperty(const(XSelectionRequestEvent)* request) {
    char* selectionString = null;
    const(Atom)[2] formats = [ _glfw.x11.UTF8_STRING, XA_STRING ];
    const(int) formatCount = formats.length; //sizeof / typeof(formats[0]).sizeof;

    if (request.selection == _glfw.x11.PRIMARY)
        selectionString = _glfw.x11.primarySelectionString;
    else
        selectionString = _glfw.x11.clipboardString;

    if (request.property == None)
    {
        // The requester is a legacy client (ICCCM section 2.2)
        // We don't support legacy clients, so fail here
        return None;
    }

    if (request.target == _glfw.x11.TARGETS)
    {
        // The list of supported targets was requested

        const(Atom)[4] targets = [ _glfw.x11.TARGETS,
                                 _glfw.x11.MULTIPLE,
                                 _glfw.x11.UTF8_STRING,
                                 XA_STRING ];

        XChangeProperty(_glfw.x11.display,
                        request.requestor,
                        request.property,
                        XA_ATOM,
                        32,
                        PropModeReplace,
                        cast(ubyte*) targets.ptr,
                        targets.sizeof / typeof(targets[0]).sizeof);

        return request.property;
    }

    if (request.target == _glfw.x11.MULTIPLE)
    {
        // Multiple conversions were requested

        Atom* targets;
        c_ulong i, count;

        count = _glfwGetWindowPropertyX11(request.requestor,
                                          request.property,
                                          _glfw.x11.ATOM_PAIR,
                                          cast(ubyte**) &targets);

        for (i = 0;  i < count;  i += 2)
        {
            int j;

            for (j = 0;  j < formatCount;  j++)
            {
                if (targets[i] == formats[j])
                    break;
            }

            if (j < formatCount)
            {
                XChangeProperty(_glfw.x11.display,
                                request.requestor,
                                targets[i + 1],
                                targets[i],
                                8,
                                PropModeReplace,
                                cast(ubyte*) selectionString,
                                cast(uint) strlen(selectionString));
            }
            else
                targets[i + 1] = None;
        }

        XChangeProperty(_glfw.x11.display,
                        request.requestor,
                        request.property,
                        _glfw.x11.ATOM_PAIR,
                        32,
                        PropModeReplace,
                        cast(ubyte*) targets,
                        cast(int) count);

        XFree(targets);

        return request.property;
    }

    if (request.target == _glfw.x11.SAVE_TARGETS)
    {
        // The request is a check whether we support SAVE_TARGETS
        // It should be handled as a no-op side effect target

        XChangeProperty(_glfw.x11.display,
                        request.requestor,
                        request.property,
                        _glfw.x11.NULL_,
                        32,
                        PropModeReplace,
                        null,
                        0);

        return request.property;
    }

    // Conversion to a data target was requested
    int i;
    for (i = 0;  i < formatCount;  i++)
    {
        if (request.target == formats[i])
        {
            // The requested target is one we support

            XChangeProperty(_glfw.x11.display,
                            request.requestor,
                            request.property,
                            request.target,
                            8,
                            PropModeReplace,
                            cast(ubyte*) selectionString,
                            cast(uint) strlen(selectionString));

            return request.property;
        }
    }

    // The requested target is not supported

    return None;
}

private extern(D) void handleSelectionClear(XEvent* event) {
    if (event.xselectionclear.selection == _glfw.x11.PRIMARY)
    {
        free(_glfw.x11.primarySelectionString);
        _glfw.x11.primarySelectionString = null;
    }
    else
    {
        free(_glfw.x11.clipboardString);
        _glfw.x11.clipboardString = null;
    }
}

private extern(D) void handleSelectionRequest(XEvent* event) {
    XSelectionRequestEvent* request = &event.xselectionrequest;

    XEvent reply = XEvent(SelectionNotify);
    reply.xselection.property = writeTargetToProperty(request);
    reply.xselection.display = request.display;
    reply.xselection.requestor = request.requestor;
    reply.xselection.selection = request.selection;
    reply.xselection.target = request.target;
    reply.xselection.time = request.time;

    XSendEvent(_glfw.x11.display, request.requestor, False, 0, &reply);
}

private const(char)* getSelectionString(Atom selection) {
    char** selectionString = null;
    const(Atom)[2] targets = [ _glfw.x11.UTF8_STRING, XA_STRING ];
    const(size_t) targetCount = targets.length; //targets.sizeof / typeof(targets[0]).sizeof;

    if (selection == _glfw.x11.PRIMARY)
        selectionString = &_glfw.x11.primarySelectionString;
    else
        selectionString = &_glfw.x11.clipboardString;

    if (XGetSelectionOwner(_glfw.x11.display, selection) ==
        _glfw.x11.helperWindowHandle)
    {
        // Instead of doing a large number of X round-trips just to put this
        // string into a window property and then read it back, just return it
        return *selectionString;
    }

    free(*selectionString);
    *selectionString = null;

    for (size_t i = 0;  i < targetCount;  i++)
    {
        char* data;
        Atom actualType;
        int actualFormat;
        import core.stdc.config: c_ulong;
        c_ulong itemCount;c_ulong bytesAfter;
        XEvent notification;XEvent dummy;

        XConvertSelection(_glfw.x11.display,
                          selection,
                          targets[i],
                          _glfw.x11.GLFW_SELECTION,
                          _glfw.x11.helperWindowHandle,
                          CurrentTime);

        while (!XCheckTypedWindowEvent(_glfw.x11.display,
                                       _glfw.x11.helperWindowHandle,
                                       SelectionNotify,
                                       &notification))
        {
            waitForEvent(null);
        }

        if (notification.xselection.property == None)
            continue;

        XCheckIfEvent(_glfw.x11.display,
                      &dummy,
                      &isSelPropNewValueNotify,
                      cast(XPointer) &notification);

        XGetWindowProperty(_glfw.x11.display,
                           notification.xselection.requestor,
                           notification.xselection.property,
                           0,
                           LONG_MAX,
                           True,
                           AnyPropertyType,
                           &actualType,
                           &actualFormat,
                           &itemCount,
                           &bytesAfter,
                           cast(ubyte**) &data);

        if (actualType == _glfw.x11.INCR)
        {
            size_t size = 1;
            char* string_ = null;

            for (;;)
            {
                while (!XCheckIfEvent(_glfw.x11.display,
                                      &dummy,
                                      &isSelPropNewValueNotify,
                                      cast(XPointer) &notification))
                {
                    waitForEvent(null);
                }

                XFree(data);
                XGetWindowProperty(_glfw.x11.display,
                                   notification.xselection.requestor,
                                   notification.xselection.property,
                                   0,
                                   LONG_MAX,
                                   True,
                                   AnyPropertyType,
                                   &actualType,
                                   &actualFormat,
                                   &itemCount,
                                   &bytesAfter,
                                   cast(ubyte**) &data);

                if (itemCount)
                {
                    size += itemCount;
                    string_ = cast(char*) realloc(string_, size);
                    string_[size - itemCount - 1] = '\0';
                    strcat(string_, data);
                }

                if (!itemCount)
                {
                    if (targets[i] == XA_STRING)
                    {
                        *selectionString = convertLatin1toUTF8(string_);
                        free(string_);
                    }
                    else
                        *selectionString = string_;

                    break;
                }
            }
        }
        else if (actualType == targets[i])
        {
            if (targets[i] == XA_STRING)
                *selectionString = convertLatin1toUTF8(data);
            else
                *selectionString = _glfw_strdup(data);
        }

        XFree(data);

        if (*selectionString)
            break;
    }

    if (!*selectionString)
    {
        _glfwInputError(GLFW_FORMAT_UNAVAILABLE,
                        "X11: Failed to convert selection to string");
    }

    return *selectionString;
}

// Make the specified window and its video mode active on its monitor
//
private extern(D) void acquireMonitor(_GLFWwindow* window) {
    if (_glfw.x11.saver.count == 0)
    {
        // Remember old screen saver settings
        XGetScreenSaver(_glfw.x11.display,
                        &_glfw.x11.saver.timeout,
                        &_glfw.x11.saver.interval,
                        &_glfw.x11.saver.blanking,
                        &_glfw.x11.saver.exposure);

        // Disable screen saver
        XSetScreenSaver(_glfw.x11.display, 0, 0, DontPreferBlanking,
                        DefaultExposures);
    }

    if (!window.monitor.window)
        _glfw.x11.saver.count++;

    _glfwSetVideoModeX11(window.monitor, &window.videoMode);

    if (window.x11.overrideRedirect)
    {
        int xpos;int ypos;
        GLFWvidmode mode;

        // Manually position the window over its monitor
        _glfwPlatformGetMonitorPos(window.monitor, &xpos, &ypos);
        _glfwPlatformGetVideoMode(window.monitor, &mode);

        XMoveResizeWindow(_glfw.x11.display, window.x11.handle,
                          xpos, ypos, mode.width, mode.height);
    }

    _glfwInputMonitorWindow(window.monitor, window);
}

// Remove the window and restore the original video mode
//
private extern(D) void releaseMonitor(_GLFWwindow* window) {
    if (window.monitor.window != window)
        return;

    _glfwInputMonitorWindow(window.monitor, null);
    _glfwRestoreVideoModeX11(window.monitor);

    _glfw.x11.saver.count--;

    if (_glfw.x11.saver.count == 0)
    {
        // Restore old screen saver settings
        XSetScreenSaver(_glfw.x11.display,
                        _glfw.x11.saver.timeout,
                        _glfw.x11.saver.interval,
                        _glfw.x11.saver.blanking,
                        _glfw.x11.saver.exposure);
    }
}

// Process the specified X event
//
private extern(D) void processEvent(XEvent* event) {
    int keycode = 0;
    Bool filtered = False;

    // HACK: Save scancode as some IMs clear the field in XFilterEvent
    if (event.type == KeyPress || event.type == KeyRelease)
        keycode = event.xkey.keycode;

    if (_glfw.x11.im)
        filtered = XFilterEvent(event, None);

    if (_glfw.x11.randr.available)
    {
        if (event.type == _glfw.x11.randr.eventBase + RRNotify)
        {
            _glfw.x11.randr.UpdateConfiguration(event);
            _glfwPollMonitorsX11();
            return;
        }
    }

    if (_glfw.x11.xkb.available)
    {
        if (event.type == _glfw.x11.xkb.eventBase + XkbEventCode)
        {
            if ((cast(XkbEvent*) event).any.xkb_type == XkbStateNotify &&
                ((cast(XkbEvent*) event).state.changed & XkbGroupStateMask))
            {
                _glfw.x11.xkb.group = (cast(XkbEvent*) event).state.group;
            }
        }
    }

    if (event.type == GenericEvent)
    {
        if (_glfw.x11.xi.available)
        {
            _GLFWwindow* window = _glfw.x11.disabledCursorWindow;

            if (window &&
                window.rawMouseMotion &&
                event.xcookie.extension == _glfw.x11.xi.majorOpcode &&
                XGetEventData(_glfw.x11.display, &event.xcookie) &&
                event.xcookie.evtype == XI_RawMotion)
            {
                XIRawEvent* re = cast(XIRawEvent*) event.xcookie.data;
                if (re.valuators.mask_len)
                {
                    const(double)* values = re.raw_values;
                    double xpos = window.virtualCursorPosX;
                    double ypos = window.virtualCursorPosY;

                    if (XIMaskIsSet(re.valuators.mask, 0))
                    {
                        xpos += *values;
                        values++;
                    }

                    if (XIMaskIsSet(re.valuators.mask, 1))
                        ypos += *values;

                    _glfwInputCursorPos(window, xpos, ypos);
                }
            }

            XFreeEventData(_glfw.x11.display, &event.xcookie);
        }

        return;
    }

    if (event.type == SelectionClear)
    {
        handleSelectionClear(event);
        return;
    }
    else if (event.type == SelectionRequest)
    {
        handleSelectionRequest(event);
        return;
    }

    _GLFWwindow* window = null;
    if (XFindContext(_glfw.x11.display,
                     event.xany.window,
                     _glfw.x11.context,
                     cast(XPointer*) &window) != 0)
    {
        // This is an event for a window that has already been destroyed
        return;
    }

    switch (event.type)
    {
        case ReparentNotify:
        {
            window.x11.parent = event.xreparent.parent;
            return;
        }

        case KeyPress:
        {
            const(int) key = translateKey(keycode);
            const(int) mods = translateState(event.xkey.state);
            const(int) plain = !(mods & (GLFW_MOD_CONTROL | GLFW_MOD_ALT));

            if (window.x11.ic)
            {
                // HACK: Ignore duplicate key press events generated by ibus
                //       These have the same timestamp as the original event
                //       Corresponding release events are filtered out
                //       implicitly by the GLFW key repeat logic
                if (window.x11.lastKeyTime < event.xkey.time)
                {
                    if (keycode)
                        _glfwInputKey(window, key, keycode, GLFW_PRESS, mods);

                    window.x11.lastKeyTime = event.xkey.time;
                }

                if (!filtered)
                {
                    int count;
                    Status status;
version(X_HAVE_UTF8_STRING) {
                    char[100] buffer;
                    char* chars = buffer;

                    count = Xutf8LookupString(window.x11.ic,
                                              &event.xkey,
                                              buffer, typeof((buffer) - 1).sizeof,
                                              null, &status);

                    if (status == XBufferOverflow)
                    {
                        chars = calloc(count + 1, 1);
                        count = Xutf8LookupString(window.x11.ic,
                                                  &event.xkey,
                                                  chars, count,
                                                  null, &status);
                    }

                    if (status == XLookupChars || status == XLookupBoth)
                    {
                        const(char)* c = chars;
                        chars[count] = '\0';
                        while (c - chars < count)
                            _glfwInputChar(window, decodeUTF8(&c), mods, plain);
                    }
} else { /*X_HAVE_UTF8_STRING*/
                    wchar_t[16] buffer;
                    wchar_t* chars = buffer.ptr;

                    count = XwcLookupString(window.x11.ic,
                                            &event.xkey,
                                            buffer.ptr,
                                            buffer.length,
                                            null,
                                            &status);

                    if (status == XBufferOverflow)
                    {
                        chars = cast(wchar_t*) calloc(count, wchar_t.sizeof);
                        count = XwcLookupString(window.x11.ic,
                                                &event.xkey,
                                                chars, count,
                                                null, &status);
                    }

                    if (status == XLookupChars || status == XLookupBoth)
                    {
                        int i;
                        for (i = 0;  i < count;  i++)
                            _glfwInputChar(window, chars[i], mods, plain);
                    }
} /*X_HAVE_UTF8_STRING*/

                    if (chars != buffer.ptr)
                        free(chars);
                }
            }
            else
            {
                KeySym keysym;
                XLookupString(&event.xkey, null, 0, &keysym, null);

                _glfwInputKey(window, key, keycode, GLFW_PRESS, mods);

                const int character = cast(int) _glfwKeySym2Unicode(cast(int) keysym);
                if (character != -1)
                    _glfwInputChar(window, character, mods, plain);
            }

            return;
        }

        case KeyRelease:
        {
            const int key = translateKey(keycode);
            const int mods = translateState(event.xkey.state);

            if (!_glfw.x11.xkb.detectable)
            {
                // HACK: Key repeat events will arrive as KeyRelease/KeyPress
                //       pairs with similar or identical time stamps
                //       The key repeat logic in _glfwInputKey expects only key
                //       presses to repeat, so detect and discard release events
                if (XEventsQueued(_glfw.x11.display, QueuedAfterReading))
                {
                    XEvent next;
                    XPeekEvent(_glfw.x11.display, &next);

                    if (next.type == KeyPress &&
                        next.xkey.window == event.xkey.window &&
                        next.xkey.keycode == keycode)
                    {
                        // HACK: The time of repeat events sometimes doesn't
                        //       match that of the press event, so add an
                        //       epsilon
                        //       Toshiyuki Takahashi can press a button
                        //       16 times per second so it's fairly safe to
                        //       assume that no human is pressing the key 50
                        //       times per second (value is ms)
                        if ((next.xkey.time - event.xkey.time) < 20)
                        {
                            // This is very likely a server-generated key repeat
                            // event, so ignore it
                            return;
                        }
                    }
                }
            }

            _glfwInputKey(window, key, keycode, GLFW_RELEASE, mods);
            return;
        }

        case ButtonPress:
        {
            const(int) mods = translateState(event.xbutton.state);

            if (event.xbutton.button == Button1)
                _glfwInputMouseClick(window, GLFW_MOUSE_BUTTON_LEFT, GLFW_PRESS, mods);
            else if (event.xbutton.button == Button2)
                _glfwInputMouseClick(window, GLFW_MOUSE_BUTTON_MIDDLE, GLFW_PRESS, mods);
            else if (event.xbutton.button == Button3)
                _glfwInputMouseClick(window, GLFW_MOUSE_BUTTON_RIGHT, GLFW_PRESS, mods);

            // Modern X provides scroll events as mouse button presses
            else if (event.xbutton.button == Button4)
                _glfwInputScroll(window, 0.0, 1.0);
            else if (event.xbutton.button == Button5)
                _glfwInputScroll(window, 0.0, -1.0);
            else if (event.xbutton.button == Button6)
                _glfwInputScroll(window, 1.0, 0.0);
            else if (event.xbutton.button == Button7)
                _glfwInputScroll(window, -1.0, 0.0);

            else
            {
                // Additional buttons after 7 are treated as regular buttons
                // We subtract 4 to fill the gap left by scroll input above
                _glfwInputMouseClick(window,
                                     event.xbutton.button - Button1 - 4,
                                     GLFW_PRESS,
                                     mods);
            }

            return;
        }

        case ButtonRelease:
        {
            const(int) mods = translateState(event.xbutton.state);

            if (event.xbutton.button == Button1)
            {
                _glfwInputMouseClick(window,
                                     GLFW_MOUSE_BUTTON_LEFT,
                                     GLFW_RELEASE,
                                     mods);
            }
            else if (event.xbutton.button == Button2)
            {
                _glfwInputMouseClick(window,
                                     GLFW_MOUSE_BUTTON_MIDDLE,
                                     GLFW_RELEASE,
                                     mods);
            }
            else if (event.xbutton.button == Button3)
            {
                _glfwInputMouseClick(window,
                                     GLFW_MOUSE_BUTTON_RIGHT,
                                     GLFW_RELEASE,
                                     mods);
            }
            else if (event.xbutton.button > Button7)
            {
                // Additional buttons after 7 are treated as regular buttons
                // We subtract 4 to fill the gap left by scroll input above
                _glfwInputMouseClick(window,
                                     event.xbutton.button - Button1 - 4,
                                     GLFW_RELEASE,
                                     mods);
            }

            return;
        }

        case EnterNotify:
        {
            // XEnterWindowEvent is XCrossingEvent
            const(int) x = event.xcrossing.x;
            const(int) y = event.xcrossing.y;

            // HACK: This is a workaround for WMs (KWM, Fluxbox) that otherwise
            //       ignore the defined cursor for hidden cursor mode
            if (window.cursorMode == GLFW_CURSOR_HIDDEN)
                updateCursorImage(window);

            _glfwInputCursorEnter(window, GLFW_TRUE);
            _glfwInputCursorPos(window, x, y);

            window.x11.lastCursorPosX = x;
            window.x11.lastCursorPosY = y;
            return;
        }

        case LeaveNotify:
        {
            _glfwInputCursorEnter(window, GLFW_FALSE);
            return;
        }

        case MotionNotify:
        {
            const(int) x = event.xmotion.x;
            const(int) y = event.xmotion.y;

            if (x != window.x11.warpCursorPosX ||
                y != window.x11.warpCursorPosY)
            {
                // The cursor was moved by something other than GLFW

                if (window.cursorMode == GLFW_CURSOR_DISABLED)
                {
                    if (_glfw.x11.disabledCursorWindow != window)
                        return;
                    if (window.rawMouseMotion)
                        return;

                    const(int) dx = x - window.x11.lastCursorPosX;
                    const(int) dy = y - window.x11.lastCursorPosY;

                    _glfwInputCursorPos(window,
                                        window.virtualCursorPosX + dx,
                                        window.virtualCursorPosY + dy);
                }
                else
                    _glfwInputCursorPos(window, x, y);
            }

            window.x11.lastCursorPosX = x;
            window.x11.lastCursorPosY = y;
            return;
        }

        case ConfigureNotify:
        {
            if (event.xconfigure.width != window.x11.width ||
                event.xconfigure.height != window.x11.height)
            {
                _glfwInputFramebufferSize(window,
                                          event.xconfigure.width,
                                          event.xconfigure.height);

                _glfwInputWindowSize(window,
                                     event.xconfigure.width,
                                     event.xconfigure.height);

                window.x11.width = event.xconfigure.width;
                window.x11.height = event.xconfigure.height;
            }

            int xpos = event.xconfigure.x;
            int ypos = event.xconfigure.y;

            // NOTE: ConfigureNotify events from the server are in local
            //       coordinates, so if we are reparented we need to translate
            //       the position into root (screen) coordinates
            if (!event.xany.send_event && window.x11.parent != _glfw.x11.root)
            {
                Window dummy;
                XTranslateCoordinates(_glfw.x11.display,
                                      window.x11.parent,
                                      _glfw.x11.root,
                                      xpos, ypos,
                                      &xpos, &ypos,
                                      &dummy);
            }

            if (xpos != window.x11.xpos || ypos != window.x11.ypos)
            {
                _glfwInputWindowPos(window, xpos, ypos);
                window.x11.xpos = xpos;
                window.x11.ypos = ypos;
            }

            return;
        }

        case ClientMessage:
        {
            // Custom client message, probably from the window manager

            if (filtered)
                return;

            if (event.xclient.message_type == None)
                return;

            if (event.xclient.message_type == _glfw.x11.WM_PROTOCOLS)
            {
                const(Atom) protocol = event.xclient.data.l[0];
                if (protocol == None)
                    return;

                if (protocol == _glfw.x11.WM_DELETE_WINDOW)
                {
                    // The window manager was asked to close the window, for
                    // example by the user pressing a 'close' window decoration
                    // button
                    _glfwInputWindowCloseRequest(window);
                }
                else if (protocol == _glfw.x11.NET_WM_PING)
                {
                    // The window manager is pinging the application to ensure
                    // it's still responding to events

                    XEvent reply = *event;
                    reply.xclient.window = _glfw.x11.root;

                    XSendEvent(_glfw.x11.display, _glfw.x11.root,
                               False,
                               SubstructureNotifyMask | SubstructureRedirectMask,
                               &reply);
                }
            }
            else if (event.xclient.message_type == _glfw.x11.XdndEnter)
            {
                // A drag operation has entered the window
                uint i;uint count;
                Atom* formats = null;
                const(GLFWbool) list = event.xclient.data.l[1] & 1;

                _glfw.x11.xdnd.source  = event.xclient.data.l[0];
                _glfw.x11.xdnd.version_ = cast(int) (event.xclient.data.l[1] >> 24);
                _glfw.x11.xdnd.format  = None;

                if (_glfw.x11.xdnd.version_ > _GLFW_XDND_VERSION)
                    return;

                if (list)
                {
                    count = cast(int) _glfwGetWindowPropertyX11(_glfw.x11.xdnd.source,
                                                      _glfw.x11.XdndTypeList,
                                                      XA_ATOM,
                                                      cast(ubyte**) &formats);
                }
                else
                {
                    count = 3;
                    formats = cast(Atom*) event.xclient.data.l + 2;
                }

                for (i = 0;  i < count;  i++)
                {
                    if (formats[i] == _glfw.x11.text_uri_list)
                    {
                        _glfw.x11.xdnd.format = _glfw.x11.text_uri_list;
                        break;
                    }
                }

                if (list && formats)
                    XFree(formats);
            }
            else if (event.xclient.message_type == _glfw.x11.XdndDrop)
            {
                // The drag operation has finished by dropping on the window
                Time time = CurrentTime;

                if (_glfw.x11.xdnd.version_ > _GLFW_XDND_VERSION)
                    return;

                if (_glfw.x11.xdnd.format)
                {
                    if (_glfw.x11.xdnd.version_ >= 1)
                        time = event.xclient.data.l[2];

                    // Request the chosen format from the source window
                    XConvertSelection(_glfw.x11.display,
                                      _glfw.x11.XdndSelection,
                                      _glfw.x11.xdnd.format,
                                      _glfw.x11.XdndSelection,
                                      window.x11.handle,
                                      time);
                }
                else if (_glfw.x11.xdnd.version_ >= 2)
                {
                    XEvent reply = XEvent(ClientMessage);
                    reply.xclient.window = _glfw.x11.xdnd.source;
                    reply.xclient.message_type = _glfw.x11.XdndFinished;
                    reply.xclient.format = 32;
                    reply.xclient.data.l[0] = window.x11.handle;
                    reply.xclient.data.l[1] = 0; // The drag was rejected
                    reply.xclient.data.l[2] = None;

                    XSendEvent(_glfw.x11.display, _glfw.x11.xdnd.source,
                               False, NoEventMask, &reply);
                    XFlush(_glfw.x11.display);
                }
            }
            else if (event.xclient.message_type == _glfw.x11.XdndPosition)
            {
                // The drag operation has moved over the window
                const(int) xabs = (event.xclient.data.l[2] >> 16) & 0xffff;
                const(int) yabs = (event.xclient.data.l[2]) & 0xffff;
                Window dummy;
                int xpos;int ypos;

                if (_glfw.x11.xdnd.version_ > _GLFW_XDND_VERSION)
                    return;

                XTranslateCoordinates(_glfw.x11.display,
                                      _glfw.x11.root,
                                      window.x11.handle,
                                      xabs, yabs,
                                      &xpos, &ypos,
                                      &dummy);

                _glfwInputCursorPos(window, xpos, ypos);

                XEvent reply = XEvent(ClientMessage);
                reply.xclient.window = _glfw.x11.xdnd.source;
                reply.xclient.message_type = _glfw.x11.XdndStatus;
                reply.xclient.format = 32;
                reply.xclient.data.l[0] = window.x11.handle;
                reply.xclient.data.l[2] = 0; // Specify an empty rectangle
                reply.xclient.data.l[3] = 0;

                if (_glfw.x11.xdnd.format)
                {
                    // Reply that we are ready to copy the dragged data
                    reply.xclient.data.l[1] = 1; // Accept with no rectangle
                    if (_glfw.x11.xdnd.version_ >= 2)
                        reply.xclient.data.l[4] = _glfw.x11.XdndActionCopy;
                }

                XSendEvent(_glfw.x11.display, _glfw.x11.xdnd.source,
                           False, NoEventMask, &reply);
                XFlush(_glfw.x11.display);
            }

            return;
        }

        case SelectionNotify:
        {
            if (event.xselection.property == _glfw.x11.XdndSelection)
            {
                // The converted data from the drag operation has arrived
                char* data;
                const(c_ulong) result = _glfwGetWindowPropertyX11(event.xselection.requestor,
                                              event.xselection.property,
                                              event.xselection.target,
                                              cast(ubyte**) &data);

                if (result)
                {
                    int i;int count;
                    char** paths = parseUriList(data, &count);

                    _glfwInputDrop(window, count, cast(const(char)**) paths);

                    for (i = 0;  i < count;  i++)
                        free(paths[i]);
                    free(paths);
                }

                if (data)
                    XFree(data);

                if (_glfw.x11.xdnd.version_ >= 2)
                {
                    XEvent reply = XEvent(ClientMessage);
                    reply.xclient.window = _glfw.x11.xdnd.source;
                    reply.xclient.message_type = _glfw.x11.XdndFinished;
                    reply.xclient.format = 32;
                    reply.xclient.data.l[0] = window.x11.handle;
                    reply.xclient.data.l[1] = result;
                    reply.xclient.data.l[2] = _glfw.x11.XdndActionCopy;

                    XSendEvent(_glfw.x11.display, _glfw.x11.xdnd.source,
                               False, NoEventMask, &reply);
                    XFlush(_glfw.x11.display);
                }
            }

            return;
        }

        case FocusIn:
        {
            if (event.xfocus.mode == NotifyGrab ||
                event.xfocus.mode == NotifyUngrab)
            {
                // Ignore focus events from popup indicator windows, window menu
                // key chords and window dragging
                return;
            }

            if (window.cursorMode == GLFW_CURSOR_DISABLED)
                disableCursor(window);

            if (window.x11.ic)
                XSetICFocus(window.x11.ic);

            _glfwInputWindowFocus(window, GLFW_TRUE);
            return;
        }

        case FocusOut:
        {
            if (event.xfocus.mode == NotifyGrab ||
                event.xfocus.mode == NotifyUngrab)
            {
                // Ignore focus events from popup indicator windows, window menu
                // key chords and window dragging
                return;
            }

            if (window.cursorMode == GLFW_CURSOR_DISABLED)
                enableCursor(window);

            if (window.x11.ic)
                XUnsetICFocus(window.x11.ic);

            if (window.monitor && window.autoIconify)
                _glfwPlatformIconifyWindow(window);

            _glfwInputWindowFocus(window, GLFW_FALSE);
            return;
        }

        case Expose:
        {
            _glfwInputWindowDamage(window);
            return;
        }

        case PropertyNotify:
        {
            if (event.xproperty.state != PropertyNewValue)
                return;

            if (event.xproperty.atom == _glfw.x11.WM_STATE)
            {
                const(int) state = getWindowState(window);
                if (state != IconicState && state != NormalState)
                    return;

                const(GLFWbool) iconified = (state == IconicState);
                if (window.x11.iconified != iconified)
                {
                    if (window.monitor)
                    {
                        if (iconified)
                            releaseMonitor(window);
                        else
                            acquireMonitor(window);
                    }

                    window.x11.iconified = iconified;
                    _glfwInputWindowIconify(window, iconified);
                }
            }
            else if (event.xproperty.atom == _glfw.x11.NET_WM_STATE)
            {
                const(GLFWbool) maximized = _glfwPlatformWindowMaximized(window);
                if (window.x11.maximized != maximized)
                {
                    window.x11.maximized = maximized;
                    _glfwInputWindowMaximize(window, maximized);
                }
            }

            return;
        }

        case DestroyNotify:
            return;
        default: break;
    }
}


//////////////////////////////////////////////////////////////////////////
//////                       GLFW internal API                      //////
//////////////////////////////////////////////////////////////////////////

// Retrieve a single window property of the specified type
// Inspired by fghGetWindowProperty from freeglut
//
c_ulong _glfwGetWindowPropertyX11(Window window, Atom property, Atom type, ubyte** value) {
    Atom actualType;
    int actualFormat;
    c_ulong itemCount;c_ulong bytesAfter;

    XGetWindowProperty(_glfw.x11.display,
                       window,
                       property,
                       0,
                       LONG_MAX,
                       False,
                       type,
                       &actualType,
                       &actualFormat,
                       &itemCount,
                       &bytesAfter,
                       value);

    return itemCount;
}

GLFWbool _glfwIsVisualTransparentX11(Visual* visual) {
    if (!_glfw.x11.xrender.available)
        return GLFW_FALSE;

    XRenderPictFormat* pf = _glfw.x11.xrender.FindVisualFormat(_glfw.x11.display, visual);
    return pf && pf.direct.alphaMask;
}

// Push contents of our selection to clipboard manager
//
void _glfwPushSelectionToManagerX11() {
    XConvertSelection(_glfw.x11.display,
                      _glfw.x11.CLIPBOARD_MANAGER,
                      _glfw.x11.SAVE_TARGETS,
                      None,
                      _glfw.x11.helperWindowHandle,
                      CurrentTime);

    for (;;)
    {
        XEvent event;

        while (XCheckIfEvent(_glfw.x11.display, &event, &isSelectionEvent, null))
        {
            switch (event.type)
            {
                case SelectionRequest:
                    handleSelectionRequest(&event);
                    break;

                case SelectionClear:
                    handleSelectionClear(&event);
                    break;

                case SelectionNotify:
                {
                    if (event.xselection.target == _glfw.x11.SAVE_TARGETS)
                    {
                        // This means one of two things; either the selection
                        // was not owned, which means there is no clipboard
                        // manager, or the transfer to the clipboard manager has
                        // completed
                        // In either case, it means we are done here
                        return;
                    }

                    break;
                }
                default: break;
            }
        }

        waitForEvent(null);
    }
}


//////////////////////////////////////////////////////////////////////////
//////                       GLFW platform API                      //////
//////////////////////////////////////////////////////////////////////////

int _glfwPlatformCreateWindow(_GLFWwindow* window, const(_GLFWwndconfig)* wndconfig, const(_GLFWctxconfig)* ctxconfig, const(_GLFWfbconfig)* fbconfig) {
    Visual* visual;
    int depth;

    if (ctxconfig.client != GLFW_NO_API)
    {
        if (ctxconfig.source == GLFW_NATIVE_CONTEXT_API)
        {
            if (!_glfwInitGLX())
                return GLFW_FALSE;
            if (!_glfwChooseVisualGLX(wndconfig, ctxconfig, fbconfig, &visual, &depth))
                return GLFW_FALSE;
        }
        else if (ctxconfig.source == GLFW_EGL_CONTEXT_API)
        {
            if (!_glfwInitEGL())
                return GLFW_FALSE;
            if (!_glfwChooseVisualEGL(wndconfig, ctxconfig, fbconfig, &visual, &depth))
                return GLFW_FALSE;
        }
        else if (ctxconfig.source == GLFW_OSMESA_CONTEXT_API)
        {
            if (!_glfwInitOSMesa())
                return GLFW_FALSE;
        }
    }

    if (ctxconfig.client == GLFW_NO_API ||
        ctxconfig.source == GLFW_OSMESA_CONTEXT_API)
    {
        visual = DefaultVisual(_glfw.x11.display, _glfw.x11.screen);
        depth = DefaultDepth(_glfw.x11.display, _glfw.x11.screen);
    }

    if (!createNativeWindow(window, wndconfig, visual, depth))
        return GLFW_FALSE;

    if (ctxconfig.client != GLFW_NO_API)
    {
        if (ctxconfig.source == GLFW_NATIVE_CONTEXT_API)
        {
            if (!_glfwCreateContextGLX(window, ctxconfig, fbconfig))
                return GLFW_FALSE;
        }
        else if (ctxconfig.source == GLFW_EGL_CONTEXT_API)
        {
            if (!_glfwCreateContextEGL(window, ctxconfig, fbconfig))
                return GLFW_FALSE;
        }
        else if (ctxconfig.source == GLFW_OSMESA_CONTEXT_API)
        {
            if (!_glfwCreateContextOSMesa(window, ctxconfig, fbconfig))
                return GLFW_FALSE;
        }
    }

    if (window.monitor)
    {
        _glfwPlatformShowWindow(window);
        updateWindowMode(window);
        acquireMonitor(window);
    }

    XFlush(_glfw.x11.display);
    return GLFW_TRUE;
}

void _glfwPlatformDestroyWindow(_GLFWwindow* window) {
    if (_glfw.x11.disabledCursorWindow == window)
        _glfw.x11.disabledCursorWindow = null;

    if (window.monitor)
        releaseMonitor(window);

    if (window.x11.ic)
    {
        XDestroyIC(window.x11.ic);
        window.x11.ic = null;
    }

    if (window.context.destroy)
        window.context.destroy(window);

    if (window.x11.handle)
    {
        XDeleteContext(_glfw.x11.display, window.x11.handle, _glfw.x11.context);
        XUnmapWindow(_glfw.x11.display, window.x11.handle);
        XDestroyWindow(_glfw.x11.display, window.x11.handle);
        window.x11.handle = cast(Window) 0;
    }

    if (window.x11.colormap)
    {
        XFreeColormap(_glfw.x11.display, window.x11.colormap);
        window.x11.colormap = cast(Colormap) 0;
    }

    XFlush(_glfw.x11.display);
}

void _glfwPlatformSetWindowTitle(_GLFWwindow* window, const(char)* title) {
version(X_HAVE_UTF8_STRING) {
    Xutf8SetWMProperties(_glfw.x11.display,
                         window.x11.handle,
                         title, title,
                         null, 0,
                         null, null, null);
} else {
    // This may be a slightly better fallback than using XStoreName and
    // XSetIconName, which always store their arguments using STRING
    XmbSetWMProperties(_glfw.x11.display,
                       window.x11.handle,
                       title, title,
                       null, 0,
                       null, null, null);
}

    XChangeProperty(_glfw.x11.display,  window.x11.handle,
                    _glfw.x11.NET_WM_NAME, _glfw.x11.UTF8_STRING, 8,
                    PropModeReplace,
                    cast(ubyte*) title, cast(int) strlen(title));

    XChangeProperty(_glfw.x11.display,  window.x11.handle,
                    _glfw.x11.NET_WM_ICON_NAME, _glfw.x11.UTF8_STRING, 8,
                    PropModeReplace,
                    cast(ubyte*) title, cast(int) strlen(title));

    XFlush(_glfw.x11.display);
}

void _glfwPlatformSetWindowIcon(_GLFWwindow* window, int count, const(GLFWimage)* images) {
    if (count)
    {
        int i;int j;int longCount = 0;

        for (i = 0;  i < count;  i++)
            longCount += 2 + images[i].width * images[i].height;

        int* icon = cast(int*) calloc(longCount, long.sizeof);
        int* target = icon;

        for (i = 0;  i < count;  i++)
        {
            *target++ = images[i].width;
            *target++ = images[i].height;

            for (j = 0;  j < images[i].width * images[i].height;  j++)
            {
                *target++ = (images[i].pixels[j * 4 + 0] << 16) |
                            (images[i].pixels[j * 4 + 1] <<  8) |
                            (images[i].pixels[j * 4 + 2] <<  0) |
                            (images[i].pixels[j * 4 + 3] << 24);
            }
        }

        XChangeProperty(_glfw.x11.display, window.x11.handle,
                        _glfw.x11.NET_WM_ICON,
                        XA_CARDINAL, 32,
                        PropModeReplace,
                        cast(ubyte*) icon,
                        longCount);

        free(icon);
    }
    else
    {
        XDeleteProperty(_glfw.x11.display, window.x11.handle,
                        _glfw.x11.NET_WM_ICON);
    }

    XFlush(_glfw.x11.display);
}

void _glfwPlatformGetWindowPos(_GLFWwindow* window, int* xpos, int* ypos) {
    Window dummy;
    int x;int y;

    XTranslateCoordinates(_glfw.x11.display, window.x11.handle, _glfw.x11.root,
                          0, 0, &x, &y, &dummy);

    if (xpos)
        *xpos = x;
    if (ypos)
        *ypos = y;
}

void _glfwPlatformSetWindowPos(_GLFWwindow* window, int xpos, int ypos) {
    // HACK: Explicitly setting PPosition to any value causes some WMs, notably
    //       Compiz and Metacity, to honor the position of unmapped windows
    if (!_glfwPlatformWindowVisible(window))
    {
        c_long supplied;
        XSizeHints* hints = XAllocSizeHints();

        if (XGetWMNormalHints(_glfw.x11.display, window.x11.handle, hints, &supplied))
        {
            hints.flags |= PPosition;
            hints.x = hints.y = 0;

            XSetWMNormalHints(_glfw.x11.display, window.x11.handle, hints);
        }

        XFree(hints);
    }

    XMoveWindow(_glfw.x11.display, window.x11.handle, xpos, ypos);
    XFlush(_glfw.x11.display);
}

void _glfwPlatformGetWindowSize(_GLFWwindow* window, int* width, int* height) {
    XWindowAttributes attribs;
    XGetWindowAttributes(_glfw.x11.display, window.x11.handle, &attribs);

    if (width)
        *width = attribs.width;
    if (height)
        *height = attribs.height;
}

void _glfwPlatformSetWindowSize(_GLFWwindow* window, int width, int height) {
    if (window.monitor)
    {
        if (window.monitor.window == window)
            acquireMonitor(window);
    }
    else
    {
        if (!window.resizable)
            updateNormalHints(window, width, height);

        XResizeWindow(_glfw.x11.display, window.x11.handle, width, height);
    }

    XFlush(_glfw.x11.display);
}

void _glfwPlatformSetWindowSizeLimits(_GLFWwindow* window, int minwidth, int minheight, int maxwidth, int maxheight) {
    int width;int height;
    _glfwPlatformGetWindowSize(window, &width, &height);
    updateNormalHints(window, width, height);
    XFlush(_glfw.x11.display);
}

void _glfwPlatformSetWindowAspectRatio(_GLFWwindow* window, int numer, int denom) {
    int width;int height;
    _glfwPlatformGetWindowSize(window, &width, &height);
    updateNormalHints(window, width, height);
    XFlush(_glfw.x11.display);
}

void _glfwPlatformGetFramebufferSize(_GLFWwindow* window, int* width, int* height) {
    _glfwPlatformGetWindowSize(window, width, height);
}

void _glfwPlatformGetWindowFrameSize(_GLFWwindow* window, int* left, int* top, int* right, int* bottom) {
    int* extents = null;

    if (window.monitor || !window.decorated)
        return;

    if (_glfw.x11.NET_FRAME_EXTENTS == None)
        return;

    if (!_glfwPlatformWindowVisible(window) &&
        _glfw.x11.NET_REQUEST_FRAME_EXTENTS)
    {
        XEvent event;
        double timeout = 0.5;

        // Ensure _NET_FRAME_EXTENTS is set, allowing glfwGetWindowFrameSize to
        // function before the window is mapped
        sendEventToWM(window, _glfw.x11.NET_REQUEST_FRAME_EXTENTS,
                      0, 0, 0, 0, 0);

        // HACK: Use a timeout because earlier versions of some window managers
        //       (at least Unity, Fluxbox and Xfwm) failed to send the reply
        //       They have been fixed but broken versions are still in the wild
        //       If you are affected by this and your window manager is NOT
        //       listed above, PLEASE report it to their and our issue trackers
        while (!XCheckIfEvent(_glfw.x11.display,
                              &event,
                              &isFrameExtentsEvent,
                              cast(XPointer) window))
        {
            if (!waitForEvent(&timeout))
            {
                _glfwInputError(GLFW_PLATFORM_ERROR,
                                "X11: The window manager has a broken _NET_REQUEST_FRAME_EXTENTS implementation; please report this issue");
                return;
            }
        }
    }

    if (_glfwGetWindowPropertyX11(window.x11.handle,
                                  _glfw.x11.NET_FRAME_EXTENTS,
                                  XA_CARDINAL,
                                  cast(ubyte**) &extents) == 4)
    {
        if (left)
            *left = extents[0];
        if (top)
            *top = extents[2];
        if (right)
            *right = extents[1];
        if (bottom)
            *bottom = extents[3];
    }

    if (extents)
        XFree(extents);
}

void _glfwPlatformGetWindowContentScale(_GLFWwindow* window, float* xscale, float* yscale) {
    if (xscale)
        *xscale = _glfw.x11.contentScaleX;
    if (yscale)
        *yscale = _glfw.x11.contentScaleY;
}

void _glfwPlatformIconifyWindow(_GLFWwindow* window) {
    if (window.x11.overrideRedirect)
    {
        // Override-redirect windows cannot be iconified or restored, as those
        // tasks are performed by the window manager
        _glfwInputError(GLFW_PLATFORM_ERROR,
                        "X11: Iconification of full screen windows requires a WM that supports EWMH full screen");
        return;
    }

    XIconifyWindow(_glfw.x11.display, window.x11.handle, _glfw.x11.screen);
    XFlush(_glfw.x11.display);
}

void _glfwPlatformRestoreWindow(_GLFWwindow* window) {
    if (window.x11.overrideRedirect)
    {
        // Override-redirect windows cannot be iconified or restored, as those
        // tasks are performed by the window manager
        _glfwInputError(GLFW_PLATFORM_ERROR,
                        "X11: Iconification of full screen windows requires a WM that supports EWMH full screen");
        return;
    }

    if (_glfwPlatformWindowIconified(window))
    {
        XMapWindow(_glfw.x11.display, window.x11.handle);
        waitForVisibilityNotify(window);
    }
    else if (_glfwPlatformWindowVisible(window))
    {
        if (_glfw.x11.NET_WM_STATE &&
            _glfw.x11.NET_WM_STATE_MAXIMIZED_VERT &&
            _glfw.x11.NET_WM_STATE_MAXIMIZED_HORZ)
        {
            sendEventToWM(window,
                          _glfw.x11.NET_WM_STATE,
                          _NET_WM_STATE_REMOVE,
                          cast(int) _glfw.x11.NET_WM_STATE_MAXIMIZED_VERT,
                          cast(int) _glfw.x11.NET_WM_STATE_MAXIMIZED_HORZ,
                          1, 0);
        }
    }

    XFlush(_glfw.x11.display);
}

void _glfwPlatformMaximizeWindow(_GLFWwindow* window) {
    if (!_glfw.x11.NET_WM_STATE ||
        !_glfw.x11.NET_WM_STATE_MAXIMIZED_VERT ||
        !_glfw.x11.NET_WM_STATE_MAXIMIZED_HORZ)
    {
        return;
    }

    if (_glfwPlatformWindowVisible(window))
    {
        sendEventToWM(window,
                    cast(int) _glfw.x11.NET_WM_STATE,
                    _NET_WM_STATE_ADD,
                    cast(int) _glfw.x11.NET_WM_STATE_MAXIMIZED_VERT,
                    cast(int) _glfw.x11.NET_WM_STATE_MAXIMIZED_HORZ,
                    1, 0);
    }
    else
    {
        Atom* states = null;
        c_ulong count = _glfwGetWindowPropertyX11(window.x11.handle,
                                      _glfw.x11.NET_WM_STATE,
                                      XA_ATOM,
                                      cast(ubyte**) &states);

        // NOTE: We don't check for failure as this property may not exist yet
        //       and that's fine (and we'll create it implicitly with append)

        Atom[2] missing = [
            _glfw.x11.NET_WM_STATE_MAXIMIZED_VERT,
            _glfw.x11.NET_WM_STATE_MAXIMIZED_HORZ
        ];
        uint missingCount = 2;

        for (uint i = 0;  i < count;  i++)
        {
            for (uint j = 0;  j < missingCount;  j++)
            {
                if (states[i] == missing[j])
                {
                    missing[j] = missing[missingCount - 1];
                    missingCount--;
                }
            }
        }

        if (states)
            XFree(states);

        if (!missingCount)
            return;

        XChangeProperty(_glfw.x11.display, window.x11.handle,
                        _glfw.x11.NET_WM_STATE, XA_ATOM, 32,
                        PropModeAppend,
                        cast(ubyte*) missing,
                        missingCount);
    }

    XFlush(_glfw.x11.display);
}

void _glfwPlatformShowWindow(_GLFWwindow* window) {
    if (_glfwPlatformWindowVisible(window))
        return;

    XMapWindow(_glfw.x11.display, window.x11.handle);
    waitForVisibilityNotify(window);
}

void _glfwPlatformHideWindow(_GLFWwindow* window) {
    XUnmapWindow(_glfw.x11.display, window.x11.handle);
    XFlush(_glfw.x11.display);
}

void _glfwPlatformRequestWindowAttention(_GLFWwindow* window) {
    if (!_glfw.x11.NET_WM_STATE || !_glfw.x11.NET_WM_STATE_DEMANDS_ATTENTION)
        return;

    sendEventToWM(window,
                  cast(int) _glfw.x11.NET_WM_STATE,
                  _NET_WM_STATE_ADD,
                  cast(int) _glfw.x11.NET_WM_STATE_DEMANDS_ATTENTION,
                  0, 1, 0);
}

void _glfwPlatformFocusWindow(_GLFWwindow* window) {
    if (_glfw.x11.NET_ACTIVE_WINDOW)
        sendEventToWM(window, _glfw.x11.NET_ACTIVE_WINDOW, 1, 0, 0, 0, 0);
    else if (_glfwPlatformWindowVisible(window))
    {
        XRaiseWindow(_glfw.x11.display, window.x11.handle);
        XSetInputFocus(_glfw.x11.display, window.x11.handle,
                       RevertToParent, CurrentTime);
    }

    XFlush(_glfw.x11.display);
}

void _glfwPlatformSetWindowMonitor(_GLFWwindow* window, _GLFWmonitor* monitor, int xpos, int ypos, int width, int height, int refreshRate) {
    if (window.monitor == monitor)
    {
        if (monitor)
        {
            if (monitor.window == window)
                acquireMonitor(window);
        }
        else
        {
            if (!window.resizable)
                updateNormalHints(window, width, height);

            XMoveResizeWindow(_glfw.x11.display, window.x11.handle,
                              xpos, ypos, width, height);
        }

        XFlush(_glfw.x11.display);
        return;
    }

    if (window.monitor)
        releaseMonitor(window);

    _glfwInputWindowMonitor(window, monitor);
    updateNormalHints(window, width, height);

    if (window.monitor)
    {
        if (!_glfwPlatformWindowVisible(window))
        {
            XMapRaised(_glfw.x11.display, window.x11.handle);
            waitForVisibilityNotify(window);
        }

        updateWindowMode(window);
        acquireMonitor(window);
    }
    else
    {
        updateWindowMode(window);
        XMoveResizeWindow(_glfw.x11.display, window.x11.handle,
                          xpos, ypos, width, height);
    }

    XFlush(_glfw.x11.display);
}

int _glfwPlatformWindowFocused(_GLFWwindow* window) {
    Window focused;
    int state;

    XGetInputFocus(_glfw.x11.display, &focused, &state);
    return window.x11.handle == focused;
}

int _glfwPlatformWindowIconified(_GLFWwindow* window) {
    return getWindowState(window) == IconicState;
}

int _glfwPlatformWindowVisible(_GLFWwindow* window) {
    XWindowAttributes wa;
    XGetWindowAttributes(_glfw.x11.display, window.x11.handle, &wa);
    return wa.map_state == IsViewable;
}

int _glfwPlatformWindowMaximized(_GLFWwindow* window) {
    Atom* states;
    uint i;
    GLFWbool maximized = GLFW_FALSE;

    if (!_glfw.x11.NET_WM_STATE ||
        !_glfw.x11.NET_WM_STATE_MAXIMIZED_VERT ||
        !_glfw.x11.NET_WM_STATE_MAXIMIZED_HORZ)
    {
        return maximized;
    }

    c_ulong count = _glfwGetWindowPropertyX11(window.x11.handle,
                                  _glfw.x11.NET_WM_STATE,
                                  XA_ATOM,
                                  cast(ubyte**) &states);

    for (i = 0;  i < count;  i++)
    {
        if (states[i] == _glfw.x11.NET_WM_STATE_MAXIMIZED_VERT ||
            states[i] == _glfw.x11.NET_WM_STATE_MAXIMIZED_HORZ)
        {
            maximized = GLFW_TRUE;
            break;
        }
    }

    if (states)
        XFree(states);

    return maximized;
}

int _glfwPlatformWindowHovered(_GLFWwindow* window) {
    Window w = _glfw.x11.root;
    while (w)
    {
        Window root;
        int rootX;int rootY;int childX;int childY;
        uint mask;

        if (!XQueryPointer(_glfw.x11.display, w,
                           &root, &w, &rootX, &rootY, &childX, &childY, &mask))
        {
            return GLFW_FALSE;
        }

        if (w == window.x11.handle)
            return GLFW_TRUE;
    }

    return GLFW_FALSE;
}

int _glfwPlatformFramebufferTransparent(_GLFWwindow* window) {
    if (!window.x11.transparent)
        return GLFW_FALSE;

    return XGetSelectionOwner(_glfw.x11.display, _glfw.x11.NET_WM_CM_Sx) != None;
}

void _glfwPlatformSetWindowResizable(_GLFWwindow* window, GLFWbool enabled) {
    int width;int height;
    _glfwPlatformGetWindowSize(window, &width, &height);
    updateNormalHints(window, width, height);
}

void _glfwPlatformSetWindowDecorated(_GLFWwindow* window, GLFWbool enabled) {
    static struct _Hints {
        uint flags = 0;
        uint functions = 0;
        uint decorations = 0;
        int input_mode = 0;
        uint status = 0;
    }
    _Hints hints = _Hints.init;

    hints.flags = MWM_HINTS_DECORATIONS;
    hints.decorations = enabled ? MWM_DECOR_ALL : 0;

    XChangeProperty(_glfw.x11.display, window.x11.handle,
                    _glfw.x11.MOTIF_WM_HINTS,
                    _glfw.x11.MOTIF_WM_HINTS, 32,
                    PropModeReplace,
                    cast(ubyte*) &hints,
                    hints.sizeof / long.sizeof);
}

void _glfwPlatformSetWindowFloating(_GLFWwindow* window, GLFWbool enabled) {
    if (!_glfw.x11.NET_WM_STATE || !_glfw.x11.NET_WM_STATE_ABOVE)
        return;

    if (_glfwPlatformWindowVisible(window))
    {
        const(int) action = enabled ? _NET_WM_STATE_ADD : _NET_WM_STATE_REMOVE;
        sendEventToWM(window,
                      cast(int) _glfw.x11.NET_WM_STATE,
                      action,
                      cast(int) _glfw.x11.NET_WM_STATE_ABOVE,
                      0, 1, 0);
    }
    else
    {
        Atom* states = null;
        c_ulong i, count;

        count = _glfwGetWindowPropertyX11(window.x11.handle,
                                          cast(int) _glfw.x11.NET_WM_STATE,
                                          XA_ATOM,
                                          cast(ubyte**) &states);

        // NOTE: We don't check for failure as this property may not exist yet
        //       and that's fine (and we'll create it implicitly with append)

        if (enabled)
        {
            for (i = 0;  i < count;  i++)
            {
                if (states[i] == _glfw.x11.NET_WM_STATE_ABOVE)
                    break;
            }

            if (i < count)
                return;

            XChangeProperty(_glfw.x11.display, window.x11.handle,
                            _glfw.x11.NET_WM_STATE, XA_ATOM, 32,
                            PropModeAppend,
                            cast(ubyte*) &_glfw.x11.NET_WM_STATE_ABOVE,
                            1);
        }
        else if (states)
        {
            for (i = 0;  i < count;  i++)
            {
                if (states[i] == _glfw.x11.NET_WM_STATE_ABOVE)
                    break;
            }

            if (i == count)
                return;

            states[i] = states[count - 1];
            count--;

            XChangeProperty(_glfw.x11.display, window.x11.handle,
                            _glfw.x11.NET_WM_STATE, XA_ATOM, 32,
                            PropModeReplace, cast(ubyte*) states, cast(int) count);
        }

        if (states)
            XFree(states);
    }

    XFlush(_glfw.x11.display);
}

float _glfwPlatformGetWindowOpacity(_GLFWwindow* window) {
    float opacity = 1.0f;

    if (XGetSelectionOwner(_glfw.x11.display, _glfw.x11.NET_WM_CM_Sx))
    {
        CARD32* value = null;

        if (_glfwGetWindowPropertyX11(window.x11.handle,
                                      _glfw.x11.NET_WM_WINDOW_OPACITY,
                                      XA_CARDINAL,
                                      cast(ubyte**) &value))
        {
            opacity = cast(float) (*value / cast(double) 0xffffffffu);
        }

        if (value)
            XFree(value);
    }

    return opacity;
}

void _glfwPlatformSetWindowOpacity(_GLFWwindow* window, float opacity) {
    CARD32 value = cast(CARD32) (0xffffffffu * cast(double) opacity);
    XChangeProperty(_glfw.x11.display, window.x11.handle,
                    _glfw.x11.NET_WM_WINDOW_OPACITY, XA_CARDINAL, 32,
                    PropModeReplace, cast(ubyte*) &value, 1);
}

void _glfwPlatformSetRawMouseMotion(_GLFWwindow* window, GLFWbool enabled) {
    if (!_glfw.x11.xi.available)
        return;

    if (_glfw.x11.disabledCursorWindow != window)
        return;

    if (enabled)
        enableRawMouseMotion(window);
    else
        disableRawMouseMotion(window);
}

GLFWbool _glfwPlatformRawMouseMotionSupported() {
    return _glfw.x11.xi.available;
}

void _glfwPlatformPollEvents() {
    _GLFWwindow* window;

version(linux) {
    _glfwDetectJoystickConnectionLinux();
}
    XPending(_glfw.x11.display);

    while (XQLength(_glfw.x11.display))
    {
        XEvent event;
        XNextEvent(_glfw.x11.display, &event);
        processEvent(&event);
    }

    window = _glfw.x11.disabledCursorWindow;
    if (window)
    {
        int width;int height;
        _glfwPlatformGetWindowSize(window, &width, &height);

        // NOTE: Re-center the cursor only if it has moved since the last call,
        //       to avoid breaking glfwWaitEvents with MotionNotify
        if (window.x11.lastCursorPosX != width / 2 ||
            window.x11.lastCursorPosY != height / 2)
        {
            _glfwPlatformSetCursorPos(window, width / 2, height / 2);
        }
    }

    XFlush(_glfw.x11.display);
}

void _glfwPlatformWaitEvents() {
    while (!XPending(_glfw.x11.display))
        waitForEvent(null);

    _glfwPlatformPollEvents();
}

void _glfwPlatformWaitEventsTimeout(double timeout) {
    while (!XPending(_glfw.x11.display))
    {
        if (!waitForEvent(&timeout))
            break;
    }

    _glfwPlatformPollEvents();
}

void _glfwPlatformPostEmptyEvent() {
    XEvent event = XEvent(ClientMessage);
    event.xclient.window = _glfw.x11.helperWindowHandle;
    event.xclient.format = 32; // Data is 32-bit longs
    event.xclient.message_type = _glfw.x11.NULL_;

    XSendEvent(_glfw.x11.display, _glfw.x11.helperWindowHandle, False, 0, &event);
    XFlush(_glfw.x11.display);
}

void _glfwPlatformGetCursorPos(_GLFWwindow* window, double* xpos, double* ypos) {
    Window root;Window child;
    int rootX;int rootY;int childX;int childY;
    uint mask;

    XQueryPointer(_glfw.x11.display, window.x11.handle,
                  &root, &child,
                  &rootX, &rootY, &childX, &childY,
                  &mask);

    if (xpos)
        *xpos = childX;
    if (ypos)
        *ypos = childY;
}

void _glfwPlatformSetCursorPos(_GLFWwindow* window, double x, double y) {
    // Store the new position so it can be recognized later
    window.x11.warpCursorPosX = cast(int) x;
    window.x11.warpCursorPosY = cast(int) y;

    XWarpPointer(_glfw.x11.display, None, window.x11.handle,
                 0,0,0,0, cast(int) x, cast(int) y);
    XFlush(_glfw.x11.display);
}

void _glfwPlatformSetCursorMode(_GLFWwindow* window, int mode) {
    if (mode == GLFW_CURSOR_DISABLED)
    {
        if (_glfwPlatformWindowFocused(window))
            disableCursor(window);
    }
    else if (_glfw.x11.disabledCursorWindow == window)
        enableCursor(window);
    else
        updateCursorImage(window);

    XFlush(_glfw.x11.display);
}

const(char)* _glfwPlatformGetScancodeName(int scancode) {
    if (!_glfw.x11.xkb.available)
        return null;

    if (scancode < 0 || scancode > 0xff ||
        _glfw.x11.keycodes[scancode] == GLFW_KEY_UNKNOWN)
    {
        _glfwInputError(GLFW_INVALID_VALUE, "Invalid scancode");
        return null;
    }

    const(int) key = _glfw.x11.keycodes[scancode];
    const(KeySym) keysym = XkbKeycodeToKeysym(_glfw.x11.display,
                                             cast(ubyte) scancode, _glfw.x11.xkb.group, 0);
    if (keysym == NoSymbol)
        return null;

    const(int) ch = _glfwKeySym2Unicode(cast(int) keysym);
    if (ch == -1)
        return null;

    const(size_t) count = encodeUTF8(_glfw.x11.keynames[key].ptr, cast(uint) ch);
    if (count == 0)
        return null;

    _glfw.x11.keynames[key][count] = '\0';
    return _glfw.x11.keynames[key].ptr;
}

int _glfwPlatformGetKeyScancode(int key) {
    return _glfw.x11.scancodes[key];
}

int _glfwPlatformCreateCursor(_GLFWcursor* cursor, const(GLFWimage)* image, int xhot, int yhot) {
    cursor.x11.handle = _glfwCreateCursorX11(image, xhot, yhot);
    if (!cursor.x11.handle)
        return GLFW_FALSE;

    return GLFW_TRUE;
}

int _glfwPlatformCreateStandardCursor(_GLFWcursor* cursor, int shape) {
    int native = 0;

    if (shape == GLFW_ARROW_CURSOR)
        native = XC_left_ptr;
    else if (shape == GLFW_IBEAM_CURSOR)
        native = XC_xterm;
    else if (shape == GLFW_CROSSHAIR_CURSOR)
        native = XC_crosshair;
    else if (shape == GLFW_HAND_CURSOR)
        native = XC_hand2;
    else if (shape == GLFW_HRESIZE_CURSOR)
        native = XC_sb_h_double_arrow;
    else if (shape == GLFW_VRESIZE_CURSOR)
        native = XC_sb_v_double_arrow;
    else
        return GLFW_FALSE;

    cursor.x11.handle = XCreateFontCursor(_glfw.x11.display, native);
    if (!cursor.x11.handle)
    {
        _glfwInputError(GLFW_PLATFORM_ERROR,
                        "X11: Failed to create standard cursor");
        return GLFW_FALSE;
    }

    return GLFW_TRUE;
}

void _glfwPlatformDestroyCursor(_GLFWcursor* cursor) {
    if (cursor.x11.handle)
        XFreeCursor(_glfw.x11.display, cursor.x11.handle);
}

void _glfwPlatformSetCursor(_GLFWwindow* window, _GLFWcursor* cursor) {
    if (window.cursorMode == GLFW_CURSOR_NORMAL)
    {
        updateCursorImage(window);
        XFlush(_glfw.x11.display);
    }
}

void _glfwPlatformSetClipboardString(const(char)* string) {
    free(_glfw.x11.clipboardString);
    _glfw.x11.clipboardString = _glfw_strdup(string);

    XSetSelectionOwner(_glfw.x11.display,
                       _glfw.x11.CLIPBOARD,
                       _glfw.x11.helperWindowHandle,
                       CurrentTime);

    if (XGetSelectionOwner(_glfw.x11.display, _glfw.x11.CLIPBOARD) !=
        _glfw.x11.helperWindowHandle)
    {
        _glfwInputError(GLFW_PLATFORM_ERROR,
                        "X11: Failed to become owner of clipboard selection");
    }
}

const(char)* _glfwPlatformGetClipboardString() {
    return getSelectionString(_glfw.x11.CLIPBOARD);
}

void _glfwPlatformGetRequiredInstanceExtensions(const(char)** extensions) {
    if (!_glfw.vk.KHR_surface)
        return;

    if (!_glfw.vk.KHR_xcb_surface || !_glfw.x11.x11xcb.handle)
    {
        if (!_glfw.vk.KHR_xlib_surface)
            return;
    }

    extensions[0] = "VK_KHR_surface";

    // NOTE: VK_KHR_xcb_surface is preferred due to some early ICDs exposing but
    //       not correctly implementing VK_KHR_xlib_surface
    if (_glfw.vk.KHR_xcb_surface && _glfw.x11.x11xcb.handle)
        extensions[1] = "VK_KHR_xcb_surface";
    else
        extensions[1] = "VK_KHR_xlib_surface";
}

int _glfwPlatformGetPhysicalDevicePresentationSupport(VkInstance instance, VkPhysicalDevice device, uint queuefamily) {
    VisualID visualID = XVisualIDFromVisual(DefaultVisual(_glfw.x11.display,
                                                          _glfw.x11.screen));

    if (_glfw.vk.KHR_xcb_surface && _glfw.x11.x11xcb.handle)
    {
        version(_GLFW_VULKAN_STATIC) {
            PFN_vkGetPhysicalDeviceXcbPresentationSupportKHR vkGetPhysicalDeviceXcbPresentationSupportKHR = cast(PFN_vkGetPhysicalDeviceXcbPresentationSupportKHR)
                vkGetInstanceProcAddr(instance, "vkGetPhysicalDeviceXcbPresentationSupportKHR");
        } else {
            PFN_vkGetPhysicalDeviceXcbPresentationSupportKHR vkGetPhysicalDeviceXcbPresentationSupportKHR = cast(PFN_vkGetPhysicalDeviceXcbPresentationSupportKHR)
                _glfw.vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceXcbPresentationSupportKHR");
        }
        if (!vkGetPhysicalDeviceXcbPresentationSupportKHR)
        {
            _glfwInputError(GLFW_API_UNAVAILABLE,
                            "X11: Vulkan instance missing VK_KHR_xcb_surface extension");
            return GLFW_FALSE;
        }

        xcb_connection_t* connection = _glfw.x11.x11xcb.GetXCBConnection(_glfw.x11.display);
        if (!connection)
        {
            _glfwInputError(GLFW_PLATFORM_ERROR,
                            "X11: Failed to retrieve XCB connection");
            return GLFW_FALSE;
        }

        return vkGetPhysicalDeviceXcbPresentationSupportKHR(device,
                                                            queuefamily,
                                                            connection,
                                                            visualID);
    }
    else
    {
        version(_GLFW_VULKAN_STATIC) {
            PFN_vkGetPhysicalDeviceXlibPresentationSupportKHR vkGetPhysicalDeviceXlibPresentationSupportKHR = cast(PFN_vkGetPhysicalDeviceXlibPresentationSupportKHR)
                vkGetInstanceProcAddr(instance, "vkGetPhysicalDeviceXlibPresentationSupportKHR");
        } else {
            PFN_vkGetPhysicalDeviceXlibPresentationSupportKHR vkGetPhysicalDeviceXlibPresentationSupportKHR = cast(PFN_vkGetPhysicalDeviceXlibPresentationSupportKHR)
                _glfw.vk.GetInstanceProcAddr(instance, "vkGetPhysicalDeviceXlibPresentationSupportKHR");
        }
        if (!vkGetPhysicalDeviceXlibPresentationSupportKHR)
        {
            _glfwInputError(GLFW_API_UNAVAILABLE,
                            "X11: Vulkan instance missing VK_KHR_xlib_surface extension");
            return GLFW_FALSE;
        }

        return vkGetPhysicalDeviceXlibPresentationSupportKHR(device,
                                                             queuefamily,
                                                             _glfw.x11.display,
                                                             visualID);
    }
}

VkResult _glfwPlatformCreateWindowSurface(VkInstance instance, _GLFWwindow* window, const(VkAllocationCallbacks)* allocator, VkSurfaceKHR* surface) {
    if (_glfw.vk.KHR_xcb_surface && _glfw.x11.x11xcb.handle)
    {
        VkResult err;
        VkXcbSurfaceCreateInfoKHR sci;
        PFN_vkCreateXcbSurfaceKHR vkCreateXcbSurfaceKHR;

        xcb_connection_t* connection = _glfw.x11.x11xcb.GetXCBConnection(_glfw.x11.display);
        if (!connection)
        {
            _glfwInputError(GLFW_PLATFORM_ERROR,
                            "X11: Failed to retrieve XCB connection");
            return VkResult.VK_ERROR_EXTENSION_NOT_PRESENT;
        }

        version(_GLFW_VULKAN_STATIC) {
            vkCreateXcbSurfaceKHR = cast(PFN_vkCreateXcbSurfaceKHR)
                vkGetInstanceProcAddr(instance, "vkCreateXcbSurfaceKHR");
        } else {
            vkCreateXcbSurfaceKHR = cast(PFN_vkCreateXcbSurfaceKHR)
                _glfw.vk.GetInstanceProcAddr(instance, "vkCreateXcbSurfaceKHR");
        }

        if (!vkCreateXcbSurfaceKHR)
        {
            _glfwInputError(GLFW_API_UNAVAILABLE,
                            "X11: Vulkan instance missing VK_KHR_xcb_surface extension");
            return VkResult.VK_ERROR_EXTENSION_NOT_PRESENT;
        }

        memset(&sci, 0, typeof(sci).sizeof);
        sci.sType = VkStructureType.VK_STRUCTURE_TYPE_XCB_SURFACE_CREATE_INFO_KHR;
        sci.connection = connection;
        sci.window = window.x11.handle;

        err = vkCreateXcbSurfaceKHR(instance, &sci, allocator, surface);
        if (err)
        {
            _glfwInputError(GLFW_PLATFORM_ERROR,
                            "X11: Failed to create Vulkan XCB surface: %s",
                            _glfwGetVulkanResultString(err));
        }

        return err;
    }
    else
    {
        VkResult err;
        VkXlibSurfaceCreateInfoKHR sci;
        PFN_vkCreateXlibSurfaceKHR vkCreateXlibSurfaceKHR;

        version(_GLFW_VULKAN_STATIC) {
            vkCreateXlibSurfaceKHR = cast(PFN_vkCreateXlibSurfaceKHR)
                vkGetInstanceProcAddr(instance, "vkCreateXlibSurfaceKHR");
        } else {
            vkCreateXlibSurfaceKHR = cast(PFN_vkCreateXlibSurfaceKHR)
                _glfw.vk.GetInstanceProcAddr(instance, "vkCreateXlibSurfaceKHR");
        }

        if (!vkCreateXlibSurfaceKHR)
        {
            _glfwInputError(GLFW_API_UNAVAILABLE,
                            "X11: Vulkan instance missing VK_KHR_xlib_surface extension");
            return VkResult.VK_ERROR_EXTENSION_NOT_PRESENT;
        }

        memset(&sci, 0, typeof(sci).sizeof);
        sci.sType = VkStructureType.VK_STRUCTURE_TYPE_XLIB_SURFACE_CREATE_INFO_KHR;
        sci.dpy = _glfw.x11.display;
        sci.window = window.x11.handle;

        err = vkCreateXlibSurfaceKHR(instance, &sci, allocator, surface);
        if (err)
        {
            _glfwInputError(GLFW_PLATFORM_ERROR,
                            "X11: Failed to create Vulkan X11 surface: %s",
                            _glfwGetVulkanResultString(err));
        }

        return err;
    }
}


//////////////////////////////////////////////////////////////////////////
//////                        GLFW native API                       //////
//////////////////////////////////////////////////////////////////////////

Display* glfwGetX11Display() {
    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"null");
    return _glfw.x11.display;
}

Window glfwGetX11Window(GLFWwindow* handle) {
    _GLFWwindow* window = cast(_GLFWwindow*) handle;
    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"None");
    return window.x11.handle;
}

void glfwSetX11SelectionString(const(char)* string) {
    mixin(_GLFW_REQUIRE_INIT);

    free(_glfw.x11.primarySelectionString);
    _glfw.x11.primarySelectionString = _glfw_strdup(string);

    XSetSelectionOwner(_glfw.x11.display,
                       _glfw.x11.PRIMARY,
                       _glfw.x11.helperWindowHandle,
                       CurrentTime);

    if (XGetSelectionOwner(_glfw.x11.display, _glfw.x11.PRIMARY) !=
        _glfw.x11.helperWindowHandle)
    {
        _glfwInputError(GLFW_PLATFORM_ERROR,
                        "X11: Failed to become owner of primary selection");
    }
}

const(char)* glfwGetX11SelectionString() {
    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"null");
    return getSelectionString(_glfw.x11.PRIMARY);
}
