module glfw3;

public {
	import glfw3.api;
	import glfw3.apinative;
}

import glfw3.context;
import glfw3.init;
import glfw3.input;
import glfw3.monitor;
import glfw3.vulkan;
import glfw3.window;
import glfw3.mappings;
import glfw3.internal;
import glfw3.api;

version(_GLFW_OSMESA) {
	import glfw3.null_init;
	import glfw3.null_monitor;
	import glfw3.null_window;
	import glfw3.null_joystick;
	import glfw3.posix_time;
	import glfw3.posix_thread;
	import glfw3.osmesa_context;
} else version(Windows) {
	pragma(lib, "gdi32");
	pragma(lib, "user32");
	import glfw3.win32_platform;
	import glfw3.win32_init;
	import glfw3.win32_joystick;
	import glfw3.win32_monitor;
	import glfw3.win32_time;
	import glfw3.win32_thread;
	import glfw3.win32_window;
	import glfw3.wgl_context;
	import glfw3.egl_context;
	import glfw3.osmesa_context;
	import glfw3.directinput8;
} else version(linux) {
	pragma(lib, "X11");
	import glfw3.x11_header;
	import glfw3.x11_platform;
	import glfw3.x11_init;
	import glfw3.x11_monitor;
	import glfw3.x11_window;
	import glfw3.xkb_unicode;
	import glfw3.posix_time;
	import glfw3.posix_thread;
	import glfw3.glx_context;
	import glfw3.egl_context;
	import glfw3.osmesa_context;
	import glfw3.linux_joystick;
	import glfw3.linuxinput;
}
