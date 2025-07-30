/// Translated from C to D
module glfw3.win32_platform;

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

// GLFW uses DirectInput8 interfaces
enum DIRECTINPUT_VERSION = 0x0800;

public import core.stdc.wctype;
public import core.sys.windows.windows;
public import core.sys.windows.winuser;
public import glfw3.directinput8;
public import glfw3.xinput;
public import core.sys.windows.objbase; // GUID
public import core.sys.windows.dbt;

package:

// TODO: make this nothrow upstream
nothrow extern (Windows) ULONGLONG VerSetConditionMask(ULONGLONG, DWORD, BYTE);

// HACK: Define macros that some windows.h variants don't
version(LDC)
{
    static if (__VERSION__ < 2111)
        enum WM_MOUSEHWHEEL = 0x020E;
}
else
{
    static if (__VERSION__ < 2110)
        enum WM_MOUSEHWHEEL = 0x020E;
}

enum WM_DWMCOMPOSITIONCHANGED = 0x031E;
enum WM_COPYGLOBALDATA = 0x0049;
//enum UNICODE_NOCHAR = 0xFFFF;
enum WM_DPICHANGED = 0x02E0;
int GET_XBUTTON_WPARAM(ulong w) {return HIWORD(w);}
enum EDS_ROTATEDMODE = 0x00000004;
enum DISPLAY_DEVICE_ACTIVE = 0x00000001;
enum _WIN32_WINNT_WINBLUE = 0x0602;
enum _WIN32_WINNT_WIN8 = 0x0602;
enum WM_GETDPISCALEDSIZE = 0x02e4;
enum USER_DEFAULT_SCREEN_DPI = 96;
enum OCR_HAND = 32649;

// WINVER < 0x0601
version(all) {
    struct _CHANGEFILTERSTRUCT {
        DWORD cbSize;
        DWORD ExtStatus;
    }
    alias _CHANGEFILTERSTRUCT CHANGEFILTERSTRUCT;

    enum MSGFLT_ALLOW = 1;
} /*Windows 7*/

// WINVER < 0x0600
version(all) {
    enum DWM_BB_ENABLE = 0x00000001;
    enum DWM_BB_BLURREGION = 0x00000002;
    struct _DWM_BLURBEHIND {
        DWORD dwFlags;
        BOOL fEnable;
        HRGN hRgnBlur;
        BOOL fTransitionOnMaximized;
    }
    alias _DWM_BLURBEHIND DWM_BLURBEHIND;
} else {
    //public import dwmapi;
}

version(all) {
    enum PROCESS_DPI_AWARENESS {
        PROCESS_DPI_UNAWARE = 0,
        PROCESS_SYSTEM_DPI_AWARE = 1,
        PROCESS_PER_MONITOR_DPI_AWARE = 2
    }
    enum MONITOR_DPI_TYPE {
        MDT_EFFECTIVE_DPI = 0,
        MDT_ANGULAR_DPI = 1,
        MDT_RAW_DPI = 2,
        MDT_DEFAULT = MDT_EFFECTIVE_DPI
    }

    enum DISP_CHANGE_BADDUALVIEW = -6;
}

enum DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2 = cast(HANDLE) -4;

// HACK: Define versionhelpers.h functions manually as MinGW lacks the header
package {
    enum _WIN32_WINNT_WINXP = 0x0501;
    enum _WIN32_WINNT_VISTA = 0x0600;
    enum _WIN32_WINNT_WIN7 = 0x0601;

    // note: already in core.sys.windows.winver, but not @nogc
    bool IsWindowsXPOrGreater() {
        return cast(bool) _glfwIsWindowsVersionOrGreaterWin32(HIBYTE(_WIN32_WINNT_WINXP),
                                            LOBYTE(_WIN32_WINNT_WINXP), 0);
    }
    bool IsWindowsVistaOrGreater() {
        return cast(bool) _glfwIsWindowsVersionOrGreaterWin32(HIBYTE(_WIN32_WINNT_VISTA),
                                            LOBYTE(_WIN32_WINNT_VISTA), 0);
    }
    bool IsWindows7OrGreater() {
        return cast(bool) _glfwIsWindowsVersionOrGreaterWin32(HIBYTE(_WIN32_WINNT_WIN7),
                                            LOBYTE(_WIN32_WINNT_WIN7), 0);
    }
    bool IsWindows8OrGreater() {
        return cast(bool) _glfwIsWindowsVersionOrGreaterWin32(HIBYTE(_WIN32_WINNT_WIN8),
                                            LOBYTE(_WIN32_WINNT_WIN8), 0);
    }
    bool IsWindows8Point1OrGreater() {
        return cast(bool) _glfwIsWindowsVersionOrGreaterWin32(HIBYTE(_WIN32_WINNT_WINBLUE),
                                            LOBYTE(_WIN32_WINNT_WINBLUE), 0);
    }

    bool _glfwIsWindows10AnniversaryUpdateOrGreaterWin32() {
        return cast(bool) _glfwIsWindows10BuildOrGreaterWin32(14393);
    }
    bool _glfwIsWindows10CreatorsUpdateOrGreaterWin32() {
        return cast(bool) _glfwIsWindows10BuildOrGreaterWin32(15063);
    }

    auto GET_X_LPARAM(T)(T lp) {
        import core.sys.windows.windef : LOWORD;
        return (cast(int)cast(short)LOWORD(lp));
    }
    auto GET_Y_LPARAM(T)(T lp) {
        import core.sys.windows.windef : HIWORD;
        return (cast(int)cast(short)HIWORD(lp));
    }
}

// HACK: Define macros that some xinput.h variants don't
enum XINPUT_CAPS_WIRELESS = 0x0002;
enum XINPUT_DEVSUBTYPE_WHEEL = 0x02;
enum XINPUT_DEVSUBTYPE_ARCADE_STICK = 0x03;
enum XINPUT_DEVSUBTYPE_FLIGHT_STICK = 0x04;
enum XINPUT_DEVSUBTYPE_DANCE_PAD = 0x05;
enum XINPUT_DEVSUBTYPE_GUITAR = 0x06;
enum XINPUT_DEVSUBTYPE_DRUM_KIT = 0x08;
enum XINPUT_DEVSUBTYPE_ARCADE_PAD = 0x13;
enum XUSER_MAX_COUNT = 4;

// HACK: Define macros that some dinput.h variants don't
enum DIDFT_OPTIONAL = 0x80000000;

extern(Windows) {
    // winmm.dll function pointer typedefs
    alias PFN_timeGetTime = DWORD function();
    enum timeGetTime = "_glfw.win32.winmm.GetTime";

    // xinput.dll function pointer typedefs
    alias PFN_XInputGetCapabilities = DWORD function(DWORD,DWORD,XINPUT_CAPABILITIES*);
    alias PFN_XInputGetState = DWORD function(DWORD,XINPUT_STATE*);
    alias PFN_XInputSetState = DWORD function(DWORD,XINPUT_VIBRATION*);
    enum XInputGetCapabilities = "_glfw.win32.xinput.GetCapabilities";
    enum XInputGetState = "_glfw.win32.xinput.GetState";
    enum XInputSetState = "_glfw.win32.xinput.SetState";

    // dinput8.dll function pointer typedefs
    alias PFN_DirectInput8Create = HRESULT function(HINSTANCE,DWORD,REFIID,LPVOID*,LPUNKNOWN);
    enum DirectInput8Create = "_glfw.win32.dinput8.Create";

    // user32.dll function pointer typedefs
    alias PFN_SetProcessDPIAware = BOOL function();
    alias PFN_ChangeWindowMessageFilterEx = BOOL function(HWND,UINT,DWORD,CHANGEFILTERSTRUCT*);
    alias PFN_EnableNonClientDpiScaling = BOOL function(HWND);
    alias PFN_SetProcessDpiAwarenessContext = BOOL function(HANDLE);
    alias PFN_GetDpiForWindow = UINT function(HWND);
    alias PFN_AdjustWindowRectExForDpi = BOOL function(LPRECT,DWORD,BOOL,DWORD,UINT);
    enum SetProcessDPIAware = "_glfw.win32.user32.SetProcessDPIAware_";
    enum ChangeWindowMessageFilterEx = "_glfw.win32.user32.ChangeWindowMessageFilterEx_";
    enum EnableNonClientDpiScaling = "_glfw.win32.user32.EnableNonClientDpiScaling_";
    enum SetProcessDpiAwarenessContext = "_glfw.win32.user32.SetProcessDpiAwarenessContext_";
    enum GetDpiForWindow = "_glfw.win32.user32.GetDpiForWindow_";
    enum AdjustWindowRectExForDpi = "_glfw.win32.user32.AdjustWindowRectExForDpi_";

    // dwmapi.dll function pointer typedefs
    alias PFN_DwmIsCompositionEnabled = HRESULT  function(BOOL*);
    alias PFN_DwmFlush = HRESULT function();
    alias PFN_DwmEnableBlurBehindWindow = HRESULT function(HWND, const(DWM_BLURBEHIND)*);
    enum DwmIsCompositionEnabled = "_glfw.win32.dwmapi.IsCompositionEnabled";
    enum DwmFlush = "_glfw.win32.dwmapi.Flush";
    enum DwmEnableBlurBehindWindow = "_glfw.win32.dwmapi.EnableBlurBehindWindow";

    // shcore.dll function pointer typedefs
    alias PFN_SetProcessDpiAwareness = HRESULT function(PROCESS_DPI_AWARENESS);
    alias PFN_GetDpiForMonitor = HRESULT function(HMONITOR,MONITOR_DPI_TYPE,UINT*,UINT*);
    enum SetProcessDpiAwareness = "_glfw.win32.shcore.SetProcessDpiAwareness_";
    enum GetDpiForMonitor = "_glfw.win32.shcore.GetDpiForMonitor_";

    // ntdll.dll function pointer typedefs
    alias PFN_RtlVerifyVersionInfo = LONG function(OSVERSIONINFOEXW*,ULONG,ULONGLONG);
    alias RtlVerifyVersionInfo = _glfw.win32.ntdll.RtlVerifyVersionInfo_;
}

alias VkFlags VkWin32SurfaceCreateFlagsKHR;

struct VkWin32SurfaceCreateInfoKHR {
    VkStructureType sType = void;
    const(void)* pNext;
    VkWin32SurfaceCreateFlagsKHR flags;
    HINSTANCE hinstance;
    HWND hwnd;
}

alias PFN_vkCreateWin32SurfaceKHR = VkResult function(VkInstance, const(VkWin32SurfaceCreateInfoKHR)*, const(VkAllocationCallbacks)*, VkSurfaceKHR*);
alias PFN_vkGetPhysicalDeviceWin32PresentationSupportKHR = VkBool32 function(VkPhysicalDevice, uint32_t);

import glfw3.internal;
public import glfw3.win32_joystick;
public import glfw3.wgl_context;
public import glfw3.egl_context;
public import glfw3.osmesa_context;

enum _GLFW_WNDCLASSNAME = "GLFW30"w;

auto _glfw_dlopen(const(char)* name) { return LoadLibraryA(name); }
auto _glfw_dlclose(void* handle) { return FreeLibrary(cast(HMODULE) handle); }
auto _glfw_dlsym(void* handle, const(char)* name) { return GetProcAddress(cast(HMODULE) handle, name);}

enum _GLFW_EGL_NATIVE_WINDOW = "cast(EGLNativeWindowType) window.win32.handle";
enum _GLFW_EGL_NATIVE_DISPLAY = EGL_DEFAULT_DISPLAY;

mixin template _GLFW_PLATFORM_WINDOW_STATE() {        _GLFWwindowWin32  win32;}
mixin template _GLFW_PLATFORM_LIBRARY_WINDOW_STATE() {_GLFWlibraryWin32 win32;}
mixin template _GLFW_PLATFORM_LIBRARY_TIMER_STATE() { _GLFWtimerWin32   win32;}
mixin template _GLFW_PLATFORM_MONITOR_STATE() {       _GLFWmonitorWin32 win32;}
mixin template _GLFW_PLATFORM_CURSOR_STATE() {        _GLFWcursorWin32  win32;}
mixin template _GLFW_PLATFORM_TLS_STATE() {           _GLFWtlsWin32     win32;}
mixin template _GLFW_PLATFORM_MUTEX_STATE() {         _GLFWmutexWin32   win32;}

// Win32-specific per-window data
//
struct _GLFWwindowWin32 {
    HWND handle;
    HICON bigIcon;
    HICON smallIcon;

    GLFWbool cursorTracked;
    GLFWbool frameAction;
    GLFWbool iconified;
    GLFWbool maximized;
    // Whether to enable framebuffer transparency on DWM
    GLFWbool transparent;
    GLFWbool scaleToMonitor;

    // The last received cursor position, regardless of source
    int lastCursorPosX;int lastCursorPosY;

}

// Win32-specific global data
//
struct _GLFWlibraryWin32 {
    import core.sys.windows.winuser: HDEVNOTIFY;
    HWND helperWindowHandle;
    HDEVNOTIFY deviceNotificationHandle;
    DWORD foregroundLockTimeout;
    int acquiredMonitorCount;
    char* clipboardString;
    int[512] keycodes;
    int[GLFW_KEY_LAST + 1] scancodes;
    char[5][GLFW_KEY_LAST + 1] keynames = void;
    // Where to place the cursor when re-enabled
    double restoreCursorPosX = 0.0;
    double restoreCursorPosY = 0.0;
    // The window whose disabled cursor mode is active
    _GLFWwindow* disabledCursorWindow;
    RAWINPUT* rawInput;
    int rawInputSize;
    UINT mouseTrailSize;

    struct _Winmm {
        HINSTANCE instance;
        PFN_timeGetTime GetTime;
    }_Winmm winmm;

    struct _Dinput8 {
        HINSTANCE instance;
        PFN_DirectInput8Create Create;
        IDirectInput8 api;
    }_Dinput8 dinput8;

    struct _Xinput {
        HINSTANCE instance;
        PFN_XInputGetCapabilities GetCapabilities;
        PFN_XInputGetState GetState;
        PFN_XInputSetState SetState;
    }_Xinput xinput;

    struct _User32 {
        HINSTANCE instance;
        PFN_SetProcessDPIAware SetProcessDPIAware_;
        PFN_ChangeWindowMessageFilterEx ChangeWindowMessageFilterEx_;
        PFN_EnableNonClientDpiScaling EnableNonClientDpiScaling_;
        PFN_SetProcessDpiAwarenessContext SetProcessDpiAwarenessContext_;
        PFN_GetDpiForWindow GetDpiForWindow_;
        PFN_AdjustWindowRectExForDpi AdjustWindowRectExForDpi_;
    }_User32 user32;

    struct _Dwmapi {
        HINSTANCE instance;
        PFN_DwmIsCompositionEnabled IsCompositionEnabled;
        PFN_DwmFlush Flush;
        PFN_DwmEnableBlurBehindWindow EnableBlurBehindWindow;
    }_Dwmapi dwmapi;

    struct _Shcore {
        HINSTANCE instance;
        PFN_SetProcessDpiAwareness SetProcessDpiAwareness_;
        PFN_GetDpiForMonitor GetDpiForMonitor_;
    }_Shcore shcore;

    struct _Ntdll {
        HINSTANCE instance;
        PFN_RtlVerifyVersionInfo RtlVerifyVersionInfo_;
    }_Ntdll ntdll;

}

// Win32-specific per-monitor data
//
struct _GLFWmonitorWin32 {
    HMONITOR handle;
    // This size matches the static size of DISPLAY_DEVICE.DeviceName
    WCHAR[32] adapterName;
    WCHAR[32] displayName;
    char[32] publicAdapterName;
    char[32] publicDisplayName;
    GLFWbool modesPruned;
    GLFWbool modeChanged;

}

// Win32-specific per-cursor data
//
struct _GLFWcursorWin32 {
    HCURSOR handle;

}

// Win32-specific global timer data
//
struct _GLFWtimerWin32 {
    GLFWbool hasPC;
    ulong frequency;

}

// Win32-specific thread local storage data
//
struct _GLFWtlsWin32 {
    GLFWbool allocated;
    DWORD index;

}

// Win32-specific mutex data
//
struct _GLFWmutexWin32 {
    GLFWbool allocated;
    CRITICAL_SECTION section;

}


GLFWbool _glfwRegisterWindowClassWin32();
void _glfwUnregisterWindowClassWin32();

wchar* _glfwCreateWideStringFromUTF8Win32(const(char)* source);
char* _glfwCreateUTF8FromWideStringWin32(const(wchar)* source);
BOOL _glfwIsWindowsVersionOrGreaterWin32(WORD major, WORD minor, WORD sp);
BOOL _glfwIsWindows10BuildOrGreaterWin32(WORD build);
void _glfwInputErrorWin32(int error, const(char)* description);
void _glfwUpdateKeyNamesWin32();

void _glfwInitTimerWin32();

void _glfwPollMonitorsWin32();
void _glfwSetVideoModeWin32(_GLFWmonitor* monitor, const(GLFWvidmode)* desired);
void _glfwRestoreVideoModeWin32(_GLFWmonitor* monitor);
void _glfwGetMonitorContentScaleWin32(HMONITOR handle, float* xscale, float* yscale);
