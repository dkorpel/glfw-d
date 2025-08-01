/// Translated from C to D
module glfw3.x11_init;

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
    import x11.Xresource;
    import x11.extensions.XKBsrv;
    import x11.XKBlib;
}

import core.stdc.stdlib;
import core.stdc.string;
import core.stdc.limits;
import core.stdc.stdio;
import core.stdc.locale;
import core.stdc.config: c_long, c_ulong;

// Translate an X11 key code to a GLFW key code.
//
private int translateKeyCode(int scancode) {
    int keySym;

    // Valid key code range is  [8,255], according to the Xlib manual
    if (scancode < 8 || scancode > 255)
        return GLFW_KEY_UNKNOWN;

    if (_glfw.x11.xkb.available)
    {
        // Try secondary keysym, for numeric keypad keys
        // Note: This way we always force "NumLock = ON", which is intentional
        // since the returned key code should correspond to a physical
        // location.
        keySym = cast(int) XkbKeycodeToKeysym(_glfw.x11.display, cast(ubyte) scancode, cast(int) _glfw.x11.xkb.group, 1);
        switch (keySym)
        {
            case XK_KP_0:           return GLFW_KEY_KP_0;
            case XK_KP_1:           return GLFW_KEY_KP_1;
            case XK_KP_2:           return GLFW_KEY_KP_2;
            case XK_KP_3:           return GLFW_KEY_KP_3;
            case XK_KP_4:           return GLFW_KEY_KP_4;
            case XK_KP_5:           return GLFW_KEY_KP_5;
            case XK_KP_6:           return GLFW_KEY_KP_6;
            case XK_KP_7:           return GLFW_KEY_KP_7;
            case XK_KP_8:           return GLFW_KEY_KP_8;
            case XK_KP_9:           return GLFW_KEY_KP_9;
            case XK_KP_Separator:
            case XK_KP_Decimal:     return GLFW_KEY_KP_DECIMAL;
            case XK_KP_Equal:       return GLFW_KEY_KP_EQUAL;
            case XK_KP_Enter:       return GLFW_KEY_KP_ENTER;
            default:                break;
        }

        // Now try primary keysym for function keys (non-printable keys)
        // These should not depend on the current keyboard layout
        keySym = cast(int) XkbKeycodeToKeysym(_glfw.x11.display, cast(ubyte) scancode, _glfw.x11.xkb.group, 0);
    }
    else
    {
        int dummy;
        KeySym* keySyms;

        keySyms = XGetKeyboardMapping(_glfw.x11.display, cast(ubyte) scancode, 1, &dummy);
        keySym = cast(int) keySyms[0];
        XFree(keySyms);
    }

    switch (keySym)
    {
        case XK_Escape:         return GLFW_KEY_ESCAPE;
        case XK_Tab:            return GLFW_KEY_TAB;
        case XK_Shift_L:        return GLFW_KEY_LEFT_SHIFT;
        case XK_Shift_R:        return GLFW_KEY_RIGHT_SHIFT;
        case XK_Control_L:      return GLFW_KEY_LEFT_CONTROL;
        case XK_Control_R:      return GLFW_KEY_RIGHT_CONTROL;
        case XK_Meta_L:
        case XK_Alt_L:          return GLFW_KEY_LEFT_ALT;
        case XK_Mode_switch: // Mapped to Alt_R on many keyboards
        case XK_ISO_Level3_Shift: // AltGr on at least some machines
        case XK_Meta_R:
        case XK_Alt_R:          return GLFW_KEY_RIGHT_ALT;
        case XK_Super_L:        return GLFW_KEY_LEFT_SUPER;
        case XK_Super_R:        return GLFW_KEY_RIGHT_SUPER;
        case XK_Menu:           return GLFW_KEY_MENU;
        case XK_Num_Lock:       return GLFW_KEY_NUM_LOCK;
        case XK_Caps_Lock:      return GLFW_KEY_CAPS_LOCK;
        case XK_Print:          return GLFW_KEY_PRINT_SCREEN;
        case XK_Scroll_Lock:    return GLFW_KEY_SCROLL_LOCK;
        case XK_Pause:          return GLFW_KEY_PAUSE;
        case XK_Delete:         return GLFW_KEY_DELETE;
        case XK_BackSpace:      return GLFW_KEY_BACKSPACE;
        case XK_Return:         return GLFW_KEY_ENTER;
        case XK_Home:           return GLFW_KEY_HOME;
        case XK_End:            return GLFW_KEY_END;
        case XK_Page_Up:        return GLFW_KEY_PAGE_UP;
        case XK_Page_Down:      return GLFW_KEY_PAGE_DOWN;
        case XK_Insert:         return GLFW_KEY_INSERT;
        case XK_Left:           return GLFW_KEY_LEFT;
        case XK_Right:          return GLFW_KEY_RIGHT;
        case XK_Down:           return GLFW_KEY_DOWN;
        case XK_Up:             return GLFW_KEY_UP;
        case XK_F1:             return GLFW_KEY_F1;
        case XK_F2:             return GLFW_KEY_F2;
        case XK_F3:             return GLFW_KEY_F3;
        case XK_F4:             return GLFW_KEY_F4;
        case XK_F5:             return GLFW_KEY_F5;
        case XK_F6:             return GLFW_KEY_F6;
        case XK_F7:             return GLFW_KEY_F7;
        case XK_F8:             return GLFW_KEY_F8;
        case XK_F9:             return GLFW_KEY_F9;
        case XK_F10:            return GLFW_KEY_F10;
        case XK_F11:            return GLFW_KEY_F11;
        case XK_F12:            return GLFW_KEY_F12;
        case XK_F13:            return GLFW_KEY_F13;
        case XK_F14:            return GLFW_KEY_F14;
        case XK_F15:            return GLFW_KEY_F15;
        case XK_F16:            return GLFW_KEY_F16;
        case XK_F17:            return GLFW_KEY_F17;
        case XK_F18:            return GLFW_KEY_F18;
        case XK_F19:            return GLFW_KEY_F19;
        case XK_F20:            return GLFW_KEY_F20;
        case XK_F21:            return GLFW_KEY_F21;
        case XK_F22:            return GLFW_KEY_F22;
        case XK_F23:            return GLFW_KEY_F23;
        case XK_F24:            return GLFW_KEY_F24;
        case XK_F25:            return GLFW_KEY_F25;

        // Numeric keypad
        case XK_KP_Divide:      return GLFW_KEY_KP_DIVIDE;
        case XK_KP_Multiply:    return GLFW_KEY_KP_MULTIPLY;
        case XK_KP_Subtract:    return GLFW_KEY_KP_SUBTRACT;
        case XK_KP_Add:         return GLFW_KEY_KP_ADD;

        // These should have been detected in secondary keysym test above!
        case XK_KP_Insert:      return GLFW_KEY_KP_0;
        case XK_KP_End:         return GLFW_KEY_KP_1;
        case XK_KP_Down:        return GLFW_KEY_KP_2;
        case XK_KP_Page_Down:   return GLFW_KEY_KP_3;
        case XK_KP_Left:        return GLFW_KEY_KP_4;
        case XK_KP_Right:       return GLFW_KEY_KP_6;
        case XK_KP_Home:        return GLFW_KEY_KP_7;
        case XK_KP_Up:          return GLFW_KEY_KP_8;
        case XK_KP_Page_Up:     return GLFW_KEY_KP_9;
        case XK_KP_Delete:      return GLFW_KEY_KP_DECIMAL;
        case XK_KP_Equal:       return GLFW_KEY_KP_EQUAL;
        case XK_KP_Enter:       return GLFW_KEY_KP_ENTER;

        // Last resort: Check for printable keys (should not happen if the XKB
        // extension is available). This will give a layout dependent mapping
        // (which is wrong, and we may miss some keys, especially on non-US
        // keyboards), but it's better than nothing...
        case XK_a:              return GLFW_KEY_A;
        case XK_b:              return GLFW_KEY_B;
        case XK_c:              return GLFW_KEY_C;
        case XK_d:              return GLFW_KEY_D;
        case XK_e:              return GLFW_KEY_E;
        case XK_f:              return GLFW_KEY_F;
        case XK_g:              return GLFW_KEY_G;
        case XK_h:              return GLFW_KEY_H;
        case XK_i:              return GLFW_KEY_I;
        case XK_j:              return GLFW_KEY_J;
        case XK_k:              return GLFW_KEY_K;
        case XK_l:              return GLFW_KEY_L;
        case XK_m:              return GLFW_KEY_M;
        case XK_n:              return GLFW_KEY_N;
        case XK_o:              return GLFW_KEY_O;
        case XK_p:              return GLFW_KEY_P;
        case XK_q:              return GLFW_KEY_Q;
        case XK_r:              return GLFW_KEY_R;
        case XK_s:              return GLFW_KEY_S;
        case XK_t:              return GLFW_KEY_T;
        case XK_u:              return GLFW_KEY_U;
        case XK_v:              return GLFW_KEY_V;
        case XK_w:              return GLFW_KEY_W;
        case XK_x:              return GLFW_KEY_X;
        case XK_y:              return GLFW_KEY_Y;
        case XK_z:              return GLFW_KEY_Z;
        case XK_1:              return GLFW_KEY_1;
        case XK_2:              return GLFW_KEY_2;
        case XK_3:              return GLFW_KEY_3;
        case XK_4:              return GLFW_KEY_4;
        case XK_5:              return GLFW_KEY_5;
        case XK_6:              return GLFW_KEY_6;
        case XK_7:              return GLFW_KEY_7;
        case XK_8:              return GLFW_KEY_8;
        case XK_9:              return GLFW_KEY_9;
        case XK_0:              return GLFW_KEY_0;
        case XK_space:          return GLFW_KEY_SPACE;
        case XK_minus:          return GLFW_KEY_MINUS;
        case XK_equal:          return GLFW_KEY_EQUAL;
        case XK_bracketleft:    return GLFW_KEY_LEFT_BRACKET;
        case XK_bracketright:   return GLFW_KEY_RIGHT_BRACKET;
        case XK_backslash:      return GLFW_KEY_BACKSLASH;
        case XK_semicolon:      return GLFW_KEY_SEMICOLON;
        case XK_apostrophe:     return GLFW_KEY_APOSTROPHE;
        case XK_grave:          return GLFW_KEY_GRAVE_ACCENT;
        case XK_comma:          return GLFW_KEY_COMMA;
        case XK_period:         return GLFW_KEY_PERIOD;
        case XK_slash:          return GLFW_KEY_SLASH;
        case XK_less:           return GLFW_KEY_WORLD_1; // At least in some layouts...
        default:                break;
    }

    // No matching translation was found
    return GLFW_KEY_UNKNOWN;
}

// Create key code translation tables
//
private extern(D) void createKeyTables() {
    int scancode;int key;

    memset(_glfw.x11.keycodes.ptr, -1, typeof(_glfw.x11.keycodes).sizeof);
    memset(_glfw.x11.scancodes.ptr, -1, typeof(_glfw.x11.scancodes).sizeof);

    if (_glfw.x11.xkb.available)
    {
        // Use XKB to determine physical key locations independently of the
        // current keyboard layout

        char[XkbKeyNameLength + 1] name;
        XkbDescPtr desc = XkbGetMap(_glfw.x11.display, 0, XkbUseCoreKbd);
        XkbGetNames(_glfw.x11.display, XkbKeyNamesMask, desc);

        // Find the X11 key code -> GLFW key code mapping
        for (scancode = desc.min_key_code;  scancode <= desc.max_key_code;  scancode++)
        {
            memcpy(name.ptr, desc.names.keys[scancode].name.ptr, XkbKeyNameLength);
            name[XkbKeyNameLength] = '\0';

            // Map the key name to a GLFW key code. Note: We only map printable
            // keys here, and we use the US keyboard layout. The rest of the
            // keys (function keys) are mapped using traditional KeySym
            // translations.
            if (strcmp(name.ptr, "TLDE") == 0) key = GLFW_KEY_GRAVE_ACCENT;
            else if (strcmp(name.ptr, "AE01") == 0) key = GLFW_KEY_1;
            else if (strcmp(name.ptr, "AE02") == 0) key = GLFW_KEY_2;
            else if (strcmp(name.ptr, "AE03") == 0) key = GLFW_KEY_3;
            else if (strcmp(name.ptr, "AE04") == 0) key = GLFW_KEY_4;
            else if (strcmp(name.ptr, "AE05") == 0) key = GLFW_KEY_5;
            else if (strcmp(name.ptr, "AE06") == 0) key = GLFW_KEY_6;
            else if (strcmp(name.ptr, "AE07") == 0) key = GLFW_KEY_7;
            else if (strcmp(name.ptr, "AE08") == 0) key = GLFW_KEY_8;
            else if (strcmp(name.ptr, "AE09") == 0) key = GLFW_KEY_9;
            else if (strcmp(name.ptr, "AE10") == 0) key = GLFW_KEY_0;
            else if (strcmp(name.ptr, "AE11") == 0) key = GLFW_KEY_MINUS;
            else if (strcmp(name.ptr, "AE12") == 0) key = GLFW_KEY_EQUAL;
            else if (strcmp(name.ptr, "AD01") == 0) key = GLFW_KEY_Q;
            else if (strcmp(name.ptr, "AD02") == 0) key = GLFW_KEY_W;
            else if (strcmp(name.ptr, "AD03") == 0) key = GLFW_KEY_E;
            else if (strcmp(name.ptr, "AD04") == 0) key = GLFW_KEY_R;
            else if (strcmp(name.ptr, "AD05") == 0) key = GLFW_KEY_T;
            else if (strcmp(name.ptr, "AD06") == 0) key = GLFW_KEY_Y;
            else if (strcmp(name.ptr, "AD07") == 0) key = GLFW_KEY_U;
            else if (strcmp(name.ptr, "AD08") == 0) key = GLFW_KEY_I;
            else if (strcmp(name.ptr, "AD09") == 0) key = GLFW_KEY_O;
            else if (strcmp(name.ptr, "AD10") == 0) key = GLFW_KEY_P;
            else if (strcmp(name.ptr, "AD11") == 0) key = GLFW_KEY_LEFT_BRACKET;
            else if (strcmp(name.ptr, "AD12") == 0) key = GLFW_KEY_RIGHT_BRACKET;
            else if (strcmp(name.ptr, "AC01") == 0) key = GLFW_KEY_A;
            else if (strcmp(name.ptr, "AC02") == 0) key = GLFW_KEY_S;
            else if (strcmp(name.ptr, "AC03") == 0) key = GLFW_KEY_D;
            else if (strcmp(name.ptr, "AC04") == 0) key = GLFW_KEY_F;
            else if (strcmp(name.ptr, "AC05") == 0) key = GLFW_KEY_G;
            else if (strcmp(name.ptr, "AC06") == 0) key = GLFW_KEY_H;
            else if (strcmp(name.ptr, "AC07") == 0) key = GLFW_KEY_J;
            else if (strcmp(name.ptr, "AC08") == 0) key = GLFW_KEY_K;
            else if (strcmp(name.ptr, "AC09") == 0) key = GLFW_KEY_L;
            else if (strcmp(name.ptr, "AC10") == 0) key = GLFW_KEY_SEMICOLON;
            else if (strcmp(name.ptr, "AC11") == 0) key = GLFW_KEY_APOSTROPHE;
            else if (strcmp(name.ptr, "AB01") == 0) key = GLFW_KEY_Z;
            else if (strcmp(name.ptr, "AB02") == 0) key = GLFW_KEY_X;
            else if (strcmp(name.ptr, "AB03") == 0) key = GLFW_KEY_C;
            else if (strcmp(name.ptr, "AB04") == 0) key = GLFW_KEY_V;
            else if (strcmp(name.ptr, "AB05") == 0) key = GLFW_KEY_B;
            else if (strcmp(name.ptr, "AB06") == 0) key = GLFW_KEY_N;
            else if (strcmp(name.ptr, "AB07") == 0) key = GLFW_KEY_M;
            else if (strcmp(name.ptr, "AB08") == 0) key = GLFW_KEY_COMMA;
            else if (strcmp(name.ptr, "AB09") == 0) key = GLFW_KEY_PERIOD;
            else if (strcmp(name.ptr, "AB10") == 0) key = GLFW_KEY_SLASH;
            else if (strcmp(name.ptr, "BKSL") == 0) key = GLFW_KEY_BACKSLASH;
            else if (strcmp(name.ptr, "LSGT") == 0) key = GLFW_KEY_WORLD_1;
            else key = GLFW_KEY_UNKNOWN;

            if ((scancode >= 0) && (scancode < 256))
                _glfw.x11.keycodes[scancode] = key;
        }

        XkbFreeNames(desc, XkbKeyNamesMask, True);
        XkbFreeKeyboard(desc, 0, True);
    }

    for (scancode = 0;  scancode < 256;  scancode++)
    {
        // Translate the un-translated key codes using traditional X11 KeySym
        // lookups
        if (_glfw.x11.keycodes[scancode] < 0)
            _glfw.x11.keycodes[scancode] = translateKeyCode(scancode);

        // Store the reverse translation for faster key name lookup
        if (_glfw.x11.keycodes[scancode] > 0)
            _glfw.x11.scancodes[_glfw.x11.keycodes[scancode]] = scancode;
    }
}

// Check whether the IM has a usable style
//
private GLFWbool hasUsableInputMethodStyle() {
    GLFWbool found = GLFW_FALSE;
    XIMStyles* styles = null;

    if (XGetIMValues(_glfw.x11.im, XNQueryInputStyle, &styles, null) != null)
        return GLFW_FALSE;

    for (uint i = 0;  i < styles.count_styles;  i++)
    {
        if (styles.supported_styles[i] == (XIMPreeditNothing | XIMStatusNothing))
        {
            found = GLFW_TRUE;
            break;
        }
    }

    XFree(styles);
    return found;
}

// Check whether the specified atom is supported
//
private Atom getSupportedAtom(Atom* supportedAtoms, c_ulong atomCount, const(char)* atomName) {
    const(Atom) atom = XInternAtom(_glfw.x11.display, atomName, False);

    for (uint i = 0;  i < atomCount;  i++)
    {
        if (supportedAtoms[i] == atom)
            return atom;
    }

    return None;
}

// Check whether the running window manager is EWMH-compliant
//
private extern(D) void detectEWMH() {
    // First we read the _NET_SUPPORTING_WM_CHECK property on the root window

    Window* windowFromRoot = null;
    if (!_glfwGetWindowPropertyX11(_glfw.x11.root,
                                   _glfw.x11.NET_SUPPORTING_WM_CHECK,
                                   XA_WINDOW,
                                   cast(ubyte**) &windowFromRoot))
    {
        return;
    }

    _glfwGrabErrorHandlerX11();

    // If it exists, it should be the XID of a top-level window
    // Then we look for the same property on that window

    Window* windowFromChild = null;
    if (!_glfwGetWindowPropertyX11(*windowFromRoot,
                                   _glfw.x11.NET_SUPPORTING_WM_CHECK,
                                   XA_WINDOW,
                                   cast(ubyte**) &windowFromChild))
    {
        XFree(windowFromRoot);
        return;
    }

    _glfwReleaseErrorHandlerX11();

    // If the property exists, it should contain the XID of the window

    if (*windowFromRoot != *windowFromChild)
    {
        XFree(windowFromRoot);
        XFree(windowFromChild);
        return;
    }

    XFree(windowFromRoot);
    XFree(windowFromChild);

    // We are now fairly sure that an EWMH-compliant WM is currently running
    // We can now start querying the WM about what features it supports by
    // looking in the _NET_SUPPORTED property on the root window
    // It should contain a list of supported EWMH protocol and state atoms

    Atom* supportedAtoms = null;
    c_ulong atomCount = _glfwGetWindowPropertyX11(_glfw.x11.root,
                                  _glfw.x11.NET_SUPPORTED,
                                  XA_ATOM,
                                  cast(ubyte**) &supportedAtoms);

    // See which of the atoms we support that are supported by the WM

    _glfw.x11.NET_WM_STATE =
        getSupportedAtom(supportedAtoms, atomCount, "_NET_WM_STATE");
    _glfw.x11.NET_WM_STATE_ABOVE =
        getSupportedAtom(supportedAtoms, atomCount, "_NET_WM_STATE_ABOVE");
    _glfw.x11.NET_WM_STATE_FULLSCREEN =
        getSupportedAtom(supportedAtoms, atomCount, "_NET_WM_STATE_FULLSCREEN");
    _glfw.x11.NET_WM_STATE_MAXIMIZED_VERT =
        getSupportedAtom(supportedAtoms, atomCount, "_NET_WM_STATE_MAXIMIZED_VERT");
    _glfw.x11.NET_WM_STATE_MAXIMIZED_HORZ =
        getSupportedAtom(supportedAtoms, atomCount, "_NET_WM_STATE_MAXIMIZED_HORZ");
    _glfw.x11.NET_WM_STATE_DEMANDS_ATTENTION =
        getSupportedAtom(supportedAtoms, atomCount, "_NET_WM_STATE_DEMANDS_ATTENTION");
    _glfw.x11.NET_WM_FULLSCREEN_MONITORS =
        getSupportedAtom(supportedAtoms, atomCount, "_NET_WM_FULLSCREEN_MONITORS");
    _glfw.x11.NET_WM_WINDOW_TYPE =
        getSupportedAtom(supportedAtoms, atomCount, "_NET_WM_WINDOW_TYPE");
    _glfw.x11.NET_WM_WINDOW_TYPE_NORMAL =
        getSupportedAtom(supportedAtoms, atomCount, "_NET_WM_WINDOW_TYPE_NORMAL");
    _glfw.x11.NET_WORKAREA =
        getSupportedAtom(supportedAtoms, atomCount, "_NET_WORKAREA");
    _glfw.x11.NET_CURRENT_DESKTOP =
        getSupportedAtom(supportedAtoms, atomCount, "_NET_CURRENT_DESKTOP");
    _glfw.x11.NET_ACTIVE_WINDOW =
        getSupportedAtom(supportedAtoms, atomCount, "_NET_ACTIVE_WINDOW");
    _glfw.x11.NET_FRAME_EXTENTS =
        getSupportedAtom(supportedAtoms, atomCount, "_NET_FRAME_EXTENTS");
    _glfw.x11.NET_REQUEST_FRAME_EXTENTS =
        getSupportedAtom(supportedAtoms, atomCount, "_NET_REQUEST_FRAME_EXTENTS");

    if (supportedAtoms)
        XFree(supportedAtoms);
}

// Look for and initialize supported X11 extensions
//
private GLFWbool initExtensions() {
    _glfw.x11.vidmode.handle = _glfw_dlopen("libXxf86vm.so.1");
    if (_glfw.x11.vidmode.handle)
    {
        _glfw.x11.vidmode.QueryExtension = cast(PFN_XF86VidModeQueryExtension)
            _glfw_dlsym(_glfw.x11.vidmode.handle, "XF86VidModeQueryExtension");
        _glfw.x11.vidmode.GetGammaRamp = cast(PFN_XF86VidModeGetGammaRamp)
            _glfw_dlsym(_glfw.x11.vidmode.handle, "XF86VidModeGetGammaRamp");
        _glfw.x11.vidmode.SetGammaRamp = cast(PFN_XF86VidModeSetGammaRamp)
            _glfw_dlsym(_glfw.x11.vidmode.handle, "XF86VidModeSetGammaRamp");
        _glfw.x11.vidmode.GetGammaRampSize = cast(PFN_XF86VidModeGetGammaRampSize)
            _glfw_dlsym(_glfw.x11.vidmode.handle, "XF86VidModeGetGammaRampSize");

        _glfw.x11.vidmode.available =
            _glfw.x11.vidmode.QueryExtension(_glfw.x11.display,
                                      &_glfw.x11.vidmode.eventBase,
                                      &_glfw.x11.vidmode.errorBase);
    }

version(Cygwin) {
    _glfw.x11.xi.handle = _glfw_dlopen("libXi-6.so");
} else {
    _glfw.x11.xi.handle = _glfw_dlopen("libXi.so.6");
}
    if (_glfw.x11.xi.handle)
    {
        _glfw.x11.xi.QueryVersion = cast(PFN_XIQueryVersion)
            _glfw_dlsym(_glfw.x11.xi.handle, "XIQueryVersion");
        _glfw.x11.xi.SelectEvents = cast(PFN_XISelectEvents)
            _glfw_dlsym(_glfw.x11.xi.handle, "XISelectEvents");

        if (XQueryExtension(_glfw.x11.display,
                            "XInputExtension".ptr,
                            &_glfw.x11.xi.majorOpcode,
                            &_glfw.x11.xi.eventBase,
                            &_glfw.x11.xi.errorBase))
        {
            _glfw.x11.xi.major = 2;
            _glfw.x11.xi.minor = 0;

            if (_glfw.x11.xi.QueryVersion(_glfw.x11.display,
                               &_glfw.x11.xi.major,
                               &_glfw.x11.xi.minor) == XErrorCode.Success)
            {
                _glfw.x11.xi.available = GLFW_TRUE;
            }
        }
    }

version(Cygwin) {
    _glfw.x11.randr.handle = _glfw_dlopen("libXrandr-2.so");
} else {
    _glfw.x11.randr.handle = _glfw_dlopen("libXrandr.so.2");
}
    if (_glfw.x11.randr.handle)
    {
        _glfw.x11.randr.AllocGamma = cast(PFN_XRRAllocGamma)
            _glfw_dlsym(_glfw.x11.randr.handle, "XRRAllocGamma");
        _glfw.x11.randr.FreeGamma = cast(PFN_XRRFreeGamma)
            _glfw_dlsym(_glfw.x11.randr.handle, "XRRFreeGamma");
        _glfw.x11.randr.FreeCrtcInfo = cast(PFN_XRRFreeCrtcInfo)
            _glfw_dlsym(_glfw.x11.randr.handle, "XRRFreeCrtcInfo");
        _glfw.x11.randr.FreeGamma = cast(PFN_XRRFreeGamma)
            _glfw_dlsym(_glfw.x11.randr.handle, "XRRFreeGamma");
        _glfw.x11.randr.FreeOutputInfo = cast(PFN_XRRFreeOutputInfo)
            _glfw_dlsym(_glfw.x11.randr.handle, "XRRFreeOutputInfo");
        _glfw.x11.randr.FreeScreenResources = cast(PFN_XRRFreeScreenResources)
            _glfw_dlsym(_glfw.x11.randr.handle, "XRRFreeScreenResources");
        _glfw.x11.randr.GetCrtcGamma = cast(PFN_XRRGetCrtcGamma)
            _glfw_dlsym(_glfw.x11.randr.handle, "XRRGetCrtcGamma");
        _glfw.x11.randr.GetCrtcGammaSize = cast(PFN_XRRGetCrtcGammaSize)
            _glfw_dlsym(_glfw.x11.randr.handle, "XRRGetCrtcGammaSize");
        _glfw.x11.randr.GetCrtcInfo = cast(PFN_XRRGetCrtcInfo)
            _glfw_dlsym(_glfw.x11.randr.handle, "XRRGetCrtcInfo");
        _glfw.x11.randr.GetOutputInfo = cast(PFN_XRRGetOutputInfo)
            _glfw_dlsym(_glfw.x11.randr.handle, "XRRGetOutputInfo");
        _glfw.x11.randr.GetOutputPrimary = cast(PFN_XRRGetOutputPrimary)
            _glfw_dlsym(_glfw.x11.randr.handle, "XRRGetOutputPrimary");
        _glfw.x11.randr.GetScreenResourcesCurrent = cast(PFN_XRRGetScreenResourcesCurrent)
            _glfw_dlsym(_glfw.x11.randr.handle, "XRRGetScreenResourcesCurrent");
        _glfw.x11.randr.QueryExtension = cast(PFN_XRRQueryExtension)
            _glfw_dlsym(_glfw.x11.randr.handle, "XRRQueryExtension");
        _glfw.x11.randr.QueryVersion = cast(PFN_XRRQueryVersion)
            _glfw_dlsym(_glfw.x11.randr.handle, "XRRQueryVersion");
        _glfw.x11.randr.SelectInput = cast(PFN_XRRSelectInput)
            _glfw_dlsym(_glfw.x11.randr.handle, "XRRSelectInput");
        _glfw.x11.randr.SetCrtcConfig = cast(PFN_XRRSetCrtcConfig)
            _glfw_dlsym(_glfw.x11.randr.handle, "XRRSetCrtcConfig");
        _glfw.x11.randr.SetCrtcGamma = cast(PFN_XRRSetCrtcGamma)
            _glfw_dlsym(_glfw.x11.randr.handle, "XRRSetCrtcGamma");
        _glfw.x11.randr.UpdateConfiguration = cast(PFN_XRRUpdateConfiguration)
            _glfw_dlsym(_glfw.x11.randr.handle, "XRRUpdateConfiguration");

        if (_glfw.x11.randr.QueryExtension(_glfw.x11.display,
                              &_glfw.x11.randr.eventBase,
                              &_glfw.x11.randr.errorBase))
        {
            if (_glfw.x11.randr.QueryVersion(_glfw.x11.display,
                                &_glfw.x11.randr.major,
                                &_glfw.x11.randr.minor))
            {
                // The GLFW RandR path requires at least version 1.3
                if (_glfw.x11.randr.major > 1 || _glfw.x11.randr.minor >= 3)
                    _glfw.x11.randr.available = GLFW_TRUE;
            }
            else
            {
                _glfwInputError(GLFW_PLATFORM_ERROR,
                                "X11: Failed to query RandR version");
            }
        }
    }

    if (_glfw.x11.randr.available)
    {
        XRRScreenResources* sr = _glfw.x11.randr.GetScreenResourcesCurrent(_glfw.x11.display,
                                                              _glfw.x11.root);

        if (!sr.ncrtc || !_glfw.x11.randr.GetCrtcGammaSize(_glfw.x11.display, sr.crtcs[0]))
        {
            // This is likely an older Nvidia driver with broken gamma support
            // Flag it as useless and fall back to xf86vm gamma, if available
            _glfw.x11.randr.gammaBroken = GLFW_TRUE;
        }

        if (!sr.ncrtc)
        {
            // A system without CRTCs is likely a system with broken RandR
            // Disable the RandR monitor path and fall back to core functions
            _glfw.x11.randr.monitorBroken = GLFW_TRUE;
        }

        _glfw.x11.randr.FreeScreenResources(sr);
    }

    if (_glfw.x11.randr.available && !_glfw.x11.randr.monitorBroken)
    {
        _glfw.x11.randr.SelectInput(_glfw.x11.display, _glfw.x11.root,
                       RROutputChangeNotifyMask);
    }

version(Cygwin) {
    _glfw.x11.xcursor.handle = _glfw_dlopen("libXcursor-1.so");
} else {
    _glfw.x11.xcursor.handle = _glfw_dlopen("libXcursor.so.1");
}
    if (_glfw.x11.xcursor.handle)
    {
        _glfw.x11.xcursor.ImageCreate = cast(PFN_XcursorImageCreate)
            _glfw_dlsym(_glfw.x11.xcursor.handle, "XcursorImageCreate");
        _glfw.x11.xcursor.ImageDestroy = cast(PFN_XcursorImageDestroy)
            _glfw_dlsym(_glfw.x11.xcursor.handle, "XcursorImageDestroy");
        _glfw.x11.xcursor.ImageLoadCursor = cast(PFN_XcursorImageLoadCursor)
            _glfw_dlsym(_glfw.x11.xcursor.handle, "XcursorImageLoadCursor");
    }

version(Cygwin) {
    _glfw.x11.xinerama.handle = _glfw_dlopen("libXinerama-1.so");
} else {
    _glfw.x11.xinerama.handle = _glfw_dlopen("libXinerama.so.1");
}
    if (_glfw.x11.xinerama.handle)
    {
        _glfw.x11.xinerama.IsActive = cast(PFN_XineramaIsActive)
            _glfw_dlsym(_glfw.x11.xinerama.handle, "XineramaIsActive");
        _glfw.x11.xinerama.QueryExtension = cast(PFN_XineramaQueryExtension)
            _glfw_dlsym(_glfw.x11.xinerama.handle, "XineramaQueryExtension");
        _glfw.x11.xinerama.QueryScreens = cast(PFN_XineramaQueryScreens)
            _glfw_dlsym(_glfw.x11.xinerama.handle, "XineramaQueryScreens");

        if (_glfw.x11.xinerama.QueryExtension(_glfw.x11.display,
                                   &_glfw.x11.xinerama.major,
                                   &_glfw.x11.xinerama.minor))
        {
            if (_glfw.x11.xinerama.IsActive(_glfw.x11.display))
                _glfw.x11.xinerama.available = GLFW_TRUE;
        }
    }

    _glfw.x11.xkb.major = 1;
    _glfw.x11.xkb.minor = 0;
    _glfw.x11.xkb.available =
        XkbQueryExtension(_glfw.x11.display,
                          &_glfw.x11.xkb.majorOpcode,
                          &_glfw.x11.xkb.eventBase,
                          &_glfw.x11.xkb.errorBase,
                          &_glfw.x11.xkb.major,
                          &_glfw.x11.xkb.minor);

    if (_glfw.x11.xkb.available)
    {
        Bool supported;

        if (XkbSetDetectableAutoRepeat(_glfw.x11.display, True, &supported))
        {
            if (supported)
                _glfw.x11.xkb.detectable = GLFW_TRUE;
        }

        _glfw.x11.xkb.group = 0;
        XkbStateRec state;
        if (XkbGetState(_glfw.x11.display, XkbUseCoreKbd, &state) == XErrorCode.Success)
        {
            XkbSelectEventDetails(_glfw.x11.display, XkbUseCoreKbd, XkbStateNotify, XkbAllStateComponentsMask, XkbGroupStateMask);
            _glfw.x11.xkb.group = cast(uint)state.group;
        }
    }

version(Cygwin) {
    _glfw.x11.x11xcb.handle = _glfw_dlopen("libX11-xcb-1.so");
} else {
    _glfw.x11.x11xcb.handle = _glfw_dlopen("libX11-xcb.so.1");
}
    if (_glfw.x11.x11xcb.handle)
    {
        _glfw.x11.x11xcb.GetXCBConnection = cast(PFN_XGetXCBConnection)
            _glfw_dlsym(_glfw.x11.x11xcb.handle, "XGetXCBConnection");
    }

version(Cygwin) {
    _glfw.x11.xrender.handle = _glfw_dlopen("libXrender-1.so");
} else {
    _glfw.x11.xrender.handle = _glfw_dlopen("libXrender.so.1");
}
    if (_glfw.x11.xrender.handle)
    {
        _glfw.x11.xrender.QueryExtension = cast(PFN_XRenderQueryExtension)
            _glfw_dlsym(_glfw.x11.xrender.handle, "XRenderQueryExtension");
        _glfw.x11.xrender.QueryVersion = cast(PFN_XRenderQueryVersion)
            _glfw_dlsym(_glfw.x11.xrender.handle, "XRenderQueryVersion");
        _glfw.x11.xrender.FindVisualFormat = cast(PFN_XRenderFindVisualFormat)
            _glfw_dlsym(_glfw.x11.xrender.handle, "XRenderFindVisualFormat");

        if (_glfw.x11.xrender.QueryExtension(_glfw.x11.display,
                                  &_glfw.x11.xrender.errorBase,
                                  &_glfw.x11.xrender.eventBase))
        {
            if (_glfw.x11.xrender.QueryVersion(_glfw.x11.display,
                                    &_glfw.x11.xrender.major,
                                    &_glfw.x11.xrender.minor))
            {
                _glfw.x11.xrender.available = GLFW_TRUE;
            }
        }
    }

    // Update the key code LUT
    // FIXME: We should listen to XkbMapNotify events to track changes to
    // the keyboard mapping.
    createKeyTables();

    // String format atoms
    _glfw.x11.NULL_ = XInternAtom(_glfw.x11.display, "NULL", False);
    _glfw.x11.UTF8_STRING = XInternAtom(_glfw.x11.display, "UTF8_STRING", False);
    _glfw.x11.ATOM_PAIR = XInternAtom(_glfw.x11.display, "ATOM_PAIR", False);

    // Custom selection property atom
    _glfw.x11.GLFW_SELECTION =
        XInternAtom(_glfw.x11.display, "GLFW_SELECTION", False);

    // ICCCM standard clipboard atoms
    _glfw.x11.TARGETS = XInternAtom(_glfw.x11.display, "TARGETS", False);
    _glfw.x11.MULTIPLE = XInternAtom(_glfw.x11.display, "MULTIPLE", False);
    _glfw.x11.PRIMARY = XInternAtom(_glfw.x11.display, "PRIMARY", False);
    _glfw.x11.INCR = XInternAtom(_glfw.x11.display, "INCR", False);
    _glfw.x11.CLIPBOARD = XInternAtom(_glfw.x11.display, "CLIPBOARD", False);

    // Clipboard manager atoms
    _glfw.x11.CLIPBOARD_MANAGER =
        XInternAtom(_glfw.x11.display, "CLIPBOARD_MANAGER", False);
    _glfw.x11.SAVE_TARGETS =
        XInternAtom(_glfw.x11.display, "SAVE_TARGETS", False);

    // Xdnd (drag and drop) atoms
    _glfw.x11.XdndAware = XInternAtom(_glfw.x11.display, "XdndAware", False);
    _glfw.x11.XdndEnter = XInternAtom(_glfw.x11.display, "XdndEnter", False);
    _glfw.x11.XdndPosition = XInternAtom(_glfw.x11.display, "XdndPosition", False);
    _glfw.x11.XdndStatus = XInternAtom(_glfw.x11.display, "XdndStatus", False);
    _glfw.x11.XdndActionCopy = XInternAtom(_glfw.x11.display, "XdndActionCopy", False);
    _glfw.x11.XdndDrop = XInternAtom(_glfw.x11.display, "XdndDrop", False);
    _glfw.x11.XdndFinished = XInternAtom(_glfw.x11.display, "XdndFinished", False);
    _glfw.x11.XdndSelection = XInternAtom(_glfw.x11.display, "XdndSelection", False);
    _glfw.x11.XdndTypeList = XInternAtom(_glfw.x11.display, "XdndTypeList", False);
    _glfw.x11.text_uri_list = XInternAtom(_glfw.x11.display, "text/uri-list", False);

    // ICCCM, EWMH and Motif window property atoms
    // These can be set safely even without WM support
    // The EWMH atoms that require WM support are handled in detectEWMH
    _glfw.x11.WM_PROTOCOLS =
        XInternAtom(_glfw.x11.display, "WM_PROTOCOLS", False);
    _glfw.x11.WM_STATE =
        XInternAtom(_glfw.x11.display, "WM_STATE", False);
    _glfw.x11.WM_DELETE_WINDOW =
        XInternAtom(_glfw.x11.display, "WM_DELETE_WINDOW", False);
    _glfw.x11.NET_SUPPORTED =
        XInternAtom(_glfw.x11.display, "_NET_SUPPORTED", False);
    _glfw.x11.NET_SUPPORTING_WM_CHECK =
        XInternAtom(_glfw.x11.display, "_NET_SUPPORTING_WM_CHECK", False);
    _glfw.x11.NET_WM_ICON =
        XInternAtom(_glfw.x11.display, "_NET_WM_ICON", False);
    _glfw.x11.NET_WM_PING =
        XInternAtom(_glfw.x11.display, "_NET_WM_PING", False);
    _glfw.x11.NET_WM_PID =
        XInternAtom(_glfw.x11.display, "_NET_WM_PID", False);
    _glfw.x11.NET_WM_NAME =
        XInternAtom(_glfw.x11.display, "_NET_WM_NAME", False);
    _glfw.x11.NET_WM_ICON_NAME =
        XInternAtom(_glfw.x11.display, "_NET_WM_ICON_NAME", False);
    _glfw.x11.NET_WM_BYPASS_COMPOSITOR =
        XInternAtom(_glfw.x11.display, "_NET_WM_BYPASS_COMPOSITOR", False);
    _glfw.x11.NET_WM_WINDOW_OPACITY =
        XInternAtom(_glfw.x11.display, "_NET_WM_WINDOW_OPACITY", False);
    _glfw.x11.MOTIF_WM_HINTS =
        XInternAtom(_glfw.x11.display, "_MOTIF_WM_HINTS", False);

    // The compositing manager selection name contains the screen number
    {
        char[32] name;
        snprintf(name.ptr, typeof(name).sizeof, "_NET_WM_CM_S%u", _glfw.x11.screen);
        _glfw.x11.NET_WM_CM_Sx = XInternAtom(_glfw.x11.display, name.ptr, False);
    }

    // Detect whether an EWMH-conformant window manager is running
    detectEWMH();

    return GLFW_TRUE;
}

// Retrieve system content scale via folklore heuristics
//
private extern(D) void getSystemContentScale(float* xscale, float* yscale) {
    // Start by assuming the default X11 DPI
    // NOTE: Some desktop environments (KDE) may remove the Xft.dpi field when it
    //       would be set to 96, so assume that is the case if we cannot find it
    float xdpi = 96.0f;float ydpi = 96.0f;

    // NOTE: Basing the scale on Xft.dpi where available should provide the most
    //       consistent user experience (matches Qt, Gtk, etc), although not
    //       always the most accurate one
    char* rms = XResourceManagerString(_glfw.x11.display);
    if (rms)
    {
        XrmDatabase db = XrmGetStringDatabase(rms);
        if (db)
        {
            XrmValue value;
            char* type = null;

            if (XrmGetResource(db, "Xft.dpi", "Xft.Dpi", &type, &value))
            {
                if (type && strcmp(type, "String") == 0)
                    xdpi = ydpi = atof(value.addr);
            }

            XrmDestroyDatabase(db);
        }
    }

    *xscale = xdpi / 96.0f;
    *yscale = ydpi / 96.0f;
}

// Create a blank cursor for hidden and disabled cursor modes
//
private Cursor createHiddenCursor() {
    ubyte[16 * 16 * 4] pixels = 0;
    GLFWimage image = GLFWimage(16, 16, pixels.ptr);
    return _glfwCreateCursorX11(&image, 0, 0);
}

// Create a helper window for IPC
//
private Window createHelperWindow() {
    XSetWindowAttributes wa;
    wa.event_mask = PropertyChangeMask;

    return XCreateWindow(_glfw.x11.display, _glfw.x11.root,
                         0, 0, 1, 1, 0, 0,
                         InputOnly,
                         DefaultVisual(_glfw.x11.display, _glfw.x11.screen),
                         CWEventMask, &wa);
}

// X error handler
//
private int errorHandler(Display* display, XErrorEvent* event) {
    _glfw.x11.errorCode = event.error_code;
    return 0;
}


//////////////////////////////////////////////////////////////////////////
//////                       GLFW internal API                      //////
//////////////////////////////////////////////////////////////////////////

// Sets the X error handler callback
//
void _glfwGrabErrorHandlerX11() {
    _glfw.x11.errorCode = XErrorCode.Success;
    XSetErrorHandler(&errorHandler);
}

// Clears the X error handler callback
//
void _glfwReleaseErrorHandlerX11() {
    // Synchronize to make sure all commands are processed
    XSync(_glfw.x11.display, False);
    XSetErrorHandler(null);
}

// Reports the specified error, appending information about the last X error
//
void _glfwInputErrorX11(int error, const(char)* message) {
    char[_GLFW_MESSAGE_SIZE] buffer;
    XGetErrorText(_glfw.x11.display, _glfw.x11.errorCode,
                  buffer.ptr, typeof(buffer).sizeof);

    _glfwInputError(error, "%s: %s", message, buffer.ptr);
}

// Creates a native cursor object from the specified image and hotspot
//
Cursor _glfwCreateCursorX11(const(GLFWimage)* image, int xhot, int yhot) {
    int i;
    Cursor cursor;

    if (!_glfw.x11.xcursor.handle)
        return None;

    XcursorImage* native = _glfw.x11.xcursor.ImageCreate(image.width, image.height);
    if (native == null)
        return None;

    native.xhot = xhot;
    native.yhot = yhot;

    ubyte* source = cast(ubyte*) image.pixels;
    XcursorPixel* target = native.pixels;

    for (i = 0;  i < image.width * image.height;  i++, target++, source += 4)
    {
        uint alpha = source[3];

        *target = (alpha << 24) |
                  (cast(ubyte) ((source[0] * alpha) / 255) << 16) |
                  (cast(ubyte) ((source[1] * alpha) / 255) <<  8) |
                  (cast(ubyte) ((source[2] * alpha) / 255) <<  0);
    }

    cursor = _glfw.x11.xcursor.ImageLoadCursor(_glfw.x11.display, native);
    _glfw.x11.xcursor.ImageDestroy(native);

    return cursor;
}


//////////////////////////////////////////////////////////////////////////
//////                       GLFW platform API                      //////
//////////////////////////////////////////////////////////////////////////

int _glfwPlatformInit() {
version(X_HAVE_UTF8_STRING) {} else {
    // HACK: If the current locale is "C" and the Xlib UTF-8 functions are
    //       unavailable, apply the environment's locale in the hope that it's
    //       both available and not "C"
    //       This is done because the "C" locale breaks wide character input,
    //       which is what we fall back on when UTF-8 support is missing
    if (strcmp(setlocale(LC_CTYPE, null), "C") == 0)
        setlocale(LC_CTYPE, "");
}

    XInitThreads();
    XrmInitialize();

    _glfw.x11.display = XOpenDisplay(null);
    if (!_glfw.x11.display)
    {
        const(char)* display = getenv("DISPLAY");
        if (display)
        {
            _glfwInputError(GLFW_PLATFORM_ERROR,
                            "X11: Failed to open display %s", display);
        }
        else
        {
            _glfwInputError(GLFW_PLATFORM_ERROR,
                            "X11: The DISPLAY environment variable is missing");
        }

        return GLFW_FALSE;
    }

    _glfw.x11.screen = DefaultScreen(_glfw.x11.display);
    _glfw.x11.root = RootWindow(_glfw.x11.display, _glfw.x11.screen);
    _glfw.x11.context = XUniqueContext();

    getSystemContentScale(&_glfw.x11.contentScaleX, &_glfw.x11.contentScaleY);

    if (!initExtensions())
        return GLFW_FALSE;

    _glfw.x11.helperWindowHandle = createHelperWindow();
    _glfw.x11.hiddenCursorHandle = createHiddenCursor();

    if (XSupportsLocale())
    {
        XSetLocaleModifiers("");

        _glfw.x11.im = XOpenIM(_glfw.x11.display, null, null, null);
        if (_glfw.x11.im)
        {
            if (!hasUsableInputMethodStyle())
            {
                XCloseIM(_glfw.x11.im);
                _glfw.x11.im = null;
            }
        }
    }

    version(linux) {
        if (!_glfwInitJoysticksLinux())
            return GLFW_FALSE;
    }

    _glfwInitTimerPOSIX();

    _glfwPollMonitorsX11();
    return GLFW_TRUE;
}

void _glfwPlatformTerminate() {
    if (_glfw.x11.helperWindowHandle)
    {
        if (XGetSelectionOwner(_glfw.x11.display, _glfw.x11.CLIPBOARD) ==
            _glfw.x11.helperWindowHandle)
        {
            _glfwPushSelectionToManagerX11();
        }

        XDestroyWindow(_glfw.x11.display, _glfw.x11.helperWindowHandle);
        _glfw.x11.helperWindowHandle = None;
    }

    if (_glfw.x11.hiddenCursorHandle)
    {
        XFreeCursor(_glfw.x11.display, _glfw.x11.hiddenCursorHandle);
        _glfw.x11.hiddenCursorHandle = cast(Cursor) 0;
    }

    free(_glfw.x11.primarySelectionString);
    free(_glfw.x11.clipboardString);

    if (_glfw.x11.im)
    {
        XCloseIM(_glfw.x11.im);
        _glfw.x11.im = null;
    }

    if (_glfw.x11.display)
    {
        XCloseDisplay(_glfw.x11.display);
        _glfw.x11.display = null;
    }

    if (_glfw.x11.x11xcb.handle)
    {
        _glfw_dlclose(_glfw.x11.x11xcb.handle);
        _glfw.x11.x11xcb.handle = null;
    }

    if (_glfw.x11.xcursor.handle)
    {
        _glfw_dlclose(_glfw.x11.xcursor.handle);
        _glfw.x11.xcursor.handle = null;
    }

    if (_glfw.x11.randr.handle)
    {
        _glfw_dlclose(_glfw.x11.randr.handle);
        _glfw.x11.randr.handle = null;
    }

    if (_glfw.x11.xinerama.handle)
    {
        _glfw_dlclose(_glfw.x11.xinerama.handle);
        _glfw.x11.xinerama.handle = null;
    }

    if (_glfw.x11.xrender.handle)
    {
        _glfw_dlclose(_glfw.x11.xrender.handle);
        _glfw.x11.xrender.handle = null;
    }

    if (_glfw.x11.vidmode.handle)
    {
        _glfw_dlclose(_glfw.x11.vidmode.handle);
        _glfw.x11.vidmode.handle = null;
    }

    if (_glfw.x11.xi.handle)
    {
        _glfw_dlclose(_glfw.x11.xi.handle);
        _glfw.x11.xi.handle = null;
    }

    // NOTE: These need to be unloaded after XCloseDisplay, as they register
    //       cleanup callbacks that get called by that function
    _glfwTerminateEGL();
    _glfwTerminateGLX();

    version(linux) {
        _glfwTerminateJoysticksLinux();
    }
}

const(char)* _glfwPlatformGetVersionString() {
    version(linux) {
        enum evdev = " evdev";
    } else {
        enum evdev = "";
    }
    version(_GLFW_BUILD_DLL) {
        enum dllStr = " shared";
    } else {
        enum dllStr = "";
    }
    return _GLFW_VERSION_NUMBER ~ " X11 GLX EGL OSMesa" ~ evdev ~ dllStr;
}
