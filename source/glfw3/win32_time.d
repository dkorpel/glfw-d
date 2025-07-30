/// Translated from C to D
module glfw3.win32_time;

version(Windows):
nothrow:
extern(C): __gshared:


//========================================================================
// GLFW 3.3 Win32 - www.glfw.org
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
// Please use C89 style variable declarations in this file because VS 2010
//========================================================================

import glfw3.internal;
package:

//////////////////////////////////////////////////////////////////////////
//////                       GLFW internal API                      //////
//////////////////////////////////////////////////////////////////////////

// Initialise timer
//
void _glfwInitTimerWin32() {
    ulong frequency;

    if (QueryPerformanceFrequency(cast(LARGE_INTEGER*) &frequency))
    {
        _glfw.timer.win32.hasPC = GLFW_TRUE;
        _glfw.timer.win32.frequency = frequency;
    }
    else
    {
        _glfw.timer.win32.hasPC = GLFW_FALSE;
        _glfw.timer.win32.frequency = 1000;
    }
}


//////////////////////////////////////////////////////////////////////////
//////                       GLFW platform API                      //////
//////////////////////////////////////////////////////////////////////////

ulong _glfwPlatformGetTimerValue() {
    if (_glfw.timer.win32.hasPC)
    {
        ulong value;
        QueryPerformanceCounter(cast(LARGE_INTEGER*) &value);
        return value;
    }
    else
        return cast(ulong) _glfw.win32.winmm.GetTime();
}

ulong _glfwPlatformGetTimerFrequency() {
    return _glfw.timer.win32.frequency;
}
