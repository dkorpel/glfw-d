/// Translated from C to D
module glfw3.win32_window;

version(Windows):
extern(C): __gshared:

//========================================================================
// GLFW 3.3 Win32 - www.glfw.org
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

import glfw3.win32_platform: IsWindowsVistaOrGreater, IsWindowsXPOrGreater, IsWindows7OrGreater;

import core.stdc.limits;
import core.stdc.stdlib;
import core.stdc.string;
import core.sys.windows.windows;
package:

// Returns the window style for the specified window
//
private DWORD getWindowStyle(const(_GLFWwindow)* window) {
    DWORD style = WS_CLIPSIBLINGS | WS_CLIPCHILDREN;

    if (window.monitor)
        style |= WS_POPUP;
    else
    {
        style |= WS_SYSMENU | WS_MINIMIZEBOX;

        if (window.decorated)
        {
            style |= WS_CAPTION;

            if (window.resizable)
                style |= WS_MAXIMIZEBOX | WS_THICKFRAME;
        }
        else
            style |= WS_POPUP;
    }

    return style;
}

// Returns the extended window style for the specified window
//
private DWORD getWindowExStyle(const(_GLFWwindow)* window) {
    DWORD style = WS_EX_APPWINDOW;

    if (window.monitor || window.floating)
        style |= WS_EX_TOPMOST;

    return style;
}

// Returns the image whose area most closely matches the desired one
//
private const(GLFWimage)* chooseImage(int count, const(GLFWimage)* images, int width, int height) {
    int i;int leastDiff = INT_MAX;
    const(GLFWimage)* closest = null;

    for (i = 0;  i < count;  i++)
    {
        const(int) currDiff = abs(images[i].width * images[i].height -
                                 width * height);
        if (currDiff < leastDiff)
        {
            closest = images + i;
            leastDiff = currDiff;
        }
    }

    return closest;
}

// Creates an RGBA icon or cursor
//
private HICON createIcon(const(GLFWimage)* image, int xhot, int yhot, GLFWbool icon) {
    int i;
    HDC dc;
    HICON handle;
    HBITMAP color;HBITMAP mask;
    BITMAPV5HEADER bi;
    ICONINFO ii;
    ubyte* target = null;
    const(ubyte)* source = image.pixels;

    memset(&bi, 0, typeof(bi).sizeof);
    bi.bV5Size        = typeof(bi).sizeof;
    bi.bV5Width       = image.width;
    bi.bV5Height      = -image.height;
    bi.bV5Planes      = 1;
    bi.bV5BitCount    = 32;
    bi.bV5Compression = BI_BITFIELDS;
    bi.bV5RedMask     = 0x00ff0000;
    bi.bV5GreenMask   = 0x0000ff00;
    bi.bV5BlueMask    = 0x000000ff;
    bi.bV5AlphaMask   = 0xff000000;

    dc = GetDC(null);
    color = CreateDIBSection(dc,
                             cast(BITMAPINFO*) &bi,
                             DIB_RGB_COLORS,
                             cast(void**) &target,
                             null,
                             cast(DWORD) 0);
    ReleaseDC(null, dc);

    if (!color)
    {
        _glfwInputErrorWin32(GLFW_PLATFORM_ERROR,
                             "Win32: Failed to create RGBA bitmap");
        return null;
    }

    mask = CreateBitmap(image.width, image.height, 1, 1, null);
    if (!mask)
    {
        _glfwInputErrorWin32(GLFW_PLATFORM_ERROR,
                             "Win32: Failed to create mask bitmap");
        DeleteObject(color);
        return null;
    }

    for (i = 0;  i < image.width * image.height;  i++)
    {
        target[0] = source[2];
        target[1] = source[1];
        target[2] = source[0];
        target[3] = source[3];
        target += 4;
        source += 4;
    }

    memset(&ii, 0, typeof(ii).sizeof);
    ii.fIcon    = icon;
    ii.xHotspot = xhot;
    ii.yHotspot = yhot;
    ii.hbmMask  = mask;
    ii.hbmColor = color;

    handle = CreateIconIndirect(&ii);

    DeleteObject(color);
    DeleteObject(mask);

    if (!handle)
    {
        if (icon)
        {
            _glfwInputErrorWin32(GLFW_PLATFORM_ERROR,
                                 "Win32: Failed to create icon");
        }
        else
        {
            _glfwInputErrorWin32(GLFW_PLATFORM_ERROR,
                                 "Win32: Failed to create cursor");
        }
    }

    return handle;
}

// Translate content area size to full window size according to styles and DPI
//
private extern(D) void getFullWindowSize(DWORD style, DWORD exStyle, int contentWidth, int contentHeight, int* fullWidth, int* fullHeight, UINT dpi) {
    RECT rect = RECT(0, 0, contentWidth, contentHeight);

    if (_glfwIsWindows10AnniversaryUpdateOrGreaterWin32())
        mixin(AdjustWindowRectExForDpi)(&rect, style, FALSE, exStyle, dpi);
    else
        /*DynCall*/AdjustWindowRectEx(&rect, style, FALSE, exStyle);

    *fullWidth = rect.right - rect.left;
    *fullHeight = rect.bottom - rect.top;
}
// Enforce the content area aspect ratio based on which edge is being dragged
//
private extern(D) void applyAspectRatio(_GLFWwindow* window, int edge, RECT* area) {
    int xoff;int yoff;
    UINT dpi = USER_DEFAULT_SCREEN_DPI;
    const(float) ratio = cast(float) window.numer / cast(float) window.denom;

    if (_glfwIsWindows10AnniversaryUpdateOrGreaterWin32())
        dpi = mixin(GetDpiForWindow)(window.win32.handle);

    getFullWindowSize(getWindowStyle(window), getWindowExStyle(window),
                      0, 0, &xoff, &yoff, dpi);

    if (edge == WMSZ_LEFT  || edge == WMSZ_BOTTOMLEFT ||
        edge == WMSZ_RIGHT || edge == WMSZ_BOTTOMRIGHT)
    {
        area.bottom = area.top + yoff +
            cast(int) ((area.right - area.left - xoff) / ratio);
    }
    else if (edge == WMSZ_TOPLEFT || edge == WMSZ_TOPRIGHT)
    {
        area.top = area.bottom - yoff -
            cast(int) ((area.right - area.left - xoff) / ratio);
    }
    else if (edge == WMSZ_TOP || edge == WMSZ_BOTTOM)
    {
        area.right = area.left + xoff +
            cast(int) ((area.bottom - area.top - yoff) * ratio);
    }
}

// Updates the cursor image according to its cursor mode
//
private extern(D) void updateCursorImage(_GLFWwindow* window) {
    if (window.cursorMode == GLFW_CURSOR_NORMAL)
    {
        if (window.cursor)
            SetCursor(window.cursor.win32.handle);
        else
            SetCursor(LoadCursorW(null, IDC_ARROW));
    }
    else
        SetCursor(null);
}

// Updates the cursor clip rect
//
private extern(D) void updateClipRect(_GLFWwindow* window) {
    if (window)
    {
        RECT clipRect;
        GetClientRect(cast(void*) window.win32.handle, &clipRect);
        ClientToScreen(cast(void*) window.win32.handle, cast(POINT*) &clipRect.left);
        ClientToScreen(cast(void*) window.win32.handle, cast(POINT*) &clipRect.right);
        ClipCursor(&clipRect);
    }
    else
        ClipCursor(null);
}

// Enables WM_INPUT messages for the mouse for the specified window
//
private extern(D) void enableRawMouseMotion(_GLFWwindow* window) {
    const(RAWINPUTDEVICE) rid = RAWINPUTDEVICE( 0x01, 0x02, 0, cast(void*) window.win32.handle );

    if (!RegisterRawInputDevices(&rid, 1, typeof(rid).sizeof))
    {
        _glfwInputErrorWin32(GLFW_PLATFORM_ERROR,
                             "Win32: Failed to register raw input device");
    }
}

// Disables WM_INPUT messages for the mouse
//
private extern(D) void disableRawMouseMotion(_GLFWwindow* window) {
    const RAWINPUTDEVICE rid = RAWINPUTDEVICE(0x01, 0x02, RIDEV_REMOVE, null);

    if (!RegisterRawInputDevices(&rid, 1, typeof(rid).sizeof))
    {
        _glfwInputErrorWin32(GLFW_PLATFORM_ERROR,
                             "Win32: Failed to remove raw input device");
    }
}

// Apply disabled cursor mode to a focused window
//
private extern(D) void disableCursor(_GLFWwindow* window) {
    _glfw.win32.disabledCursorWindow = window;
    _glfwPlatformGetCursorPos(window,
                              &_glfw.win32.restoreCursorPosX,
                              &_glfw.win32.restoreCursorPosY);
    updateCursorImage(window);
    _glfwCenterCursorInContentArea(window);
    updateClipRect(window);

    if (window.rawMouseMotion)
        enableRawMouseMotion(window);
}

// Exit disabled cursor mode for the specified window
//
private extern(D) void enableCursor(_GLFWwindow* window) {
    if (window.rawMouseMotion)
        disableRawMouseMotion(window);

    _glfw.win32.disabledCursorWindow = null;
    updateClipRect(null);
    _glfwPlatformSetCursorPos(window,
                              _glfw.win32.restoreCursorPosX,
                              _glfw.win32.restoreCursorPosY);
    updateCursorImage(window);
}

// Returns whether the cursor is in the content area of the specified window
//
private GLFWbool cursorInContentArea(_GLFWwindow* window) {
    RECT area;
    POINT pos;

    if (!GetCursorPos(&pos))
        return GLFW_FALSE;

    if (WindowFromPoint(pos) != window.win32.handle)
        return GLFW_FALSE;

    GetClientRect(cast(void*) window.win32.handle, &area);
    ClientToScreen(cast(void*) window.win32.handle, cast(POINT*) &area.left);
    ClientToScreen(cast(void*) window.win32.handle, cast(POINT*) &area.right);

    return PtInRect(&area, pos);
}

// Update native window styles to match attributes
//
private extern(D) void updateWindowStyles(const(_GLFWwindow)* window) {
    RECT rect;
    DWORD style = GetWindowLongW(cast(void*) window.win32.handle, GWL_STYLE);
    style &= ~(WS_OVERLAPPEDWINDOW | WS_POPUP);
    style |= getWindowStyle(window);

    GetClientRect(cast(void*) window.win32.handle, &rect);

    if (_glfwIsWindows10AnniversaryUpdateOrGreaterWin32())
    {
        mixin(AdjustWindowRectExForDpi)(&rect, style, FALSE,
                                 getWindowExStyle(window),
                                 mixin(GetDpiForWindow)(cast(void*) window.win32.handle));
    }
    else
        AdjustWindowRectEx(&rect, style, FALSE, getWindowExStyle(window));

    ClientToScreen(cast(void*) window.win32.handle, cast(POINT*) &rect.left);
    ClientToScreen(cast(void*) window.win32.handle, cast(POINT*) &rect.right);
    SetWindowLongW(cast(void*) window.win32.handle, GWL_STYLE, style);
    SetWindowPos(cast(void*) window.win32.handle, HWND_TOP,
                 rect.left, rect.top,
                 rect.right - rect.left, rect.bottom - rect.top,
                 SWP_FRAMECHANGED | SWP_NOACTIVATE | SWP_NOZORDER);
}

// Update window framebuffer transparency
//
private extern(D) void updateFramebufferTransparency(const(_GLFWwindow)* window) {
    BOOL enabled;

    if (!IsWindowsVistaOrGreater())
        return;

    if (SUCCEEDED(_glfw.win32.dwmapi.IsCompositionEnabled(&enabled)) && enabled)
    {
        HRGN region = CreateRectRgn(0, 0, -1, -1);
        DWM_BLURBEHIND bb = DWM_BLURBEHIND(0);
        bb.dwFlags = DWM_BB_ENABLE | DWM_BB_BLURREGION;
        bb.hRgnBlur = region;
        bb.fEnable = TRUE;

        if (SUCCEEDED(_glfw.win32.dwmapi.EnableBlurBehindWindow(cast(void*) window.win32.handle, &bb)))
        {
            // Decorated windows don't repaint the transparent background
            // leaving a trail behind animations
            // HACK: Making the window layered with a transparency color key
            //       seems to fix this.  Normally, when specifying
            //       a transparency color key to be used when composing the
            //       layered window, all pixels painted by the window in this
            //       color will be transparent.  That doesn't seem to be the
            //       case anymore, at least when used with blur behind window
            //       plus negative region.
            LONG exStyle = GetWindowLongW(cast(void*) window.win32.handle, GWL_EXSTYLE);
            exStyle |= WS_EX_LAYERED;
            SetWindowLongW(cast(void*) window.win32.handle, GWL_EXSTYLE, exStyle);

            // Using a color key not equal to black to fix the trailing
            // issue.  When set to black, something is making the hit test
            // not resize with the window frame.
            SetLayeredWindowAttributes(cast(void*) window.win32.handle,
                                       RGB(255, 0, 255), 255, LWA_COLORKEY);
        }

        DeleteObject(region);
    }
    else
    {
        LONG exStyle = GetWindowLongW(cast(void*) window.win32.handle, GWL_EXSTYLE);
        exStyle &= ~WS_EX_LAYERED;
        SetWindowLongW(cast(void*) window.win32.handle, GWL_EXSTYLE, exStyle);
        RedrawWindow(cast(void*) window.win32.handle, null, null,
                     RDW_ERASE | RDW_INVALIDATE | RDW_FRAME);
    }
}

// Retrieves and translates modifier keys
//
private int getKeyMods() {
    int mods = 0;

    if (GetKeyState(VK_SHIFT) & 0x8000)
        mods |= GLFW_MOD_SHIFT;
    if (GetKeyState(VK_CONTROL) & 0x8000)
        mods |= GLFW_MOD_CONTROL;
    if (GetKeyState(VK_MENU) & 0x8000)
        mods |= GLFW_MOD_ALT;
    if ((GetKeyState(VK_LWIN) | GetKeyState(VK_RWIN)) & 0x8000)
        mods |= GLFW_MOD_SUPER;
    if (GetKeyState(VK_CAPITAL) & 1)
        mods |= GLFW_MOD_CAPS_LOCK;
    if (GetKeyState(VK_NUMLOCK) & 1)
        mods |= GLFW_MOD_NUM_LOCK;

    return mods;
}

private extern(D) void fitToMonitor(_GLFWwindow* window) {
    MONITORINFO mi = MONITORINFO(MONITORINFO.sizeof);
    GetMonitorInfo(window.monitor.win32.handle, &mi);
    SetWindowPos(cast(void*) window.win32.handle, HWND_TOPMOST,
                 mi.rcMonitor.left,
                 mi.rcMonitor.top,
                 mi.rcMonitor.right - mi.rcMonitor.left,
                 mi.rcMonitor.bottom - mi.rcMonitor.top,
                 SWP_NOZORDER | SWP_NOACTIVATE | SWP_NOCOPYBITS);
}

// Make the specified window and its video mode active on its monitor
//
private extern(D) void acquireMonitor(_GLFWwindow* window) {
    if (!_glfw.win32.acquiredMonitorCount)
    {
        SetThreadExecutionState(ES_CONTINUOUS | ES_DISPLAY_REQUIRED);

        // HACK: When mouse trails are enabled the cursor becomes invisible when
        //       the OpenGL ICD switches to page flipping
        if (IsWindowsXPOrGreater())
        {
            SystemParametersInfo(SPI_GETMOUSETRAILS, 0, &_glfw.win32.mouseTrailSize, 0);
            SystemParametersInfo(SPI_SETMOUSETRAILS, 0, null, 0);
        }
    }

    if (!window.monitor.window)
        _glfw.win32.acquiredMonitorCount++;

    _glfwSetVideoModeWin32(window.monitor, &window.videoMode);
    _glfwInputMonitorWindow(window.monitor, window);
}

// Remove the window and restore the original video mode
//
private extern(D) void releaseMonitor(_GLFWwindow* window) {
    if (window.monitor.window != window)
        return;

    _glfw.win32.acquiredMonitorCount--;
    if (!_glfw.win32.acquiredMonitorCount)
    {
        SetThreadExecutionState(ES_CONTINUOUS);

        // HACK: Restore mouse trail length saved in acquireMonitor
        if (IsWindowsXPOrGreater())
            SystemParametersInfo(SPI_SETMOUSETRAILS, _glfw.win32.mouseTrailSize, null, 0);
    }

    _glfwInputMonitorWindow(window.monitor, null);
    _glfwRestoreVideoModeWin32(window.monitor);
}

// Window callback function (handles window messages)
//
private LRESULT windowProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam) {
    auto window = cast(_GLFWwindow*) GetPropW(hWnd, "GLFW"w.ptr);
    if (!window)
    {
        // This is the message handling for the hidden helper window
        // and for a regular window during its initial creation

        switch (uMsg)
        {
            case WM_NCCREATE:
            {
                if (_glfwIsWindows10AnniversaryUpdateOrGreaterWin32())
                    mixin(EnableNonClientDpiScaling)(hWnd);

                break;
            }

            case WM_DISPLAYCHANGE:
                _glfwPollMonitorsWin32();
                break;

            case WM_DEVICECHANGE:
            {
                if (wParam == DBT_DEVICEARRIVAL)
                {
                    DEV_BROADCAST_HDR* dbh = cast(DEV_BROADCAST_HDR*) lParam;
                    if (dbh && dbh.dbch_devicetype == DBT_DEVTYP_DEVICEINTERFACE)
                        _glfwDetectJoystickConnectionWin32();
                }
                else if (wParam == DBT_DEVICEREMOVECOMPLETE)
                {
                    DEV_BROADCAST_HDR* dbh = cast(DEV_BROADCAST_HDR*) lParam;
                    if (dbh && dbh.dbch_devicetype == DBT_DEVTYP_DEVICEINTERFACE)
                        _glfwDetectJoystickDisconnectionWin32();
                }

                break;
            }
            default: break;
        }

        return DefWindowProcW(hWnd, uMsg, wParam, lParam);
    }

    switch (uMsg)
    {
        case WM_MOUSEACTIVATE:
        {
            // HACK: Postpone cursor disabling when the window was activated by
            //       clicking a caption button
            if (HIWORD(lParam) == WM_LBUTTONDOWN)
            {
                if (LOWORD(lParam) != HTCLIENT)
                    window.win32.frameAction = GLFW_TRUE;
            }

            break;
        }

        case WM_CAPTURECHANGED:
        {
            // HACK: Disable the cursor once the caption button action has been
            //       completed or cancelled
            if (lParam == 0 && window.win32.frameAction)
            {
                if (window.cursorMode == GLFW_CURSOR_DISABLED)
                    disableCursor(window);

                window.win32.frameAction = GLFW_FALSE;
            }

            break;
        }

        case WM_SETFOCUS:
        {
            _glfwInputWindowFocus(window, GLFW_TRUE);

            // HACK: Do not disable cursor while the user is interacting with
            //       a caption button
            if (window.win32.frameAction)
                break;

            if (window.cursorMode == GLFW_CURSOR_DISABLED)
                disableCursor(window);

            return 0;
        }

        case WM_KILLFOCUS:
        {
            if (window.cursorMode == GLFW_CURSOR_DISABLED)
                enableCursor(window);

            if (window.monitor && window.autoIconify)
                _glfwPlatformIconifyWindow(window);

            _glfwInputWindowFocus(window, GLFW_FALSE);
            return 0;
        }

        case WM_SYSCOMMAND:
        {
            switch (wParam & 0xfff0)
            {
                case SC_SCREENSAVE:
                case SC_MONITORPOWER:
                {
                    if (window.monitor)
                    {
                        // We are running in full screen mode, so disallow
                        // screen saver and screen blanking
                        return 0;
                    }
                    else
                        break;
                }

                // User trying to access application menu using ALT?
                case SC_KEYMENU:
                    return 0;
                default: break;
            }
            break;
        }

        case WM_CLOSE:
        {
            _glfwInputWindowCloseRequest(window);
            return 0;
        }

        case WM_INPUTLANGCHANGE:
        {
            _glfwUpdateKeyNamesWin32();
            break;
        }

        case WM_CHAR:
        case WM_SYSCHAR:
        case WM_UNICHAR:
        {
            const(GLFWbool) plain = (uMsg != WM_SYSCHAR);

            if (uMsg == WM_UNICHAR && wParam == UNICODE_NOCHAR)
            {
                // WM_UNICHAR is not sent by Windows, but is sent by some
                // third-party input method engine
                // Returning TRUE here announces support for this message
                return TRUE;
            }

            _glfwInputChar(window, cast(uint) wParam, getKeyMods(), plain);
            return 0;
        }

        case WM_KEYDOWN:
        case WM_SYSKEYDOWN:
        case WM_KEYUP:
        case WM_SYSKEYUP:
        {
            int key;int scancode;
            const(int) action = (HIWORD(lParam) & KF_UP) ? GLFW_RELEASE : GLFW_PRESS;
            const(int) mods = getKeyMods();

            scancode = (HIWORD(lParam) & (KF_EXTENDED | 0xff));
            if (!scancode)
            {
                // NOTE: Some synthetic key messages have a scancode of zero
                // HACK: Map the virtual key back to a usable scancode
                scancode = MapVirtualKeyW(cast(UINT) wParam, MAPVK_VK_TO_VSC);
            }

            key = _glfw.win32.keycodes[scancode];

            // The Ctrl keys require special handling
            if (wParam == VK_CONTROL)
            {
                if (HIWORD(lParam) & KF_EXTENDED)
                {
                    // Right side keys have the extended key bit set
                    key = GLFW_KEY_RIGHT_CONTROL;
                }
                else
                {
                    // NOTE: Alt Gr sends Left Ctrl followed by Right Alt
                    // HACK: We only want one event for Alt Gr, so if we detect
                    //       this sequence we discard this Left Ctrl message now
                    //       and later report Right Alt normally
                    MSG next;
                    const(DWORD) time = GetMessageTime();

                    if (PeekMessageW(&next, null, 0, 0, PM_NOREMOVE))
                    {
                        if (next.message == WM_KEYDOWN ||
                            next.message == WM_SYSKEYDOWN ||
                            next.message == WM_KEYUP ||
                            next.message == WM_SYSKEYUP)
                        {
                            if (next.wParam == VK_MENU &&
                                (HIWORD(next.lParam) & KF_EXTENDED) &&
                                next.time == time)
                            {
                                // Next message is Right Alt down so discard this
                                break;
                            }
                        }
                    }

                    // This is a regular Left Ctrl message
                    key = GLFW_KEY_LEFT_CONTROL;
                }
            }
            else if (wParam == VK_PROCESSKEY)
            {
                // IME notifies that keys have been filtered by setting the
                // virtual key-code to VK_PROCESSKEY
                break;
            }

            if (action == GLFW_RELEASE && wParam == VK_SHIFT)
            {
                // HACK: Release both Shift keys on Shift up event, as when both
                //       are pressed the first release does not emit any event
                // NOTE: The other half of this is in _glfwPlatformPollEvents
                _glfwInputKey(window, GLFW_KEY_LEFT_SHIFT, scancode, action, mods);
                _glfwInputKey(window, GLFW_KEY_RIGHT_SHIFT, scancode, action, mods);
            }
            else if (wParam == VK_SNAPSHOT)
            {
                // HACK: Key down is not reported for the Print Screen key
                _glfwInputKey(window, key, scancode, GLFW_PRESS, mods);
                _glfwInputKey(window, key, scancode, GLFW_RELEASE, mods);
            }
            else
                _glfwInputKey(window, key, scancode, action, mods);

            break;
        }

        case WM_LBUTTONDOWN:
        case WM_RBUTTONDOWN:
        case WM_MBUTTONDOWN:
        case WM_XBUTTONDOWN:
        case WM_LBUTTONUP:
        case WM_RBUTTONUP:
        case WM_MBUTTONUP:
        case WM_XBUTTONUP:
        {
            int i;int button;int action;

            if (uMsg == WM_LBUTTONDOWN || uMsg == WM_LBUTTONUP)
                button = GLFW_MOUSE_BUTTON_LEFT;
            else if (uMsg == WM_RBUTTONDOWN || uMsg == WM_RBUTTONUP)
                button = GLFW_MOUSE_BUTTON_RIGHT;
            else if (uMsg == WM_MBUTTONDOWN || uMsg == WM_MBUTTONUP)
                button = GLFW_MOUSE_BUTTON_MIDDLE;
            else if (GET_XBUTTON_WPARAM(wParam) == XBUTTON1)
                button = GLFW_MOUSE_BUTTON_4;
            else
                button = GLFW_MOUSE_BUTTON_5;

            if (uMsg == WM_LBUTTONDOWN || uMsg == WM_RBUTTONDOWN ||
                uMsg == WM_MBUTTONDOWN || uMsg == WM_XBUTTONDOWN)
            {
                action = GLFW_PRESS;
            }
            else
                action = GLFW_RELEASE;

            for (i = 0;  i <= GLFW_MOUSE_BUTTON_LAST;  i++)
            {
                if (window.mouseButtons[i] == GLFW_PRESS)
                    break;
            }

            if (i > GLFW_MOUSE_BUTTON_LAST)
                SetCapture(hWnd);

            _glfwInputMouseClick(window, button, action, getKeyMods());

            for (i = 0;  i <= GLFW_MOUSE_BUTTON_LAST;  i++)
            {
                if (window.mouseButtons[i] == GLFW_PRESS)
                    break;
            }

            if (i > GLFW_MOUSE_BUTTON_LAST)
                ReleaseCapture();

            if (uMsg == WM_XBUTTONDOWN || uMsg == WM_XBUTTONUP)
                return TRUE;

            return 0;
        }

        case WM_MOUSEMOVE:
        {
            const(int) x = GET_X_LPARAM(lParam);
            const(int) y = GET_Y_LPARAM(lParam);

            if (!window.win32.cursorTracked)
            {
                TRACKMOUSEEVENT tme;
                memset(&tme, 0, typeof(tme).sizeof);
                tme.cbSize = typeof(tme).sizeof;
                tme.dwFlags = TME_LEAVE;
                tme.hwndTrack = window.win32.handle;
                TrackMouseEvent(&tme);

                window.win32.cursorTracked = GLFW_TRUE;
                _glfwInputCursorEnter(window, GLFW_TRUE);
            }

            if (window.cursorMode == GLFW_CURSOR_DISABLED)
            {
                const(int) dx = x - window.win32.lastCursorPosX;
                const(int) dy = y - window.win32.lastCursorPosY;

                if (_glfw.win32.disabledCursorWindow != window)
                    break;
                if (window.rawMouseMotion)
                    break;

                _glfwInputCursorPos(window,
                                    window.virtualCursorPosX + dx,
                                    window.virtualCursorPosY + dy);
            }
            else
                _glfwInputCursorPos(window, x, y);

            window.win32.lastCursorPosX = x;
            window.win32.lastCursorPosY = y;

            return 0;
        }

        case WM_INPUT:
        {
            UINT size = 0;
            HRAWINPUT ri = cast(HRAWINPUT) lParam;
            RAWINPUT* data = null;
            int dx;int dy;

            if (_glfw.win32.disabledCursorWindow != window)
                break;
            if (!window.rawMouseMotion)
                break;

            GetRawInputData(ri, RID_INPUT, null, &size, RAWINPUTHEADER.sizeof);
            if (size > cast(UINT) _glfw.win32.rawInputSize)
            {
                free(_glfw.win32.rawInput);
                _glfw.win32.rawInput = cast(RAWINPUT*) calloc(size, 1);
                _glfw.win32.rawInputSize = size;
            }

            size = _glfw.win32.rawInputSize;
            if (GetRawInputData(ri, RID_INPUT,
                                _glfw.win32.rawInput, &size,
                                RAWINPUTHEADER.sizeof) == cast(UINT) -1)
            {
                _glfwInputError(GLFW_PLATFORM_ERROR,
                                "Win32: Failed to retrieve raw input data");
                break;
            }

            data = _glfw.win32.rawInput;
            if (data.data.mouse.usFlags & MOUSE_MOVE_ABSOLUTE)
            {
                dx = data.data.mouse.lLastX - window.win32.lastCursorPosX;
                dy = data.data.mouse.lLastY - window.win32.lastCursorPosY;
            }
            else
            {
                dx = data.data.mouse.lLastX;
                dy = data.data.mouse.lLastY;
            }

            _glfwInputCursorPos(window,
                                window.virtualCursorPosX + dx,
                                window.virtualCursorPosY + dy);

            window.win32.lastCursorPosX += dx;
            window.win32.lastCursorPosY += dy;
            break;
        }

        case WM_MOUSELEAVE:
        {
            window.win32.cursorTracked = GLFW_FALSE;
            _glfwInputCursorEnter(window, GLFW_FALSE);
            return 0;
        }

        case WM_MOUSEWHEEL:
        {
            _glfwInputScroll(window, 0.0, cast(SHORT) HIWORD(wParam) / cast(double) WHEEL_DELTA);
            return 0;
        }

        case WM_MOUSEHWHEEL:
        {
            // This message is only sent on Windows Vista and later
            // NOTE: The X-axis is inverted for consistency with macOS and X11
            _glfwInputScroll(window, -(cast(SHORT) HIWORD(wParam) / cast(double) WHEEL_DELTA), 0.0);
            return 0;
        }

        case WM_ENTERSIZEMOVE:
        case WM_ENTERMENULOOP:
        {
            if (window.win32.frameAction)
                break;

            // HACK: Enable the cursor while the user is moving or
            //       resizing the window or using the window menu
            if (window.cursorMode == GLFW_CURSOR_DISABLED)
                enableCursor(window);

            break;
        }

        case WM_EXITSIZEMOVE:
        case WM_EXITMENULOOP:
        {
            if (window.win32.frameAction)
                break;

            // HACK: Disable the cursor once the user is done moving or
            //       resizing the window or using the menu
            if (window.cursorMode == GLFW_CURSOR_DISABLED)
                disableCursor(window);

            break;
        }

        case WM_SIZE:
        {
            const(GLFWbool) iconified = wParam == SIZE_MINIMIZED;
            const(GLFWbool) maximized = wParam == SIZE_MAXIMIZED ||
                                       (window.win32.maximized &&
                                        wParam != SIZE_RESTORED);

            if (_glfw.win32.disabledCursorWindow == window)
                updateClipRect(window);

            if (window.win32.iconified != iconified)
                _glfwInputWindowIconify(window, iconified);

            if (window.win32.maximized != maximized)
                _glfwInputWindowMaximize(window, maximized);

            _glfwInputFramebufferSize(window, LOWORD(lParam), HIWORD(lParam));
            _glfwInputWindowSize(window, LOWORD(lParam), HIWORD(lParam));

            if (window.monitor && window.win32.iconified != iconified)
            {
                if (iconified)
                    releaseMonitor(window);
                else
                {
                    acquireMonitor(window);
                    fitToMonitor(window);
                }
            }

            window.win32.iconified = iconified;
            window.win32.maximized = maximized;
            return 0;
        }

        case WM_MOVE:
        {
            if (_glfw.win32.disabledCursorWindow == window)
                updateClipRect(window);

            // NOTE: This cannot use LOWORD/HIWORD recommended by MSDN, as
            // those macros do not handle negative window positions correctly
            _glfwInputWindowPos(window,
                                GET_X_LPARAM(lParam),
                                GET_Y_LPARAM(lParam));
            return 0;
        }

        case WM_SIZING:
        {
            if (window.numer == GLFW_DONT_CARE ||
                window.denom == GLFW_DONT_CARE)
            {
                break;
            }

            applyAspectRatio(window, cast(int) wParam, cast(RECT*) lParam);
            return TRUE;
        }

        case WM_GETMINMAXINFO:
        {
            int xoff;int yoff;
            UINT dpi = USER_DEFAULT_SCREEN_DPI;
            MINMAXINFO* mmi = cast(MINMAXINFO*) lParam;

            if (window.monitor)
                break;

            if (_glfwIsWindows10AnniversaryUpdateOrGreaterWin32())
                dpi = mixin(GetDpiForWindow)(cast(void*) window.win32.handle);

            getFullWindowSize(getWindowStyle(window), getWindowExStyle(window),
                              0, 0, &xoff, &yoff, dpi);

            if (window.minwidth != GLFW_DONT_CARE &&
                window.minheight != GLFW_DONT_CARE)
            {
                mmi.ptMinTrackSize.x = window.minwidth + xoff;
                mmi.ptMinTrackSize.y = window.minheight + yoff;
            }

            if (window.maxwidth != GLFW_DONT_CARE &&
                window.maxheight != GLFW_DONT_CARE)
            {
                mmi.ptMaxTrackSize.x = window.maxwidth + xoff;
                mmi.ptMaxTrackSize.y = window.maxheight + yoff;
            }

            if (!window.decorated)
            {
                MONITORINFO mi;
                HMONITOR mh = MonitorFromWindow(cast(void*) window.win32.handle,
                                                      MONITOR_DEFAULTTONEAREST);

                memset(&mi, 0, typeof(mi).sizeof);
                mi.cbSize = typeof(mi).sizeof;
                GetMonitorInfo(mh, &mi);

                mmi.ptMaxPosition.x = mi.rcWork.left - mi.rcMonitor.left;
                mmi.ptMaxPosition.y = mi.rcWork.top - mi.rcMonitor.top;
                mmi.ptMaxSize.x = mi.rcWork.right - mi.rcWork.left;
                mmi.ptMaxSize.y = mi.rcWork.bottom - mi.rcWork.top;
            }

            return 0;
        }

        case WM_PAINT:
        {
            _glfwInputWindowDamage(window);
            break;
        }

        case WM_ERASEBKGND:
        {
            return TRUE;
        }

        case WM_NCACTIVATE:
        case WM_NCPAINT:
        {
            // Prevent title bar from being drawn after restoring a minimized
            // undecorated window
            if (!window.decorated)
                return TRUE;

            break;
        }

        case WM_DWMCOMPOSITIONCHANGED:
        {
            if (window.win32.transparent)
                updateFramebufferTransparency(window);
            return 0;
        }

        case WM_GETDPISCALEDSIZE:
        {
            if (window.win32.scaleToMonitor)
                break;

            // Adjust the window size to keep the content area size constant
            if (_glfwIsWindows10CreatorsUpdateOrGreaterWin32())
            {
                RECT source = RECT(0);RECT target = RECT(0);
                SIZE* size = cast(SIZE*) lParam;

                mixin(AdjustWindowRectExForDpi)(&source, getWindowStyle(window),
                                         FALSE, getWindowExStyle(window),
                                         mixin(GetDpiForWindow)(cast(void*) window.win32.handle));
                mixin(AdjustWindowRectExForDpi)(&target, getWindowStyle(window),
                                         FALSE, getWindowExStyle(window),
                                         LOWORD(wParam));

                size.cx += (target.right - target.left) -
                            (source.right - source.left);
                size.cy += (target.bottom - target.top) -
                            (source.bottom - source.top);
                return TRUE;
            }

            break;
        }

        case WM_DPICHANGED:
        {
            const(float) xscale = HIWORD(wParam) / cast(float) USER_DEFAULT_SCREEN_DPI;
            const(float) yscale = LOWORD(wParam) / cast(float) USER_DEFAULT_SCREEN_DPI;

            // Only apply the suggested size if the OS is new enough to have
            // sent a WM_GETDPISCALEDSIZE before this
            if (_glfwIsWindows10CreatorsUpdateOrGreaterWin32())
            {
                RECT* suggested = cast(RECT*) lParam;
                SetWindowPos(cast(void*) window.win32.handle, HWND_TOP,
                             suggested.left,
                             suggested.top,
                             suggested.right - suggested.left,
                             suggested.bottom - suggested.top,
                             SWP_NOACTIVATE | SWP_NOZORDER);
            }

            _glfwInputWindowContentScale(window, xscale, yscale);
            break;
        }

        case WM_SETCURSOR:
        {
            if (LOWORD(lParam) == HTCLIENT)
            {
                updateCursorImage(window);
                return TRUE;
            }

            break;
        }

        case WM_DROPFILES:
        {
            HDROP drop = cast(HDROP) wParam;
            POINT pt;
            int i;

            const(int) count = DragQueryFileW(drop, 0xffffffff, null, 0);
            auto paths = cast(char**) calloc(count, (char*).sizeof);

            // Move the mouse to the position of the drop
            DragQueryPoint(drop, &pt);
            _glfwInputCursorPos(window, pt.x, pt.y);

            for (i = 0;  i < count;  i++)
            {
                const(UINT) length = DragQueryFileW(drop, i, null, 0);
                WCHAR* buffer = cast(WCHAR*) calloc(cast(size_t) length + 1, WCHAR.sizeof);

                DragQueryFileW(drop, i, buffer, length + 1);
                paths[i] = _glfwCreateUTF8FromWideStringWin32(buffer);

                free(buffer);
            }

            _glfwInputDrop(window, count, cast(const(char)**) paths);

            for (i = 0;  i < count;  i++)
                free(paths[i]);
            free(paths);

            DragFinish(drop);
            return 0;
        }
        default: break;
    }

    return DefWindowProcW(hWnd, uMsg, wParam, lParam);
}

// Creates the GLFW window
//
private int createNativeWindow(_GLFWwindow* window, const(_GLFWwndconfig)* wndconfig, const(_GLFWfbconfig)* fbconfig) {
    int xpos;int ypos;int fullWidth;int fullHeight;
    WCHAR* wideTitle;
    DWORD style = getWindowStyle(window);
    DWORD exStyle = getWindowExStyle(window);

    if (window.monitor)
    {
        GLFWvidmode mode;

        // NOTE: This window placement is temporary and approximate, as the
        //       correct position and size cannot be known until the monitor
        //       video mode has been picked in _glfwSetVideoModeWin32
        _glfwPlatformGetMonitorPos(window.monitor, &xpos, &ypos);
        _glfwPlatformGetVideoMode(window.monitor, &mode);
        fullWidth  = mode.width;
        fullHeight = mode.height;
    }
    else
    {
        xpos = CW_USEDEFAULT;
        ypos = CW_USEDEFAULT;

        window.win32.maximized = wndconfig.maximized;
        if (wndconfig.maximized)
            style |= WS_MAXIMIZE;

        getFullWindowSize(style, exStyle,
                          wndconfig.width, wndconfig.height,
                          &fullWidth, &fullHeight,
                          USER_DEFAULT_SCREEN_DPI);
    }

    wideTitle = _glfwCreateWideStringFromUTF8Win32(wndconfig.title);
    if (!wideTitle)
        return GLFW_FALSE;

    window.win32.handle = CreateWindowExW(exStyle,
                                           _GLFW_WNDCLASSNAME.ptr,
                                           wideTitle,
                                           style,
                                           xpos, ypos,
                                           fullWidth, fullHeight,
                                           null, // No parent window
                                           null, // No window menu
                                           GetModuleHandleW(null),
                                           null);

    free(wideTitle);

    if (!window.win32.handle)
    {
        _glfwInputErrorWin32(GLFW_PLATFORM_ERROR,
                             "Win32: Failed to create window");
        return GLFW_FALSE;
    }

    SetPropW(window.win32.handle, "GLFW"w.ptr, window);

    if (IsWindows7OrGreater())
    {
        mixin(ChangeWindowMessageFilterEx)(window.win32.handle,
                                    WM_DROPFILES, MSGFLT_ALLOW, null);
        mixin(ChangeWindowMessageFilterEx)(window.win32.handle,
                                    WM_COPYDATA, MSGFLT_ALLOW, null);
        mixin(ChangeWindowMessageFilterEx)(window.win32.handle,
                                    WM_COPYGLOBALDATA, MSGFLT_ALLOW, null);
    }

    window.win32.scaleToMonitor = wndconfig.scaleToMonitor;

    // Adjust window rect to account for DPI scaling of the window frame and
    // (if enabled) DPI scaling of the content area
    // This cannot be done until we know what monitor the window was placed on
    if (!window.monitor)
    {
        RECT rect = RECT( 0, 0, wndconfig.width, wndconfig.height );
        WINDOWPLACEMENT wp = WINDOWPLACEMENT( WINDOWPLACEMENT.sizeof );

        if (wndconfig.scaleToMonitor)
        {
            float xscale;float yscale;
            _glfwPlatformGetWindowContentScale(window, &xscale, &yscale);
            rect.right = cast(int) (rect.right * xscale);
            rect.bottom = cast(int) (rect.bottom * yscale);
        }

        ClientToScreen(window.win32.handle, cast(POINT*) &rect.left);
        ClientToScreen(window.win32.handle, cast(POINT*) &rect.right);

        if (_glfwIsWindows10AnniversaryUpdateOrGreaterWin32())
        {
            mixin(AdjustWindowRectExForDpi)(&rect, style, FALSE, exStyle,
                                     mixin(GetDpiForWindow)(window.win32.handle));
        }
        else
            AdjustWindowRectEx(&rect, style, FALSE, exStyle);

        // Only update the restored window rect as the window may be maximized
        GetWindowPlacement(window.win32.handle, &wp);
        wp.rcNormalPosition = rect;
        wp.showCmd = SW_HIDE;
        SetWindowPlacement(window.win32.handle, &wp);
    }

    DragAcceptFiles(window.win32.handle, TRUE);

    if (fbconfig.transparent)
    {
        updateFramebufferTransparency(window);
        window.win32.transparent = GLFW_TRUE;
    }

    return GLFW_TRUE;
}


//////////////////////////////////////////////////////////////////////////
//////                       GLFW internal API                      //////
//////////////////////////////////////////////////////////////////////////

// Registers the GLFW window class
//
GLFWbool _glfwRegisterWindowClassWin32() {
    WNDCLASSEXW wc;

    memset(&wc, 0, typeof(wc).sizeof);
    wc.cbSize        = typeof(wc).sizeof;
    wc.style         = CS_HREDRAW | CS_VREDRAW | CS_OWNDC;
    wc.lpfnWndProc   = cast(WNDPROC) &windowProc;
    wc.hInstance     = GetModuleHandleW(null);
    wc.hCursor       = LoadCursorW(null, IDC_ARROW);
    wc.lpszClassName = _GLFW_WNDCLASSNAME.ptr;

    // Load user-provided icon if available
    wc.hIcon = LoadImageW(GetModuleHandleW(null),
                          "GLFW_ICON"w.ptr, IMAGE_ICON,
                          0, 0, LR_DEFAULTSIZE | LR_SHARED);
    if (!wc.hIcon)
    {
        // No user-provided icon found, load default icon
        wc.hIcon = LoadImageW(null,
                              IDI_APPLICATION, IMAGE_ICON,
                              0, 0, LR_DEFAULTSIZE | LR_SHARED);
    }

    if (!RegisterClassExW(&wc))
    {
        _glfwInputErrorWin32(GLFW_PLATFORM_ERROR,
                             "Win32: Failed to register window class");
        return GLFW_FALSE;
    }

    return GLFW_TRUE;
}

// Unregisters the GLFW window class
//
void _glfwUnregisterWindowClassWin32() {
    UnregisterClassW(_GLFW_WNDCLASSNAME.ptr, GetModuleHandleW(null));
}


//////////////////////////////////////////////////////////////////////////
//////                       GLFW platform API                      //////
//////////////////////////////////////////////////////////////////////////

int _glfwPlatformCreateWindow(_GLFWwindow* window, const(_GLFWwndconfig)* wndconfig, const(_GLFWctxconfig)* ctxconfig, const(_GLFWfbconfig)* fbconfig) {
    if (!createNativeWindow(window, wndconfig, fbconfig))
        return GLFW_FALSE;

    if (ctxconfig.client != GLFW_NO_API)
    {
        if (ctxconfig.source == GLFW_NATIVE_CONTEXT_API)
        {
            if (!_glfwInitWGL())
                return GLFW_FALSE;
            if (!_glfwCreateContextWGL(window, ctxconfig, fbconfig))
                return GLFW_FALSE;
        }
        else if (ctxconfig.source == GLFW_EGL_CONTEXT_API)
        {
            if (!_glfwInitEGL())
                return GLFW_FALSE;
            if (!_glfwCreateContextEGL(window, ctxconfig, fbconfig))
                return GLFW_FALSE;
        }
        else if (ctxconfig.source == GLFW_OSMESA_CONTEXT_API)
        {
            if (!_glfwInitOSMesa())
                return GLFW_FALSE;
            if (!_glfwCreateContextOSMesa(window, ctxconfig, fbconfig))
                return GLFW_FALSE;
        }
    }

    if (window.monitor)
    {
        _glfwPlatformShowWindow(window);
        _glfwPlatformFocusWindow(window);
        acquireMonitor(window);
        fitToMonitor(window);
    }

    return GLFW_TRUE;
}

void _glfwPlatformDestroyWindow(_GLFWwindow* window) {
    if (window.monitor)
        releaseMonitor(window);

    if (window.context.destroy)
        window.context.destroy(window);

    if (_glfw.win32.disabledCursorWindow == window)
        _glfw.win32.disabledCursorWindow = null;

    if (window.win32.handle)
    {
        RemovePropW(window.win32.handle, "GLFW"w.ptr);
        DestroyWindow(window.win32.handle);
        window.win32.handle = null;
    }

    if (window.win32.bigIcon)
        DestroyIcon(window.win32.bigIcon);

    if (window.win32.smallIcon)
        DestroyIcon(window.win32.smallIcon);
}

void _glfwPlatformSetWindowTitle(_GLFWwindow* window, const(char)* title) {
    WCHAR* wideTitle = _glfwCreateWideStringFromUTF8Win32(title);
    if (!wideTitle)
        return;

    SetWindowTextW(window.win32.handle, wideTitle);
    free(wideTitle);
}

void _glfwPlatformSetWindowIcon(_GLFWwindow* window, int count, const(GLFWimage)* images) {
    HICON bigIcon = null;HICON smallIcon = null;

    if (count)
    {
        const(GLFWimage)* bigImage = chooseImage(count, images,
                                                GetSystemMetrics(SM_CXICON),
                                                GetSystemMetrics(SM_CYICON));
        const(GLFWimage)* smallImage = chooseImage(count, images,
                                                  GetSystemMetrics(SM_CXSMICON),
                                                  GetSystemMetrics(SM_CYSMICON));

        bigIcon = createIcon(bigImage, 0, 0, GLFW_TRUE);
        smallIcon = createIcon(smallImage, 0, 0, GLFW_TRUE);
    }
    else
    {
        bigIcon = cast(HICON) GetClassLongPtrW(window.win32.handle, GCLP_HICON);
        smallIcon = cast(HICON) GetClassLongPtrW(window.win32.handle, GCLP_HICONSM);
    }

    SendMessage(window.win32.handle, WM_SETICON, ICON_BIG, cast(LPARAM) bigIcon);
    SendMessage(window.win32.handle, WM_SETICON, ICON_SMALL, cast(LPARAM) smallIcon);

    if (window.win32.bigIcon)
        DestroyIcon(window.win32.bigIcon);

    if (window.win32.smallIcon)
        DestroyIcon(window.win32.smallIcon);

    if (count)
    {
        window.win32.bigIcon = bigIcon;
        window.win32.smallIcon = smallIcon;
    }
}

void _glfwPlatformGetWindowPos(_GLFWwindow* window, int* xpos, int* ypos) {
    POINT pos = POINT(0, 0);
    ClientToScreen(window.win32.handle, &pos);

    if (xpos)
        *xpos = pos.x;
    if (ypos)
        *ypos = pos.y;
}

void _glfwPlatformSetWindowPos(_GLFWwindow* window, int xpos, int ypos) {
    RECT rect = RECT( xpos, ypos, xpos, ypos );

    if (_glfwIsWindows10AnniversaryUpdateOrGreaterWin32())
    {
        mixin(AdjustWindowRectExForDpi)(&rect, getWindowStyle(window),
                                 FALSE, getWindowExStyle(window),
                                 mixin(GetDpiForWindow)(window.win32.handle));
    }
    else
    {
        /*DynCall*/AdjustWindowRectEx(&rect, getWindowStyle(window),
                           FALSE, getWindowExStyle(window));
    }

    SetWindowPos(window.win32.handle, null, rect.left, rect.top, 0, 0,
                 SWP_NOACTIVATE | SWP_NOZORDER | SWP_NOSIZE);
}

void _glfwPlatformGetWindowSize(_GLFWwindow* window, int* width, int* height) {
    RECT area;
    GetClientRect(window.win32.handle, &area);

    if (width)
        *width = area.right;
    if (height)
        *height = area.bottom;
}

void _glfwPlatformSetWindowSize(_GLFWwindow* window, int width, int height) {
    if (window.monitor)
    {
        if (window.monitor.window == window)
        {
            acquireMonitor(window);
            fitToMonitor(window);
        }
    }
    else
    {
        RECT rect = RECT( 0, 0, width, height );

        if (_glfwIsWindows10AnniversaryUpdateOrGreaterWin32())
        {
            mixin(AdjustWindowRectExForDpi)(&rect, getWindowStyle(window),
                                     FALSE, getWindowExStyle(window),
                                     mixin(GetDpiForWindow)(window.win32.handle));
        }
        else
        {
            /*DynCall*/AdjustWindowRectEx(&rect, getWindowStyle(window),
                               FALSE, getWindowExStyle(window));
        }

        SetWindowPos(window.win32.handle, HWND_TOP,
                     0, 0, rect.right - rect.left, rect.bottom - rect.top,
                     SWP_NOACTIVATE | SWP_NOOWNERZORDER | SWP_NOMOVE | SWP_NOZORDER);
    }
}

void _glfwPlatformSetWindowSizeLimits(_GLFWwindow* window, int minwidth, int minheight, int maxwidth, int maxheight) {
    RECT area;

    if ((minwidth == GLFW_DONT_CARE || minheight == GLFW_DONT_CARE) &&
        (maxwidth == GLFW_DONT_CARE || maxheight == GLFW_DONT_CARE))
    {
        return;
    }

    GetWindowRect(window.win32.handle, &area);
    MoveWindow(window.win32.handle,
               area.left, area.top,
               area.right - area.left,
               area.bottom - area.top, TRUE);
}

void _glfwPlatformSetWindowAspectRatio(_GLFWwindow* window, int numer, int denom) {
    RECT area;

    if (numer == GLFW_DONT_CARE || denom == GLFW_DONT_CARE)
        return;

    GetWindowRect(window.win32.handle, &area);
    applyAspectRatio(window, WMSZ_BOTTOMRIGHT, &area);
    MoveWindow(window.win32.handle,
               area.left, area.top,
               area.right - area.left,
               area.bottom - area.top, TRUE);
}

void _glfwPlatformGetFramebufferSize(_GLFWwindow* window, int* width, int* height) {
    _glfwPlatformGetWindowSize(window, width, height);
}

void _glfwPlatformGetWindowFrameSize(_GLFWwindow* window, int* left, int* top, int* right, int* bottom) {
    RECT rect;
    int width;int height;

    _glfwPlatformGetWindowSize(window, &width, &height);
    SetRect(&rect, 0, 0, width, height);

    if (_glfwIsWindows10AnniversaryUpdateOrGreaterWin32())
    {
        mixin(AdjustWindowRectExForDpi)(&rect, getWindowStyle(window),
                                 FALSE, getWindowExStyle(window),
                                 mixin(GetDpiForWindow)(window.win32.handle));
    }
    else
    {
        /*DynCall*/AdjustWindowRectEx(&rect, getWindowStyle(window),
                           FALSE, getWindowExStyle(window));
    }

    if (left)
        *left = -rect.left;
    if (top)
        *top = -rect.top;
    if (right)
        *right = rect.right - width;
    if (bottom)
        *bottom = rect.bottom - height;
}

void _glfwPlatformGetWindowContentScale(_GLFWwindow* window, float* xscale, float* yscale) {
    HANDLE handle = MonitorFromWindow(window.win32.handle,
                                            MONITOR_DEFAULTTONEAREST);
    _glfwGetMonitorContentScaleWin32(handle, xscale, yscale);
}

void _glfwPlatformIconifyWindow(_GLFWwindow* window) {
    ShowWindow(window.win32.handle, SW_MINIMIZE);
}

void _glfwPlatformRestoreWindow(_GLFWwindow* window) {
    ShowWindow(window.win32.handle, SW_RESTORE);
}

void _glfwPlatformMaximizeWindow(_GLFWwindow* window) {
    ShowWindow(window.win32.handle, SW_MAXIMIZE);
}

void _glfwPlatformShowWindow(_GLFWwindow* window) {
    ShowWindow(window.win32.handle, SW_SHOWNA);
}

void _glfwPlatformHideWindow(_GLFWwindow* window) {
    ShowWindow(window.win32.handle, SW_HIDE);
}

void _glfwPlatformRequestWindowAttention(_GLFWwindow* window) {
    FlashWindow(window.win32.handle, TRUE);
}

void _glfwPlatformFocusWindow(_GLFWwindow* window) {
    BringWindowToTop(window.win32.handle);
    SetForegroundWindow(window.win32.handle);
    SetFocus(window.win32.handle);
}

void _glfwPlatformSetWindowMonitor(_GLFWwindow* window, _GLFWmonitor* monitor, int xpos, int ypos, int width, int height, int refreshRate) {
    if (window.monitor == monitor)
    {
        if (monitor)
        {
            if (monitor.window == window)
            {
                acquireMonitor(window);
                fitToMonitor(window);
            }
        }
        else
        {
            RECT rect = RECT( xpos, ypos, xpos + width, ypos + height );

            if (_glfwIsWindows10AnniversaryUpdateOrGreaterWin32())
            {
                mixin(AdjustWindowRectExForDpi)(&rect, getWindowStyle(window),
                                         FALSE, getWindowExStyle(window),
                                         mixin(GetDpiForWindow)(window.win32.handle));
            }
            else
            {
                /*DynCall*/AdjustWindowRectEx(&rect, getWindowStyle(window),
                                   FALSE, getWindowExStyle(window));
            }

            SetWindowPos(window.win32.handle, HWND_TOP,
                         rect.left, rect.top,
                         rect.right - rect.left, rect.bottom - rect.top,
                         SWP_NOCOPYBITS | SWP_NOACTIVATE | SWP_NOZORDER);
        }

        return;
    }

    if (window.monitor)
        releaseMonitor(window);

    _glfwInputWindowMonitor(window, monitor);

    if (window.monitor)
    {
        MONITORINFO mi = MONITORINFO(MONITORINFO.sizeof);
        UINT flags = SWP_SHOWWINDOW | SWP_NOACTIVATE | SWP_NOCOPYBITS;

        if (window.decorated)
        {
            DWORD style = GetWindowLongW(window.win32.handle, GWL_STYLE);
            style &= ~WS_OVERLAPPEDWINDOW;
            style |= getWindowStyle(window);
            SetWindowLongW(window.win32.handle, GWL_STYLE, style);
            flags |= SWP_FRAMECHANGED;
        }

        acquireMonitor(window);

        GetMonitorInfo(window.monitor.win32.handle, &mi);
        SetWindowPos(window.win32.handle, HWND_TOPMOST,
                     mi.rcMonitor.left,
                     mi.rcMonitor.top,
                     mi.rcMonitor.right - mi.rcMonitor.left,
                     mi.rcMonitor.bottom - mi.rcMonitor.top,
                     flags);
    }
    else
    {
        HWND after;
        RECT rect = RECT( xpos, ypos, xpos + width, ypos + height );
        DWORD style = GetWindowLongW(window.win32.handle, GWL_STYLE);
        UINT flags = SWP_NOACTIVATE | SWP_NOCOPYBITS;

        if (window.decorated)
        {
            style &= ~WS_POPUP;
            style |= getWindowStyle(window);
            SetWindowLongW(window.win32.handle, GWL_STYLE, style);

            flags |= SWP_FRAMECHANGED;
        }

        if (window.floating)
            after = HWND_TOPMOST;
        else
            after = HWND_NOTOPMOST;

        if (_glfwIsWindows10AnniversaryUpdateOrGreaterWin32())
        {
            mixin(AdjustWindowRectExForDpi)(&rect, getWindowStyle(window),
                                     FALSE, getWindowExStyle(window),
                                     mixin(GetDpiForWindow)(window.win32.handle));
        }
        else
        {
            /*DynCall*/AdjustWindowRectEx(&rect, getWindowStyle(window),
                               FALSE, getWindowExStyle(window));
        }

        SetWindowPos(window.win32.handle, after,
                     rect.left, rect.top,
                     rect.right - rect.left, rect.bottom - rect.top,
                     flags);
    }
}

int _glfwPlatformWindowFocused(_GLFWwindow* window) {
    return window.win32.handle == GetActiveWindow();
}

int _glfwPlatformWindowIconified(_GLFWwindow* window) {
    return IsIconic(window.win32.handle);
}

int _glfwPlatformWindowVisible(_GLFWwindow* window) {
    return IsWindowVisible(window.win32.handle);
}

int _glfwPlatformWindowMaximized(_GLFWwindow* window) {
    return IsZoomed(window.win32.handle);
}

int _glfwPlatformWindowHovered(_GLFWwindow* window) {
    return cursorInContentArea(window);
}

int _glfwPlatformFramebufferTransparent(_GLFWwindow* window) {
    BOOL enabled;

    if (!window.win32.transparent)
        return GLFW_FALSE;

    if (!IsWindowsVistaOrGreater())
        return GLFW_FALSE;

    return SUCCEEDED(_glfw.win32.dwmapi.IsCompositionEnabled(&enabled)) && enabled;
}

void _glfwPlatformSetWindowResizable(_GLFWwindow* window, GLFWbool enabled) {
    updateWindowStyles(window);
}

void _glfwPlatformSetWindowDecorated(_GLFWwindow* window, GLFWbool enabled) {
    updateWindowStyles(window);
}

void _glfwPlatformSetWindowFloating(_GLFWwindow* window, GLFWbool enabled) {
    HWND after = enabled ? HWND_TOPMOST : HWND_NOTOPMOST;
    SetWindowPos(window.win32.handle, after, 0, 0, 0, 0,
                 SWP_NOACTIVATE | SWP_NOMOVE | SWP_NOSIZE);
}

float _glfwPlatformGetWindowOpacity(_GLFWwindow* window) {
    BYTE alpha;
    DWORD flags;

    if ((GetWindowLongW(window.win32.handle, GWL_EXSTYLE) & WS_EX_LAYERED) &&
        GetLayeredWindowAttributes(window.win32.handle, null, &alpha, &flags))
    {
        if (flags & LWA_ALPHA)
            return alpha / 255.0f;
    }

    return 1.0f;
}

void _glfwPlatformSetWindowOpacity(_GLFWwindow* window, float opacity) {
    if (opacity < 1.0f)
    {
        const(BYTE) alpha = cast(BYTE) (255 * opacity);
        DWORD style = GetWindowLongW(window.win32.handle, GWL_EXSTYLE);
        style |= WS_EX_LAYERED;
        SetWindowLongW(window.win32.handle, GWL_EXSTYLE, style);
        SetLayeredWindowAttributes(window.win32.handle, 0, alpha, LWA_ALPHA);
    }
    else
    {
        DWORD style = GetWindowLongW(window.win32.handle, GWL_EXSTYLE);
        style &= ~WS_EX_LAYERED;
        SetWindowLongW(window.win32.handle, GWL_EXSTYLE, style);
    }
}

void _glfwPlatformSetRawMouseMotion(_GLFWwindow* window, GLFWbool enabled) {
    if (_glfw.win32.disabledCursorWindow != window)
        return;

    if (enabled)
        enableRawMouseMotion(window);
    else
        disableRawMouseMotion(window);
}

GLFWbool _glfwPlatformRawMouseMotionSupported() {
    return GLFW_TRUE;
}

void _glfwPlatformPollEvents() {
    MSG msg;
    HWND handle;
    _GLFWwindow* window;

    while (PeekMessageW(&msg, null, 0, 0, PM_REMOVE))
    {
        if (msg.message == WM_QUIT)
        {
            // NOTE: While GLFW does not itself post WM_QUIT, other processes
            //       may post it to this one, for example Task Manager
            // HACK: Treat WM_QUIT as a close on all windows

            window = _glfw.windowListHead;
            while (window)
            {
                _glfwInputWindowCloseRequest(window);
                window = window.next;
            }
        }
        else
        {
            TranslateMessage(&msg);
            DispatchMessageW(&msg);
        }
    }

    // HACK: Release modifier keys that the system did not emit KEYUP for
    // NOTE: Shift keys on Windows tend to "stick" when both are pressed as
    //       no key up message is generated by the first key release
    // NOTE: Windows key is not reported as released by the Win+V hotkey
    //       Other Win hotkeys are handled implicitly by _glfwInputWindowFocus
    //       because they change the input focus
    // NOTE: The other half of this is in the WM_*KEY* handler in windowProc
    handle = GetActiveWindow();
    if (handle)
    {
        window = cast(_GLFWwindow*) GetPropW(handle, "GLFW"w.ptr);
        if (window)
        {
            int i;
            const(int)[2][4] keys = [
                [ VK_LSHIFT, GLFW_KEY_LEFT_SHIFT ],
                [ VK_RSHIFT, GLFW_KEY_RIGHT_SHIFT ],
                [ VK_LWIN, GLFW_KEY_LEFT_SUPER ],
                [ VK_RWIN, GLFW_KEY_RIGHT_SUPER ]
            ];

            for (i = 0;  i < 4;  i++)
            {
                const(int) vk = keys[i][0];
                const(int) key = keys[i][1];
                const(int) scancode = _glfw.win32.scancodes[key];

                if ((GetKeyState(vk) & 0x8000))
                    continue;
                if (window.keys[key] != GLFW_PRESS)
                    continue;

                _glfwInputKey(window, key, scancode, GLFW_RELEASE, getKeyMods());
            }
        }
    }

    window = _glfw.win32.disabledCursorWindow;
    if (window)
    {
        int width;int height;
        _glfwPlatformGetWindowSize(window, &width, &height);

        // NOTE: Re-center the cursor only if it has moved since the last call,
        //       to avoid breaking glfwWaitEvents with WM_MOUSEMOVE
        if (window.win32.lastCursorPosX != width / 2 ||
            window.win32.lastCursorPosY != height / 2)
        {
            _glfwPlatformSetCursorPos(window, width / 2, height / 2);
        }
    }
}

void _glfwPlatformWaitEvents() {
    WaitMessage();

    _glfwPlatformPollEvents();
}

void _glfwPlatformWaitEventsTimeout(double timeout) {
    MsgWaitForMultipleObjects(0, null, FALSE, cast(DWORD) (timeout * 1e3), QS_ALLEVENTS);

    _glfwPlatformPollEvents();
}

void _glfwPlatformPostEmptyEvent() {
    PostMessage(_glfw.win32.helperWindowHandle, WM_NULL, 0, 0);
}

void _glfwPlatformGetCursorPos(_GLFWwindow* window, double* xpos, double* ypos) {
    POINT pos;

    if (GetCursorPos(&pos))
    {
        ScreenToClient(window.win32.handle, &pos);

        if (xpos)
            *xpos = pos.x;
        if (ypos)
            *ypos = pos.y;
    }
}

void _glfwPlatformSetCursorPos(_GLFWwindow* window, double xpos, double ypos) {
    POINT pos = POINT( cast(int) xpos, cast(int) ypos );

    // Store the new position so it can be recognized later
    window.win32.lastCursorPosX = pos.x;
    window.win32.lastCursorPosY = pos.y;

    ClientToScreen(window.win32.handle, &pos);
    SetCursorPos(pos.x, pos.y);
}

void _glfwPlatformSetCursorMode(_GLFWwindow* window, int mode) {
    if (mode == GLFW_CURSOR_DISABLED)
    {
        if (_glfwPlatformWindowFocused(window))
            disableCursor(window);
    }
    else if (_glfw.win32.disabledCursorWindow == window)
        enableCursor(window);
    else if (cursorInContentArea(window))
        updateCursorImage(window);
}

const(char)* _glfwPlatformGetScancodeName(int scancode) {
    if (scancode < 0 || scancode > (KF_EXTENDED | 0xff) ||
        _glfw.win32.keycodes[scancode] == GLFW_KEY_UNKNOWN)
    {
        _glfwInputError(GLFW_INVALID_VALUE, "Invalid scancode");
        return null;
    }

    return _glfw.win32.keynames[_glfw.win32.keycodes[scancode]].ptr;
}

int _glfwPlatformGetKeyScancode(int key) {
    return _glfw.win32.scancodes[key];
}

int _glfwPlatformCreateCursor(_GLFWcursor* cursor, const(GLFWimage)* image, int xhot, int yhot) {
    cursor.win32.handle = cast(HCURSOR) createIcon(image, xhot, yhot, GLFW_FALSE);
    if (!cursor.win32.handle)
        return GLFW_FALSE;

    return GLFW_TRUE;
}

int _glfwPlatformCreateStandardCursor(_GLFWcursor* cursor, int shape) {
    int id = 0;

    if (shape == GLFW_ARROW_CURSOR)
        id = OCR_NORMAL;
    else if (shape == GLFW_IBEAM_CURSOR)
        id = OCR_IBEAM;
    else if (shape == GLFW_CROSSHAIR_CURSOR)
        id = OCR_CROSS;
    else if (shape == GLFW_HAND_CURSOR)
        id = OCR_HAND;
    else if (shape == GLFW_HRESIZE_CURSOR)
        id = OCR_SIZEWE;
    else if (shape == GLFW_VRESIZE_CURSOR)
        id = OCR_SIZENS;
    else
        return GLFW_FALSE;

    cursor.win32.handle = LoadImageW(null,
                                      MAKEINTRESOURCEW(id), IMAGE_CURSOR, 0, 0,
                                      LR_DEFAULTSIZE | LR_SHARED);
    if (!cursor.win32.handle)
    {
        _glfwInputErrorWin32(GLFW_PLATFORM_ERROR,
                             "Win32: Failed to create standard cursor");
        return GLFW_FALSE;
    }

    return GLFW_TRUE;
}

void _glfwPlatformDestroyCursor(_GLFWcursor* cursor) {
    if (cursor.win32.handle)
        DestroyIcon(cast(HICON) cursor.win32.handle);
}

void _glfwPlatformSetCursor(_GLFWwindow* window, _GLFWcursor* cursor) {
    if (cursorInContentArea(window))
        updateCursorImage(window);
}

void _glfwPlatformSetClipboardString(const(char)* string) {
    int characterCount;
    HANDLE object;
    WCHAR* buffer;

    characterCount = MultiByteToWideChar(CP_UTF8, 0, string, -1, null, 0);
    if (!characterCount)
        return;

    object = GlobalAlloc(GMEM_MOVEABLE, characterCount * WCHAR.sizeof);
    if (!object)
    {
        _glfwInputErrorWin32(GLFW_PLATFORM_ERROR,
                             "Win32: Failed to allocate global handle for clipboard");
        return;
    }

    buffer = cast(WCHAR*) GlobalLock(object); // needless re-use of buffer variable?
    if (!buffer)
    {
        _glfwInputErrorWin32(GLFW_PLATFORM_ERROR,
                             "Win32: Failed to lock global handle");
        GlobalFree(object);
        return;
    }

    MultiByteToWideChar(CP_UTF8, 0, string, -1, buffer, characterCount);
    GlobalUnlock(object);

    if (!OpenClipboard(_glfw.win32.helperWindowHandle))
    {
        _glfwInputErrorWin32(GLFW_PLATFORM_ERROR,
                             "Win32: Failed to open clipboard");
        GlobalFree(object);
        return;
    }

    EmptyClipboard();
    SetClipboardData(CF_UNICODETEXT, object);
    CloseClipboard();
}

const(char)* _glfwPlatformGetClipboardString() {
    HANDLE object;
    WCHAR* buffer;

    if (!OpenClipboard(_glfw.win32.helperWindowHandle))
    {
        _glfwInputErrorWin32(GLFW_PLATFORM_ERROR,
                             "Win32: Failed to open clipboard");
        return null;
    }

    object = GetClipboardData(CF_UNICODETEXT);
    if (!object)
    {
        _glfwInputErrorWin32(GLFW_FORMAT_UNAVAILABLE,
                             "Win32: Failed to convert clipboard to string");
        CloseClipboard();
        return null;
    }

    buffer = cast(WCHAR*) GlobalLock(object);
    if (!buffer)
    {
        _glfwInputErrorWin32(GLFW_PLATFORM_ERROR,
                             "Win32: Failed to lock global handle");
        CloseClipboard();
        return null;
    }

    free(_glfw.win32.clipboardString);
    _glfw.win32.clipboardString = _glfwCreateUTF8FromWideStringWin32(buffer);

    GlobalUnlock(object);
    CloseClipboard();

    return _glfw.win32.clipboardString;
}

void _glfwPlatformGetRequiredInstanceExtensions(const(char)** extensions) {
    if (!_glfw.vk.KHR_surface || !_glfw.vk.KHR_win32_surface)
        return;

    extensions[0] = "VK_KHR_surface".ptr;
    extensions[1] = "VK_KHR_win32_surface".ptr;
}

int _glfwPlatformGetPhysicalDevicePresentationSupport(VkInstance instance, VkPhysicalDevice device, uint queuefamily) {
    PFN_vkGetPhysicalDeviceWin32PresentationSupportKHR vkGetPhysicalDeviceWin32PresentationSupportKHR = cast(PFN_vkGetPhysicalDeviceWin32PresentationSupportKHR)
        mixin(vkGetInstanceProcAddr)(instance, "vkGetPhysicalDeviceWin32PresentationSupportKHR");
    if (!vkGetPhysicalDeviceWin32PresentationSupportKHR)
    {
        _glfwInputError(GLFW_API_UNAVAILABLE,
                        "Win32: Vulkan instance missing VK_KHR_win32_surface extension");
        return GLFW_FALSE;
    }

    return vkGetPhysicalDeviceWin32PresentationSupportKHR(device, queuefamily);
}

VkResult _glfwPlatformCreateWindowSurface(VkInstance instance, _GLFWwindow* window, const(VkAllocationCallbacks)* allocator, VkSurfaceKHR* surface) {
    VkResult err;
    VkWin32SurfaceCreateInfoKHR sci;
    PFN_vkCreateWin32SurfaceKHR vkCreateWin32SurfaceKHR;

    vkCreateWin32SurfaceKHR = cast(PFN_vkCreateWin32SurfaceKHR)
        mixin(vkGetInstanceProcAddr)(instance, "vkCreateWin32SurfaceKHR");
    if (!vkCreateWin32SurfaceKHR)
    {
        _glfwInputError(GLFW_API_UNAVAILABLE,
                        "Win32: Vulkan instance missing VK_KHR_win32_surface extension");
        return VkResult.VK_ERROR_EXTENSION_NOT_PRESENT;
    }

    memset(&sci, 0, typeof(sci).sizeof);
    sci.sType = VkStructureType.VK_STRUCTURE_TYPE_WIN32_SURFACE_CREATE_INFO_KHR;
    sci.hinstance = GetModuleHandle(null);
    sci.hwnd = window.win32.handle;

    err = vkCreateWin32SurfaceKHR(instance, &sci, allocator, surface);
    if (err)
    {
        _glfwInputError(GLFW_PLATFORM_ERROR,
                        "Win32: Failed to create Vulkan surface: %s",
                        _glfwGetVulkanResultString(err));
    }

    return err;
}


//////////////////////////////////////////////////////////////////////////
//////                        GLFW native API                       //////
//////////////////////////////////////////////////////////////////////////

HWND glfwGetWin32Window(GLFWwindow* handle) {
    _GLFWwindow* window = cast(_GLFWwindow*) handle;
    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"null");
    return window.win32.handle;
}
