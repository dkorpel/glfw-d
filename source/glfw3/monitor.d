/// Translated from C to D
module glfw3.monitor;

nothrow:
extern(C): __gshared:

//========================================================================
// GLFW 3.3 - www.glfw.org
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

import core.stdc.assert_;
import core.stdc.math;
import core.stdc.string;
import core.stdc.stdlib;
import core.stdc.limits;

// Lexically compare video modes, used by qsort
//
private int compareVideoModes(const(void)* fp, const(void)* sp) {
    auto fm = cast(const(GLFWvidmode)*) fp;
    auto sm = cast(const(GLFWvidmode)*) sp;
    const(int) fbpp = fm.redBits + fm.greenBits + fm.blueBits;
    const(int) sbpp = sm.redBits + sm.greenBits + sm.blueBits;
    const(int) farea = fm.width * fm.height;
    const(int) sarea = sm.width * sm.height;

    // First sort on color bits per pixel
    if (fbpp != sbpp)
        return fbpp - sbpp;

    // Then sort on screen area
    if (farea != sarea)
        return farea - sarea;

    // Then sort on width
    if (fm.width != sm.width)
        return fm.width - sm.width;

    // Lastly sort on refresh rate
    return fm.refreshRate - sm.refreshRate;
}

// Retrieves the available modes for the specified monitor
//
private GLFWbool refreshVideoModes(_GLFWmonitor* monitor) {
    int modeCount;
    GLFWvidmode* modes;

    if (monitor.modes)
        return GLFW_TRUE;

    modes = _glfwPlatformGetVideoModes(monitor, &modeCount);
    if (!modes)
        return GLFW_FALSE;

    qsort(modes, modeCount, GLFWvidmode.sizeof, &compareVideoModes);

    free(monitor.modes);
    monitor.modes = modes;
    monitor.modeCount = modeCount;

    return GLFW_TRUE;
}


//////////////////////////////////////////////////////////////////////////
//////                         GLFW event API                       //////
//////////////////////////////////////////////////////////////////////////

// Notifies shared code of a monitor connection or disconnection
//
void _glfwInputMonitor(_GLFWmonitor* monitor, int action, int placement) {
    if (action == GLFW_CONNECTED)
    {
        _glfw.monitorCount++;
        _glfw.monitors =
            cast(_GLFWmonitor**) realloc(_glfw.monitors, (_GLFWmonitor*).sizeof * _glfw.monitorCount);

        if (placement == _GLFW_INSERT_FIRST)
        {
            memmove(_glfw.monitors + 1,
                    _glfw.monitors,
                    (cast(size_t) _glfw.monitorCount - 1) * (_GLFWmonitor*).sizeof);
            _glfw.monitors[0] = monitor;
        }
        else
            _glfw.monitors[_glfw.monitorCount - 1] = monitor;
    }
    else if (action == GLFW_DISCONNECTED)
    {
        int i;
        _GLFWwindow* window;

        for (window = _glfw.windowListHead;  window;  window = window.next)
        {
            if (window.monitor == monitor)
            {
                int width;int height;int xoff;int yoff;
                _glfwPlatformGetWindowSize(window, &width, &height);
                _glfwPlatformSetWindowMonitor(window, null, 0, 0, width, height, 0);
                _glfwPlatformGetWindowFrameSize(window, &xoff, &yoff, null, null);
                _glfwPlatformSetWindowPos(window, xoff, yoff);
            }
        }

        for (i = 0;  i < _glfw.monitorCount;  i++)
        {
            if (_glfw.monitors[i] == monitor)
            {
                _glfw.monitorCount--;
                memmove(_glfw.monitors + i,
                        _glfw.monitors + i + 1,
                        (cast(size_t) _glfw.monitorCount - i) * (_GLFWmonitor*).sizeof);
                break;
            }
        }
    }

    if (_glfw.callbacks.monitor)
        _glfw.callbacks.monitor(cast(GLFWmonitor*) monitor, action);

    if (action == GLFW_DISCONNECTED)
        _glfwFreeMonitor(monitor);
}

// Notifies shared code that a full screen window has acquired or released
// a monitor
//
void _glfwInputMonitorWindow(_GLFWmonitor* monitor, _GLFWwindow* window) {
    monitor.window = window;
}


//////////////////////////////////////////////////////////////////////////
//////                       GLFW internal API                      //////
//////////////////////////////////////////////////////////////////////////

// Allocates and returns a monitor object with the specified name and dimensions
//
_GLFWmonitor* _glfwAllocMonitor(const(char)* name, int widthMM, int heightMM) {
    auto monitor = cast(_GLFWmonitor*) calloc(1, _GLFWmonitor.sizeof);
    monitor.widthMM = widthMM;
    monitor.heightMM = heightMM;

    if (name)
        monitor.name = _glfw_strdup(name);

    return monitor;
}

// Frees a monitor object and any data associated with it
//
void _glfwFreeMonitor(_GLFWmonitor* monitor) {
    if (monitor == null)
        return;

    _glfwPlatformFreeMonitor(monitor);

    _glfwFreeGammaArrays(&monitor.originalRamp);
    _glfwFreeGammaArrays(&monitor.currentRamp);

    free(monitor.modes);
    free(monitor.name);
    free(monitor);
}

// Allocates red, green and blue value arrays of the specified size
//
void _glfwAllocGammaArrays(GLFWgammaramp* ramp, uint size) {
    ramp.red =   cast(ushort*) calloc(size, ushort.sizeof);
    ramp.green = cast(ushort*) calloc(size, ushort.sizeof);
    ramp.blue =  cast(ushort*) calloc(size, ushort.sizeof);
    ramp.size = size;
}

// Frees the red, green and blue value arrays and clears the struct
//
void _glfwFreeGammaArrays(GLFWgammaramp* ramp) {
    free(ramp.red);
    free(ramp.green);
    free(ramp.blue);

    memset(ramp, 0, GLFWgammaramp.sizeof);
}

// Chooses the video mode most closely matching the desired one
//
const(GLFWvidmode)* _glfwChooseVideoMode(_GLFWmonitor* monitor, const(GLFWvidmode)* desired) {
    int i;
    uint sizeDiff;uint leastSizeDiff = UINT_MAX;
    uint rateDiff;uint leastRateDiff = UINT_MAX;
    uint colorDiff;uint leastColorDiff = UINT_MAX;
    const(GLFWvidmode)* current;
    const(GLFWvidmode)* closest = null;

    if (!refreshVideoModes(monitor))
        return null;

    for (i = 0;  i < monitor.modeCount;  i++)
    {
        current = monitor.modes + i;

        colorDiff = 0;

        if (desired.redBits != GLFW_DONT_CARE)
            colorDiff += abs(current.redBits - desired.redBits);
        if (desired.greenBits != GLFW_DONT_CARE)
            colorDiff += abs(current.greenBits - desired.greenBits);
        if (desired.blueBits != GLFW_DONT_CARE)
            colorDiff += abs(current.blueBits - desired.blueBits);

        sizeDiff = abs((current.width - desired.width) *
                       (current.width - desired.width) +
                       (current.height - desired.height) *
                       (current.height - desired.height));

        if (desired.refreshRate != GLFW_DONT_CARE)
            rateDiff = abs(current.refreshRate - desired.refreshRate);
        else
            rateDiff = UINT_MAX - current.refreshRate;

        if ((colorDiff < leastColorDiff) ||
            (colorDiff == leastColorDiff && sizeDiff < leastSizeDiff) ||
            (colorDiff == leastColorDiff && sizeDiff == leastSizeDiff && rateDiff < leastRateDiff))
        {
            closest = current;
            leastSizeDiff = sizeDiff;
            leastRateDiff = rateDiff;
            leastColorDiff = colorDiff;
        }
    }

    return closest;
}

// Performs lexical comparison between two @ref GLFWvidmode structures
//
int _glfwCompareVideoModes(const(GLFWvidmode)* fm, const(GLFWvidmode)* sm) {
    return compareVideoModes(fm, sm);
}

// Splits a color depth into red, green and blue bit depths
//
void _glfwSplitBPP(int bpp, int* red, int* green, int* blue) {
    int delta;

    // We assume that by 32 the user really meant 24
    if (bpp == 32)
        bpp = 24;

    // Convert "bits per pixel" to red, green & blue sizes

    *red = *green = *blue = bpp / 3;
    delta = bpp - (*red * 3);
    if (delta >= 1)
        *green = *green + 1;

    if (delta == 2)
        *red = *red + 1;
}


//////////////////////////////////////////////////////////////////////////
//////                        GLFW public API                       //////
//////////////////////////////////////////////////////////////////////////

GLFWmonitor** glfwGetMonitors(int* count) {
    assert(count != null);

    *count = 0;

    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"null");

    *count = _glfw.monitorCount;
    return cast(GLFWmonitor**) _glfw.monitors;
}

GLFWmonitor* glfwGetPrimaryMonitor() {
    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"null");

    if (!_glfw.monitorCount)
        return null;

    return cast(GLFWmonitor*) _glfw.monitors[0];
}

void glfwGetMonitorPos(GLFWmonitor* handle, int* xpos, int* ypos) {
    _GLFWmonitor* monitor = cast(_GLFWmonitor*) handle;
    assert(monitor != null);

    if (xpos)
        *xpos = 0;
    if (ypos)
        *ypos = 0;

    mixin(_GLFW_REQUIRE_INIT);

    _glfwPlatformGetMonitorPos(monitor, xpos, ypos);
}

void glfwGetMonitorWorkarea(GLFWmonitor* handle, int* xpos, int* ypos, int* width, int* height) {
    _GLFWmonitor* monitor = cast(_GLFWmonitor*) handle;
    assert(monitor != null);

    if (xpos)
        *xpos = 0;
    if (ypos)
        *ypos = 0;
    if (width)
        *width = 0;
    if (height)
        *height = 0;

    mixin(_GLFW_REQUIRE_INIT);

    _glfwPlatformGetMonitorWorkarea(monitor, xpos, ypos, width, height);
}

void glfwGetMonitorPhysicalSize(GLFWmonitor* handle, int* widthMM, int* heightMM) {
    _GLFWmonitor* monitor = cast(_GLFWmonitor*) handle;
    assert(monitor != null);

    if (widthMM)
        *widthMM = 0;
    if (heightMM)
        *heightMM = 0;

    mixin(_GLFW_REQUIRE_INIT);

    if (widthMM)
        *widthMM = monitor.widthMM;
    if (heightMM)
        *heightMM = monitor.heightMM;
}

void glfwGetMonitorContentScale(GLFWmonitor* handle, float* xscale, float* yscale) {
    _GLFWmonitor* monitor = cast(_GLFWmonitor*) handle;
    assert(monitor != null);

    if (xscale)
        *xscale = 0.0f;
    if (yscale)
        *yscale = 0.0f;

    mixin(_GLFW_REQUIRE_INIT);
    _glfwPlatformGetMonitorContentScale(monitor, xscale, yscale);
}

const(char)* glfwGetMonitorName(GLFWmonitor* handle) {
    _GLFWmonitor* monitor = cast(_GLFWmonitor*) handle;
    assert(monitor != null);

    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"null");
    return monitor.name;
}

void glfwSetMonitorUserPointer(GLFWmonitor* handle, void* pointer) {
    _GLFWmonitor* monitor = cast(_GLFWmonitor*) handle;
    assert(monitor != null);

    mixin(_GLFW_REQUIRE_INIT);
    monitor.userPointer = pointer;
}

void* glfwGetMonitorUserPointer(GLFWmonitor* handle) {
    _GLFWmonitor* monitor = cast(_GLFWmonitor*) handle;
    assert(monitor != null);

    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"null");
    return monitor.userPointer;
}

GLFWmonitorfun glfwSetMonitorCallback(GLFWmonitorfun cbfun) {
    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"null");
    _GLFW_SWAP_POINTERS(_glfw.callbacks.monitor, cbfun);
    return cbfun;
}

const(GLFWvidmode)* glfwGetVideoModes(GLFWmonitor* handle, int* count) {
    _GLFWmonitor* monitor = cast(_GLFWmonitor*) handle;
    assert(monitor != null);
    assert(count != null);

    *count = 0;

    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"null");

    if (!refreshVideoModes(monitor))
        return null;

    *count = monitor.modeCount;
    return monitor.modes;
}

const(GLFWvidmode)* glfwGetVideoMode(GLFWmonitor* handle) {
    _GLFWmonitor* monitor = cast(_GLFWmonitor*) handle;
    assert(monitor != null);

    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"null");

    _glfwPlatformGetVideoMode(monitor, &monitor.currentMode);
    return &monitor.currentMode;
}

void glfwSetGamma(GLFWmonitor* handle, float gamma) {
    uint i;
    ushort* values;
    GLFWgammaramp ramp;
    const(GLFWgammaramp)* original;
    assert(handle != null);
    assert(gamma > 0.0f);
    assert(gamma <= float.max);

    mixin(_GLFW_REQUIRE_INIT);

    if (gamma != gamma || gamma <= 0.0f || gamma > float.max)
    {
        _glfwInputError(GLFW_INVALID_VALUE, "Invalid gamma value %f", gamma);
        return;
    }

    original = glfwGetGammaRamp(handle);
    if (!original)
        return;

    values = cast(ushort*) calloc(original.size, ushort.sizeof);

    for (i = 0;  i < original.size;  i++)
    {
        float value;

        // Calculate intensity
        value = i / cast(float) (original.size - 1);
        // Apply gamma curve
        value = powf(value, 1.0f / gamma) * 65535.0f + 0.5f;
        // Clamp to value range
        value = _glfw_fminf(value, 65535.0f);

        values[i] = cast(ushort) value;
    }

    ramp.red = values;
    ramp.green = values;
    ramp.blue = values;
    ramp.size = original.size;

    glfwSetGammaRamp(handle, &ramp);
    free(values);
}

const(GLFWgammaramp)* glfwGetGammaRamp(GLFWmonitor* handle) {
    _GLFWmonitor* monitor = cast(_GLFWmonitor*) handle;
    assert(monitor != null);

    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"null");

    _glfwFreeGammaArrays(&monitor.currentRamp);
    if (!_glfwPlatformGetGammaRamp(monitor, &monitor.currentRamp))
        return null;

    return &monitor.currentRamp;
}

void glfwSetGammaRamp(GLFWmonitor* handle, const(GLFWgammaramp)* ramp) {
    _GLFWmonitor* monitor = cast(_GLFWmonitor*) handle;
    assert(monitor != null);
    assert(ramp != null);
    assert(ramp.size > 0);
    assert(ramp.red != null);
    assert(ramp.green != null);
    assert(ramp.blue != null);

    if (ramp.size <= 0)
    {
        _glfwInputError(GLFW_INVALID_VALUE,
                        "Invalid gamma ramp size %i",
                        ramp.size);
        return;
    }

    mixin(_GLFW_REQUIRE_INIT);

    if (!monitor.originalRamp.size)
    {
        if (!_glfwPlatformGetGammaRamp(monitor, &monitor.originalRamp))
            return;
    }

    _glfwPlatformSetGammaRamp(monitor, ramp);
}
