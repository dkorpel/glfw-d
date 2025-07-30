/// Translated from C to D
module glfw3.win32_monitor;

version(Windows):
nothrow:
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

import core.stdc.stdlib;
import core.stdc.string;
import core.stdc.limits;
import core.stdc.wchar_;

package:

// Callback for EnumDisplayMonitors in createMonitor
//
extern(Windows) private BOOL monitorCallback(HMONITOR handle, HDC dc, RECT* rect, LPARAM data) {
    MONITORINFOEXW mi;
    memset(&mi, 0, typeof(mi).sizeof);
    mi.cbSize = typeof(mi).sizeof;

    if (GetMonitorInfoW(handle, cast(MONITORINFO*) &mi))
    {
        _GLFWmonitor* monitor = cast(_GLFWmonitor*) data;
        if (wcscmp(mi.szDevice.ptr, monitor.win32.adapterName.ptr) == 0)
            monitor.win32.handle = handle;
    }

    return TRUE;
}

// Create monitor from an adapter and (optionally) a display
//
private extern(D) _GLFWmonitor* createMonitor(DISPLAY_DEVICEW* adapter, DISPLAY_DEVICEW* display) {
    _GLFWmonitor* monitor;
    int widthMM;int heightMM;
    char* name;
    HDC dc;
    DEVMODEW dm;
    RECT rect;

    if (display)
        name = _glfwCreateUTF8FromWideStringWin32(display.DeviceString.ptr);
    else
        name = _glfwCreateUTF8FromWideStringWin32(adapter.DeviceString.ptr);
    if (!name)
        return null;

    memset(&dm, 0, typeof(dm).sizeof);
    dm.dmSize = typeof(dm).sizeof;
    EnumDisplaySettingsW(adapter.DeviceName.ptr, ENUM_CURRENT_SETTINGS, &dm);

    dc = CreateDCW("DISPLAY"w.ptr, adapter.DeviceName.ptr, null, null);

    if (IsWindows8Point1OrGreater())
    {
        widthMM  = GetDeviceCaps(dc, HORZSIZE);
        heightMM = GetDeviceCaps(dc, VERTSIZE);
    }
    else
    {
        widthMM  = cast(int) (dm.dmPelsWidth * 25.4f / GetDeviceCaps(dc, LOGPIXELSX));
        heightMM = cast(int) (dm.dmPelsHeight * 25.4f / GetDeviceCaps(dc, LOGPIXELSY));
    }

    DeleteDC(dc);

    monitor = _glfwAllocMonitor(name, widthMM, heightMM);
    free(name);

    if (adapter.StateFlags & DISPLAY_DEVICE_MODESPRUNED)
        monitor.win32.modesPruned = GLFW_TRUE;

    wcscpy(monitor.win32.adapterName.ptr, adapter.DeviceName.ptr);
    WideCharToMultiByte(CP_UTF8, 0,
                        adapter.DeviceName.ptr, -1,
                        monitor.win32.publicAdapterName.ptr,
                        typeof(monitor.win32.publicAdapterName).sizeof,
                        null, null);

    if (display)
    {
        wcscpy(monitor.win32.displayName.ptr, display.DeviceName.ptr);
        WideCharToMultiByte(CP_UTF8, 0,
                            display.DeviceName.ptr, -1,
                            monitor.win32.publicDisplayName.ptr,
                            typeof(monitor.win32.publicDisplayName).sizeof,
                            null, null);
    }

    rect.left   = dm.dmPosition.x;
    rect.top    = dm.dmPosition.y;
    rect.right  = dm.dmPosition.x + dm.dmPelsWidth;
    rect.bottom = dm.dmPosition.y + dm.dmPelsHeight;

    EnumDisplayMonitors(null, &rect, &monitorCallback, cast(LPARAM) monitor);
    return monitor;
}


//////////////////////////////////////////////////////////////////////////
//////                       GLFW internal API                      //////
//////////////////////////////////////////////////////////////////////////

// Poll for changes in the set of connected monitors
//
void _glfwPollMonitorsWin32() {
    int i;int disconnectedCount;
    _GLFWmonitor** disconnected = null;
    DWORD adapterIndex;DWORD displayIndex;
    DISPLAY_DEVICEW adapter;DISPLAY_DEVICEW display;
    _GLFWmonitor* monitor;

    disconnectedCount = _glfw.monitorCount;
    if (disconnectedCount)
    {
        disconnected = cast(_GLFWmonitor**) calloc(_glfw.monitorCount, (_GLFWmonitor*).sizeof);
        memcpy(disconnected,
               _glfw.monitors,
               _glfw.monitorCount * (_GLFWmonitor*).sizeof);
    }

    for (adapterIndex = 0;  ;  adapterIndex++)
    {
        int type = _GLFW_INSERT_LAST;

        memset(&adapter, 0, typeof(adapter).sizeof);
        adapter.cb = typeof(adapter).sizeof;

        if (!EnumDisplayDevicesW(null, adapterIndex, &adapter, 0))
            break;

        if (!(adapter.StateFlags & DISPLAY_DEVICE_ACTIVE))
            continue;

        if (adapter.StateFlags & DISPLAY_DEVICE_PRIMARY_DEVICE)
            type = _GLFW_INSERT_FIRST;

        for (displayIndex = 0;  ;  displayIndex++)
        {
            memset(&display, 0, typeof(display).sizeof);
            display.cb = typeof(display).sizeof;

            if (!EnumDisplayDevicesW(adapter.DeviceName.ptr, displayIndex, &display, 0))
                break;

            if (!(display.StateFlags & DISPLAY_DEVICE_ACTIVE))
                continue;

            for (i = 0;  i < disconnectedCount;  i++)
            {
                if (disconnected[i] &&
                    wcscmp(disconnected[i].win32.displayName.ptr,
                           display.DeviceName.ptr) == 0)
                {
                    disconnected[i] = null;
                    break;
                }
            }

            if (i < disconnectedCount)
                continue;

            monitor = createMonitor(&adapter, &display);
            if (!monitor)
            {
                free(disconnected);
                return;
            }

            _glfwInputMonitor(monitor, GLFW_CONNECTED, type);

            type = _GLFW_INSERT_LAST;
        }

        // HACK: If an active adapter does not have any display devices
        //       (as sometimes happens), add it directly as a monitor
        if (displayIndex == 0)
        {
            for (i = 0;  i < disconnectedCount;  i++)
            {
                if (disconnected[i] &&
                    wcscmp(disconnected[i].win32.adapterName.ptr,
                           adapter.DeviceName.ptr) == 0)
                {
                    disconnected[i] = null;
                    break;
                }
            }

            if (i < disconnectedCount)
                continue;

            monitor = createMonitor(&adapter, null);
            if (!monitor)
            {
                free(disconnected);
                return;
            }

            _glfwInputMonitor(monitor, GLFW_CONNECTED, type);
        }
    }

    for (i = 0;  i < disconnectedCount;  i++)
    {
        if (disconnected[i])
            _glfwInputMonitor(disconnected[i], GLFW_DISCONNECTED, 0);
    }

    free(disconnected);
}

// Change the current video mode
//
void _glfwSetVideoModeWin32(_GLFWmonitor* monitor, const(GLFWvidmode)* desired) {
    GLFWvidmode current;
    const(GLFWvidmode)* best;
    DEVMODEW dm;
    LONG result;

    best = _glfwChooseVideoMode(monitor, desired);
    _glfwPlatformGetVideoMode(monitor, &current);
    if (_glfwCompareVideoModes(&current, best) == 0)
        return;

    memset(&dm, 0, typeof(dm).sizeof);
    dm.dmSize = typeof(dm).sizeof;
    dm.dmFields           = DM_PELSWIDTH | DM_PELSHEIGHT | DM_BITSPERPEL |
                            DM_DISPLAYFREQUENCY;
    dm.dmPelsWidth        = best.width;
    dm.dmPelsHeight       = best.height;
    dm.dmBitsPerPel       = best.redBits + best.greenBits + best.blueBits;
    dm.dmDisplayFrequency = best.refreshRate;

    if (dm.dmBitsPerPel < 15 || dm.dmBitsPerPel >= 24)
        dm.dmBitsPerPel = 32;

    result = ChangeDisplaySettingsExW(monitor.win32.adapterName.ptr,
                                      &dm,
                                      null,
                                      CDS_FULLSCREEN,
                                      null);
    if (result == DISP_CHANGE_SUCCESSFUL)
        monitor.win32.modeChanged = GLFW_TRUE;
    else
    {
        const(char)* description = "Unknown error";

        if (result == DISP_CHANGE_BADDUALVIEW)
            description = "The system uses DualView";
        else if (result == DISP_CHANGE_BADFLAGS)
            description = "Invalid flags";
        else if (result == DISP_CHANGE_BADMODE)
            description = "Graphics mode not supported";
        else if (result == DISP_CHANGE_BADPARAM)
            description = "Invalid parameter";
        else if (result == DISP_CHANGE_FAILED)
            description = "Graphics mode failed";
        else if (result == DISP_CHANGE_NOTUPDATED)
            description = "Failed to write to registry";
        else if (result == DISP_CHANGE_RESTART)
            description = "Computer restart required";

        _glfwInputError(GLFW_PLATFORM_ERROR,
                        "Win32: Failed to set video mode: %s",
                        description);
    }
}

// Restore the previously saved (original) video mode
//
void _glfwRestoreVideoModeWin32(_GLFWmonitor* monitor) {
    if (monitor.win32.modeChanged)
    {
        ChangeDisplaySettingsExW(monitor.win32.adapterName.ptr,
                                 null, null, CDS_FULLSCREEN, null);
        monitor.win32.modeChanged = GLFW_FALSE;
    }
}

void _glfwGetMonitorContentScaleWin32(HMONITOR handle, float* xscale, float* yscale) {
    UINT xdpi;UINT ydpi;

    if (IsWindows8Point1OrGreater())
        mixin(GetDpiForMonitor)(handle, MONITOR_DPI_TYPE.MDT_EFFECTIVE_DPI, &xdpi, &ydpi);
    else
    {
        HDC dc = GetDC(null);
        xdpi = GetDeviceCaps(dc, LOGPIXELSX);
        ydpi = GetDeviceCaps(dc, LOGPIXELSY);
        ReleaseDC(null, dc);
    }

    if (xscale)
        *xscale = xdpi / cast(float) USER_DEFAULT_SCREEN_DPI;
    if (yscale)
        *yscale = ydpi / cast(float) USER_DEFAULT_SCREEN_DPI;
}


//////////////////////////////////////////////////////////////////////////
//////                       GLFW platform API                      //////
//////////////////////////////////////////////////////////////////////////

void _glfwPlatformFreeMonitor(_GLFWmonitor* monitor) {
}

void _glfwPlatformGetMonitorPos(_GLFWmonitor* monitor, int* xpos, int* ypos) {
    DEVMODEW dm;
    memset(&dm, 0, typeof(dm).sizeof);
    dm.dmSize = typeof(dm).sizeof;

    EnumDisplaySettingsExW(monitor.win32.adapterName.ptr,
                           ENUM_CURRENT_SETTINGS,
                           &dm,
                           EDS_ROTATEDMODE);

    if (xpos)
        *xpos = dm.dmPosition.x;
    if (ypos)
        *ypos = dm.dmPosition.y;
}

void _glfwPlatformGetMonitorContentScale(_GLFWmonitor* monitor, float* xscale, float* yscale) {
    _glfwGetMonitorContentScaleWin32(monitor.win32.handle, xscale, yscale);
}

void _glfwPlatformGetMonitorWorkarea(_GLFWmonitor* monitor, int* xpos, int* ypos, int* width, int* height) {
    MONITORINFO mi = MONITORINFO(MONITORINFO.sizeof);
    GetMonitorInfo(monitor.win32.handle, &mi);

    if (xpos)
        *xpos = mi.rcWork.left;
    if (ypos)
        *ypos = mi.rcWork.top;
    if (width)
        *width = mi.rcWork.right - mi.rcWork.left;
    if (height)
        *height = mi.rcWork.bottom - mi.rcWork.top;
}

GLFWvidmode* _glfwPlatformGetVideoModes(_GLFWmonitor* monitor, int* count) {
    int modeIndex = 0;int size = 0;
    GLFWvidmode* result = null;

    *count = 0;

    for (;;)
    {
        int i;
        GLFWvidmode mode;
        DEVMODEW dm;

        memset(&dm, 0, typeof(dm).sizeof);
        dm.dmSize = typeof(dm).sizeof;

        if (!EnumDisplaySettingsW(monitor.win32.adapterName.ptr, modeIndex, &dm))
            break;

        modeIndex++;

        // Skip modes with less than 15 BPP
        if (dm.dmBitsPerPel < 15)
            continue;

        mode.width  = dm.dmPelsWidth;
        mode.height = dm.dmPelsHeight;
        mode.refreshRate = dm.dmDisplayFrequency;
        _glfwSplitBPP(dm.dmBitsPerPel,
                      &mode.redBits,
                      &mode.greenBits,
                      &mode.blueBits);

        for (i = 0;  i < *count;  i++)
        {
            if (_glfwCompareVideoModes(result + i, &mode) == 0)
                break;
        }

        // Skip duplicate modes
        if (i < *count)
            continue;

        if (monitor.win32.modesPruned)
        {
            // Skip modes not supported by the connected displays
            if (ChangeDisplaySettingsExW(monitor.win32.adapterName.ptr,
                                         &dm,
                                         null,
                                         CDS_TEST,
                                         null) != DISP_CHANGE_SUCCESSFUL)
            {
                continue;
            }
        }

        if (*count == size)
        {
            size += 128;
            result = cast(GLFWvidmode*) realloc(result, size * GLFWvidmode.sizeof);
        }

        (*count)++;
        result[*count - 1] = mode;
    }

    if (!*count)
    {
        // HACK: Report the current mode if no valid modes were found
        result = cast(GLFWvidmode*) calloc(1, GLFWvidmode.sizeof);
        _glfwPlatformGetVideoMode(monitor, result);
        *count = 1;
    }

    return result;
}

void _glfwPlatformGetVideoMode(_GLFWmonitor* monitor, GLFWvidmode* mode) {
    DEVMODEW dm;
    memset(&dm, 0, typeof(dm).sizeof);
    dm.dmSize = typeof(dm).sizeof;

    EnumDisplaySettingsW(monitor.win32.adapterName.ptr, ENUM_CURRENT_SETTINGS, &dm);

    mode.width  = dm.dmPelsWidth;
    mode.height = dm.dmPelsHeight;
    mode.refreshRate = dm.dmDisplayFrequency;
    _glfwSplitBPP(dm.dmBitsPerPel,
                  &mode.redBits,
                  &mode.greenBits,
                  &mode.blueBits);
}

GLFWbool _glfwPlatformGetGammaRamp(_GLFWmonitor* monitor, GLFWgammaramp* ramp) {
    HDC dc;
    WORD[256][3] values;

    dc = CreateDCW("DISPLAY"w.ptr, monitor.win32.adapterName.ptr, null, null);
    GetDeviceGammaRamp(dc, values.ptr);
    DeleteDC(dc);

    _glfwAllocGammaArrays(ramp, 256);

    memcpy(ramp.red,   values[0].ptr, typeof(values[0]).sizeof);
    memcpy(ramp.green, values[1].ptr, typeof(values[1]).sizeof);
    memcpy(ramp.blue,  values[2].ptr, typeof(values[2]).sizeof);

    return GLFW_TRUE;
}

void _glfwPlatformSetGammaRamp(_GLFWmonitor* monitor, const(GLFWgammaramp)* ramp) {
    HDC dc;
    WORD[256][3] values;

    if (ramp.size != 256)
    {
        _glfwInputError(GLFW_PLATFORM_ERROR,
                        "Win32: Gamma ramp size must be 256");
        return;
    }

    memcpy(values[0].ptr, ramp.red,   typeof(values[0]).sizeof);
    memcpy(values[1].ptr, ramp.green, typeof(values[1]).sizeof);
    memcpy(values[2].ptr, ramp.blue,  typeof(values[2]).sizeof);

    dc = CreateDCW("DISPLAY"w.ptr, monitor.win32.adapterName.ptr, null, null);
    SetDeviceGammaRamp(dc, values.ptr);
    DeleteDC(dc);
}


//////////////////////////////////////////////////////////////////////////
//////                        GLFW native API                       //////
//////////////////////////////////////////////////////////////////////////

const(char)* glfwGetWin32Adapter(GLFWmonitor* handle) {
    _GLFWmonitor* monitor = cast(_GLFWmonitor*) handle;
    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"null");
    return monitor.win32.publicAdapterName.ptr;
}

const(char)* glfwGetWin32Monitor(GLFWmonitor* handle) {
    _GLFWmonitor* monitor = cast(_GLFWmonitor*) handle;
    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"null");
    return monitor.win32.publicDisplayName.ptr;
}
