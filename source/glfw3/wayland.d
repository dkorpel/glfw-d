module glfw3.wayland;

version(TODO):
extern(C): nothrow: @nogc:

// extensions

struct zxdg_toplevel_decoration_v1_listener {
extern(C): nothrow: @nogc:
	void function(void* data, zxdg_toplevel_decoration_v1* decoration, uint mode) configure;
}

struct xdg_toplevel_listener {
extern(C): nothrow: @nogc:
	void function(void* data, xdg_toplevel* toplevel, int width, int height, wl_array* states) configure;
	void function(void* data, xdg_toplevel* toplevel) close;
}

struct xdg_surface_listener {
extern(C): nothrow: @nogc:
	void function(void* data, xdg_surface* surface, uint serial) configure;
}

struct zwp_relative_pointer_v1_listener {
extern(C): nothrow: @nogc:
	void function(void* data, zwp_relative_pointer_v1* pointer, uint timeHi, uint timeLo, wl_fixed_t dx, wl_fixed_t dy, wl_fixed_t dxUnaccel, wl_fixed_t dyUnaccel) relativeMotion;
}

struct zwp_locked_pointer_v1_listener {
extern(C): nothrow: @nogc:
	void function(void* data, zwp_locked_pointer_v1* lockedPointer) locked;
	void function(void* data, zwp_locked_pointer_v1* lockedPointer) unlocked;
}

//
struct wl_buffer;
struct wl_callback;
struct wl_compositor;
struct wl_cursor_theme;
struct wl_data_device_manager;
struct wl_data_device;
struct wl_data_offer;
struct wl_data_source;
struct wl_display;
struct wl_egl_window;
struct wl_keyboard;
struct wl_output;
struct wl_pointer;
struct wl_region;
struct wl_registry;
struct wl_seat;
struct wl_shell_surface;
struct wl_shell;
struct wl_shm_pool;
struct wl_shm;
struct wl_subcompositor;
struct wl_subsurface;
struct wl_surface;
struct wl_touch;
struct wp_viewport;
struct wp_viewporter;
struct xdg_surface;
struct xdg_toplevel;
struct xdg_wm_base;
struct zwp_idle_inhibit_manager_v1;
struct zwp_idle_inhibitor_v1;
struct zwp_locked_pointer_v1;
struct zwp_pointer_constraints_v1;
struct zwp_relative_pointer_manager_v1;
struct zwp_relative_pointer_v1;
struct zxdg_decoration_manager_v1;
struct zxdg_toplevel_decoration_v1;

alias wl_fixed_t = uint;

pure @safe nothrow @nogc
pragma(inline, true) double wl_fixed_to_double(wl_fixed_t f) {
	static struct U {
		union {
			double d;
			ulong i;
		}
	}
	U u;
	u.i = ((1023L + 44L) << 52) + (1L << 51) + f;
	return u.d - (3L << 43);
}

struct wl_array {
	size_t size;
	size_t alloc;
	void *data;
}

enum wl_seat_capability {
	WL_SEAT_CAPABILITY_POINTER = 1,
	WL_SEAT_CAPABILITY_KEYBOARD = 2,
	WL_SEAT_CAPABILITY_TOUCH = 4,
}
enum WL_SEAT_CAPABILITY_POINTER = wl_seat_capability.WL_SEAT_CAPABILITY_POINTER;
enum WL_SEAT_CAPABILITY_KEYBOARD = wl_seat_capability.WL_SEAT_CAPABILITY_KEYBOARD;
enum WL_SEAT_CAPABILITY_TOUCH = wl_seat_capability.WL_SEAT_CAPABILITY_TOUCH;

enum wl_output_mode {
	WL_OUTPUT_MODE_CURRENT = 0x1,
	WL_OUTPUT_MODE_PREFERRED = 0x2,
}
enum WL_OUTPUT_MODE_CURRENT = wl_output_mode.WL_OUTPUT_MODE_CURRENT;
enum WL_OUTPUT_MODE_PREFERRED = wl_output_mode.WL_OUTPUT_MODE_PREFERRED;

enum wl_pointer_button_state {
	WL_POINTER_BUTTON_STATE_RELEASED = 0,
	WL_POINTER_BUTTON_STATE_PRESSED = 1,
}
enum WL_POINTER_BUTTON_STATE_RELEASED = wl_pointer_button_state.WL_POINTER_BUTTON_STATE_RELEASED;
enum WL_POINTER_BUTTON_STATE_PRESSED = wl_pointer_button_state.WL_POINTER_BUTTON_STATE_PRESSED;

enum wl_keyboard_key_state {
	WL_KEYBOARD_KEY_STATE_RELEASED = 0,
	WL_KEYBOARD_KEY_STATE_PRESSED = 1,
}
enum WL_KEYBOARD_KEY_STATE_RELEASED = wl_keyboard_key_state.WL_KEYBOARD_KEY_STATE_RELEASED;
enum WL_KEYBOARD_KEY_STATE_PRESSED = wl_keyboard_key_state.WL_KEYBOARD_KEY_STATE_PRESSED;

enum wl_pointer_axis {
	WL_POINTER_AXIS_VERTICAL_SCROLL = 0,
	WL_POINTER_AXIS_HORIZONTAL_SCROLL = 1,
}
enum WL_POINTER_AXIS_VERTICAL_SCROLL = wl_pointer_axis.WL_POINTER_AXIS_VERTICAL_SCROLL;
enum WL_POINTER_AXIS_HORIZONTAL_SCROLL = wl_pointer_axis.WL_POINTER_AXIS_HORIZONTAL_SCROLL;

enum wl_keyboard_keymap_format {
	WL_KEYBOARD_KEYMAP_FORMAT_NO_KEYMAP = 0,
	WL_KEYBOARD_KEYMAP_FORMAT_XKB_V1 = 1,
}
enum WL_KEYBOARD_KEYMAP_FORMAT_NO_KEYMAP = wl_keyboard_keymap_format.WL_KEYBOARD_KEYMAP_FORMAT_NO_KEYMAP;
enum WL_KEYBOARD_KEYMAP_FORMAT_XKB_V1 = wl_keyboard_keymap_format.WL_KEYBOARD_KEYMAP_FORMAT_XKB_V1;

struct wl_message {
	const(char)* name;
	const(char)* signature;
	const(wl_interface)** types;
}

struct wl_interface {
	const char *name;
	int version_;
	int method_count;
	const(wl_message)* methods;
	int event_count;
	const(wl_message)* events;
}

/*
wl_array_for_each(pos, array)
	for (pos = (array)->data;
	     (const char *) pos < ((const char *) (array)->data + (array)->size);
	     (pos)++)
*/

struct wl_pointer_listener {
	extern(C): @nogc: nothrow:
	void function(void* data, wl_pointer* wl_pointer, uint serial, wl_surface* surface, wl_fixed_t surface_x, wl_fixed_t surface_y) enter;
	void function(void* data, wl_pointer* wl_pointer, uint serial, wl_surface* surface) leave;
	void function(void* data, wl_pointer* wl_pointer, uint time, wl_fixed_t surface_x, wl_fixed_t surface_y) motion;
	void function(void* data, wl_pointer* wl_pointer, uint serial, uint time, uint button, uint state) button;
	void function(void* data, wl_pointer* wl_pointer, uint time, uint axis, wl_fixed_t value) axis;
	void function(void* data, wl_pointer* wl_pointer) frame;
	void function(void* data, wl_pointer* wl_pointer, uint axis_source) axis_source;
	void function(void* data, wl_pointer* wl_pointer, uint time, uint axis) axis_stop;
	void function(void* data, wl_pointer* wl_pointer, uint axis, int discrete) axis_discrete;
}

struct wl_keyboard_listener {
	extern(C): @nogc: nothrow:
	void function(void* data, wl_keyboard* wl_keyboard, uint format, int fd, uint size) keymap;
	void function(void* data, wl_keyboard* wl_keyboard, uint serial, wl_surface* surface, wl_array* keys) enter;
	void function(void* data, wl_keyboard* wl_keyboard, uint serial, wl_surface* surface) leave;
	void function(void* data, wl_keyboard* wl_keyboard, uint serial, uint time, uint key, uint state) key;
	void function(void* data, wl_keyboard* wl_keyboard, uint serial, uint mods_depressed, uint mods_latched, uint mods_locked, uint group) modifiers;
	void function(void* data, wl_keyboard* wl_keyboard, int rate, int delay) repeat_info;
}

struct wl_seat_listener {
	extern(C): @nogc: nothrow:
	void function(void* data, wl_seat* wl_seat, uint capabilities) capabilities;
	void function(void* data, wl_seat* wl_seat, const(char)* name) name;
}
struct wl_data_offer_listener {
	extern(C): @nogc: nothrow:
	void function(void* data, wl_data_offer* wl_data_offer, const(char)* mime_type) offer;
	void function(void* data, wl_data_offer* wl_data_offer, uint source_actions) source_actions;
	void function(void* data, wl_data_offer* wl_data_offer, uint dnd_action) action;
}

struct wl_surface_listener {
	extern(C): @nogc: nothrow:
	void function(void* data, wl_surface* wl_surface, wl_output* output) enter;
	void function(void* data, wl_surface* wl_surface, wl_output* output) leave;
}

struct wl_data_device_listener {
	extern(C): @nogc: nothrow:
	void function(void* data, wl_data_device* wl_data_device, wl_data_offer* id) data_offer;
	void function(void* data, wl_data_device* wl_data_device, uint serial, wl_surface* surface, wl_fixed_t x, wl_fixed_t y, wl_data_offer* id) enter;
	void function(void* data, wl_data_device* wl_data_device) leave;
	void function(void* data, wl_data_device* wl_data_device, uint time, wl_fixed_t x, wl_fixed_t y) motion;
	void function(void* data, wl_data_device* wl_data_device) drop;
	void function(void* data, wl_data_device* wl_data_device, wl_data_offer* id) selection;
}

struct wl_registry_listener {
	extern(C): @nogc: nothrow:
	void function(void* data, wl_registry* wl_registry, uint name, const(char)* interface_, uint version_) global;
	void function(void* data, wl_registry* wl_registry, uint name) global_remove;
}

struct wl_output_listener {
	extern(C): @nogc: nothrow:
	void function(void* data, wl_output* wl_output, int x, int y, int physical_width, int physical_height, int subpixel, const(char)* make, const(char)* model, int transform) geometry;
	void function(void* data, wl_output* wl_output, uint flags, int width, int height, int refresh) mode;
	void function(void* data, wl_output* wl_output) done;
	void function(void* data, wl_output* wl_output, int factor) scale;
}
struct wl_data_source_listener {
	extern(C): @nogc: nothrow:
	void function(void* data, wl_data_source* wl_data_source, const(char)* mime_type) target;
	void function(void* data, wl_data_source* wl_data_source, const(char)* mime_type, int fd) send;
	void function(void* data, wl_data_source* wl_data_source) cancelled;
	void function(void* data, wl_data_source* wl_data_source) dnd_drop_performed;
	void function(void* data, wl_data_source* wl_data_source) dnd_finished;
	void function(void* data, wl_data_source* wl_data_source, uint dnd_action) action;
}

// note: I have no idea where this is defined in C headers, but this is how it's used in GLFW
struct xdg_wm_base_listener {
	extern(C): @nogc: nothrow:
	void function(void* data, xdg_wm_base* wmBase, uint serial) ping;
}

struct wl_shell_surface_listener {
	extern(C): @nogc: nothrow:
	void function(void* data, wl_shell_surface* wl_shell_surface, uint serial) ping;
	void function(void* data, wl_shell_surface* wl_shell_surface, uint edges, int width, int height) configure;
	void function(void* data, wl_shell_surface* wl_shell_surface) popup_done;
}

pragma(inline, true) private void* wl_registry_bind(wl_registry* wl_registry, uint name, const(wl_interface)* interface_, uint version_) {
	wl_proxy* id;
	id = wl_proxy_marshal_constructor_versioned(cast(wl_proxy*) wl_registry,
			 WL_REGISTRY_BIND, interface_, version_, name, interface_.name, version_, null);

	return cast(void*) id;
}

pragma(inline, true) private int wl_output_add_listener(wl_output* wl_output, const(wl_output_listener)* listener, void* data) {
	return wl_proxy_add_listener(cast(wl_proxy*) wl_output,
				     cast(void function()) listener, data);
}

pragma(inline, true) private void wl_output_destroy(wl_output* wl_output) {
	wl_proxy_destroy(cast(wl_proxy*) wl_output);
}

extern const wl_interface wl_display_interface;
extern const wl_interface wl_registry_interface;
extern const wl_interface wl_callback_interface;
extern const wl_interface wl_compositor_interface;
extern const wl_interface wl_shm_pool_interface;
extern const wl_interface wl_shm_interface;
extern const wl_interface wl_buffer_interface;
extern const wl_interface wl_data_offer_interface;
extern const wl_interface wl_data_source_interface;
extern const wl_interface wl_data_device_interface;
extern const wl_interface wl_data_device_manager_interface;
extern const wl_interface wl_shell_interface;
extern const wl_interface wl_shell_surface_interface;
extern const wl_interface wl_surface_interface;
extern const wl_interface wl_seat_interface;
extern const wl_interface wl_pointer_interface;
extern const wl_interface wl_keyboard_interface;
extern const wl_interface wl_touch_interface;
extern const wl_interface wl_output_interface;
extern const wl_interface wl_region_interface;
extern const wl_interface wl_subcompositor_interface;
extern const wl_interface wl_subsurface_interface;

enum /*wl_shell_surface_resize*/ {
	WL_SHELL_SURFACE_RESIZE_NONE = 0,
	WL_SHELL_SURFACE_RESIZE_TOP = 1,
	WL_SHELL_SURFACE_RESIZE_BOTTOM = 2,
	WL_SHELL_SURFACE_RESIZE_LEFT = 4,
	WL_SHELL_SURFACE_RESIZE_TOP_LEFT = 5,
	WL_SHELL_SURFACE_RESIZE_BOTTOM_LEFT = 6,
	WL_SHELL_SURFACE_RESIZE_RIGHT = 8,
	WL_SHELL_SURFACE_RESIZE_TOP_RIGHT = 9,
	WL_SHELL_SURFACE_RESIZE_BOTTOM_RIGHT = 10,
}

// Bulk
enum wl_display_error {
	WL_DISPLAY_ERROR_INVALID_OBJECT = 0,
	WL_DISPLAY_ERROR_INVALID_METHOD = 1,
	WL_DISPLAY_ERROR_NO_MEMORY = 2,
}
struct wl_display_listener {
	void function(void* data, wl_display* wl_display, void* object_id, uint code, const(char)* message) error;
	void function(void* data, wl_display* wl_display, uint id) delete_id;
}
pragma(inline, true) private int wl_display_add_listener(wl_display* wl_display, const(wl_display_listener)* listener, void* data) {
	return wl_proxy_add_listener(cast(wl_proxy*) wl_display,
				     cast(void function()) listener, data);
}
enum WL_DISPLAY_SYNC = 0;
enum WL_DISPLAY_GET_REGISTRY = 1;
enum WL_DISPLAY_ERROR_SINCE_VERSION = 1;
enum WL_DISPLAY_DELETE_ID_SINCE_VERSION = 1;
enum WL_DISPLAY_SYNC_SINCE_VERSION = 1;
enum WL_DISPLAY_GET_REGISTRY_SINCE_VERSION = 1;

pragma(inline, true) private void wl_display_set_user_data(wl_display* wl_display, void* user_data) {
	wl_proxy_set_user_data(cast(wl_proxy*) wl_display, user_data);
}
pragma(inline, true) private void* wl_display_get_user_data(wl_display* wl_display) {
	return wl_proxy_get_user_data(cast(wl_proxy*) wl_display);
}
pragma(inline, true) private uint wl_display_get_version(wl_display* wl_display) {
	return wl_proxy_get_version(cast(wl_proxy*) wl_display);
}
pragma(inline, true) static wl_callback* wl_display_sync(wl_display* wl_display) {
	wl_proxy* callback;
	callback = wl_proxy_marshal_constructor(cast(wl_proxy*) wl_display,
			 WL_DISPLAY_SYNC, &wl_callback_interface, null);
	return cast(wl_callback*) callback;
}
pragma(inline, true) static wl_registry* wl_display_get_registry(wl_display* wl_display) {
	wl_proxy* registry;
	registry = wl_proxy_marshal_constructor(cast(wl_proxy*) wl_display,
			 WL_DISPLAY_GET_REGISTRY, &wl_registry_interface, null);
	return cast(wl_registry*) registry;
}
pragma(inline, true) private int wl_registry_add_listener(wl_registry* wl_registry, const(wl_registry_listener)* listener, void* data) {
	return wl_proxy_add_listener(cast(wl_proxy*) wl_registry,
				     cast(void function()) listener, data);
}
enum WL_REGISTRY_BIND = 0;
enum WL_REGISTRY_GLOBAL_SINCE_VERSION = 1;
enum WL_REGISTRY_GLOBAL_REMOVE_SINCE_VERSION = 1;
enum WL_REGISTRY_BIND_SINCE_VERSION = 1;

pragma(inline, true) private void wl_registry_set_user_data(wl_registry* wl_registry, void* user_data) {
	wl_proxy_set_user_data(cast(wl_proxy*) wl_registry, user_data);
}
pragma(inline, true) private void* wl_registry_get_user_data(wl_registry* wl_registry) {
	return wl_proxy_get_user_data(cast(wl_proxy*) wl_registry);
}
pragma(inline, true) private uint wl_registry_get_version(wl_registry* wl_registry) {
	return wl_proxy_get_version(cast(wl_proxy*) wl_registry);
}

pragma(inline, true) private void wl_registry_destroy(wl_registry* wl_registry) {
	wl_proxy_destroy(cast(wl_proxy*) wl_registry);
}
struct wl_callback_listener {
	void function(void* data, wl_callback* wl_callback, uint callback_data) done;
}
pragma(inline, true) private int wl_callback_add_listener(wl_callback* wl_callback, const(wl_callback_listener)* listener, void* data) {
	return wl_proxy_add_listener(cast(wl_proxy*) wl_callback,
				     cast(void function()) listener, data);
}
enum WL_CALLBACK_DONE_SINCE_VERSION = 1;

pragma(inline, true) private void wl_callback_set_user_data(wl_callback* wl_callback, void* user_data) {
	wl_proxy_set_user_data(cast(wl_proxy*) wl_callback, user_data);
}
pragma(inline, true) private void* wl_callback_get_user_data(wl_callback* wl_callback) {
	return wl_proxy_get_user_data(cast(wl_proxy*) wl_callback);
}
pragma(inline, true) private uint wl_callback_get_version(wl_callback* wl_callback) {
	return wl_proxy_get_version(cast(wl_proxy*) wl_callback);
}
pragma(inline, true) private void wl_callback_destroy(wl_callback* wl_callback) {
	wl_proxy_destroy(cast(wl_proxy*) wl_callback);
}
enum WL_COMPOSITOR_CREATE_SURFACE = 0;
enum WL_COMPOSITOR_CREATE_REGION = 1;
enum WL_COMPOSITOR_CREATE_SURFACE_SINCE_VERSION = 1;
enum WL_COMPOSITOR_CREATE_REGION_SINCE_VERSION = 1;

pragma(inline, true) private void wl_compositor_set_user_data(wl_compositor* wl_compositor, void* user_data) {
	wl_proxy_set_user_data(cast(wl_proxy*) wl_compositor, user_data);
}
pragma(inline, true) private void* wl_compositor_get_user_data(wl_compositor* wl_compositor) {
	return wl_proxy_get_user_data(cast(wl_proxy*) wl_compositor);
}
pragma(inline, true) private uint wl_compositor_get_version(wl_compositor* wl_compositor) {
	return wl_proxy_get_version(cast(wl_proxy*) wl_compositor);
}
pragma(inline, true) private void wl_compositor_destroy(wl_compositor* wl_compositor) {
	wl_proxy_destroy(cast(wl_proxy*) wl_compositor);
}
pragma(inline, true) static wl_surface* wl_compositor_create_surface(wl_compositor* wl_compositor) {
	wl_proxy* id;
	id = wl_proxy_marshal_constructor(cast(wl_proxy*) wl_compositor,
			 WL_COMPOSITOR_CREATE_SURFACE, &wl_surface_interface, null);
	return cast(wl_surface*) id;
}
pragma(inline, true) static wl_region* wl_compositor_create_region(wl_compositor* wl_compositor) {
	wl_proxy* id;
	id = wl_proxy_marshal_constructor(cast(wl_proxy*) wl_compositor,
			 WL_COMPOSITOR_CREATE_REGION, &wl_region_interface, null);
	return cast(wl_region*) id;
}
enum WL_SHM_POOL_CREATE_BUFFER = 0;
enum WL_SHM_POOL_DESTROY = 1;
enum WL_SHM_POOL_RESIZE = 2;
enum WL_SHM_POOL_CREATE_BUFFER_SINCE_VERSION = 1;
enum WL_SHM_POOL_DESTROY_SINCE_VERSION = 1;
enum WL_SHM_POOL_RESIZE_SINCE_VERSION = 1;

pragma(inline, true) private void wl_shm_pool_set_user_data(wl_shm_pool* wl_shm_pool, void* user_data) {
	wl_proxy_set_user_data(cast(wl_proxy*) wl_shm_pool, user_data);
}
pragma(inline, true) private void* wl_shm_pool_get_user_data(wl_shm_pool* wl_shm_pool) {
	return wl_proxy_get_user_data(cast(wl_proxy*) wl_shm_pool);
}
pragma(inline, true) private uint wl_shm_pool_get_version(wl_shm_pool* wl_shm_pool) {
	return wl_proxy_get_version(cast(wl_proxy*) wl_shm_pool);
}
pragma(inline, true) static wl_buffer* wl_shm_pool_create_buffer(wl_shm_pool* wl_shm_pool, int offset, int width, int height, int stride, uint format) {
	wl_proxy* id;
	id = wl_proxy_marshal_constructor(cast(wl_proxy*) wl_shm_pool,
			 WL_SHM_POOL_CREATE_BUFFER, &wl_buffer_interface, null, offset, width, height, stride, format);
	return cast(wl_buffer*) id;
}
pragma(inline, true) private void wl_shm_pool_destroy(wl_shm_pool* wl_shm_pool) {
	wl_proxy_marshal(cast(wl_proxy*) wl_shm_pool,
			 WL_SHM_POOL_DESTROY);
	wl_proxy_destroy(cast(wl_proxy*) wl_shm_pool);
}
pragma(inline, true) private void wl_shm_pool_resize(wl_shm_pool* wl_shm_pool, int size) {
	wl_proxy_marshal(cast(wl_proxy*) wl_shm_pool, WL_SHM_POOL_RESIZE, size);
}
enum wl_shm_error {
	WL_SHM_ERROR_INVALID_FORMAT = 0,
	WL_SHM_ERROR_INVALID_STRIDE = 1,
	WL_SHM_ERROR_INVALID_FD = 2,
}
enum wl_shm_format {
	WL_SHM_FORMAT_ARGB8888 = 0,
	WL_SHM_FORMAT_XRGB8888 = 1,
	WL_SHM_FORMAT_C8 = 0x20203843,
	WL_SHM_FORMAT_RGB332 = 0x38424752,
	WL_SHM_FORMAT_BGR233 = 0x38524742,
	WL_SHM_FORMAT_XRGB4444 = 0x32315258,
	WL_SHM_FORMAT_XBGR4444 = 0x32314258,
	WL_SHM_FORMAT_RGBX4444 = 0x32315852,
	WL_SHM_FORMAT_BGRX4444 = 0x32315842,
	WL_SHM_FORMAT_ARGB4444 = 0x32315241,
	WL_SHM_FORMAT_ABGR4444 = 0x32314241,
	WL_SHM_FORMAT_RGBA4444 = 0x32314152,
	WL_SHM_FORMAT_BGRA4444 = 0x32314142,
	WL_SHM_FORMAT_XRGB1555 = 0x35315258,
	WL_SHM_FORMAT_XBGR1555 = 0x35314258,
	WL_SHM_FORMAT_RGBX5551 = 0x35315852,
	WL_SHM_FORMAT_BGRX5551 = 0x35315842,
	WL_SHM_FORMAT_ARGB1555 = 0x35315241,
	WL_SHM_FORMAT_ABGR1555 = 0x35314241,
	WL_SHM_FORMAT_RGBA5551 = 0x35314152,
	WL_SHM_FORMAT_BGRA5551 = 0x35314142,
	WL_SHM_FORMAT_RGB565 = 0x36314752,
	WL_SHM_FORMAT_BGR565 = 0x36314742,
	WL_SHM_FORMAT_RGB888 = 0x34324752,
	WL_SHM_FORMAT_BGR888 = 0x34324742,
	WL_SHM_FORMAT_XBGR8888 = 0x34324258,
	WL_SHM_FORMAT_RGBX8888 = 0x34325852,
	WL_SHM_FORMAT_BGRX8888 = 0x34325842,
	WL_SHM_FORMAT_ABGR8888 = 0x34324241,
	WL_SHM_FORMAT_RGBA8888 = 0x34324152,
	WL_SHM_FORMAT_BGRA8888 = 0x34324142,
	WL_SHM_FORMAT_XRGB2101010 = 0x30335258,
	WL_SHM_FORMAT_XBGR2101010 = 0x30334258,
	WL_SHM_FORMAT_RGBX1010102 = 0x30335852,
	WL_SHM_FORMAT_BGRX1010102 = 0x30335842,
	WL_SHM_FORMAT_ARGB2101010 = 0x30335241,
	WL_SHM_FORMAT_ABGR2101010 = 0x30334241,
	WL_SHM_FORMAT_RGBA1010102 = 0x30334152,
	WL_SHM_FORMAT_BGRA1010102 = 0x30334142,
	WL_SHM_FORMAT_YUYV = 0x56595559,
	WL_SHM_FORMAT_YVYU = 0x55595659,
	WL_SHM_FORMAT_UYVY = 0x59565955,
	WL_SHM_FORMAT_VYUY = 0x59555956,
	WL_SHM_FORMAT_AYUV = 0x56555941,
	WL_SHM_FORMAT_NV12 = 0x3231564e,
	WL_SHM_FORMAT_NV21 = 0x3132564e,
	WL_SHM_FORMAT_NV16 = 0x3631564e,
	WL_SHM_FORMAT_NV61 = 0x3136564e,
	WL_SHM_FORMAT_YUV410 = 0x39565559,
	WL_SHM_FORMAT_YVU410 = 0x39555659,
	WL_SHM_FORMAT_YUV411 = 0x31315559,
	WL_SHM_FORMAT_YVU411 = 0x31315659,
	WL_SHM_FORMAT_YUV420 = 0x32315559,
	WL_SHM_FORMAT_YVU420 = 0x32315659,
	WL_SHM_FORMAT_YUV422 = 0x36315559,
	WL_SHM_FORMAT_YVU422 = 0x36315659,
	WL_SHM_FORMAT_YUV444 = 0x34325559,
	WL_SHM_FORMAT_YVU444 = 0x34325659,
}
struct wl_shm_listener {
	void function(void* data, wl_shm* wl_shm, uint format) format;
};
pragma(inline, true) private int wl_shm_add_listener(wl_shm* wl_shm, const(wl_shm_listener)* listener, void* data) {
	return wl_proxy_add_listener(cast(wl_proxy*) wl_shm, cast(void function()) listener, data);
}
enum WL_SHM_CREATE_POOL = 0;
enum WL_SHM_FORMAT_SINCE_VERSION = 1;
enum WL_SHM_CREATE_POOL_SINCE_VERSION = 1;

pragma(inline, true) private void wl_shm_set_user_data(wl_shm* wl_shm, void* user_data) {
	wl_proxy_set_user_data(cast(wl_proxy*) wl_shm, user_data);
}
pragma(inline, true) private void* wl_shm_get_user_data(wl_shm* wl_shm) {
	return wl_proxy_get_user_data(cast(wl_proxy*) wl_shm);
}
pragma(inline, true) private uint wl_shm_get_version(wl_shm* wl_shm) {
	return wl_proxy_get_version(cast(wl_proxy*) wl_shm);
}
pragma(inline, true) private void wl_shm_destroy(wl_shm* wl_shm) {
	wl_proxy_destroy(cast(wl_proxy*) wl_shm);
}
pragma(inline, true) static wl_shm_pool* wl_shm_create_pool(wl_shm* wl_shm, int fd, int size) {
	wl_proxy* id;
	id = wl_proxy_marshal_constructor(cast(wl_proxy*) wl_shm,
			 WL_SHM_CREATE_POOL, &wl_shm_pool_interface, null, fd, size);
	return cast(wl_shm_pool*) id;
}
struct wl_buffer_listener {
	void function(void* data, wl_buffer* wl_buffer) release;
};
pragma(inline, true) private int wl_buffer_add_listener(wl_buffer* wl_buffer, const(wl_buffer_listener)* listener, void* data) {
	return wl_proxy_add_listener(cast(wl_proxy*) wl_buffer,
				     cast(void function()) listener, data);
}
enum WL_BUFFER_DESTROY = 0;
enum WL_BUFFER_RELEASE_SINCE_VERSION = 1;
enum WL_BUFFER_DESTROY_SINCE_VERSION = 1;
pragma(inline, true) private void wl_buffer_set_user_data(wl_buffer* wl_buffer, void* user_data) {
	wl_proxy_set_user_data(cast(wl_proxy*) wl_buffer, user_data);
}
pragma(inline, true) private void* wl_buffer_get_user_data(wl_buffer* wl_buffer) {
	return wl_proxy_get_user_data(cast(wl_proxy*) wl_buffer);
}
pragma(inline, true) private uint wl_buffer_get_version(wl_buffer* wl_buffer) {
	return wl_proxy_get_version(cast(wl_proxy*) wl_buffer);
}
pragma(inline, true) private void wl_buffer_destroy(wl_buffer* wl_buffer) {
	wl_proxy_marshal(cast(wl_proxy*) wl_buffer,
			 WL_BUFFER_DESTROY);
	wl_proxy_destroy(cast(wl_proxy*) wl_buffer);
}
enum wl_data_offer_error {
	WL_DATA_OFFER_ERROR_INVALID_FINISH = 0,
	WL_DATA_OFFER_ERROR_INVALID_ACTION_MASK = 1,
	WL_DATA_OFFER_ERROR_INVALID_ACTION = 2,
	WL_DATA_OFFER_ERROR_INVALID_OFFER = 3,
}
pragma(inline, true) private int wl_data_offer_add_listener(wl_data_offer* wl_data_offer, const(wl_data_offer_listener)* listener, void* data) {
	return wl_proxy_add_listener(cast(wl_proxy*) wl_data_offer,
				     cast(void function()) listener, data);
}
enum WL_DATA_OFFER_ACCEPT = 0;
enum WL_DATA_OFFER_RECEIVE = 1;
enum WL_DATA_OFFER_DESTROY = 2;
enum WL_DATA_OFFER_FINISH = 3;
enum WL_DATA_OFFER_SET_ACTIONS = 4;
enum WL_DATA_OFFER_OFFER_SINCE_VERSION = 1;
enum WL_DATA_OFFER_SOURCE_ACTIONS_SINCE_VERSION = 3;
enum WL_DATA_OFFER_ACTION_SINCE_VERSION = 3;
enum WL_DATA_OFFER_ACCEPT_SINCE_VERSION = 1;
enum WL_DATA_OFFER_RECEIVE_SINCE_VERSION = 1;
enum WL_DATA_OFFER_DESTROY_SINCE_VERSION = 1;
enum WL_DATA_OFFER_FINISH_SINCE_VERSION = 3;
enum WL_DATA_OFFER_SET_ACTIONS_SINCE_VERSION = 3;
pragma(inline, true) private void wl_data_offer_set_user_data(wl_data_offer* wl_data_offer, void* user_data) {
	wl_proxy_set_user_data(cast(wl_proxy*) wl_data_offer, user_data);
}
pragma(inline, true) private void* wl_data_offer_get_user_data(wl_data_offer* wl_data_offer) {
	return wl_proxy_get_user_data(cast(wl_proxy*) wl_data_offer);
}
pragma(inline, true) private uint wl_data_offer_get_version(wl_data_offer* wl_data_offer) {
	return wl_proxy_get_version(cast(wl_proxy*) wl_data_offer);
}
pragma(inline, true) private void wl_data_offer_accept(wl_data_offer* wl_data_offer, uint serial, const(char)* mime_type) {
	wl_proxy_marshal(cast(wl_proxy*) wl_data_offer,
			 WL_DATA_OFFER_ACCEPT, serial, mime_type);
}
pragma(inline, true) private void wl_data_offer_receive(wl_data_offer* wl_data_offer, const(char)* mime_type, int fd) {
	wl_proxy_marshal(cast(wl_proxy*) wl_data_offer,
			 WL_DATA_OFFER_RECEIVE, mime_type, fd);
}
pragma(inline, true) private void wl_data_offer_destroy(wl_data_offer* wl_data_offer) {
	wl_proxy_marshal(cast(wl_proxy*) wl_data_offer,
			 WL_DATA_OFFER_DESTROY);
	wl_proxy_destroy(cast(wl_proxy*) wl_data_offer);
}
pragma(inline, true) private void wl_data_offer_finish(wl_data_offer* wl_data_offer) {
	wl_proxy_marshal(cast(wl_proxy*) wl_data_offer,
			 WL_DATA_OFFER_FINISH);
}
pragma(inline, true) private void wl_data_offer_set_actions(wl_data_offer* wl_data_offer, uint dnd_actions, uint preferred_action) {
	wl_proxy_marshal(cast(wl_proxy*) wl_data_offer,
			 WL_DATA_OFFER_SET_ACTIONS, dnd_actions, preferred_action);
}
enum wl_data_source_error {
	WL_DATA_SOURCE_ERROR_INVALID_ACTION_MASK = 0,
	WL_DATA_SOURCE_ERROR_INVALID_SOURCE = 1,
}
pragma(inline, true) private int wl_data_source_add_listener(wl_data_source* wl_data_source, const(wl_data_source_listener)* listener, void* data) {
	return wl_proxy_add_listener(cast(wl_proxy*) wl_data_source,
				     cast(void function()) listener, data);
}
enum WL_DATA_SOURCE_OFFER = 0;
enum WL_DATA_SOURCE_DESTROY = 1;
enum WL_DATA_SOURCE_SET_ACTIONS = 2;
enum WL_DATA_SOURCE_TARGET_SINCE_VERSION = 1;
enum WL_DATA_SOURCE_SEND_SINCE_VERSION = 1;
enum WL_DATA_SOURCE_CANCELLED_SINCE_VERSION = 1;
enum WL_DATA_SOURCE_DND_DROP_PERFORMED_SINCE_VERSION = 3;
enum WL_DATA_SOURCE_DND_FINISHED_SINCE_VERSION = 3;
enum WL_DATA_SOURCE_ACTION_SINCE_VERSION = 3;
enum WL_DATA_SOURCE_OFFER_SINCE_VERSION = 1;
enum WL_DATA_SOURCE_DESTROY_SINCE_VERSION = 1;
enum WL_DATA_SOURCE_SET_ACTIONS_SINCE_VERSION = 3;
pragma(inline, true) private void wl_data_source_set_user_data(wl_data_source* wl_data_source, void* user_data) {
	wl_proxy_set_user_data(cast(wl_proxy*) wl_data_source, user_data);
}
pragma(inline, true) private void* wl_data_source_get_user_data(wl_data_source* wl_data_source) {
	return wl_proxy_get_user_data(cast(wl_proxy*) wl_data_source);
}
pragma(inline, true) private uint wl_data_source_get_version(wl_data_source* wl_data_source) {
	return wl_proxy_get_version(cast(wl_proxy*) wl_data_source);
}
pragma(inline, true) private void wl_data_source_offer(wl_data_source* wl_data_source, const(char)* mime_type) {
	wl_proxy_marshal(cast(wl_proxy*) wl_data_source,
			 WL_DATA_SOURCE_OFFER, mime_type);
}
pragma(inline, true) private void wl_data_source_destroy(wl_data_source* wl_data_source) {
	wl_proxy_marshal(cast(wl_proxy*) wl_data_source,
			 WL_DATA_SOURCE_DESTROY);
	wl_proxy_destroy(cast(wl_proxy*) wl_data_source);
}
pragma(inline, true) private void wl_data_source_set_actions(wl_data_source* wl_data_source, uint dnd_actions) {
	wl_proxy_marshal(cast(wl_proxy*) wl_data_source,
			 WL_DATA_SOURCE_SET_ACTIONS, dnd_actions);
}
enum wl_data_device_error {
	WL_DATA_DEVICE_ERROR_ROLE = 0,
}
pragma(inline, true) private int wl_data_device_add_listener(wl_data_device* wl_data_device, const(wl_data_device_listener)* listener, void* data) {
	return wl_proxy_add_listener(cast(wl_proxy*) wl_data_device,
				     cast(void function()) listener, data);
}
enum WL_DATA_DEVICE_START_DRAG = 0;
enum WL_DATA_DEVICE_SET_SELECTION = 1;
enum WL_DATA_DEVICE_RELEASE = 2;
enum WL_DATA_DEVICE_DATA_OFFER_SINCE_VERSION = 1;
enum WL_DATA_DEVICE_ENTER_SINCE_VERSION = 1;
enum WL_DATA_DEVICE_LEAVE_SINCE_VERSION = 1;
enum WL_DATA_DEVICE_MOTION_SINCE_VERSION = 1;
enum WL_DATA_DEVICE_DROP_SINCE_VERSION = 1;
enum WL_DATA_DEVICE_SELECTION_SINCE_VERSION = 1;
enum WL_DATA_DEVICE_START_DRAG_SINCE_VERSION = 1;
enum WL_DATA_DEVICE_SET_SELECTION_SINCE_VERSION = 1;
enum WL_DATA_DEVICE_RELEASE_SINCE_VERSION = 2;
pragma(inline, true) private void wl_data_device_set_user_data(wl_data_device* wl_data_device, void* user_data) {
	wl_proxy_set_user_data(cast(wl_proxy*) wl_data_device, user_data);
}
pragma(inline, true) private void* wl_data_device_get_user_data(wl_data_device* wl_data_device) {
	return wl_proxy_get_user_data(cast(wl_proxy*) wl_data_device);
}
pragma(inline, true) private uint wl_data_device_get_version(wl_data_device* wl_data_device) {
	return wl_proxy_get_version(cast(wl_proxy*) wl_data_device);
}
pragma(inline, true) private void wl_data_device_destroy(wl_data_device* wl_data_device) {
	wl_proxy_destroy(cast(wl_proxy*) wl_data_device);
}
pragma(inline, true) private void wl_data_device_start_drag(wl_data_device* wl_data_device, wl_data_source* source, wl_surface* origin, wl_surface* icon, uint serial) {
	wl_proxy_marshal(cast(wl_proxy*) wl_data_device,
			 WL_DATA_DEVICE_START_DRAG, source, origin, icon, serial);
}
pragma(inline, true) private void wl_data_device_set_selection(wl_data_device* wl_data_device, wl_data_source* source, uint serial) {
	wl_proxy_marshal(cast(wl_proxy*) wl_data_device,
			 WL_DATA_DEVICE_SET_SELECTION, source, serial);
}
pragma(inline, true) private void wl_data_device_release(wl_data_device* wl_data_device) {
	wl_proxy_marshal(cast(wl_proxy*) wl_data_device,
			 WL_DATA_DEVICE_RELEASE);
	wl_proxy_destroy(cast(wl_proxy*) wl_data_device);
}
enum wl_data_device_manager_dnd_action {
	WL_DATA_DEVICE_MANAGER_DND_ACTION_NONE = 0,
	WL_DATA_DEVICE_MANAGER_DND_ACTION_COPY = 1,
	WL_DATA_DEVICE_MANAGER_DND_ACTION_MOVE = 2,
	WL_DATA_DEVICE_MANAGER_DND_ACTION_ASK = 4,
}
enum WL_DATA_DEVICE_MANAGER_CREATE_DATA_SOURCE = 0;
enum WL_DATA_DEVICE_MANAGER_GET_DATA_DEVICE = 1;
enum WL_DATA_DEVICE_MANAGER_CREATE_DATA_SOURCE_SINCE_VERSION = 1;
enum WL_DATA_DEVICE_MANAGER_GET_DATA_DEVICE_SINCE_VERSION = 1;
pragma(inline, true) private void wl_data_device_manager_set_user_data(wl_data_device_manager* wl_data_device_manager, void* user_data) {
	wl_proxy_set_user_data(cast(wl_proxy*) wl_data_device_manager, user_data);
}
pragma(inline, true) private void* wl_data_device_manager_get_user_data(wl_data_device_manager* wl_data_device_manager) {
	return wl_proxy_get_user_data(cast(wl_proxy*) wl_data_device_manager);
}
pragma(inline, true) private uint wl_data_device_manager_get_version(wl_data_device_manager* wl_data_device_manager) {
	return wl_proxy_get_version(cast(wl_proxy*) wl_data_device_manager);
}
pragma(inline, true) private void wl_data_device_manager_destroy(wl_data_device_manager* wl_data_device_manager) {
	wl_proxy_destroy(cast(wl_proxy*) wl_data_device_manager);
}
pragma(inline, true) static wl_data_source* wl_data_device_manager_create_data_source(wl_data_device_manager* wl_data_device_manager) {
	wl_proxy* id;
	id = wl_proxy_marshal_constructor(cast(wl_proxy*) wl_data_device_manager,
			 WL_DATA_DEVICE_MANAGER_CREATE_DATA_SOURCE, &wl_data_source_interface, null);
	return cast(wl_data_source*) id;
}
pragma(inline, true) static wl_data_device* wl_data_device_manager_get_data_device(wl_data_device_manager* wl_data_device_manager, wl_seat* seat) {
	wl_proxy* id;
	id = wl_proxy_marshal_constructor(cast(wl_proxy*) wl_data_device_manager,
			 WL_DATA_DEVICE_MANAGER_GET_DATA_DEVICE, &wl_data_device_interface, null, seat);
	return cast(wl_data_device*) id;
}
enum wl_shell_error {
	WL_SHELL_ERROR_ROLE = 0,
}
enum WL_SHELL_GET_SHELL_SURFACE = 0;
enum WL_SHELL_GET_SHELL_SURFACE_SINCE_VERSION = 1;
pragma(inline, true) private void wl_shell_set_user_data(wl_shell* wl_shell, void* user_data) {
	wl_proxy_set_user_data(cast(wl_proxy*) wl_shell, user_data);
}
pragma(inline, true) private void* wl_shell_get_user_data(wl_shell* wl_shell) {
	return wl_proxy_get_user_data(cast(wl_proxy*) wl_shell);
}
pragma(inline, true) private uint wl_shell_get_version(wl_shell* wl_shell) {
	return wl_proxy_get_version(cast(wl_proxy*) wl_shell);
}
pragma(inline, true) private void wl_shell_destroy(wl_shell* wl_shell) {
	wl_proxy_destroy(cast(wl_proxy*) wl_shell);
}
pragma(inline, true) static wl_shell_surface* wl_shell_get_shell_surface(wl_shell* wl_shell, wl_surface* surface) {
	wl_proxy* id;
	id = wl_proxy_marshal_constructor(cast(wl_proxy*) wl_shell,
			 WL_SHELL_GET_SHELL_SURFACE, &wl_shell_surface_interface, null, surface);
	return cast(wl_shell_surface*) id;
}
enum /*wl_shell_surface_transient*/ {
	WL_SHELL_SURFACE_TRANSIENT_INACTIVE = 0x1,
}
enum wl_shell_surface_fullscreen_method {
	WL_SHELL_SURFACE_FULLSCREEN_METHOD_DEFAULT = 0,
	WL_SHELL_SURFACE_FULLSCREEN_METHOD_SCALE = 1,
	WL_SHELL_SURFACE_FULLSCREEN_METHOD_DRIVER = 2,
	WL_SHELL_SURFACE_FULLSCREEN_METHOD_FILL = 3,
}
pragma(inline, true) private int wl_shell_surface_add_listener(wl_shell_surface* wl_shell_surface, const(wl_shell_surface_listener)* listener, void* data) {
	return wl_proxy_add_listener(cast(wl_proxy*) wl_shell_surface, cast(void function()) listener, data);
}
enum WL_SHELL_SURFACE_PONG = 0;
enum WL_SHELL_SURFACE_MOVE = 1;
enum WL_SHELL_SURFACE_RESIZE = 2;
enum WL_SHELL_SURFACE_SET_TOPLEVEL = 3;
enum WL_SHELL_SURFACE_SET_TRANSIENT = 4;
enum WL_SHELL_SURFACE_SET_FULLSCREEN = 5;
enum WL_SHELL_SURFACE_SET_POPUP = 6;
enum WL_SHELL_SURFACE_SET_MAXIMIZED = 7;
enum WL_SHELL_SURFACE_SET_TITLE = 8;
enum WL_SHELL_SURFACE_SET_CLASS = 9;
enum WL_SHELL_SURFACE_PING_SINCE_VERSION = 1;
enum WL_SHELL_SURFACE_CONFIGURE_SINCE_VERSION = 1;
enum WL_SHELL_SURFACE_POPUP_DONE_SINCE_VERSION = 1;
enum WL_SHELL_SURFACE_PONG_SINCE_VERSION = 1;
enum WL_SHELL_SURFACE_MOVE_SINCE_VERSION = 1;
enum WL_SHELL_SURFACE_RESIZE_SINCE_VERSION = 1;
enum WL_SHELL_SURFACE_SET_TOPLEVEL_SINCE_VERSION = 1;
enum WL_SHELL_SURFACE_SET_TRANSIENT_SINCE_VERSION = 1;
enum WL_SHELL_SURFACE_SET_FULLSCREEN_SINCE_VERSION = 1;
enum WL_SHELL_SURFACE_SET_POPUP_SINCE_VERSION = 1;
enum WL_SHELL_SURFACE_SET_MAXIMIZED_SINCE_VERSION = 1;
enum WL_SHELL_SURFACE_SET_TITLE_SINCE_VERSION = 1;
enum WL_SHELL_SURFACE_SET_CLASS_SINCE_VERSION = 1;

pragma(inline, true) private void wl_shell_surface_set_user_data(wl_shell_surface* wl_shell_surface, void* user_data) {
	wl_proxy_set_user_data(cast(wl_proxy*) wl_shell_surface, user_data);
}
pragma(inline, true) private void* wl_shell_surface_get_user_data(wl_shell_surface* wl_shell_surface) {
	return wl_proxy_get_user_data(cast(wl_proxy*) wl_shell_surface);
}
pragma(inline, true) private uint wl_shell_surface_get_version(wl_shell_surface* wl_shell_surface) {
	return wl_proxy_get_version(cast(wl_proxy*) wl_shell_surface);
}
pragma(inline, true) private void wl_shell_surface_destroy(wl_shell_surface* wl_shell_surface) {
	wl_proxy_destroy(cast(wl_proxy*) wl_shell_surface);
}
pragma(inline, true) private void wl_shell_surface_pong(wl_shell_surface* wl_shell_surface, uint serial) {
	wl_proxy_marshal(cast(wl_proxy*) wl_shell_surface,
			 WL_SHELL_SURFACE_PONG, serial);
}
pragma(inline, true) private void wl_shell_surface_move(wl_shell_surface* wl_shell_surface, wl_seat* seat, uint serial) {
	wl_proxy_marshal(cast(wl_proxy*) wl_shell_surface,
			 WL_SHELL_SURFACE_MOVE, seat, serial);
}
pragma(inline, true) private void wl_shell_surface_resize(wl_shell_surface* wl_shell_surface, wl_seat* seat, uint serial, uint edges) {
	wl_proxy_marshal(cast(wl_proxy*) wl_shell_surface,
			 WL_SHELL_SURFACE_RESIZE, seat, serial, edges);
}
pragma(inline, true) private void wl_shell_surface_set_toplevel(wl_shell_surface* wl_shell_surface) {
	wl_proxy_marshal(cast(wl_proxy*) wl_shell_surface, WL_SHELL_SURFACE_SET_TOPLEVEL);
}
pragma(inline, true) private void wl_shell_surface_set_transient(wl_shell_surface* wl_shell_surface, wl_surface* parent, int x, int y, uint flags) {
	wl_proxy_marshal(cast(wl_proxy*) wl_shell_surface,
			 WL_SHELL_SURFACE_SET_TRANSIENT, parent, x, y, flags);
}
pragma(inline, true) private void wl_shell_surface_set_fullscreen(wl_shell_surface* wl_shell_surface, uint method, uint framerate, wl_output* output) {
	wl_proxy_marshal(cast(wl_proxy*) wl_shell_surface,
			 WL_SHELL_SURFACE_SET_FULLSCREEN, method, framerate, output);
}
pragma(inline, true) private void wl_shell_surface_set_popup(wl_shell_surface* wl_shell_surface, wl_seat* seat, uint serial, wl_surface* parent, int x, int y, uint flags) {
	wl_proxy_marshal(cast(wl_proxy*) wl_shell_surface,
			 WL_SHELL_SURFACE_SET_POPUP, seat, serial, parent, x, y, flags);
}
pragma(inline, true) private void wl_shell_surface_set_maximized(wl_shell_surface* wl_shell_surface, wl_output* output) {
	wl_proxy_marshal(cast(wl_proxy*) wl_shell_surface, WL_SHELL_SURFACE_SET_MAXIMIZED, output);
}
pragma(inline, true) private void wl_shell_surface_set_title(wl_shell_surface* wl_shell_surface, const(char)* title) {
	wl_proxy_marshal(cast(wl_proxy*) wl_shell_surface, WL_SHELL_SURFACE_SET_TITLE, title);
}
pragma(inline, true) private void wl_shell_surface_set_class(wl_shell_surface* wl_shell_surface, const(char)* class_) {
	wl_proxy_marshal(cast(wl_proxy*) wl_shell_surface,
			 WL_SHELL_SURFACE_SET_CLASS, class_);
}
enum wl_surface_error {
	WL_SURFACE_ERROR_INVALID_SCALE = 0,
	WL_SURFACE_ERROR_INVALID_TRANSFORM = 1,
}
pragma(inline, true) private int wl_surface_add_listener(wl_surface* wl_surface, const(wl_surface_listener)* listener, void* data) {
	return wl_proxy_add_listener(cast(wl_proxy*) wl_surface, cast(void function()) listener, data);
}
enum WL_SURFACE_DESTROY = 0;
enum WL_SURFACE_ATTACH = 1;
enum WL_SURFACE_DAMAGE = 2;
enum WL_SURFACE_FRAME = 3;
enum WL_SURFACE_SET_OPAQUE_REGION = 4;
enum WL_SURFACE_SET_INPUT_REGION = 5;
enum WL_SURFACE_COMMIT = 6;
enum WL_SURFACE_SET_BUFFER_TRANSFORM = 7;
enum WL_SURFACE_SET_BUFFER_SCALE = 8;
enum WL_SURFACE_DAMAGE_BUFFER = 9;
enum WL_SURFACE_ENTER_SINCE_VERSION = 1;
enum WL_SURFACE_LEAVE_SINCE_VERSION = 1;
enum WL_SURFACE_DESTROY_SINCE_VERSION = 1;
enum WL_SURFACE_ATTACH_SINCE_VERSION = 1;
enum WL_SURFACE_DAMAGE_SINCE_VERSION = 1;
enum WL_SURFACE_FRAME_SINCE_VERSION = 1;
enum WL_SURFACE_SET_OPAQUE_REGION_SINCE_VERSION = 1;
enum WL_SURFACE_SET_INPUT_REGION_SINCE_VERSION = 1;
enum WL_SURFACE_COMMIT_SINCE_VERSION = 1;
enum WL_SURFACE_SET_BUFFER_TRANSFORM_SINCE_VERSION = 2;
enum WL_SURFACE_SET_BUFFER_SCALE_SINCE_VERSION = 3;
enum WL_SURFACE_DAMAGE_BUFFER_SINCE_VERSION = 4;

pragma(inline, true) private void wl_surface_set_user_data(wl_surface* wl_surface, void* user_data) {
	wl_proxy_set_user_data(cast(wl_proxy*) wl_surface, user_data);
}
pragma(inline, true) private void* wl_surface_get_user_data(wl_surface* wl_surface) {
	return wl_proxy_get_user_data(cast(wl_proxy*) wl_surface);
}
pragma(inline, true) private uint wl_surface_get_version(wl_surface* wl_surface) {
	return wl_proxy_get_version(cast(wl_proxy*) wl_surface);
}
pragma(inline, true) private void wl_surface_destroy(wl_surface* wl_surface) {
	wl_proxy_marshal(cast(wl_proxy*) wl_surface,
			 WL_SURFACE_DESTROY);
	wl_proxy_destroy(cast(wl_proxy*) wl_surface);
}
pragma(inline, true) private void wl_surface_attach(wl_surface* wl_surface, wl_buffer* buffer, int x, int y) {
	wl_proxy_marshal(cast(wl_proxy*) wl_surface,
			 WL_SURFACE_ATTACH, buffer, x, y);
}
pragma(inline, true) private void wl_surface_damage(wl_surface* wl_surface, int x, int y, int width, int height) {
	wl_proxy_marshal(cast(wl_proxy*) wl_surface,
			 WL_SURFACE_DAMAGE, x, y, width, height);
}
pragma(inline, true) static wl_callback* wl_surface_frame(wl_surface* wl_surface) {
	wl_proxy* callback;
	callback = wl_proxy_marshal_constructor(cast(wl_proxy*) wl_surface,
			 WL_SURFACE_FRAME, &wl_callback_interface, null);
	return cast(wl_callback*) callback;
}
pragma(inline, true) private void wl_surface_set_opaque_region(wl_surface* wl_surface, wl_region* region) {
	wl_proxy_marshal(cast(wl_proxy*) wl_surface,
			 WL_SURFACE_SET_OPAQUE_REGION, region);
}
pragma(inline, true) private void wl_surface_set_input_region(wl_surface* wl_surface, wl_region* region) {
	wl_proxy_marshal(cast(wl_proxy*) wl_surface,
			 WL_SURFACE_SET_INPUT_REGION, region);
}
pragma(inline, true) private void wl_surface_commit(wl_surface* wl_surface) {
	wl_proxy_marshal(cast(wl_proxy*) wl_surface,
			 WL_SURFACE_COMMIT);
}
pragma(inline, true) private void wl_surface_set_buffer_transform(wl_surface* wl_surface, int transform) {
	wl_proxy_marshal(cast(wl_proxy*) wl_surface,
			 WL_SURFACE_SET_BUFFER_TRANSFORM, transform);
}
pragma(inline, true) private void wl_surface_set_buffer_scale(wl_surface* wl_surface, int scale) {
	wl_proxy_marshal(cast(wl_proxy*) wl_surface,
			 WL_SURFACE_SET_BUFFER_SCALE, scale);
}
pragma(inline, true) private void wl_surface_damage_buffer(wl_surface* wl_surface, int x, int y, int width, int height) {
	wl_proxy_marshal(cast(wl_proxy*) wl_surface,
			 WL_SURFACE_DAMAGE_BUFFER, x, y, width, height);
}
pragma(inline, true) private int wl_seat_add_listener(wl_seat* wl_seat, const(wl_seat_listener)* listener, void* data) {
	return wl_proxy_add_listener(cast(wl_proxy*) wl_seat,
				     cast(void function()) listener, data);
}
enum WL_SEAT_GET_POINTER = 0;
enum WL_SEAT_GET_KEYBOARD = 1;
enum WL_SEAT_GET_TOUCH = 2;
enum WL_SEAT_RELEASE = 3;
enum WL_SEAT_CAPABILITIES_SINCE_VERSION = 1;
enum WL_SEAT_NAME_SINCE_VERSION = 2;
enum WL_SEAT_GET_POINTER_SINCE_VERSION = 1;
enum WL_SEAT_GET_KEYBOARD_SINCE_VERSION = 1;
enum WL_SEAT_GET_TOUCH_SINCE_VERSION = 1;
enum WL_SEAT_RELEASE_SINCE_VERSION = 5;

pragma(inline, true) private void wl_seat_set_user_data(wl_seat* wl_seat, void* user_data) {
	wl_proxy_set_user_data(cast(wl_proxy*) wl_seat, user_data);
}
pragma(inline, true) private void* wl_seat_get_user_data(wl_seat* wl_seat) {
	return wl_proxy_get_user_data(cast(wl_proxy*) wl_seat);
}
pragma(inline, true) private uint wl_seat_get_version(wl_seat* wl_seat) {
	return wl_proxy_get_version(cast(wl_proxy*) wl_seat);
}

pragma(inline, true) private void wl_seat_destroy(wl_seat* wl_seat) {
	wl_proxy_destroy(cast(wl_proxy*) wl_seat);
}
pragma(inline, true) static wl_pointer* wl_seat_get_pointer(wl_seat* wl_seat) {
	wl_proxy* id;
	id = wl_proxy_marshal_constructor(cast(wl_proxy*) wl_seat,
			 WL_SEAT_GET_POINTER, &wl_pointer_interface, null);
	return cast(wl_pointer*) id;
}
pragma(inline, true) static wl_keyboard* wl_seat_get_keyboard(wl_seat* wl_seat) {
	wl_proxy* id;
	id = wl_proxy_marshal_constructor(cast(wl_proxy*) wl_seat,
			 WL_SEAT_GET_KEYBOARD, &wl_keyboard_interface, null);
	return cast(wl_keyboard*) id;
}
pragma(inline, true) static wl_touch* wl_seat_get_touch(wl_seat* wl_seat) {
	wl_proxy* id;
	id = wl_proxy_marshal_constructor(cast(wl_proxy*) wl_seat, WL_SEAT_GET_TOUCH, &wl_touch_interface, null);
	return cast(wl_touch*) id;
}
pragma(inline, true) private void wl_seat_release(wl_seat* wl_seat) {
	wl_proxy_marshal(cast(wl_proxy*) wl_seat, WL_SEAT_RELEASE);
	wl_proxy_destroy(cast(wl_proxy*) wl_seat);
}
enum wl_pointer_error {
	WL_POINTER_ERROR_ROLE = 0,
}
enum wl_pointer_axis_source {
	WL_POINTER_AXIS_SOURCE_WHEEL = 0,
	WL_POINTER_AXIS_SOURCE_FINGER = 1,
	WL_POINTER_AXIS_SOURCE_CONTINUOUS = 2,
}
pragma(inline, true) private int wl_pointer_add_listener(wl_pointer* wl_pointer, const(wl_pointer_listener)* listener, void* data) {
	return wl_proxy_add_listener(cast(wl_proxy*) wl_pointer, cast(void function()) listener, data);
}
enum WL_POINTER_SET_CURSOR = 0;
enum WL_POINTER_RELEASE = 1;
enum WL_POINTER_ENTER_SINCE_VERSION = 1;
enum WL_POINTER_LEAVE_SINCE_VERSION = 1;
enum WL_POINTER_MOTION_SINCE_VERSION = 1;
enum WL_POINTER_BUTTON_SINCE_VERSION = 1;
enum WL_POINTER_AXIS_SINCE_VERSION = 1;
enum WL_POINTER_FRAME_SINCE_VERSION = 5;
enum WL_POINTER_AXIS_SOURCE_SINCE_VERSION = 5;
enum WL_POINTER_AXIS_STOP_SINCE_VERSION = 5;
enum WL_POINTER_AXIS_DISCRETE_SINCE_VERSION = 5;
enum WL_POINTER_SET_CURSOR_SINCE_VERSION = 1;
enum WL_POINTER_RELEASE_SINCE_VERSION = 3;

pragma(inline, true) private void wl_pointer_set_user_data(wl_pointer* wl_pointer, void* user_data) {
	wl_proxy_set_user_data(cast(wl_proxy*) wl_pointer, user_data);
}
pragma(inline, true) private void* wl_pointer_get_user_data(wl_pointer* wl_pointer) {
	return wl_proxy_get_user_data(cast(wl_proxy*) wl_pointer);
}
pragma(inline, true) private uint wl_pointer_get_version(wl_pointer* wl_pointer) {
	return wl_proxy_get_version(cast(wl_proxy*) wl_pointer);
}
pragma(inline, true) private void wl_pointer_destroy(wl_pointer* wl_pointer) {
	wl_proxy_destroy(cast(wl_proxy*) wl_pointer);
}
pragma(inline, true) private void wl_pointer_set_cursor(wl_pointer* wl_pointer, uint serial, wl_surface* surface, int hotspot_x, int hotspot_y) {
	wl_proxy_marshal(cast(wl_proxy*) wl_pointer,
			 WL_POINTER_SET_CURSOR, serial, surface, hotspot_x, hotspot_y);
}
pragma(inline, true) private void wl_pointer_release(wl_pointer* wl_pointer) {
	wl_proxy_marshal(cast(wl_proxy*) wl_pointer,
			 WL_POINTER_RELEASE);
	wl_proxy_destroy(cast(wl_proxy*) wl_pointer);
}
pragma(inline, true) private int wl_keyboard_add_listener(wl_keyboard* wl_keyboard, const(wl_keyboard_listener)* listener, void* data) {
	return wl_proxy_add_listener(cast(wl_proxy*) wl_keyboard,
				     cast(void function()) listener, data);
}
enum WL_KEYBOARD_RELEASE = 0;
enum WL_KEYBOARD_KEYMAP_SINCE_VERSION = 1;
enum WL_KEYBOARD_ENTER_SINCE_VERSION = 1;
enum WL_KEYBOARD_LEAVE_SINCE_VERSION = 1;
enum WL_KEYBOARD_KEY_SINCE_VERSION = 1;
enum WL_KEYBOARD_MODIFIERS_SINCE_VERSION = 1;
enum WL_KEYBOARD_REPEAT_INFO_SINCE_VERSION = 4;
enum WL_KEYBOARD_RELEASE_SINCE_VERSION = 3;

pragma(inline, true) private void wl_keyboard_set_user_data(wl_keyboard* wl_keyboard, void* user_data) {
	wl_proxy_set_user_data(cast(wl_proxy*) wl_keyboard, user_data);
}

pragma(inline, true) private void* wl_keyboard_get_user_data(wl_keyboard* wl_keyboard) {
	return wl_proxy_get_user_data(cast(wl_proxy*) wl_keyboard);
}
pragma(inline, true) private uint wl_keyboard_get_version(wl_keyboard* wl_keyboard) {
	return wl_proxy_get_version(cast(wl_proxy*) wl_keyboard);
}

pragma(inline, true) private void wl_keyboard_destroy(wl_keyboard* wl_keyboard) {
	wl_proxy_destroy(cast(wl_proxy*) wl_keyboard);
}
pragma(inline, true) private void wl_keyboard_release(wl_keyboard* wl_keyboard) {
	wl_proxy_marshal(cast(wl_proxy*) wl_keyboard,
			 WL_KEYBOARD_RELEASE);
	wl_proxy_destroy(cast(wl_proxy*) wl_keyboard);
}
struct wl_touch_listener {
	void function(void* data, wl_touch* wl_touch, uint serial, uint time, wl_surface* surface, int id, wl_fixed_t x, wl_fixed_t y) down;
	void function(void* data, wl_touch* wl_touch, uint serial, uint time, int id) up;
	void function(void* data, wl_touch* wl_touch, uint time, int id, wl_fixed_t x, wl_fixed_t y) motion;
	void function(void* data, wl_touch* wl_touch) frame;
	void function(void* data, wl_touch* wl_touch) cancel;
};
pragma(inline, true) private int wl_touch_add_listener(wl_touch* wl_touch, const(wl_touch_listener)* listener, void* data) {
	return wl_proxy_add_listener(cast(wl_proxy*) wl_touch, cast(void function()) listener, data);
}
enum WL_TOUCH_RELEASE = 0;
enum WL_TOUCH_DOWN_SINCE_VERSION = 1;
enum WL_TOUCH_UP_SINCE_VERSION = 1;
enum WL_TOUCH_MOTION_SINCE_VERSION = 1;
enum WL_TOUCH_FRAME_SINCE_VERSION = 1;
enum WL_TOUCH_CANCEL_SINCE_VERSION = 1;
enum WL_TOUCH_RELEASE_SINCE_VERSION = 3;

pragma(inline, true) private void wl_touch_set_user_data(wl_touch* wl_touch, void* user_data) {
	wl_proxy_set_user_data(cast(wl_proxy*) wl_touch, user_data);
}

pragma(inline, true) private void* wl_touch_get_user_data(wl_touch* wl_touch) {
	return wl_proxy_get_user_data(cast(wl_proxy*) wl_touch);
}
pragma(inline, true) private uint wl_touch_get_version(wl_touch* wl_touch) {
	return wl_proxy_get_version(cast(wl_proxy*) wl_touch);
}

pragma(inline, true) private void wl_touch_destroy(wl_touch* wl_touch) {
	wl_proxy_destroy(cast(wl_proxy*) wl_touch);
}
pragma(inline, true) private void wl_touch_release(wl_touch* wl_touch) {
	wl_proxy_marshal(cast(wl_proxy*) wl_touch, WL_TOUCH_RELEASE);
	wl_proxy_destroy(cast(wl_proxy*) wl_touch);
}
enum wl_output_subpixel {
	WL_OUTPUT_SUBPIXEL_UNKNOWN = 0,
	WL_OUTPUT_SUBPIXEL_NONE = 1,
	WL_OUTPUT_SUBPIXEL_HORIZONTAL_RGB = 2,
	WL_OUTPUT_SUBPIXEL_HORIZONTAL_BGR = 3,
	WL_OUTPUT_SUBPIXEL_VERTICAL_RGB = 4,
	WL_OUTPUT_SUBPIXEL_VERTICAL_BGR = 5,
}
enum wl_output_transform {
	WL_OUTPUT_TRANSFORM_NORMAL = 0,
	WL_OUTPUT_TRANSFORM_90 = 1,
	WL_OUTPUT_TRANSFORM_180 = 2,
	WL_OUTPUT_TRANSFORM_270 = 3,
	WL_OUTPUT_TRANSFORM_FLIPPED = 4,
	WL_OUTPUT_TRANSFORM_FLIPPED_90 = 5,
	WL_OUTPUT_TRANSFORM_FLIPPED_180 = 6,
	WL_OUTPUT_TRANSFORM_FLIPPED_270 = 7,
}
enum WL_OUTPUT_RELEASE = 0;
enum WL_OUTPUT_GEOMETRY_SINCE_VERSION = 1;
enum WL_OUTPUT_MODE_SINCE_VERSION = 1;
enum WL_OUTPUT_DONE_SINCE_VERSION = 2;
enum WL_OUTPUT_SCALE_SINCE_VERSION = 2;
enum WL_OUTPUT_RELEASE_SINCE_VERSION = 3;

pragma(inline, true) private void wl_output_set_user_data(wl_output* wl_output, void* user_data) {
	wl_proxy_set_user_data(cast(wl_proxy*) wl_output, user_data);
}
pragma(inline, true) private void* wl_output_get_user_data(wl_output* wl_output) {
	return wl_proxy_get_user_data(cast(wl_proxy*) wl_output);
}
pragma(inline, true) private uint wl_output_get_version(wl_output* wl_output) {
	return wl_proxy_get_version(cast(wl_proxy*) wl_output);
}
pragma(inline, true) private void wl_output_release(wl_output* wl_output) {
	wl_proxy_marshal(cast(wl_proxy*) wl_output, WL_OUTPUT_RELEASE);
	wl_proxy_destroy(cast(wl_proxy*) wl_output);
}
enum WL_REGION_DESTROY = 0;
enum WL_REGION_ADD = 1;
enum WL_REGION_SUBTRACT = 2;
enum WL_REGION_DESTROY_SINCE_VERSION = 1;
enum WL_REGION_ADD_SINCE_VERSION = 1;
enum WL_REGION_SUBTRACT_SINCE_VERSION = 1;

pragma(inline, true) private void wl_region_set_user_data(wl_region* wl_region, void* user_data) {
	wl_proxy_set_user_data(cast(wl_proxy*) wl_region, user_data);
}

pragma(inline, true) private void* wl_region_get_user_data(wl_region* wl_region) {
	return wl_proxy_get_user_data(cast(wl_proxy*) wl_region);
}
pragma(inline, true) private uint wl_region_get_version(wl_region* wl_region) {
	return wl_proxy_get_version(cast(wl_proxy*) wl_region);
}
pragma(inline, true) private void wl_region_destroy(wl_region* wl_region) {
	wl_proxy_marshal(cast(wl_proxy*) wl_region,
			 WL_REGION_DESTROY);
	wl_proxy_destroy(cast(wl_proxy*) wl_region);
}
pragma(inline, true) private void wl_region_add(wl_region* wl_region, int x, int y, int width, int height) {
	wl_proxy_marshal(cast(wl_proxy*) wl_region,
			 WL_REGION_ADD, x, y, width, height);
}
pragma(inline, true) private void wl_region_subtract(wl_region* wl_region, int x, int y, int width, int height) {
	wl_proxy_marshal(cast(wl_proxy*) wl_region,
			 WL_REGION_SUBTRACT, x, y, width, height);
}
enum wl_subcompositor_error {
	WL_SUBCOMPOSITOR_ERROR_BAD_SURFACE = 0,
}
enum WL_SUBCOMPOSITOR_DESTROY = 0;
enum WL_SUBCOMPOSITOR_GET_SUBSURFACE = 1;
enum WL_SUBCOMPOSITOR_DESTROY_SINCE_VERSION = 1;
enum WL_SUBCOMPOSITOR_GET_SUBSURFACE_SINCE_VERSION = 1;


pragma(inline, true) private void wl_subcompositor_set_user_data(wl_subcompositor* wl_subcompositor, void* user_data) {
	wl_proxy_set_user_data(cast(wl_proxy*) wl_subcompositor, user_data);
}


pragma(inline, true) private void* wl_subcompositor_get_user_data(wl_subcompositor* wl_subcompositor) {
	return wl_proxy_get_user_data(cast(wl_proxy*) wl_subcompositor);
}
pragma(inline, true) private uint wl_subcompositor_get_version(wl_subcompositor* wl_subcompositor) {
	return wl_proxy_get_version(cast(wl_proxy*) wl_subcompositor);
}
pragma(inline, true) private void wl_subcompositor_destroy(wl_subcompositor* wl_subcompositor) {
	wl_proxy_marshal(cast(wl_proxy*) wl_subcompositor,
			 WL_SUBCOMPOSITOR_DESTROY);
	wl_proxy_destroy(cast(wl_proxy*) wl_subcompositor);
}
pragma(inline, true) static wl_subsurface* wl_subcompositor_get_subsurface(wl_subcompositor* wl_subcompositor, wl_surface* surface, wl_surface* parent) {
	wl_proxy* id;
	id = wl_proxy_marshal_constructor(cast(wl_proxy*) wl_subcompositor,
			 WL_SUBCOMPOSITOR_GET_SUBSURFACE, &wl_subsurface_interface, null, surface, parent);
	return cast(wl_subsurface*) id;
}
enum wl_subsurface_error {
	WL_SUBSURFACE_ERROR_BAD_SURFACE = 0,
}
enum WL_SUBSURFACE_DESTROY = 0;
enum WL_SUBSURFACE_SET_POSITION = 1;
enum WL_SUBSURFACE_PLACE_ABOVE = 2;
enum WL_SUBSURFACE_PLACE_BELOW = 3;
enum WL_SUBSURFACE_SET_SYNC = 4;
enum WL_SUBSURFACE_SET_DESYNC = 5;
enum WL_SUBSURFACE_DESTROY_SINCE_VERSION = 1;
enum WL_SUBSURFACE_SET_POSITION_SINCE_VERSION = 1;
enum WL_SUBSURFACE_PLACE_ABOVE_SINCE_VERSION = 1;
enum WL_SUBSURFACE_PLACE_BELOW_SINCE_VERSION = 1;
enum WL_SUBSURFACE_SET_SYNC_SINCE_VERSION = 1;
enum WL_SUBSURFACE_SET_DESYNC_SINCE_VERSION = 1;

pragma(inline, true) private void wl_subsurface_set_user_data(wl_subsurface* wl_subsurface, void* user_data) {
	wl_proxy_set_user_data(cast(wl_proxy*) wl_subsurface, user_data);
}
pragma(inline, true) private void* wl_subsurface_get_user_data(wl_subsurface* wl_subsurface) {
	return wl_proxy_get_user_data(cast(wl_proxy*) wl_subsurface);
}
pragma(inline, true) private uint wl_subsurface_get_version(wl_subsurface* wl_subsurface) {
	return wl_proxy_get_version(cast(wl_proxy*) wl_subsurface);
}
pragma(inline, true) private void wl_subsurface_destroy(wl_subsurface* wl_subsurface) {
	wl_proxy_marshal(cast(wl_proxy*) wl_subsurface, WL_SUBSURFACE_DESTROY);
	wl_proxy_destroy(cast(wl_proxy*) wl_subsurface);
}
pragma(inline, true) private void wl_subsurface_set_position(wl_subsurface* wl_subsurface, int x, int y) {
	wl_proxy_marshal(cast(wl_proxy*) wl_subsurface,
			 WL_SUBSURFACE_SET_POSITION, x, y);
}
pragma(inline, true) private void wl_subsurface_place_above(wl_subsurface* wl_subsurface, wl_surface* sibling) {
	wl_proxy_marshal(cast(wl_proxy*) wl_subsurface,
			 WL_SUBSURFACE_PLACE_ABOVE, sibling);
}
pragma(inline, true) private void wl_subsurface_place_below(wl_subsurface* wl_subsurface, wl_surface* sibling) {
	wl_proxy_marshal(cast(wl_proxy*) wl_subsurface,
			 WL_SUBSURFACE_PLACE_BELOW, sibling);
}
pragma(inline, true) private void wl_subsurface_set_sync(wl_subsurface* wl_subsurface) {
	wl_proxy_marshal(cast(wl_proxy*) wl_subsurface,
			 WL_SUBSURFACE_SET_SYNC);
}
pragma(inline, true) private void wl_subsurface_set_desync(wl_subsurface* wl_subsurface) {
	wl_proxy_marshal(cast(wl_proxy*) wl_subsurface,
			 WL_SUBSURFACE_SET_DESYNC);
}
