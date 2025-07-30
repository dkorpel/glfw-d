/// Translated from C to D
module glfw3.posix_time;

nothrow:
extern(C): __gshared:
version(Posix):

//========================================================================
// GLFW 3.3 POSIX - www.glfw.org
//------------------------------------------------------------------------
// Copyright (c) 2002-2006 Marcus Geelnard
// Copyright (c) 2006-2017 Camilla Löwy <elmindreda@glfw.org>
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

import core.sys.posix.time;
import core.sys.posix.sys.time;

import core.stdc.time;

mixin template _GLFW_PLATFORM_LIBRARY_TIMER_STATE() {_GLFWtimerPOSIX posix;}

// POSIX-specific global timer data
//
struct _GLFWtimerPOSIX
{
    GLFWbool    monotonic;
    ulong    frequency;
}

//////////////////////////////////////////////////////////////////////////
//////                       GLFW internal API                      //////
//////////////////////////////////////////////////////////////////////////

// Initialise timer
//
void _glfwInitTimerPOSIX() {
    timespec ts;
    if (clock_gettime(CLOCK_MONOTONIC, &ts) == 0)
    {
        _glfw.timer.posix.monotonic = GLFW_TRUE;
        _glfw.timer.posix.frequency = 1000000000;
    }
}


//////////////////////////////////////////////////////////////////////////
//////                       GLFW platform API                      //////
//////////////////////////////////////////////////////////////////////////

ulong _glfwPlatformGetTimerValue() {
    if (_glfw.timer.posix.monotonic) {
        timespec ts;
        clock_gettime(CLOCK_MONOTONIC, &ts);
        return cast(ulong) ts.tv_sec * cast(ulong) 1000000000 + cast(ulong) ts.tv_nsec;
    } else {
        timeval tv;
        gettimeofday(&tv, null);
        return cast(ulong) tv.tv_sec * cast(ulong) 1000000 + cast(ulong) tv.tv_usec;
    }
}

ulong _glfwPlatformGetTimerFrequency() {
    return _glfw.timer.posix.frequency;
}
