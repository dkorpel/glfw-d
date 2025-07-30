/// Translated from C to D
module glfw3.osmesa_context;

nothrow:
extern(C): __gshared:

//========================================================================
// GLFW 3.3 OSMesa - www.glfw.org
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
// Please use C89 style variable declarations in this file because VS 2010
//========================================================================

import core.stdc.stdlib;
import core.stdc.string;
import core.stdc.assert_;

import glfw3.internal;

enum OSMESA_RGBA = 0x1908;
enum OSMESA_FORMAT = 0x22;
enum OSMESA_DEPTH_BITS = 0x30;
enum OSMESA_STENCIL_BITS = 0x31;
enum OSMESA_ACCUM_BITS = 0x32;
enum OSMESA_PROFILE = 0x33;
enum OSMESA_CORE_PROFILE = 0x34;
enum OSMESA_COMPAT_PROFILE = 0x35;
enum OSMESA_CONTEXT_MAJOR_VERSION = 0x36;
enum OSMESA_CONTEXT_MINOR_VERSION = 0x37;

alias void* OSMesaContext;
alias void function() OSMESAproc;

alias OSMesaContext function(GLenum, GLint, GLint, GLint, OSMesaContext) PFN_OSMesaCreateContextExt;
alias OSMesaContext function(const(int)*, OSMesaContext) PFN_OSMesaCreateContextAttribs;
alias void function(OSMesaContext) PFN_OSMesaDestroyContext;
alias int function(OSMesaContext, void*, int, int, int) PFN_OSMesaMakeCurrent;
alias int function(OSMesaContext, int*, int*, int*, void**) PFN_OSMesaGetColorBuffer;
alias int function(OSMesaContext, int*, int*, int*, void**) PFN_OSMesaGetDepthBuffer;
alias GLFWglproc function(const(char)*) PFN_OSMesaGetProcAddress;
alias OSMesaCreateContextExt = _glfw.osmesa.CreateContextExt;
alias OSMesaCreateContextAttribs = _glfw.osmesa.CreateContextAttribs;
alias OSMesaDestroyContext = _glfw.osmesa.DestroyContext;
alias OSMesaMakeCurrent = _glfw.osmesa.MakeCurrent;
alias OSMesaGetColorBuffer = _glfw.osmesa.GetColorBuffer;
alias OSMesaGetDepthBuffer = _glfw.osmesa.GetDepthBuffer;
alias OSMesaGetProcAddress = _glfw.osmesa.GetProcAddress;

mixin template _GLFW_OSMESA_CONTEXT_STATE() {         _GLFWcontextOSMesa osmesa;}
mixin template _GLFW_OSMESA_LIBRARY_CONTEXT_STATE() { _GLFWlibraryOSMesa osmesa;}

// OSMesa-specific per-context data
//
struct _GLFWcontextOSMesa {
    OSMesaContext handle;
    int width;
    int height;
    void* buffer;

}

// OSMesa-specific global data
//
struct _GLFWlibraryOSMesa {
    void* handle;

    PFN_OSMesaCreateContextExt CreateContextExt;
    PFN_OSMesaCreateContextAttribs CreateContextAttribs;
    PFN_OSMesaDestroyContext DestroyContext;
    PFN_OSMesaMakeCurrent MakeCurrent;
    PFN_OSMesaGetColorBuffer GetColorBuffer;
    PFN_OSMesaGetDepthBuffer GetDepthBuffer;
    PFN_OSMesaGetProcAddress GetProcAddress;

}

GLFWbool _glfwInitOSMesa();
void _glfwTerminateOSMesa();
GLFWbool _glfwCreateContextOSMesa(_GLFWwindow* window, const(_GLFWctxconfig)* ctxconfig, const(_GLFWfbconfig)* fbconfig);

private void makeContextCurrentOSMesa(_GLFWwindow* window) {
    if (window)
    {
        int width;int height;
        _glfwPlatformGetFramebufferSize(window, &width, &height);

        // Check to see if we need to allocate a new buffer
        if ((window.context.osmesa.buffer == null) ||
            (width != window.context.osmesa.width) ||
            (height != window.context.osmesa.height))
        {
            free(window.context.osmesa.buffer);

            // Allocate the new buffer (width * height * 8-bit RGBA)
            window.context.osmesa.buffer = calloc(4, cast(size_t) width * height);
            window.context.osmesa.width  = width;
            window.context.osmesa.height = height;
        }

        if (!_glfw.osmesa.MakeCurrent(window.context.osmesa.handle,
                               window.context.osmesa.buffer,
                               GL_UNSIGNED_BYTE,
                               width, height))
        {
            _glfwInputError(GLFW_PLATFORM_ERROR,
                            "OSMesa: Failed to make context current");
            return;
        }
    }

    _glfwPlatformSetTls(&_glfw.contextSlot, window);
}

private GLFWglproc getProcAddressOSMesa(const(char)* procname) {
    return cast(GLFWglproc) _glfw.osmesa.GetProcAddress(procname);
}

private void destroyContextOSMesa(_GLFWwindow* window) {
    if (window.context.osmesa.handle)
    {
        _glfw.osmesa.DestroyContext(window.context.osmesa.handle);
        window.context.osmesa.handle = null;
    }

    if (window.context.osmesa.buffer)
    {
        free(window.context.osmesa.buffer);
        window.context.osmesa.width = 0;
        window.context.osmesa.height = 0;
    }
}

private void swapBuffersOSMesa(_GLFWwindow* window) {
    // No double buffering on OSMesa
}

private void swapIntervalOSMesa(int interval) {
    // No swap interval on OSMesa
}

private int extensionSupportedOSMesa(const(char)* extension) {
    // OSMesa does not have extensions
    return GLFW_FALSE;
}


//////////////////////////////////////////////////////////////////////////
//////                       GLFW internal API                      //////
//////////////////////////////////////////////////////////////////////////

GLFWbool _glfwInitOSMesa() {
    int i;

    version(Windows) {
        static immutable char*[3] sonames = ["libOSMesa.dll", "OSMesa.dll", null];
    } else version(Cygwin) {
        static immutable char*[2] sonames = ["libOSMesa.8.dylib", null];
    } else {
        static immutable char*[3] sonames = ["libOSMesa.so.8", "libOSMesa.so.6", null];
    }

    if (_glfw.osmesa.handle)
        return GLFW_TRUE;

    for (i = 0;  sonames[i];  i++)
    {
        _glfw.osmesa.handle = _glfw_dlopen(sonames[i]);
        if (_glfw.osmesa.handle)
            break;
    }

    if (!_glfw.osmesa.handle)
    {
        _glfwInputError(GLFW_API_UNAVAILABLE, "OSMesa: Library not found");
        return GLFW_FALSE;
    }

    _glfw.osmesa.CreateContextExt = cast(PFN_OSMesaCreateContextExt)
        _glfw_dlsym(_glfw.osmesa.handle, "OSMesaCreateContextExt");
    _glfw.osmesa.CreateContextAttribs = cast(PFN_OSMesaCreateContextAttribs)
        _glfw_dlsym(_glfw.osmesa.handle, "OSMesaCreateContextAttribs");
    _glfw.osmesa.DestroyContext = cast(PFN_OSMesaDestroyContext)
        _glfw_dlsym(_glfw.osmesa.handle, "OSMesaDestroyContext");
    _glfw.osmesa.MakeCurrent = cast(PFN_OSMesaMakeCurrent)
        _glfw_dlsym(_glfw.osmesa.handle, "OSMesaMakeCurrent");
    _glfw.osmesa.GetColorBuffer = cast(PFN_OSMesaGetColorBuffer)
        _glfw_dlsym(_glfw.osmesa.handle, "OSMesaGetColorBuffer");
    _glfw.osmesa.GetDepthBuffer = cast(PFN_OSMesaGetDepthBuffer)
        _glfw_dlsym(_glfw.osmesa.handle, "OSMesaGetDepthBuffer");
    _glfw.osmesa.GetProcAddress = cast(PFN_OSMesaGetProcAddress)
        _glfw_dlsym(_glfw.osmesa.handle, "OSMesaGetProcAddress");

    if (!_glfw.osmesa.CreateContextExt ||
        !_glfw.osmesa.DestroyContext ||
        !_glfw.osmesa.MakeCurrent ||
        !_glfw.osmesa.GetColorBuffer ||
        !_glfw.osmesa.GetDepthBuffer ||
        !_glfw.osmesa.GetProcAddress)
    {
        _glfwInputError(GLFW_PLATFORM_ERROR,
                        "OSMesa: Failed to load required entry points");

        _glfwTerminateOSMesa();
        return GLFW_FALSE;
    }

    return GLFW_TRUE;
}

void _glfwTerminateOSMesa() {
    if (_glfw.osmesa.handle)
    {
        _glfw_dlclose(_glfw.osmesa.handle);
        _glfw.osmesa.handle = null;
    }
}

GLFWbool _glfwCreateContextOSMesa(_GLFWwindow* window, const(_GLFWctxconfig)* ctxconfig, const(_GLFWfbconfig)* fbconfig) {
    OSMesaContext share = null;
    const(int) accumBits = fbconfig.accumRedBits +
                          fbconfig.accumGreenBits +
                          fbconfig.accumBlueBits +
                          fbconfig.accumAlphaBits;

    if (ctxconfig.client == GLFW_OPENGL_ES_API)
    {
        _glfwInputError(GLFW_API_UNAVAILABLE,
                        "OSMesa: OpenGL ES is not available on OSMesa");
        return GLFW_FALSE;
    }

    if (ctxconfig.share)
        share = cast(void*) ctxconfig.share.context.osmesa.handle;

    //if (OSMesaCreateContextAttribs)
    if (_glfw.osmesa.CreateContextAttribs)
    {
        int index = 0;int[40] attribs;
        void setAttrib(int a, int v) {
            assert((cast(size_t) index + 1) < attribs.length);
            attribs[index++] = a;
            attribs[index++] = v;
        }

        setAttrib(OSMESA_FORMAT, OSMESA_RGBA);
        setAttrib(OSMESA_DEPTH_BITS, fbconfig.depthBits);
        setAttrib(OSMESA_STENCIL_BITS, fbconfig.stencilBits);
        setAttrib(OSMESA_ACCUM_BITS, accumBits);

        if (ctxconfig.profile == GLFW_OPENGL_CORE_PROFILE)
        {
            setAttrib(OSMESA_PROFILE, OSMESA_CORE_PROFILE);
        }
        else if (ctxconfig.profile == GLFW_OPENGL_COMPAT_PROFILE)
        {
            setAttrib(OSMESA_PROFILE, OSMESA_COMPAT_PROFILE);
        }

        if (ctxconfig.major != 1 || ctxconfig.minor != 0)
        {
            setAttrib(OSMESA_CONTEXT_MAJOR_VERSION, ctxconfig.major);
            setAttrib(OSMESA_CONTEXT_MINOR_VERSION, ctxconfig.minor);
        }

        if (ctxconfig.forward)
        {
            _glfwInputError(GLFW_VERSION_UNAVAILABLE,
                            "OSMesa: Forward-compatible contexts not supported");
            return GLFW_FALSE;
        }

        setAttrib(0, 0);

        window.context.osmesa.handle =
            _glfw.osmesa.CreateContextAttribs(attribs.ptr, share);
    }
    else
    {
        if (ctxconfig.profile)
        {
            _glfwInputError(GLFW_VERSION_UNAVAILABLE,
                            "OSMesa: OpenGL profiles unavailable");
            return GLFW_FALSE;
        }

        window.context.osmesa.handle =
            _glfw.osmesa.CreateContextExt(OSMESA_RGBA,
                                   fbconfig.depthBits,
                                   fbconfig.stencilBits,
                                   accumBits,
                                   share);
    }

    if (window.context.osmesa.handle == null)
    {
        _glfwInputError(GLFW_VERSION_UNAVAILABLE,
                        "OSMesa: Failed to create context");
        return GLFW_FALSE;
    }

    window.context.makeCurrent = &makeContextCurrentOSMesa;
    window.context.swapBuffers = &swapBuffersOSMesa;
    window.context.swapInterval = &swapIntervalOSMesa;
    window.context.extensionSupported = &extensionSupportedOSMesa;
    window.context.getProcAddress = &getProcAddressOSMesa;
    window.context.destroy = &destroyContextOSMesa;

    return GLFW_TRUE;
}

//////////////////////////////////////////////////////////////////////////
//////                        GLFW native API                       //////
//////////////////////////////////////////////////////////////////////////

int glfwGetOSMesaColorBuffer(GLFWwindow* handle, int* width, int* height, int* format, void** buffer) {
    void* mesaBuffer;
    GLint mesaWidth;GLint mesaHeight;GLint mesaFormat;
    _GLFWwindow* window = cast(_GLFWwindow*) handle;
    assert(window != null);

    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!("GLFW_FALSE"));

    if (!_glfw.osmesa.GetColorBuffer(window.context.osmesa.handle,
                              &mesaWidth, &mesaHeight,
                              &mesaFormat, &mesaBuffer))
    {
        _glfwInputError(GLFW_PLATFORM_ERROR,
                        "OSMesa: Failed to retrieve color buffer");
        return GLFW_FALSE;
    }

    if (width)
        *width = mesaWidth;
    if (height)
        *height = mesaHeight;
    if (format)
        *format = mesaFormat;
    if (buffer)
        *buffer = mesaBuffer;

    return GLFW_TRUE;
}

int glfwGetOSMesaDepthBuffer(GLFWwindow* handle, int* width, int* height, int* bytesPerValue, void** buffer) {
    void* mesaBuffer;
    GLint mesaWidth;GLint mesaHeight;GLint mesaBytes;
    _GLFWwindow* window = cast(_GLFWwindow*) handle;
    assert(window != null);

    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!("GLFW_FALSE"));

    if (!_glfw.osmesa.GetDepthBuffer(window.context.osmesa.handle,
                              &mesaWidth, &mesaHeight,
                              &mesaBytes, &mesaBuffer))
    {
        _glfwInputError(GLFW_PLATFORM_ERROR,
                        "OSMesa: Failed to retrieve depth buffer");
        return GLFW_FALSE;
    }

    if (width)
        *width = mesaWidth;
    if (height)
        *height = mesaHeight;
    if (bytesPerValue)
        *bytesPerValue = mesaBytes;
    if (buffer)
        *buffer = mesaBuffer;

    return GLFW_TRUE;
}

OSMesaContext glfwGetOSMesaContext(GLFWwindow* handle) {
    _GLFWwindow* window = cast(_GLFWwindow*) handle;
    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!("null"));

    if (window.context.client == GLFW_NO_API)
    {
        _glfwInputError(GLFW_NO_WINDOW_CONTEXT, null);
        return null;
    }

    return window.context.osmesa.handle;
}
