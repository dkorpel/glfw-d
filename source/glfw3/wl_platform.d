/// Translated from C to D
module glfw3.wl_platform;

version(Windows):
@nogc nothrow:
extern(C): __gshared:


//========================================================================
// GLFW 3.3 Wayland - www.glfw.org
//------------------------------------------------------------------------
// Copyright (c) 2014 Jonas Ådahl <jadahl@gmail.com>
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

//public import wayland.client;
//public import xkbcommon.xkbcommon;
version(HAVE_XKBCOMMON_COMPOSE_H) {
    public import xkbcommon.xkbcommon_compose;
}
//import xkbcommon.xkbcommon;
public import core.sys.posix.dlfcn;
import glfw3.internal;

alias VkFlags VkWaylandSurfaceCreateFlagsKHR;

struct VkWaylandSurfaceCreateInfoKHR {
    VkStructureType sType;
    const(void)* pNext;
    VkWaylandSurfaceCreateFlagsKHR flags;
    wl_display* display;
    wl_surface* surface;
}

alias VkResult function(VkInstance, const(VkWaylandSurfaceCreateInfoKHR)*, const(VkAllocationCallbacks)*, VkSurfaceKHR*) PFN_vkCreateWaylandSurfaceKHR;
alias VkBool32 function(VkPhysicalDevice, uint, wl_display*) PFN_vkGetPhysicalDeviceWaylandPresentationSupportKHR;

public import glfw3.posix_thread;
public import glfw3.posix_time;
version(linux) {
    public import glfw3.linux_joystick;
} else {
    public import glfw3.null_joystick;
}
public import glfw3.xkb_unicode;
public import glfw3.egl_context;
public import glfw3.osmesa_context;
public import glfw3.wayland;
//public import wayland.client;
//public import wayland-xdg-shell-client-protocol;
//public import wayland-xdg-decoration-client-protocol;
//public import wayland-viewporter-client-protocol;
//public import wayland-relative-pointer-unstable-v1-client-protocol;
//public import wayland-pointer-constraints-unstable-v1-client-protocol;
//public import wayland-idle-inhibit-unstable-v1-client-protocol;

auto _glfw_dlopen(const(char)* name) {return dlopen(name, RTLD_LAZY | RTLD_LOCAL);}
auto _glfw_dlclose(void* handle) {return dlclose(handle);}
auto _glfw_dlsym(void* handle, const(char)* name) {return dlsym(handle, name);}

enum _GLFW_EGL_NATIVE_WINDOW =  `(cast(EGLNativeWindowType) window.wl.native)`;
enum _GLFW_EGL_NATIVE_DISPLAY = `(cast(EGLNativeDisplayType) _glfw.wl.display)`;

mixin template _GLFW_PLATFORM_WINDOW_STATE() {       _GLFWwindowWayland  wl;}
mixin template _GLFW_PLATFORM_LIBRARY_WINDOW_STATE() {_GLFWlibraryWayland wl;}
mixin template _GLFW_PLATFORM_MONITOR_STATE() {      _GLFWmonitorWayland wl;}
mixin template _GLFW_PLATFORM_CURSOR_STATE() {       _GLFWcursorWayland  wl;}

mixin template _GLFW_PLATFORM_CONTEXT_STATE() { int dummyContext; }
mixin template _GLFW_PLATFORM_LIBRARY_CONTEXT_STATE() { int dummyLibraryContext; }

struct wl_cursor_image {
    uint width;
    uint height;
    uint hotspot_x;
    uint hotspot_y;
    uint delay;
}
struct wl_cursor {
    uint image_count;
    wl_cursor_image** images;
    char* name;
}
alias wl_cursor_theme* function(const(char)*, int, wl_shm*) PFN_wl_cursor_theme_load;
alias void function(wl_cursor_theme*) PFN_wl_cursor_theme_destroy;
alias wl_cursor* function(wl_cursor_theme*, const(char)*) PFN_wl_cursor_theme_get_cursor;
alias wl_buffer* function(wl_cursor_image*) PFN_wl_cursor_image_get_buffer;
// wl_cursor_theme_load = _glfw.wl.cursor.theme_load;
// wl_cursor_theme_destroy = _glfw.wl.cursor.theme_destroy;
// wl_cursor_theme_get_cursor = _glfw.wl.cursor.theme_get_cursor;
// wl_cursor_image_get_buffer = _glfw.wl.cursor.image_get_buffer;
// wl_egl_window_create = _glfw.wl.egl.window_create;
// wl_egl_window_destroy = _glfw.wl.egl.window_destroy;
// wl_egl_window_resize = _glfw.wl.egl.window_resize;
// xkb_context_new = _glfw.wl.xkb.context_new;
// xkb_context_unref = _glfw.wl.xkb.context_unref;
// xkb_keymap_new_from_string = _glfw.wl.xkb.keymap_new_from_string;
// xkb_keymap_unref = _glfw.wl.xkb.keymap_unref;
// xkb_keymap_mod_get_index = _glfw.wl.xkb.keymap_mod_get_index;
// xkb_keymap_key_repeats = _glfw.wl.xkb.keymap_key_repeats;
// xkb_state_new = _glfw.wl.xkb.state_new;
// xkb_state_unref = _glfw.wl.xkb.state_unref;
// xkb_state_key_get_syms = _glfw.wl.xkb.state_key_get_syms;
// xkb_state_update_mask = _glfw.wl.xkb.state_update_mask;
// xkb_state_serialize_mods = _glfw.wl.xkb.state_serialize_mods;

alias wl_egl_window* function(wl_surface*, int, int) PFN_wl_egl_window_create;
alias void function(wl_egl_window*) PFN_wl_egl_window_destroy;
alias void function(wl_egl_window*, int, int, int, int) PFN_wl_egl_window_resize;

alias xkb_context* function(xkb_context_flags) PFN_xkb_context_new;
alias void function(xkb_context*) PFN_xkb_context_unref;
alias xkb_keymap* function(xkb_context*, const(char)*, xkb_keymap_format, xkb_keymap_compile_flags) PFN_xkb_keymap_new_from_string;
alias void function(xkb_keymap*) PFN_xkb_keymap_unref;
alias xkb_mod_index_t function(xkb_keymap*, const(char)*) PFN_xkb_keymap_mod_get_index;
alias int function(xkb_keymap*, xkb_keycode_t) PFN_xkb_keymap_key_repeats;
alias xkb_state* function(xkb_keymap*) PFN_xkb_state_new;
alias void function(xkb_state*) PFN_xkb_state_unref;
alias int function(xkb_state*, xkb_keycode_t, const(xkb_keysym_t)**) PFN_xkb_state_key_get_syms;
alias xkb_state_component function(xkb_state*, xkb_mod_mask_t, xkb_mod_mask_t, xkb_mod_mask_t, xkb_layout_index_t, xkb_layout_index_t, xkb_layout_index_t) PFN_xkb_state_update_mask;
alias xkb_mod_mask_t function(xkb_state*, xkb_state_component) PFN_xkb_state_serialize_mods;

version(HAVE_XKBCOMMON_COMPOSE_H) {
    alias xkb_compose_table* function(xkb_context*, const(char)*, xkb_compose_compile_flags) PFN_xkb_compose_table_new_from_locale;
    alias void function(xkb_compose_table*) PFN_xkb_compose_table_unref;
    alias xkb_compose_state* function(xkb_compose_table*, xkb_compose_state_flags) PFN_xkb_compose_state_new;
    alias void function(xkb_compose_state*) PFN_xkb_compose_state_unref;
    alias xkb_compose_feed_result function(xkb_compose_state*, xkb_keysym_t) PFN_xkb_compose_state_feed;
    alias xkb_compose_status function(xkb_compose_state*) PFN_xkb_compose_state_get_status;
    alias xkb_keysym_t function(xkb_compose_state*) PFN_xkb_compose_state_get_one_sym;
    //enum xkb_compose_table_new_from_locale = _glfw.wl.xkb.compose_table_new_from_locale;
    //enum xkb_compose_table_unref = _glfw.wl.xkb.compose_table_unref;
    //enum xkb_compose_state_new = _glfw.wl.xkb.compose_state_new;
    //enum xkb_compose_state_unref = _glfw.wl.xkb.compose_state_unref;
    //enum xkb_compose_state_feed = _glfw.wl.xkb.compose_state_feed;
    //enum xkb_compose_state_get_status = _glfw.wl.xkb.compose_state_get_status;
    //enum xkb_compose_state_get_one_sym = _glfw.wl.xkb.compose_state_get_one_sym;
}

enum _GLFW_DECORATION_WIDTH = 4;
enum _GLFW_DECORATION_TOP = 24;
enum _GLFW_DECORATION_VERTICAL = (_GLFW_DECORATION_TOP + _GLFW_DECORATION_WIDTH);
enum _GLFW_DECORATION_HORIZONTAL = (2 * _GLFW_DECORATION_WIDTH);

enum _GLFWdecorationSideWayland {
    mainWindow,
    topDecoration,
    leftDecoration,
    rightDecoration,
    bottomDecoration,

}
alias mainWindow = _GLFWdecorationSideWayland.mainWindow;
alias topDecoration = _GLFWdecorationSideWayland.topDecoration;
alias leftDecoration = _GLFWdecorationSideWayland.leftDecoration;
alias rightDecoration = _GLFWdecorationSideWayland.rightDecoration;
alias bottomDecoration = _GLFWdecorationSideWayland.bottomDecoration;

struct _GLFWdecorationWayland {
    wl_surface* surface;
    wl_subsurface* subsurface;
    wp_viewport* viewport;

}

// Wayland-specific per-window data
//
struct _GLFWwindowWayland {
    int width;int height;
    GLFWbool visible;
    GLFWbool maximized;
    GLFWbool hovered;
    GLFWbool transparent;
    wl_surface* surface;
    wl_egl_window* native;
    wl_shell_surface* shellSurface;
    wl_callback* callback;

    struct _Xdg {
        xdg_surface* surface;
        xdg_toplevel* toplevel;
        zxdg_toplevel_decoration_v1* decoration;
    }_Xdg xdg;

    _GLFWcursor* currentCursor;
    double cursorPosX;double cursorPosY;

    char* title;

    // We need to track the monitors the window spans on to calculate the
    // optimal scaling factor.
    int scale;
    _GLFWmonitor** monitors;
    int monitorsCount;
    int monitorsSize;

    struct _PointerLock {
        zwp_relative_pointer_v1* relativePointer;
        zwp_locked_pointer_v1* lockedPointer;
    }_PointerLock pointerLock;

    zwp_idle_inhibitor_v1* idleInhibitor;

    GLFWbool wasFullscreen;

    struct _Decorations {
        GLFWbool serverSide;
        wl_buffer* buffer;
        _GLFWdecorationWayland top;_GLFWdecorationWayland left;_GLFWdecorationWayland right;_GLFWdecorationWayland bottom;
        int focus;
    }_Decorations decorations;

}

// Wayland-specific global data
//
struct _GLFWlibraryWayland {
    wl_display* display;
    wl_registry* registry;
    wl_compositor* compositor;
    wl_subcompositor* subcompositor;
    wl_shell* shell;
    wl_shm* shm;
    wl_seat* seat;
    wl_pointer* pointer;
    wl_keyboard* keyboard;
    wl_data_device_manager* dataDeviceManager;
    wl_data_device* dataDevice;
    wl_data_offer* dataOffer;
    wl_data_source* dataSource;
    xdg_wm_base* wmBase;
    zxdg_decoration_manager_v1* decorationManager;
    wp_viewporter* viewporter;
    zwp_relative_pointer_manager_v1* relativePointerManager;
    zwp_pointer_constraints_v1* pointerConstraints;
    zwp_idle_inhibit_manager_v1* idleInhibitManager;

    int compositorVersion;
    int seatVersion;

    wl_cursor_theme* cursorTheme;
    wl_cursor_theme* cursorThemeHiDPI;
    wl_surface* cursorSurface;
    const(char)* cursorPreviousName;
    int cursorTimerfd;
    uint serial;

    int keyboardRepeatRate;
    int keyboardRepeatDelay;
    int keyboardLastKey;
    int keyboardLastScancode;
    char* clipboardString;
    size_t clipboardSize;
    char* clipboardSendString;
    size_t clipboardSendSize;
    int timerfd;
    int[256] keycodes;
    int[GLFW_KEY_LAST + 1] scancodes;

    struct _Xkb {
        void* handle;
        xkb_context* context;
        xkb_keymap* keymap;
        xkb_state* state;

version(HAVE_XKBCOMMON_COMPOSE_H) {
        xkb_compose_state* composeState;
}

        xkb_mod_mask_t controlMask;
        xkb_mod_mask_t altMask;
        xkb_mod_mask_t shiftMask;
        xkb_mod_mask_t superMask;
        xkb_mod_mask_t capsLockMask;
        xkb_mod_mask_t numLockMask;
        uint modifiers;

        PFN_xkb_context_new context_new;
        PFN_xkb_context_unref context_unref;
        PFN_xkb_keymap_new_from_string keymap_new_from_string;
        PFN_xkb_keymap_unref keymap_unref;
        PFN_xkb_keymap_mod_get_index keymap_mod_get_index;
        PFN_xkb_keymap_key_repeats keymap_key_repeats;
        PFN_xkb_state_new state_new;
        PFN_xkb_state_unref state_unref;
        PFN_xkb_state_key_get_syms state_key_get_syms;
        PFN_xkb_state_update_mask state_update_mask;
        PFN_xkb_state_serialize_mods state_serialize_mods;

version(HAVE_XKBCOMMON_COMPOSE_H) {
        PFN_xkb_compose_table_new_from_locale compose_table_new_from_locale;
        PFN_xkb_compose_table_unref compose_table_unref;
        PFN_xkb_compose_state_new compose_state_new;
        PFN_xkb_compose_state_unref compose_state_unref;
        PFN_xkb_compose_state_feed compose_state_feed;
        PFN_xkb_compose_state_get_status compose_state_get_status;
        PFN_xkb_compose_state_get_one_sym compose_state_get_one_sym;
}
    }_Xkb xkb;

    _GLFWwindow* pointerFocus;
    _GLFWwindow* keyboardFocus;

    struct _Cursor {
        void* handle;

        PFN_wl_cursor_theme_load theme_load;
        PFN_wl_cursor_theme_destroy theme_destroy;
        PFN_wl_cursor_theme_get_cursor theme_get_cursor;
        PFN_wl_cursor_image_get_buffer image_get_buffer;
    }_Cursor cursor;

    struct _Egl {
        void* handle;

        PFN_wl_egl_window_create window_create;
        PFN_wl_egl_window_destroy window_destroy;
        PFN_wl_egl_window_resize window_resize;
    }_Egl egl;

}

// Wayland-specific per-monitor data
//
struct _GLFWmonitorWayland {
    wl_output* output;
    uint name;
    int currentMode;

    int x;
    int y;
    int scale;

}

// Wayland-specific per-cursor data
//
struct _GLFWcursorWayland {
    wl_cursor* cursor;
    wl_cursor* cursorHiDPI;
    wl_buffer* buffer;
    int width;int height;
    int xhot;int yhot;
    int currentImage;
}


void _glfwAddOutputWayland(uint name, uint version_);
