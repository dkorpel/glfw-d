/// Translated from C to D
module glfw3.wl_monitor;

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
// It is fine to use C99 in this file because it will not be built with VS
//========================================================================

public import glfw3.internal;

public import core.stdc.stdio;
public import core.stdc.stdlib;
public import core.stdc.string;
public import core.stdc.errno;
public import core.stdc.math;


private void outputHandleGeometry(void* data, wl_output* output, int x, int y, int physicalWidth, int physicalHeight, int subpixel, const(char)* make, const(char)* model, int transform) {
    auto monitor = cast(_GLFWmonitor*) data;
    char[1024] name;

    monitor.wl.x = x;
    monitor.wl.y = y;
    monitor.widthMM = physicalWidth;
    monitor.heightMM = physicalHeight;

    snprintf(name.ptr, name.sizeof, "%s %s", make, model);
    monitor.name = _glfw_strdup(name.ptr);
}

private void outputHandleMode(void* data, wl_output* output, uint flags, int width, int height, int refresh) {
    auto monitor = cast(_GLFWmonitor*) data;
    GLFWvidmode mode;

    mode.width = width;
    mode.height = height;
    mode.redBits = 8;
    mode.greenBits = 8;
    mode.blueBits = 8;
    mode.refreshRate = cast(int) round(refresh / 1000.0);

    monitor.modeCount++;
    monitor.modes =
        cast(GLFWvidmode*) realloc(monitor.modes, monitor.modeCount * GLFWvidmode.sizeof);
    monitor.modes[monitor.modeCount - 1] = mode;

    if (flags & WL_OUTPUT_MODE_CURRENT)
        monitor.wl.currentMode = monitor.modeCount - 1;
}

private void outputHandleDone(void* data, wl_output* output) {
    auto monitor = cast(_GLFWmonitor*) data;

    _glfwInputMonitor(monitor, GLFW_CONNECTED, _GLFW_INSERT_LAST);
}

private void outputHandleScale(void* data, wl_output* output, int factor) {
    auto monitor = cast(_GLFWmonitor*) data;

    monitor.wl.scale = factor;
}

private const(wl_output_listener) outputListener = wl_output_listener(
    &outputHandleGeometry,
    &outputHandleMode,
    &outputHandleDone,
    &outputHandleScale,
);


//////////////////////////////////////////////////////////////////////////
//////                       GLFW internal API                      //////
//////////////////////////////////////////////////////////////////////////

void _glfwAddOutputWayland(uint name, uint version_) {
    _GLFWmonitor* monitor;
    wl_output* output;

    if (version_ < 2)
    {
        _glfwInputError(GLFW_PLATFORM_ERROR,
                        "Wayland: Unsupported output interface version");
        return;
    }

    // The actual name of this output will be set in the geometry handler.
    monitor = _glfwAllocMonitor(null, 0, 0);

    output = cast(wl_output*) wl_registry_bind(_glfw.wl.registry,
                              name,
                              &wl_output_interface,
                              2);
    if (!output)
    {
        _glfwFreeMonitor(monitor);
        return;
    }

    monitor.wl.scale = 1;
    monitor.wl.output = output;
    monitor.wl.name = name;

    wl_output_add_listener(output, &outputListener, monitor);
}


//////////////////////////////////////////////////////////////////////////
//////                       GLFW platform API                      //////
//////////////////////////////////////////////////////////////////////////

void _glfwPlatformFreeMonitor(_GLFWmonitor* monitor) {
    if (monitor.wl.output)
        wl_output_destroy(monitor.wl.output);
}

void _glfwPlatformGetMonitorPos(_GLFWmonitor* monitor, int* xpos, int* ypos) {
    if (xpos)
        *xpos = monitor.wl.x;
    if (ypos)
        *ypos = monitor.wl.y;
}

void _glfwPlatformGetMonitorContentScale(_GLFWmonitor* monitor, float* xscale, float* yscale) {
    if (xscale)
        *xscale = cast(float) monitor.wl.scale;
    if (yscale)
        *yscale = cast(float) monitor.wl.scale;
}

void _glfwPlatformGetMonitorWorkarea(_GLFWmonitor* monitor, int* xpos, int* ypos, int* width, int* height) {
    if (xpos)
        *xpos = monitor.wl.x;
    if (ypos)
        *ypos = monitor.wl.y;
    if (width)
        *width = monitor.modes[monitor.wl.currentMode].width;
    if (height)
        *height = monitor.modes[monitor.wl.currentMode].height;
}

GLFWvidmode* _glfwPlatformGetVideoModes(_GLFWmonitor* monitor, int* found) {
    *found = monitor.modeCount;
    return monitor.modes;
}

void _glfwPlatformGetVideoMode(_GLFWmonitor* monitor, GLFWvidmode* mode) {
    *mode = monitor.modes[monitor.wl.currentMode];
}

GLFWbool _glfwPlatformGetGammaRamp(_GLFWmonitor* monitor, GLFWgammaramp* ramp) {
    _glfwInputError(GLFW_PLATFORM_ERROR,
                    "Wayland: Gamma ramp access is not available");
    return GLFW_FALSE;
}

void _glfwPlatformSetGammaRamp(_GLFWmonitor* monitor, const(GLFWgammaramp)* ramp) {
    _glfwInputError(GLFW_PLATFORM_ERROR,
                    "Wayland: Gamma ramp access is not available");
}


//////////////////////////////////////////////////////////////////////////
//////                        GLFW native API                       //////
//////////////////////////////////////////////////////////////////////////

wl_output* glfwGetWaylandMonitor(GLFWmonitor* handle) {
    _GLFWmonitor* monitor = cast(_GLFWmonitor*) handle;
    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"null");
    return monitor.wl.output;
}
