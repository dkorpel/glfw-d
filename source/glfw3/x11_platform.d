/// Translated from C to D
module glfw3.x11_platform;

version(linux):
nothrow:
extern(C): __gshared:
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

import core.sys.posix.unistd;
import core.stdc.signal;
import core.stdc.stdint;
import core.sys.posix.dlfcn;
import core.stdc.config: c_long, c_ulong;

version(none) {
    public import x11.X;
    public import x11.Xutil;
    public import x11.extensions.Xrender;
    public import x11.extensions.randr;
    public import x11.Xcursor;

    public import x11.Xlib;
    public import x11.keysym;
    public import x11.Xatom;

    // The XRandR extension provides mode setting and gamma control
    public import x11.extensions.Xrandr;

    // The Xkb extension provides improved keyboard support
    //public import x11.XKBlib;

    // The Xinerama extension provides legacy monitor indices
    public import x11.extensions.Xinerama;

    // The XInput extension provides raw mouse motion input
    public import x11.extensions.XInput2;
} else {
    public import glfw3.x11_header;
}

alias XRRCrtcGamma* function(int) PFN_XRRAllocGamma;
alias void function(XRRCrtcInfo*) PFN_XRRFreeCrtcInfo;
alias void function(XRRCrtcGamma*) PFN_XRRFreeGamma;
alias void function(XRROutputInfo*) PFN_XRRFreeOutputInfo;
alias void function(XRRScreenResources*) PFN_XRRFreeScreenResources;
alias XRRCrtcGamma* function(Display*, RRCrtc) PFN_XRRGetCrtcGamma;
alias int function(Display*, RRCrtc) PFN_XRRGetCrtcGammaSize;
alias XRRCrtcInfo* function(Display*, XRRScreenResources*, RRCrtc) PFN_XRRGetCrtcInfo;
alias XRROutputInfo* function(Display*, XRRScreenResources*, RROutput) PFN_XRRGetOutputInfo;
alias RROutput function(Display*, Window) PFN_XRRGetOutputPrimary;
alias XRRScreenResources* function(Display*, Window) PFN_XRRGetScreenResourcesCurrent;
alias Bool function(Display*, int*, int*) PFN_XRRQueryExtension;
alias Status function(Display*, int*, int*) PFN_XRRQueryVersion;
alias void function(Display*, Window, int) PFN_XRRSelectInput;
alias Status function(Display*, XRRScreenResources*, RRCrtc, Time, int, int, RRMode, Rotation, RROutput*, int) PFN_XRRSetCrtcConfig;
alias void function(Display*, RRCrtc, XRRCrtcGamma*) PFN_XRRSetCrtcGamma;
alias int function(XEvent*) PFN_XRRUpdateConfiguration;
alias XRRAllocGamma = _glfw.x11.randr.AllocGamma;
alias XRRFreeCrtcInfo = _glfw.x11.randr.FreeCrtcInfo;
alias XRRFreeGamma = _glfw.x11.randr.FreeGamma;
alias XRRFreeOutputInfo = _glfw.x11.randr.FreeOutputInfo;
alias XRRFreeScreenResources = _glfw.x11.randr.FreeScreenResources;
alias XRRGetCrtcGamma = _glfw.x11.randr.GetCrtcGamma;
alias XRRGetCrtcGammaSize = _glfw.x11.randr.GetCrtcGammaSize;
alias XRRGetCrtcInfo = _glfw.x11.randr.GetCrtcInfo;
alias XRRGetOutputInfo = _glfw.x11.randr.GetOutputInfo;
alias XRRGetOutputPrimary = _glfw.x11.randr.GetOutputPrimary;
alias XRRGetScreenResourcesCurrent = _glfw.x11.randr.GetScreenResourcesCurrent;
alias XRRQueryExtension = _glfw.x11.randr.QueryExtension;
alias XRRQueryVersion = _glfw.x11.randr.QueryVersion;
alias XRRSelectInput = _glfw.x11.randr.SelectInput;
alias XRRSetCrtcConfig = _glfw.x11.randr.SetCrtcConfig;
alias XRRSetCrtcGamma = _glfw.x11.randr.SetCrtcGamma;
alias XRRUpdateConfiguration = _glfw.x11.randr.UpdateConfiguration;

alias XcursorImage* function(int, int) PFN_XcursorImageCreate;
alias void function(XcursorImage*) PFN_XcursorImageDestroy;
alias Cursor function(Display*, const(XcursorImage)*) PFN_XcursorImageLoadCursor;
alias XcursorImageCreate = _glfw.x11.xcursor.ImageCreate;
alias XcursorImageDestroy = _glfw.x11.xcursor.ImageDestroy;
alias XcursorImageLoadCursor = _glfw.x11.xcursor.ImageLoadCursor;

alias Bool function(Display*) PFN_XineramaIsActive;
alias Bool function(Display*, int*, int*) PFN_XineramaQueryExtension;
alias XineramaScreenInfo* function(Display*, int*) PFN_XineramaQueryScreens;
alias XineramaIsActive = _glfw.x11.xinerama.IsActive;
alias XineramaQueryExtension = _glfw.x11.xinerama.QueryExtension;
alias XineramaQueryScreens = _glfw.x11.xinerama.QueryScreens;

alias XID xcb_window_t;
alias XID xcb_visualid_t;
struct xcb_connection_t;
alias xcb_connection_t* function(Display*) PFN_XGetXCBConnection;
alias XGetXCBConnection = _glfw.x11.x11xcb.GetXCBConnection;

alias Bool function(Display*, int*, int*) PFN_XF86VidModeQueryExtension;
alias Bool function(Display*, int, int, ushort*, ushort*, ushort*) PFN_XF86VidModeGetGammaRamp;
alias Bool function(Display*, int, int, ushort*, ushort*, ushort*) PFN_XF86VidModeSetGammaRamp;
alias Bool function(Display*, int, int*) PFN_XF86VidModeGetGammaRampSize;
alias XF86VidModeQueryExtension = _glfw.x11.vidmode.QueryExtension;
alias XF86VidModeGetGammaRamp = _glfw.x11.vidmode.GetGammaRamp;
alias XF86VidModeSetGammaRamp = _glfw.x11.vidmode.SetGammaRamp;
alias XF86VidModeGetGammaRampSize = _glfw.x11.vidmode.GetGammaRampSize;

alias Status function(Display*, int*, int*) PFN_XIQueryVersion;
alias int function(Display*, Window, XIEventMask*, int) PFN_XISelectEvents;
alias XIQueryVersion = _glfw.x11.xi.QueryVersion;
alias XISelectEvents = _glfw.x11.xi.SelectEvents;

alias Bool function(Display*, int*, int*) PFN_XRenderQueryExtension;
alias Status function(Display* dpy, int*, int*) PFN_XRenderQueryVersion;
alias XRenderPictFormat* function(Display*, const(Visual)*) PFN_XRenderFindVisualFormat;
alias XRenderQueryExtension = _glfw.x11.xrender.QueryExtension;
alias XRenderQueryVersion = _glfw.x11.xrender.QueryVersion;
alias XRenderFindVisualFormat = _glfw.x11.xrender.FindVisualFormat;

alias VkFlags VkXlibSurfaceCreateFlagsKHR;
alias VkFlags VkXcbSurfaceCreateFlagsKHR;

struct VkXlibSurfaceCreateInfoKHR {
    VkStructureType sType = void;
    const(void)* pNext;
    VkXlibSurfaceCreateFlagsKHR flags;
    Display* dpy;
    Window window;
}

struct VkXcbSurfaceCreateInfoKHR {
    VkStructureType sType = void;
    const(void)* pNext;
    VkXcbSurfaceCreateFlagsKHR flags;
    xcb_connection_t* connection;
    xcb_window_t window;
}

alias VkResult function(VkInstance, const(VkXlibSurfaceCreateInfoKHR)*, const(VkAllocationCallbacks)*, VkSurfaceKHR*) PFN_vkCreateXlibSurfaceKHR;
alias VkBool32 function(VkPhysicalDevice, uint, Display*, VisualID) PFN_vkGetPhysicalDeviceXlibPresentationSupportKHR;
alias VkResult function(VkInstance, const(VkXcbSurfaceCreateInfoKHR)*, const(VkAllocationCallbacks)*, VkSurfaceKHR*) PFN_vkCreateXcbSurfaceKHR;
alias VkBool32 function(VkPhysicalDevice, uint, xcb_connection_t*, xcb_visualid_t) PFN_vkGetPhysicalDeviceXcbPresentationSupportKHR;

public import glfw3.posix_thread;
public import glfw3.posix_time;
public import glfw3.xkb_unicode;
public import glfw3.glx_context;
public import glfw3.egl_context;
public import glfw3.osmesa_context;
import glfw3.internal;

version(linux) {
    public import glfw3.linux_joystick;
} else {
    public import glfw3.null_joystick;
}

auto _glfw_dlopen(const(char)* name) {return dlopen(name, RTLD_LAZY | RTLD_LOCAL);}
auto _glfw_dlclose(void* handle) {return dlclose(handle);}
auto _glfw_dlsym(void* handle, const(char)* name) {return dlsym(handle, name);}

enum _GLFW_EGL_NATIVE_WINDOW =  `(cast(EGLNativeWindowType) window.x11.handle)`;
enum _GLFW_EGL_NATIVE_DISPLAY = `(cast(EGLNativeDisplayType) _glfw.x11.display)`;

mixin template _GLFW_PLATFORM_WINDOW_STATE() {         _GLFWwindowX11  x11;}
mixin template _GLFW_PLATFORM_LIBRARY_WINDOW_STATE() { _GLFWlibraryX11 x11;}
mixin template _GLFW_PLATFORM_MONITOR_STATE() {        _GLFWmonitorX11 x11;}
mixin template _GLFW_PLATFORM_CURSOR_STATE() {         _GLFWcursorX11  x11;}

// X11-specific per-window data
//
struct _GLFWwindowX11 {
    Colormap colormap;
    Window handle;
    Window parent;
    XIC ic;

    GLFWbool overrideRedirect;
    GLFWbool iconified;
    GLFWbool maximized;

    // Whether the visual supports framebuffer transparency
    GLFWbool transparent;

    // Cached position and size used to filter out duplicate events
    int width;
    int height;
    int xpos;
    int ypos;

    // The last received cursor position, regardless of source
    int lastCursorPosX;
    int lastCursorPosY;
    // The last position the cursor was warped to by GLFW
    int warpCursorPosX;
    int warpCursorPosY;

    // The time of the last KeyPress event
    Time lastKeyTime;

}

// X11-specific global data
//
struct _GLFWlibraryX11 {
    Display* display;
    int screen;
    Window root;

    // System content scale
    float contentScaleX = 0.0;
    float contentScaleY = 0.0;
    // Helper window for IPC
    Window helperWindowHandle;
    // Invisible cursor for hidden cursor mode
    Cursor hiddenCursorHandle;
    // Context for mapping window XIDs to _GLFWwindow pointers
    XContext context;
    // XIM input method
    XIM im;
    // Most recent error code received by X error handler
    int errorCode;
    // Primary selection string (while the primary selection is owned)
    char* primarySelectionString;
    // Clipboard string (while the selection is owned)
    char* clipboardString;
    // Key name string
    char[5][GLFW_KEY_LAST + 1] keynames = void; // ='\0'; older dmd versions can't initialize 2D static array with element
    // X11 keycode to GLFW key LUT
    int[256] keycodes;
    // GLFW key to X11 keycode LUT
    int[GLFW_KEY_LAST + 1] scancodes;
    // Where to place the cursor when re-enabled
    double restoreCursorPosX = 0.0;
    double restoreCursorPosY = 0.0;
    // The window whose disabled cursor mode is active
    _GLFWwindow* disabledCursorWindow;

    // Window manager atoms
    Atom NET_SUPPORTED;
    Atom NET_SUPPORTING_WM_CHECK;
    Atom WM_PROTOCOLS;
    Atom WM_STATE;
    Atom WM_DELETE_WINDOW;
    Atom NET_WM_NAME;
    Atom NET_WM_ICON_NAME;
    Atom NET_WM_ICON;
    Atom NET_WM_PID;
    Atom NET_WM_PING;
    Atom NET_WM_WINDOW_TYPE;
    Atom NET_WM_WINDOW_TYPE_NORMAL;
    Atom NET_WM_STATE;
    Atom NET_WM_STATE_ABOVE;
    Atom NET_WM_STATE_FULLSCREEN;
    Atom NET_WM_STATE_MAXIMIZED_VERT;
    Atom NET_WM_STATE_MAXIMIZED_HORZ;
    Atom NET_WM_STATE_DEMANDS_ATTENTION;
    Atom NET_WM_BYPASS_COMPOSITOR;
    Atom NET_WM_FULLSCREEN_MONITORS;
    Atom NET_WM_WINDOW_OPACITY;
    Atom NET_WM_CM_Sx;
    Atom NET_WORKAREA;
    Atom NET_CURRENT_DESKTOP;
    Atom NET_ACTIVE_WINDOW;
    Atom NET_FRAME_EXTENTS;
    Atom NET_REQUEST_FRAME_EXTENTS;
    Atom MOTIF_WM_HINTS;

    // Xdnd (drag and drop) atoms
    Atom XdndAware;
    Atom XdndEnter;
    Atom XdndPosition;
    Atom XdndStatus;
    Atom XdndActionCopy;
    Atom XdndDrop;
    Atom XdndFinished;
    Atom XdndSelection;
    Atom XdndTypeList;
    Atom text_uri_list;

    // Selection (clipboard) atoms
    Atom TARGETS;
    Atom MULTIPLE;
    Atom INCR;
    Atom CLIPBOARD;
    Atom PRIMARY;
    Atom CLIPBOARD_MANAGER;
    Atom SAVE_TARGETS;
    Atom NULL_;
    Atom UTF8_STRING;
    Atom COMPOUND_STRING;
    Atom ATOM_PAIR;
    Atom GLFW_SELECTION;

    struct _Randr {
        GLFWbool available;
        void* handle;
        int eventBase;
        int errorBase;
        int major;
        int minor;
        GLFWbool gammaBroken;
        GLFWbool monitorBroken;
        PFN_XRRAllocGamma AllocGamma;
        PFN_XRRFreeCrtcInfo FreeCrtcInfo;
        PFN_XRRFreeGamma FreeGamma;
        PFN_XRRFreeOutputInfo FreeOutputInfo;
        PFN_XRRFreeScreenResources FreeScreenResources;
        PFN_XRRGetCrtcGamma GetCrtcGamma;
        PFN_XRRGetCrtcGammaSize GetCrtcGammaSize;
        PFN_XRRGetCrtcInfo GetCrtcInfo;
        PFN_XRRGetOutputInfo GetOutputInfo;
        PFN_XRRGetOutputPrimary GetOutputPrimary;
        PFN_XRRGetScreenResourcesCurrent GetScreenResourcesCurrent;
        PFN_XRRQueryExtension QueryExtension;
        PFN_XRRQueryVersion QueryVersion;
        PFN_XRRSelectInput SelectInput;
        PFN_XRRSetCrtcConfig SetCrtcConfig;
        PFN_XRRSetCrtcGamma SetCrtcGamma;
        PFN_XRRUpdateConfiguration UpdateConfiguration;
    }_Randr randr;

    struct _Xkb {
        GLFWbool available;
        GLFWbool detectable;
        int majorOpcode;
        int eventBase;
        int errorBase;
        int major;
        int minor;
        uint group;
    }_Xkb xkb;

    struct _Saver {
        int count;
        int timeout;
        int interval;
        int blanking;
        int exposure;
    }_Saver saver;

    struct _Xdnd {
        int version_;
        Window source;
        Atom format;
    }_Xdnd xdnd;

    struct _Xcursor {
        void* handle;
        PFN_XcursorImageCreate ImageCreate;
        PFN_XcursorImageDestroy ImageDestroy;
        PFN_XcursorImageLoadCursor ImageLoadCursor;
    }_Xcursor xcursor;

    struct _Xinerama {
        GLFWbool available;
        void* handle;
        int major;
        int minor;
        PFN_XineramaIsActive IsActive;
        PFN_XineramaQueryExtension QueryExtension;
        PFN_XineramaQueryScreens QueryScreens;
    }_Xinerama xinerama;

    struct _X11xcb {
        void* handle;
        PFN_XGetXCBConnection GetXCBConnection;
    }_X11xcb x11xcb;

    struct _Vidmode {
        GLFWbool available;
        void* handle;
        int eventBase;
        int errorBase;
        PFN_XF86VidModeQueryExtension QueryExtension;
        PFN_XF86VidModeGetGammaRamp GetGammaRamp;
        PFN_XF86VidModeSetGammaRamp SetGammaRamp;
        PFN_XF86VidModeGetGammaRampSize GetGammaRampSize;
    }_Vidmode vidmode;

    struct _Xi {
        GLFWbool available;
        void* handle;
        int majorOpcode;
        int eventBase;
        int errorBase;
        int major;
        int minor;
        PFN_XIQueryVersion QueryVersion;
        PFN_XISelectEvents SelectEvents;
    }_Xi xi;

    struct _Xrender {
        GLFWbool available;
        void* handle;
        int major;
        int minor;
        int eventBase;
        int errorBase;
        PFN_XRenderQueryExtension QueryExtension;
        PFN_XRenderQueryVersion QueryVersion;
        PFN_XRenderFindVisualFormat FindVisualFormat;
    }_Xrender xrender;

}

// X11-specific per-monitor data
//
struct _GLFWmonitorX11 {
    RROutput output;
    RRCrtc crtc;
    RRMode oldMode;

    // Index of corresponding Xinerama screen,
    // for EWMH full screen window placement
    int index;

}

// X11-specific per-cursor data
//
struct _GLFWcursorX11 {
    Cursor handle;

}


void _glfwPollMonitorsX11();
void _glfwSetVideoModeX11(_GLFWmonitor* monitor, const(GLFWvidmode)* desired);
void _glfwRestoreVideoModeX11(_GLFWmonitor* monitor);

Cursor _glfwCreateCursorX11(const(GLFWimage)* image, int xhot, int yhot);

c_ulong _glfwGetWindowPropertyX11(Window window, Atom property, Atom type, ubyte** value);
GLFWbool _glfwIsVisualTransparentX11(Visual* visual);

void _glfwGrabErrorHandlerX11();
void _glfwReleaseErrorHandlerX11();
void _glfwInputErrorX11(int error, const(char)* message);

void _glfwPushSelectionToManagerX11();
