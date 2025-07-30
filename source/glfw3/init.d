/// Translated from C to D
module glfw3.init;

extern(C): nothrow: __gshared:

//========================================================================
// GLFW 3.3 - www.glfw.org
//------------------------------------------------------------------------
// Copyright (c) 2002-2006 Marcus Geelnard
// Copyright (c) 2006-2018 Camilla Löwy <elmindreda@glfw.org>
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
import glfw3.mappings;

import core.stdc.string;
import core.stdc.stdlib;
import core.stdc.stdio;
import core.stdc.stdarg;
import core.stdc.assert_;

// The global variables below comprise all mutable global data in GLFW
//
// Any other global variable is a bug

// Global state shared between compilation units of GLFW
//
_GLFWlibrary _glfw; // = _GLFWlibrary.init;

// #compiletime: CTFE for _GLFWlibrary.init or _GLFWlibrary(GLFW_FALSE) takes 21ms

// These are outside of _glfw so they can be used before initialization and
// after termination
//
private _GLFWerror _glfwMainThreadError;
private GLFWerrorfun _glfwErrorCallback;
private _GLFWinitconfig _glfwInitHints = _GLFWinitconfig(
    GLFW_TRUE,      // hat buttons
    _GLFWinitconfig._Ns(
        GLFW_TRUE,  // macOS menu bar
        GLFW_TRUE   // macOS bundle chdir
    )
);

// Terminate the library
//
private extern(D) void terminate() {
    int i;

    memset(&_glfw.callbacks, 0, typeof(_glfw.callbacks).sizeof);

    while (_glfw.windowListHead)
        glfwDestroyWindow(cast(GLFWwindow*) _glfw.windowListHead);

    while (_glfw.cursorListHead)
        glfwDestroyCursor(cast(GLFWcursor*) _glfw.cursorListHead);

    for (i = 0;  i < _glfw.monitorCount;  i++)
    {
        _GLFWmonitor* monitor = _glfw.monitors[i];
        if (monitor.originalRamp.size)
            _glfwPlatformSetGammaRamp(monitor, &monitor.originalRamp);
        _glfwFreeMonitor(monitor);
    }

    free(_glfw.monitors);
    _glfw.monitors = null;
    _glfw.monitorCount = 0;

    free(_glfw.mappings);
    _glfw.mappings = null;
    _glfw.mappingCount = 0;

    _glfwTerminateVulkan();
    _glfwPlatformTerminate();

    _glfw.initialized = GLFW_FALSE;

    while (_glfw.errorListHead)
    {
        _GLFWerror* error = _glfw.errorListHead;
        _glfw.errorListHead = error.next;
        free(error);
    }

    _glfwPlatformDestroyTls(&_glfw.contextSlot);
    _glfwPlatformDestroyTls(&_glfw.errorSlot);
    _glfwPlatformDestroyMutex(&_glfw.errorLock);

    memset(&_glfw, 0, typeof(_glfw).sizeof);
}


//////////////////////////////////////////////////////////////////////////
//////                       GLFW internal API                      //////
//////////////////////////////////////////////////////////////////////////

char* _glfw_strdup(const(char)* source) {
    const(size_t) length = strlen(source);
    auto result = cast(char*) calloc(length + 1, 1);
    strcpy(result, source);
    return result;
}

float _glfw_fminf(float a, float b) {
    if (a != a)
        return b;
    else if (b != b)
        return a;
    else if (a < b)
        return a;
    else
        return b;
}

float _glfw_fmaxf(float a, float b) {
    if (a != a)
        return b;
    else if (b != b)
        return a;
    else if (a > b)
        return a;
    else
        return b;
}


//////////////////////////////////////////////////////////////////////////
//////                         GLFW event API                       //////
//////////////////////////////////////////////////////////////////////////

// Notifies shared code of an error
//
void _glfwInputError(int code, const(char)* format, ...) {
    _GLFWerror* error;
    char[_GLFW_MESSAGE_SIZE] description;

    if (format)
    {
        va_list vl;
        va_start(vl, format);
        vsnprintf(description.ptr, description.length, format, vl);
        va_end(vl);

        description[$-1] = '\0';
    }
    else
    {
        if (code == GLFW_NOT_INITIALIZED)
            strcpy(description.ptr, "The GLFW library is not initialized");
        else if (code == GLFW_NO_CURRENT_CONTEXT)
            strcpy(description.ptr, "There is no current context");
        else if (code == GLFW_INVALID_ENUM)
            strcpy(description.ptr, "Invalid argument for enum parameter");
        else if (code == GLFW_INVALID_VALUE)
            strcpy(description.ptr, "Invalid value for parameter");
        else if (code == GLFW_OUT_OF_MEMORY)
            strcpy(description.ptr, "Out of memory");
        else if (code == GLFW_API_UNAVAILABLE)
            strcpy(description.ptr, "The requested API is unavailable");
        else if (code == GLFW_VERSION_UNAVAILABLE)
            strcpy(description.ptr, "The requested API version is unavailable");
        else if (code == GLFW_PLATFORM_ERROR)
            strcpy(description.ptr, "A platform-specific error occurred");
        else if (code == GLFW_FORMAT_UNAVAILABLE)
            strcpy(description.ptr, "The requested format is unavailable");
        else if (code == GLFW_NO_WINDOW_CONTEXT)
            strcpy(description.ptr, "The specified window has no context");
        else
            strcpy(description.ptr, "ERROR: UNKNOWN GLFW ERROR");
    }

    if (_glfw.initialized)
    {
        error = cast(_GLFWerror*) _glfwPlatformGetTls(&_glfw.errorSlot);
        if (!error)
        {
            error = cast(_GLFWerror*) calloc(1, _GLFWerror.sizeof);
            _glfwPlatformSetTls(&_glfw.errorSlot, error);
            _glfwPlatformLockMutex(&_glfw.errorLock);
            error.next = _glfw.errorListHead;
            _glfw.errorListHead = error;
            _glfwPlatformUnlockMutex(&_glfw.errorLock);
        }
    }
    else
        error = &_glfwMainThreadError;

    error.code = code;
    strcpy(error.description.ptr, description.ptr);

    if (_glfwErrorCallback)
        _glfwErrorCallback(code, description.ptr);
}


//////////////////////////////////////////////////////////////////////////
//////                        GLFW public API                       //////
//////////////////////////////////////////////////////////////////////////

int glfwInit() {
    if (_glfw.initialized)
        return GLFW_TRUE;

    memset(&_glfw, 0, typeof(_glfw).sizeof);
    _glfw.hints.init = _glfwInitHints;

    if (!_glfwPlatformInit())
    {
        terminate();
        return GLFW_FALSE;
    }

    if (!_glfwPlatformCreateMutex(&_glfw.errorLock) ||
        !_glfwPlatformCreateTls(&_glfw.errorSlot) ||
        !_glfwPlatformCreateTls(&_glfw.contextSlot))
    {
        terminate();
        return GLFW_FALSE;
    }

    _glfwPlatformSetTls(&_glfw.errorSlot, &_glfwMainThreadError);

    _glfw.initialized = GLFW_TRUE;
    _glfw.timer.offset = _glfwPlatformGetTimerValue();

    glfwDefaultWindowHints();

    {
        int i;

        for (i = 0;  _glfwDefaultMappings[i];  i++)
        {
            if (!glfwUpdateGamepadMappings(_glfwDefaultMappings[i]))
            {
                terminate();
                return GLFW_FALSE;
            }
        }
    }

    return GLFW_TRUE;
}

void glfwTerminate() {
    if (!_glfw.initialized)
        return;

    terminate();
}

void glfwInitHint(int hint, int value) {
    switch (hint)
    {
        case GLFW_JOYSTICK_HAT_BUTTONS:
            _glfwInitHints.hatButtons = value;
            return;
        case GLFW_COCOA_CHDIR_RESOURCES:
            _glfwInitHints.ns.chdir = value;
            return;
        case GLFW_COCOA_MENUBAR:
            _glfwInitHints.ns.menubar = value;
            return;
        default: break;
    }

    _glfwInputError(GLFW_INVALID_ENUM,
                    "Invalid init hint 0x%08X", hint);
}

void glfwGetVersion(int* major, int* minor, int* rev) {
    if (major != null)
        *major = GLFW_VERSION_MAJOR;
    if (minor != null)
        *minor = GLFW_VERSION_MINOR;
    if (rev != null)
        *rev = GLFW_VERSION_REVISION;
}

const(char)* glfwGetVersionString() {
    return _glfwPlatformGetVersionString();
}

int glfwGetError(const(char)** description) {
    _GLFWerror* error;
    int code = GLFW_NO_ERROR;

    if (description)
        *description = null;

    if (_glfw.initialized)
        error = cast(_GLFWerror*) _glfwPlatformGetTls(&_glfw.errorSlot);
    else
        error = &_glfwMainThreadError;

    if (error)
    {
        code = error.code;
        error.code = GLFW_NO_ERROR;
        if (description && code)
            *description = error.description.ptr;
    }

    return code;
}

GLFWerrorfun glfwSetErrorCallback(GLFWerrorfun cbfun) {
    const old = _glfwErrorCallback;
    _glfwErrorCallback = cbfun;
    return old;
}
