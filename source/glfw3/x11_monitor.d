/// Translated from C to D
module glfw3.x11_monitor;

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
// It is fine to use C99 in this file because it will not be built with VS
//========================================================================

import glfw3.internal;

version(linux):
import core.stdc.limits;
import core.stdc.stdlib;
import core.stdc.string;
import core.stdc.math;
import core.stdc.config: c_long, c_ulong;

// Check whether the display mode should be included in enumeration
//
private GLFWbool modeIsGood(const(XRRModeInfo)* mi) {
    return (mi.modeFlags & RR_Interlace) == 0;
}

// Calculates the refresh rate, in Hz, from the specified RandR mode info
//
private int calculateRefreshRate(const(XRRModeInfo)* mi) {
    if (mi.hTotal && mi.vTotal)
        return cast(int) round(cast(double) mi.dotClock / (cast(double) mi.hTotal * cast(double) mi.vTotal));
    else
        return 0;
}

// Returns the mode info for a RandR mode XID
//
private const(XRRModeInfo)* getModeInfo(const(XRRScreenResources)* sr, RRMode id) {
    for (int i = 0;  i < sr.nmode;  i++)
    {
        if (sr.modes[i].id == id)
            return sr.modes + i;
    }

    return null;
}

// Convert RandR mode info to GLFW video mode
//
private GLFWvidmode vidmodeFromModeInfo(const(XRRModeInfo)* mi, const(XRRCrtcInfo)* ci) {
    GLFWvidmode mode;

    if (ci.rotation == RR_Rotate_90 || ci.rotation == RR_Rotate_270)
    {
        mode.width  = mi.height;
        mode.height = mi.width;
    }
    else
    {
        mode.width  = mi.width;
        mode.height = mi.height;
    }

    mode.refreshRate = calculateRefreshRate(mi);

    _glfwSplitBPP(DefaultDepth(_glfw.x11.display, _glfw.x11.screen),
                  &mode.redBits, &mode.greenBits, &mode.blueBits);

    return mode;
}


//////////////////////////////////////////////////////////////////////////
//////                       GLFW internal API                      //////
//////////////////////////////////////////////////////////////////////////

// Poll for changes in the set of connected monitors
//
void _glfwPollMonitorsX11() {
    if (_glfw.x11.randr.available && !_glfw.x11.randr.monitorBroken)
    {
        int disconnectedCount;int screenCount = 0;
        _GLFWmonitor** disconnected = null;
        XineramaScreenInfo* screens = null;
        XRRScreenResources* sr = _glfw.x11.randr.GetScreenResourcesCurrent(_glfw.x11.display,
                                                              _glfw.x11.root);
        RROutput primary = _glfw.x11.randr.GetOutputPrimary(_glfw.x11.display,
                                               _glfw.x11.root);

        if (_glfw.x11.xinerama.available)
            screens = _glfw.x11.xinerama.QueryScreens(_glfw.x11.display, &screenCount);

        disconnectedCount = _glfw.monitorCount;
        if (disconnectedCount)
        {
            disconnected = cast(_GLFWmonitor**) calloc(_glfw.monitorCount, (_GLFWmonitor*).sizeof);
            memcpy(disconnected,
                   _glfw.monitors,
                   _glfw.monitorCount * (_GLFWmonitor*).sizeof);
        }

        for (int i = 0;  i < sr.noutput;  i++)
        {
            int j;int type;int widthMM;int heightMM;

            XRROutputInfo* oi = _glfw.x11.randr.GetOutputInfo(_glfw.x11.display, sr, sr.outputs[i]);
            if (oi.connection != RR_Connected || oi.crtc == None)
            {
                _glfw.x11.randr.FreeOutputInfo(oi);
                continue;
            }

            for (j = 0;  j < disconnectedCount;  j++)
            {
                if (disconnected[j] &&
                    disconnected[j].x11.output == sr.outputs[i])
                {
                    disconnected[j] = null;
                    break;
                }
            }

            if (j < disconnectedCount)
            {
                _glfw.x11.randr.FreeOutputInfo(oi);
                continue;
            }

            XRRCrtcInfo* ci = _glfw.x11.randr.GetCrtcInfo(_glfw.x11.display, sr, oi.crtc);
            if (ci.rotation == RR_Rotate_90 || ci.rotation == RR_Rotate_270)
            {
                widthMM  = cast(int) oi.mm_height;
                heightMM = cast(int) oi.mm_width;
            }
            else
            {
                widthMM  = cast(int) oi.mm_width;
                heightMM = cast(int) oi.mm_height;
            }

            if (widthMM <= 0 || heightMM <= 0)
            {
                // HACK: If RandR does not provide a physical size, assume the
                //       X11 default 96 DPI and calcuate from the CRTC viewport
                // NOTE: These members are affected by rotation, unlike the mode
                //       info and output info members
                widthMM  = cast(int) (ci.width * 25.4f / 96.0f);
                heightMM = cast(int) (ci.height * 25.4f / 96.0f);
            }

            _GLFWmonitor* monitor = _glfwAllocMonitor(oi.name, widthMM, heightMM);
            monitor.x11.output = sr.outputs[i];
            monitor.x11.crtc   = oi.crtc;

            for (j = 0;  j < screenCount;  j++)
            {
                if (screens[j].x_org == ci.x &&
                    screens[j].y_org == ci.y &&
                    screens[j].width == ci.width &&
                    screens[j].height == ci.height)
                {
                    monitor.x11.index = j;
                    break;
                }
            }

            if (monitor.x11.output == primary)
                type = _GLFW_INSERT_FIRST;
            else
                type = _GLFW_INSERT_LAST;

            _glfwInputMonitor(monitor, GLFW_CONNECTED, type);

            _glfw.x11.randr.FreeOutputInfo(oi);
            _glfw.x11.randr.FreeCrtcInfo(ci);
        }

        _glfw.x11.randr.FreeScreenResources(sr);

        if (screens)
            XFree(screens);

        for (int i = 0;  i < disconnectedCount;  i++)
        {
            if (disconnected[i])
                _glfwInputMonitor(disconnected[i], GLFW_DISCONNECTED, 0);
        }

        free(disconnected);
    }
    else
    {
        const(int) widthMM = DisplayWidthMM(_glfw.x11.display, _glfw.x11.screen);
        const(int) heightMM = DisplayHeightMM(_glfw.x11.display, _glfw.x11.screen);

        _glfwInputMonitor(_glfwAllocMonitor("Display", widthMM, heightMM),
                          GLFW_CONNECTED,
                          _GLFW_INSERT_FIRST);
    }
}

// Set the current video mode for the specified monitor
//
void _glfwSetVideoModeX11(_GLFWmonitor* monitor, const(GLFWvidmode)* desired) {
    if (_glfw.x11.randr.available && !_glfw.x11.randr.monitorBroken)
    {
        GLFWvidmode current;
        RRMode native = None;

        const(GLFWvidmode)* best = _glfwChooseVideoMode(monitor, desired);
        _glfwPlatformGetVideoMode(monitor, &current);
        if (_glfwCompareVideoModes(&current, best) == 0)
            return;

        XRRScreenResources* sr = _glfw.x11.randr.GetScreenResourcesCurrent(_glfw.x11.display, _glfw.x11.root);
        XRRCrtcInfo* ci = _glfw.x11.randr.GetCrtcInfo(_glfw.x11.display, sr, monitor.x11.crtc);
        XRROutputInfo* oi = _glfw.x11.randr.GetOutputInfo(_glfw.x11.display, sr, monitor.x11.output);

        for (int i = 0;  i < oi.nmode;  i++)
        {
            const(XRRModeInfo)* mi = getModeInfo(sr, oi.modes[i]);
            if (!modeIsGood(mi))
                continue;

            const(GLFWvidmode) mode = vidmodeFromModeInfo(mi, ci);
            if (_glfwCompareVideoModes(best, &mode) == 0)
            {
                native = mi.id;
                break;
            }
        }

        if (native)
        {
            if (monitor.x11.oldMode == None)
                monitor.x11.oldMode = ci.mode;

            _glfw.x11.randr.SetCrtcConfig(_glfw.x11.display,
                             sr, monitor.x11.crtc,
                             CurrentTime,
                             ci.x, ci.y,
                             native,
                             ci.rotation,
                             ci.outputs,
                             ci.noutput);
        }

        _glfw.x11.randr.FreeOutputInfo(oi);
        _glfw.x11.randr.FreeCrtcInfo(ci);
        _glfw.x11.randr.FreeScreenResources(sr);
    }
}

// Restore the saved (original) video mode for the specified monitor
//
void _glfwRestoreVideoModeX11(_GLFWmonitor* monitor) {
    if (_glfw.x11.randr.available && !_glfw.x11.randr.monitorBroken)
    {
        if (monitor.x11.oldMode == None)
            return;

        XRRScreenResources* sr = _glfw.x11.randr.GetScreenResourcesCurrent(_glfw.x11.display, _glfw.x11.root);
        XRRCrtcInfo* ci = _glfw.x11.randr.GetCrtcInfo(_glfw.x11.display, sr, monitor.x11.crtc);

        _glfw.x11.randr.SetCrtcConfig(_glfw.x11.display,
                         sr, monitor.x11.crtc,
                         CurrentTime,
                         ci.x, ci.y,
                         monitor.x11.oldMode,
                         ci.rotation,
                         ci.outputs,
                         ci.noutput);

        _glfw.x11.randr.FreeCrtcInfo(ci);
        _glfw.x11.randr.FreeScreenResources(sr);

        monitor.x11.oldMode = None;
    }
}


//////////////////////////////////////////////////////////////////////////
//////                       GLFW platform API                      //////
//////////////////////////////////////////////////////////////////////////

void _glfwPlatformFreeMonitor(_GLFWmonitor* monitor) {
}

void _glfwPlatformGetMonitorPos(_GLFWmonitor* monitor, int* xpos, int* ypos) {
    if (_glfw.x11.randr.available && !_glfw.x11.randr.monitorBroken)
    {
        XRRScreenResources* sr = _glfw.x11.randr.GetScreenResourcesCurrent(_glfw.x11.display, _glfw.x11.root);
        XRRCrtcInfo* ci = _glfw.x11.randr.GetCrtcInfo(_glfw.x11.display, sr, monitor.x11.crtc);

        if (ci)
        {
            if (xpos)
                *xpos = ci.x;
            if (ypos)
                *ypos = ci.y;

            _glfw.x11.randr.FreeCrtcInfo(ci);
        }

        _glfw.x11.randr.FreeScreenResources(sr);
    }
}

void _glfwPlatformGetMonitorContentScale(_GLFWmonitor* monitor, float* xscale, float* yscale) {
    if (xscale)
        *xscale = _glfw.x11.contentScaleX;
    if (yscale)
        *yscale = _glfw.x11.contentScaleY;
}

void _glfwPlatformGetMonitorWorkarea(_GLFWmonitor* monitor, int* xpos, int* ypos, int* width, int* height) {
    int areaX = 0;int areaY = 0;int areaWidth = 0;int areaHeight = 0;

    if (_glfw.x11.randr.available && !_glfw.x11.randr.monitorBroken)
    {
        XRRScreenResources* sr = _glfw.x11.randr.GetScreenResourcesCurrent(_glfw.x11.display, _glfw.x11.root);
        XRRCrtcInfo* ci = _glfw.x11.randr.GetCrtcInfo(_glfw.x11.display, sr, monitor.x11.crtc);

        areaX = ci.x;
        areaY = ci.y;

        const(XRRModeInfo)* mi = getModeInfo(sr, ci.mode);

        if (ci.rotation == RR_Rotate_90 || ci.rotation == RR_Rotate_270)
        {
            areaWidth  = mi.height;
            areaHeight = mi.width;
        }
        else
        {
            areaWidth  = mi.width;
            areaHeight = mi.height;
        }

        _glfw.x11.randr.FreeCrtcInfo(ci);
        _glfw.x11.randr.FreeScreenResources(sr);
    }
    else
    {
        areaWidth  = DisplayWidth(_glfw.x11.display, _glfw.x11.screen);
        areaHeight = DisplayHeight(_glfw.x11.display, _glfw.x11.screen);
    }

    if (_glfw.x11.NET_WORKAREA && _glfw.x11.NET_CURRENT_DESKTOP)
    {
        Atom* extents = null;
        Atom* desktop = null;
        c_ulong extentCount = _glfwGetWindowPropertyX11(_glfw.x11.root,
                                      _glfw.x11.NET_WORKAREA,
                                      XA_CARDINAL,
                                      cast(ubyte**) &extents);

        if (_glfwGetWindowPropertyX11(_glfw.x11.root,
                                      _glfw.x11.NET_CURRENT_DESKTOP,
                                      XA_CARDINAL,
                                      cast(ubyte**) &desktop) > 0)
        {
            if (extentCount >= 4 && *desktop < extentCount / 4)
            {
                const int globalX      = cast(int) extents[*desktop * 4 + 0];
                const int globalY      = cast(int) extents[*desktop * 4 + 1];
                const int globalWidth  = cast(int) extents[*desktop * 4 + 2];
                const int globalHeight = cast(int) extents[*desktop * 4 + 3];

                if (areaX < globalX)
                {
                    areaWidth -= globalX - areaX;
                    areaX = globalX;
                }

                if (areaY < globalY)
                {
                    areaHeight -= globalY - areaY;
                    areaY = globalY;
                }

                if (areaX + areaWidth > globalX + globalWidth)
                    areaWidth = globalX - areaX + globalWidth;
                if (areaY + areaHeight > globalY + globalHeight)
                    areaHeight = globalY - areaY + globalHeight;
            }
        }

        if (extents)
            XFree(extents);
        if (desktop)
            XFree(desktop);
    }

    if (xpos)
        *xpos = areaX;
    if (ypos)
        *ypos = areaY;
    if (width)
        *width = areaWidth;
    if (height)
        *height = areaHeight;
}

GLFWvidmode* _glfwPlatformGetVideoModes(_GLFWmonitor* monitor, int* count) {
    GLFWvidmode* result;

    *count = 0;

    if (_glfw.x11.randr.available && !_glfw.x11.randr.monitorBroken)
    {
        XRRScreenResources* sr = _glfw.x11.randr.GetScreenResourcesCurrent(_glfw.x11.display, _glfw.x11.root);
        XRRCrtcInfo* ci = _glfw.x11.randr.GetCrtcInfo(_glfw.x11.display, sr, monitor.x11.crtc);
        XRROutputInfo* oi = _glfw.x11.randr.GetOutputInfo(_glfw.x11.display, sr, monitor.x11.output);

        result = cast(GLFWvidmode*) calloc(oi.nmode, GLFWvidmode.sizeof);

        for (int i = 0;  i < oi.nmode;  i++)
        {
            const(XRRModeInfo)* mi = getModeInfo(sr, oi.modes[i]);
            if (!modeIsGood(mi))
                continue;

            const(GLFWvidmode) mode = vidmodeFromModeInfo(mi, ci);
            int j;

            for (j = 0;  j < *count;  j++)
            {
                if (_glfwCompareVideoModes(result + j, &mode) == 0)
                    break;
            }

            // Skip duplicate modes
            if (j < *count)
                continue;

            (*count)++;
            result[*count - 1] = mode;
        }

        _glfw.x11.randr.FreeOutputInfo(oi);
        _glfw.x11.randr.FreeCrtcInfo(ci);
        _glfw.x11.randr.FreeScreenResources(sr);
    }
    else
    {
        *count = 1;
        result = cast(GLFWvidmode*) calloc(1, GLFWvidmode.sizeof);
        _glfwPlatformGetVideoMode(monitor, result);
    }

    return result;
}

void _glfwPlatformGetVideoMode(_GLFWmonitor* monitor, GLFWvidmode* mode) {
    if (_glfw.x11.randr.available && !_glfw.x11.randr.monitorBroken)
    {
        XRRScreenResources* sr = _glfw.x11.randr.GetScreenResourcesCurrent(_glfw.x11.display, _glfw.x11.root);
        XRRCrtcInfo* ci = _glfw.x11.randr.GetCrtcInfo(_glfw.x11.display, sr, monitor.x11.crtc);

        if (ci)
        {
            const(XRRModeInfo)* mi = getModeInfo(sr, ci.mode);
            if (mi)  // mi can be NULL if the monitor has been disconnected
                *mode = vidmodeFromModeInfo(mi, ci);

            _glfw.x11.randr.FreeCrtcInfo(ci);
        }

        _glfw.x11.randr.FreeScreenResources(sr);
    }
    else
    {
        mode.width = DisplayWidth(_glfw.x11.display, _glfw.x11.screen);
        mode.height = DisplayHeight(_glfw.x11.display, _glfw.x11.screen);
        mode.refreshRate = 0;

        _glfwSplitBPP(DefaultDepth(_glfw.x11.display, _glfw.x11.screen),
                      &mode.redBits, &mode.greenBits, &mode.blueBits);
    }
}

GLFWbool _glfwPlatformGetGammaRamp(_GLFWmonitor* monitor, GLFWgammaramp* ramp) {
    if (_glfw.x11.randr.available && !_glfw.x11.randr.gammaBroken)
    {
        const(size_t) size = _glfw.x11.randr.GetCrtcGammaSize(_glfw.x11.display,
                                                monitor.x11.crtc);
        XRRCrtcGamma* gamma = _glfw.x11.randr.GetCrtcGamma(_glfw.x11.display,
                                              monitor.x11.crtc);

        _glfwAllocGammaArrays(ramp, cast(uint) size);

        memcpy(ramp.red,   gamma.red,   size * ushort.sizeof);
        memcpy(ramp.green, gamma.green, size * ushort.sizeof);
        memcpy(ramp.blue,  gamma.blue,  size * ushort.sizeof);

        _glfw.x11.randr.FreeGamma(gamma);
        return GLFW_TRUE;
    }
    else if (_glfw.x11.vidmode.available)
    {
        int size;
        _glfw.x11.vidmode.GetGammaRampSize(_glfw.x11.display, _glfw.x11.screen, &size);

        _glfwAllocGammaArrays(ramp, size);

        _glfw.x11.vidmode.GetGammaRamp(_glfw.x11.display,
                                _glfw.x11.screen,
                                ramp.size, ramp.red, ramp.green, ramp.blue);
        return GLFW_TRUE;
    }
    else
    {
        _glfwInputError(GLFW_PLATFORM_ERROR,
                        "X11: Gamma ramp access not supported by server");
        return GLFW_FALSE;
    }
}

void _glfwPlatformSetGammaRamp(_GLFWmonitor* monitor, const(GLFWgammaramp)* ramp) {
    if (_glfw.x11.randr.available && !_glfw.x11.randr.gammaBroken)
    {
        if (_glfw.x11.randr.GetCrtcGammaSize(_glfw.x11.display, monitor.x11.crtc) != ramp.size)
        {
            _glfwInputError(GLFW_PLATFORM_ERROR,
                            "X11: Gamma ramp size must match current ramp size");
            return;
        }

        XRRCrtcGamma* gamma = _glfw.x11.randr.AllocGamma(ramp.size);

        memcpy(gamma.red,   ramp.red,   ramp.size * ushort.sizeof);
        memcpy(gamma.green, ramp.green, ramp.size * ushort.sizeof);
        memcpy(gamma.blue,  ramp.blue,  ramp.size * ushort.sizeof);

        _glfw.x11.randr.SetCrtcGamma(_glfw.x11.display, monitor.x11.crtc, gamma);
        _glfw.x11.randr.FreeGamma(gamma);
    }
    else if (_glfw.x11.vidmode.available)
    {
        _glfw.x11.vidmode.SetGammaRamp(_glfw.x11.display,
                                _glfw.x11.screen,
                                ramp.size,
                                cast(ushort*) ramp.red,
                                cast(ushort*) ramp.green,
                                cast(ushort*) ramp.blue);
    }
    else
    {
        _glfwInputError(GLFW_PLATFORM_ERROR,
                        "X11: Gamma ramp access not supported by server");
    }
}


//////////////////////////////////////////////////////////////////////////
//////                        GLFW native API                       //////
//////////////////////////////////////////////////////////////////////////

RRCrtc glfwGetX11Adapter(GLFWmonitor* handle) {
    _GLFWmonitor* monitor = cast(_GLFWmonitor*) handle;
    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"None");
    return monitor.x11.crtc;
}

RROutput glfwGetX11Monitor(GLFWmonitor* handle) {
    _GLFWmonitor* monitor = cast(_GLFWmonitor*) handle;
    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"None");
    return monitor.x11.output;
}
