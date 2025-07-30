/**
 * The header of the native access functions, translated from `glfw3native.h`
 *
 * This is the header file of the native access functions.
 */
module glfw3.apinative;

nothrow:
extern(C): __gshared:

/*************************************************************************
 * GLFW 3.3 - www.glfw.org
 * A library for OpenGL, window and input
 *------------------------------------------------------------------------
 * Copyright (c) 2002-2006 Marcus Geelnard
 * Copyright (c) 2006-2018 Camilla Löwy <elmindreda@glfw.org>
 *
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would
 *    be appreciated but is not required.
 *
 * 2. Altered source versions must be plainly marked as such, and must not
 *    be misrepresented as being the original software.
 *
 * 3. This notice may not be removed or altered from any source
 *    distribution.
 *
 *************************************************************************/

import glfw3.api;

/** @defgroup native Native access
 *  Functions related to accessing native handles.
 *
 *  **By using the native access functions you assert that you know what you're
 *  doing and how to fix problems caused by using them.  If you don't, you
 *  shouldn't be using them.**
 *
 *  Before the inclusion of @ref glfw3native.h, you may define zero or more
 *  window system API macro and zero or more context creation API macros.
 *
 *  The chosen backends must match those the library was compiled for.  Failure
 *  to do this will cause a link-time error.
 *
 *  The available window API macros are:
 *  * `GLFW_EXPOSE_NATIVE_WIN32`
 *  * `GLFW_EXPOSE_NATIVE_COCOA`
 *  * `GLFW_EXPOSE_NATIVE_X11`
 *  * `GLFW_EXPOSE_NATIVE_WAYLAND`
 *
 *  The available context API macros are:
 *  * `GLFW_EXPOSE_NATIVE_WGL`
 *  * `GLFW_EXPOSE_NATIVE_NSGL`
 *  * `GLFW_EXPOSE_NATIVE_GLX`
 *  * `GLFW_EXPOSE_NATIVE_EGL`
 *  * `GLFW_EXPOSE_NATIVE_OSMESA`
 *
 *  These macros select which of the native access functions that are declared
 *  and which platform-specific headers to include.  It is then up your (by
 *  definition platform-specific) code to handle which of these should be
 *  defined.
 */

/*************************************************************************
 * System headers and types
 *************************************************************************/

// Omitted

/*************************************************************************
 * Functions
 *************************************************************************/

version(GLFW_EXPOSE_NATIVE_WIN32) {
import core.sys.windows.windows: HWND;

/** Returns the adapter device name of the specified monitor.
 *
 *  Returns: The UTF-8 encoded adapter device name (for example `\\.\DISPLAY1`)
 *  of the specified monitor, or `null` if an [error](@ref error_handling)
 *  occurred.
 *
 *  Thread_Safety: This function may be called from any thread.  Access is not
 *  synchronized.
 *
 *  Since: Added in version 3.1.
 *
 *  Ingroup: native
 */
const(char)* glfwGetWin32Adapter(GLFWmonitor* monitor);

/** Returns the display device name of the specified monitor.
 *
 *  Returns: The UTF-8 encoded display device name (for example
 *  `\\.\DISPLAY1\Monitor0`) of the specified monitor, or `null` if an
 *  [error](@ref error_handling) occurred.
 *
 *  Thread_Safety: This function may be called from any thread.  Access is not
 *  synchronized.
 *
 *  Since: Added in version 3.1.
 *
 *  Ingroup: native
 */
const(char)* glfwGetWin32Monitor(GLFWmonitor* monitor);

/** Returns the `HWND` of the specified window.
 *
 *  Returns: The `HWND` of the specified window, or `null` if an
 *  [error](@ref error_handling) occurred.
 *
 *  Thread_Safety: This function may be called from any thread.  Access is not
 *  synchronized.
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: native
 */
HWND glfwGetWin32Window(GLFWwindow* window);
}

version(GLFW_EXPOSE_NATIVE_WGL) {
/** Returns the `HGLRC` of the specified window.
 *
 *  Returns: The `HGLRC` of the specified window, or `null` if an
 *  [error](@ref error_handling) occurred.
 *
 *  Thread_Safety: This function may be called from any thread.  Access is not
 *  synchronized.
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: native
 */
HGLRC glfwGetWGLContext(GLFWwindow* window);
}

version(GLFW_EXPOSE_NATIVE_COCOA) {
/** Returns the `CGDirectDisplayID` of the specified monitor.
 *
 *  Returns: The `CGDirectDisplayID` of the specified monitor, or
 *  `kCGNullDirectDisplay` if an [error](@ref error_handling) occurred.
 *
 *  Thread_Safety: This function may be called from any thread.  Access is not
 *  synchronized.
 *
 *  Since: Added in version 3.1.
 *
 *  Ingroup: native
 */
CGDirectDisplayID glfwGetCocoaMonitor(GLFWmonitor* monitor);

/** Returns the `NSWindow` of the specified window.
 *
 *  Returns: The `NSWindow` of the specified window, or `nil` if an
 *  [error](@ref error_handling) occurred.
 *
 *  Thread_Safety: This function may be called from any thread.  Access is not
 *  synchronized.
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: native
 */
id glfwGetCocoaWindow(GLFWwindow* window);
}

version(GLFW_EXPOSE_NATIVE_NSGL) {
/** Returns the `NSOpenGLContext` of the specified window.
 *
 *  Returns: The `NSOpenGLContext` of the specified window, or `nil` if an
 *  [error](@ref error_handling) occurred.
 *
 *  Thread_Safety: This function may be called from any thread.  Access is not
 *  synchronized.
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: native
 */
id glfwGetNSGLContext(GLFWwindow* window);
}

version(GLFW_EXPOSE_NATIVE_X11) {
import glfw3.x11_header;

/** Returns the `Display` used by GLFW.
 *
 *  Returns: The `Display` used by GLFW, or `null` if an
 *  [error](@ref error_handling) occurred.
 *
 *  Thread_Safety: This function may be called from any thread.  Access is not
 *  synchronized.
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: native
 */
Display* glfwGetX11Display();

/** Returns the `RRCrtc` of the specified monitor.
 *
 *  Returns: The `RRCrtc` of the specified monitor, or `None` if an
 *  [error](@ref error_handling) occurred.
 *
 *  Thread_Safety: This function may be called from any thread.  Access is not
 *  synchronized.
 *
 *  Since: Added in version 3.1.
 *
 *  Ingroup: native
 */
RRCrtc glfwGetX11Adapter(GLFWmonitor* monitor);

/** Returns the `RROutput` of the specified monitor.
 *
 *  Returns: The `RROutput` of the specified monitor, or `None` if an
 *  [error](@ref error_handling) occurred.
 *
 *  Thread_Safety: This function may be called from any thread.  Access is not
 *  synchronized.
 *
 *  Since: Added in version 3.1.
 *
 *  Ingroup: native
 */
RROutput glfwGetX11Monitor(GLFWmonitor* monitor);

/** Returns the `Window` of the specified window.
 *
 *  Returns: The `Window` of the specified window, or `None` if an
 *  [error](@ref error_handling) occurred.
 *
 *  Thread_Safety: This function may be called from any thread.  Access is not
 *  synchronized.
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: native
 */
Window glfwGetX11Window(GLFWwindow* window);

/** Sets the current primary selection to the specified string.
 *
 * Params:
 *  string = A UTF-8 encoded string.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  Pointer_lifetime: The specified string is copied before this function
 *  returns.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref clipboard
 *  @sa glfwGetX11SelectionString
 *  @sa glfwSetClipboardString
 *
 *  Since: Added in version 3.3.
 *
 *  Ingroup: native
 */
void glfwSetX11SelectionString(const(char)* string_);

/** Returns the contents of the current primary selection as a string.
 *
 *  If the selection is empty or if its contents cannot be converted, `null`
 *  is returned and a @ref GLFW_FORMAT_UNAVAILABLE error is generated.
 *
 *  Returns: The contents of the selection as a UTF-8 encoded string, or `null`
 *  if an [error](@ref error_handling) occurred.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  Pointer_lifetime: The returned string is allocated and freed by GLFW. You
 *  should not free it yourself. It is valid until the next call to @ref
 *  glfwGetX11SelectionString or @ref glfwSetX11SelectionString, or until the
 *  library is terminated.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref clipboard
 *  @sa glfwSetX11SelectionString
 *  @sa glfwGetClipboardString
 *
 *  Since: Added in version 3.3.
 *
 *  Ingroup: native
 */
const(char)* glfwGetX11SelectionString();
}

version(GLFW_EXPOSE_NATIVE_GLX) {
/** Returns the `GLXContext` of the specified window.
 *
 *  Returns: The `GLXContext` of the specified window, or `null` if an
 *  [error](@ref error_handling) occurred.
 *
 *  Thread_Safety: This function may be called from any thread.  Access is not
 *  synchronized.
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: native
 */
GLXContext glfwGetGLXContext(GLFWwindow* window);

/** Returns the `GLXWindow` of the specified window.
 *
 *  Returns: The `GLXWindow` of the specified window, or `None` if an
 *  [error](@ref error_handling) occurred.
 *
 *  Thread_Safety: This function may be called from any thread.  Access is not
 *  synchronized.
 *
 *  Since: Added in version 3.2.
 *
 *  Ingroup: native
 */
GLXWindow glfwGetGLXWindow(GLFWwindow* window);
}

version(GLFW_EXPOSE_NATIVE_WAYLAND) {
/** Returns the `struct wl_display*` used by GLFW.
 *
 *  Returns: The `struct wl_display*` used by GLFW, or `null` if an
 *  [error](@ref error_handling) occurred.
 *
 *  Thread_Safety: This function may be called from any thread.  Access is not
 *  synchronized.
 *
 *  Since: Added in version 3.2.
 *
 *  Ingroup: native
 */
wl_display* glfwGetWaylandDisplay();

/** Returns the `struct wl_output*` of the specified monitor.
 *
 *  Returns: The `struct wl_output*` of the specified monitor, or `null` if an
 *  [error](@ref error_handling) occurred.
 *
 *  Thread_Safety: This function may be called from any thread.  Access is not
 *  synchronized.
 *
 *  Since: Added in version 3.2.
 *
 *  Ingroup: native
 */
wl_output* glfwGetWaylandMonitor(GLFWmonitor* monitor);

/** Returns the main `struct wl_surface*` of the specified window.
 *
 *  Returns: The main `struct wl_surface*` of the specified window, or `null` if
 *  an [error](@ref error_handling) occurred.
 *
 *  Thread_Safety: This function may be called from any thread.  Access is not
 *  synchronized.
 *
 *  Since: Added in version 3.2.
 *
 *  Ingroup: native
 */
wl_surface* glfwGetWaylandWindow(GLFWwindow* window);
}

version(GLFW_EXPOSE_NATIVE_EGL) {
/** Returns the `EGLDisplay` used by GLFW.
 *
 *  Returns: The `EGLDisplay` used by GLFW, or `EGL_NO_DISPLAY` if an
 *  [error](@ref error_handling) occurred.
 *
 *  Thread_Safety: This function may be called from any thread.  Access is not
 *  synchronized.
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: native
 */
EGLDisplay glfwGetEGLDisplay();

/** Returns the `EGLContext` of the specified window.
 *
 *  Returns: The `EGLContext` of the specified window, or `EGL_NO_CONTEXT` if an
 *  [error](@ref error_handling) occurred.
 *
 *  Thread_Safety: This function may be called from any thread.  Access is not
 *  synchronized.
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: native
 */
EGLContext glfwGetEGLContext(GLFWwindow* window);

/** Returns the `EGLSurface` of the specified window.
 *
 *  Returns: The `EGLSurface` of the specified window, or `EGL_NO_SURFACE` if an
 *  [error](@ref error_handling) occurred.
 *
 *  Thread_Safety: This function may be called from any thread.  Access is not
 *  synchronized.
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: native
 */
EGLSurface glfwGetEGLSurface(GLFWwindow* window);
}

version(GLFW_EXPOSE_NATIVE_OSMESA) {
/** Retrieves the color buffer associated with the specified window.
 *
 * Params:
 *  window = The window whose color buffer to retrieve.
 *  width = Where to store the width of the color buffer, or `null`.
 *  height = Where to store the height of the color buffer, or `null`.
 *  format = Where to store the OSMesa pixel format of the color
 *  buffer, or `null`.
 *  buffer = Where to store the address of the color buffer, or
 *  `null`.
 *  Returns: `GLFW_TRUE` if successful, or `GLFW_FALSE` if an
 *  [error](@ref error_handling) occurred.
 *
 *  Thread_Safety: This function may be called from any thread.  Access is not
 *  synchronized.
 *
 *  Since: Added in version 3.3.
 *
 *  Ingroup: native
 */
int glfwGetOSMesaColorBuffer(GLFWwindow* window, int* width, int* height, int* format, void** buffer);

/** Retrieves the depth buffer associated with the specified window.
 *
 * Params:
 *  window = The window whose depth buffer to retrieve.
 *  width = Where to store the width of the depth buffer, or `null`.
 *  height = Where to store the height of the depth buffer, or `null`.
 *  bytesPerValue = Where to store the number of bytes per depth
 *  buffer element, or `null`.
 *  buffer = Where to store the address of the depth buffer, or
 *  `null`.
 *  Returns: `GLFW_TRUE` if successful, or `GLFW_FALSE` if an
 *  [error](@ref error_handling) occurred.
 *
 *  Thread_Safety: This function may be called from any thread.  Access is not
 *  synchronized.
 *
 *  Since: Added in version 3.3.
 *
 *  Ingroup: native
 */
int glfwGetOSMesaDepthBuffer(GLFWwindow* window, int* width, int* height, int* bytesPerValue, void** buffer);

/** Returns the `OSMesaContext` of the specified window.
 *
 *  Returns: The `OSMesaContext` of the specified window, or `null` if an
 *  [error](@ref error_handling) occurred.
 *
 *  Thread_Safety: This function may be called from any thread.  Access is not
 *  synchronized.
 *
 *  Since: Added in version 3.3.
 *
 *  Ingroup: native
 */
OSMesaContext glfwGetOSMesaContext(GLFWwindow* window);
}
