/// Translated from C to D
module glfw3.null_platform;

nothrow:
extern(C): __gshared:

//========================================================================
// GLFW 3.3 - www.glfw.org
//------------------------------------------------------------------------
// Copyright (c) 2016 Google Inc.
// Copyright (c) 2016-2017 Camilla Löwy <elmindreda@glfw.org>
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

import core.sys.posix.dlfcn;

mixin template _GLFW_PLATFORM_WINDOW_STATE() {GLFWwindowNull null_;}

mixin template _GLFW_PLATFORM_CONTEXT_STATE() {        int dummyContext; };
mixin template _GLFW_PLATFORM_MONITOR_STATE() {        int dummyMonitor; };
mixin template _GLFW_PLATFORM_CURSOR_STATE() {         int dummyCursor; };
mixin template _GLFW_PLATFORM_LIBRARY_WINDOW_STATE() { int dummyLibraryWindow; };
mixin template _GLFW_PLATFORM_LIBRARY_CONTEXT_STATE() {int dummyLibraryContext; };
mixin template _GLFW_EGL_CONTEXT_STATE() {             int dummyEGLContext; };
mixin template _GLFW_EGL_LIBRARY_CONTEXT_STATE() {     int dummyEGLLibraryContext; };

public import glfw3.osmesa_context;
public import glfw3.posix_time;
public import glfw3.posix_thread;
public import glfw3.null_joystick;

version(Windows) {
    // auto _glfw_dlopen(const(char)* name) { return LoadLibraryA(name); }
    // auto _glfw_dlclose(void* handle) { return FreeLibrary(cast(HMODULE) handle); }
    // auto _glfw_dlsym(void* handle, const(char)* name) { return GetProcAddress(cast(HMODULE) handle, name);}
} else {
    auto _glfw_dlopen(const(char)* name) {return dlopen(name, RTLD_LAZY | RTLD_LOCAL);}
    auto _glfw_dlclose(void* handle) {return dlclose(handle);}
    auto _glfw_dlsym(void* handle, const(char)* name) {return dlsym(handle, name);}
}

// Null-specific per-window data
//
struct _GLFWwindowNull {
    int width;
    int height;
}
