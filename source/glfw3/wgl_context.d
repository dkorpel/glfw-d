/// Translated from C to D
module glfw3.wgl_context;

version(Windows):
nothrow:
extern(C): __gshared:


//========================================================================
// GLFW 3.3 WGL - www.glfw.org
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
import core.stdc.string: memset;

// header
enum WGL_NUMBER_PIXEL_FORMATS_ARB = 0x2000;
enum WGL_SUPPORT_OPENGL_ARB = 0x2010;
enum WGL_DRAW_TO_WINDOW_ARB = 0x2001;
enum WGL_PIXEL_TYPE_ARB = 0x2013;
enum WGL_TYPE_RGBA_ARB = 0x202b;
enum WGL_ACCELERATION_ARB = 0x2003;
enum WGL_NO_ACCELERATION_ARB = 0x2025;
enum WGL_RED_BITS_ARB = 0x2015;
enum WGL_RED_SHIFT_ARB = 0x2016;
enum WGL_GREEN_BITS_ARB = 0x2017;
enum WGL_GREEN_SHIFT_ARB = 0x2018;
enum WGL_BLUE_BITS_ARB = 0x2019;
enum WGL_BLUE_SHIFT_ARB = 0x201a;
enum WGL_ALPHA_BITS_ARB = 0x201b;
enum WGL_ALPHA_SHIFT_ARB = 0x201c;
enum WGL_ACCUM_BITS_ARB = 0x201d;
enum WGL_ACCUM_RED_BITS_ARB = 0x201e;
enum WGL_ACCUM_GREEN_BITS_ARB = 0x201f;
enum WGL_ACCUM_BLUE_BITS_ARB = 0x2020;
enum WGL_ACCUM_ALPHA_BITS_ARB = 0x2021;
enum WGL_DEPTH_BITS_ARB = 0x2022;
enum WGL_STENCIL_BITS_ARB = 0x2023;
enum WGL_AUX_BUFFERS_ARB = 0x2024;
enum WGL_STEREO_ARB = 0x2012;
enum WGL_DOUBLE_BUFFER_ARB = 0x2011;
enum WGL_SAMPLES_ARB = 0x2042;
enum WGL_FRAMEBUFFER_SRGB_CAPABLE_ARB = 0x20a9;
enum WGL_CONTEXT_DEBUG_BIT_ARB = 0x00000001;
enum WGL_CONTEXT_FORWARD_COMPATIBLE_BIT_ARB = 0x00000002;
enum WGL_CONTEXT_PROFILE_MASK_ARB = 0x9126;
enum WGL_CONTEXT_CORE_PROFILE_BIT_ARB = 0x00000001;
enum WGL_CONTEXT_COMPATIBILITY_PROFILE_BIT_ARB = 0x00000002;
enum WGL_CONTEXT_MAJOR_VERSION_ARB = 0x2091;
enum WGL_CONTEXT_MINOR_VERSION_ARB = 0x2092;
enum WGL_CONTEXT_FLAGS_ARB = 0x2094;
enum WGL_CONTEXT_ES2_PROFILE_BIT_EXT = 0x00000004;
enum WGL_CONTEXT_ROBUST_ACCESS_BIT_ARB = 0x00000004;
enum WGL_LOSE_CONTEXT_ON_RESET_ARB = 0x8252;
enum WGL_CONTEXT_RESET_NOTIFICATION_STRATEGY_ARB = 0x8256;
enum WGL_NO_RESET_NOTIFICATION_ARB = 0x8261;
enum WGL_CONTEXT_RELEASE_BEHAVIOR_ARB = 0x2097;
enum WGL_CONTEXT_RELEASE_BEHAVIOR_NONE_ARB = 0;
enum WGL_CONTEXT_RELEASE_BEHAVIOR_FLUSH_ARB = 0x2098;
enum WGL_CONTEXT_OPENGL_NO_ERROR_ARB = 0x31b3;
enum WGL_COLORSPACE_EXT = 0x309d;
enum WGL_COLORSPACE_SRGB_EXT = 0x3089;

enum ERROR_INVALID_VERSION_ARB = 0x2095;
enum ERROR_INVALID_PROFILE_ARB = 0x2096;
enum ERROR_INCOMPATIBLE_DEVICE_CONTEXTS_ARB = 0x2054;

// WGL extension pointer typedefs
extern(Windows) {
    alias BOOL function(int) PFNWGLSWAPINTERVALEXTPROC;
    alias BOOL function(HDC, int, int, UINT, const(int)*, int*) PFNWGLGETPIXELFORMATATTRIBIVARBPROC;
    alias const(char)* function() PFNWGLGETEXTENSIONSSTRINGEXTPROC;
    alias const(char)* function(HDC) PFNWGLGETEXTENSIONSSTRINGARBPROC;
    alias HGLRC function(HDC, HGLRC, const(int)*) PFNWGLCREATECONTEXTATTRIBSARBPROC;
    alias wglSwapIntervalEXT = _glfw.wgl.SwapIntervalEXT;
    alias wglGetPixelFormatAttribivARB = _glfw.wgl.GetPixelFormatAttribivARB;
    alias wglGetExtensionsStringEXT = _glfw.wgl.GetExtensionsStringEXT;
    alias wglGetExtensionsStringARB = _glfw.wgl.GetExtensionsStringARB;
    alias wglCreateContextAttribsARB = _glfw.wgl.CreateContextAttribsARB;

    // opengl32.dll function pointer typedefs
    alias HGLRC function(HDC) PFN_wglCreateContext;
    alias BOOL function(HGLRC) PFN_wglDeleteContext;
    alias PROC function(LPCSTR) PFN_wglGetProcAddress;
    alias HDC function() PFN_wglGetCurrentDC;
    alias HGLRC function() PFN_wglGetCurrentContext;
    alias BOOL function(HDC, HGLRC) PFN_wglMakeCurrent;
    alias BOOL function(HGLRC, HGLRC) PFN_wglShareLists;
    alias wglCreateContext = _glfw.wgl.CreateContext;
    alias wglDeleteContext = _glfw.wgl.DeleteContext;
    alias wglGetProcAddress = _glfw.wgl.GetProcAddress;
    alias wglGetCurrentDC = _glfw.wgl.GetCurrentDC;
    alias wglGetCurrentContext = _glfw.wgl.GetCurrentContext;
    alias wglMakeCurrent = _glfw.wgl.MakeCurrent;
    alias wglShareLists = _glfw.wgl.ShareLists;
}

enum _GLFW_RECREATION_NOT_NEEDED = 0;
enum _GLFW_RECREATION_REQUIRED =   1;
enum _GLFW_RECREATION_IMPOSSIBLE = 2;

mixin template _GLFW_PLATFORM_CONTEXT_STATE() {        _GLFWcontextWGL wgl;}
mixin template _GLFW_PLATFORM_LIBRARY_CONTEXT_STATE() {_GLFWlibraryWGL wgl;}

// WGL-specific per-context data
//
struct _GLFWcontextWGL {
    HDC dc;
    HGLRC handle;
    int interval;

}

// WGL-specific global data
//
struct _GLFWlibraryWGL {
    HINSTANCE instance;
    PFN_wglCreateContext CreateContext;
    PFN_wglDeleteContext DeleteContext;
    PFN_wglGetProcAddress GetProcAddress;
    PFN_wglGetCurrentDC GetCurrentDC;
    PFN_wglGetCurrentContext GetCurrentContext;
    PFN_wglMakeCurrent MakeCurrent;
    PFN_wglShareLists ShareLists;

    PFNWGLSWAPINTERVALEXTPROC SwapIntervalEXT;
    PFNWGLGETPIXELFORMATATTRIBIVARBPROC GetPixelFormatAttribivARB;
    PFNWGLGETEXTENSIONSSTRINGEXTPROC GetExtensionsStringEXT;
    PFNWGLGETEXTENSIONSSTRINGARBPROC GetExtensionsStringARB;
    PFNWGLCREATECONTEXTATTRIBSARBPROC CreateContextAttribsARB;
    GLFWbool EXT_swap_control;
    GLFWbool EXT_colorspace;
    GLFWbool ARB_multisample;
    GLFWbool ARB_framebuffer_sRGB;
    GLFWbool EXT_framebuffer_sRGB;
    GLFWbool ARB_pixel_format;
    GLFWbool ARB_create_context;
    GLFWbool ARB_create_context_profile;
    GLFWbool EXT_create_context_es2_profile;
    GLFWbool ARB_create_context_robustness;
    GLFWbool ARB_create_context_no_error;
    GLFWbool ARB_context_flush_control;

}

GLFWbool _glfwInitWGL();
void _glfwTerminateWGL();
GLFWbool _glfwCreateContextWGL(_GLFWwindow* window, const(_GLFWctxconfig)* ctxconfig, const(_GLFWfbconfig)* fbconfig);
//

import core.stdc.stdlib;
import core.stdc.assert_;

// Return the value corresponding to the specified attribute
//
private int findPixelFormatAttribValue(const(int)* attribs, int attribCount, const(int)* values, int attrib) {
    int i;

    for (i = 0;  i < attribCount;  i++)
    {
        if (attribs[i] == attrib)
            return values[i];
    }

    _glfwInputErrorWin32(GLFW_PLATFORM_ERROR,
                         "WGL: Unknown pixel format attribute requested");
    return 0;
}


// Return a list of available and usable framebuffer configs
//
private int choosePixelFormat(_GLFWwindow* window, const(_GLFWctxconfig)* ctxconfig, const(_GLFWfbconfig)* fbconfig) {
    _GLFWfbconfig* usableConfigs;
    const(_GLFWfbconfig)* closest;
    int i;int pixelFormat;int nativeCount;int usableCount = 0;int attribCount = 0;
    int[40] attribs;
    int[attribs.sizeof / typeof(attribs[0]).sizeof] values;

    void addAttrib(int a) {
        assert(cast(size_t) attribCount < attribs.length);
        attribs[attribCount++] = a;
    }

    auto findAttribValue(int a) {
        return findPixelFormatAttribValue(attribs.ptr, attribCount, values.ptr, a);
    }

    if (_glfw.wgl.ARB_pixel_format)
    {
        const(int) attrib = WGL_NUMBER_PIXEL_FORMATS_ARB;

        if (!_glfw.wgl.GetPixelFormatAttribivARB(window.context.wgl.dc,
                                          1, 0, 1, &attrib, &nativeCount))
        {
            _glfwInputErrorWin32(GLFW_PLATFORM_ERROR,
                                 "WGL: Failed to retrieve pixel format attribute");
            return 0;
        }

        addAttrib(WGL_SUPPORT_OPENGL_ARB);
        addAttrib(WGL_DRAW_TO_WINDOW_ARB);
        addAttrib(WGL_PIXEL_TYPE_ARB);
        addAttrib(WGL_ACCELERATION_ARB);
        addAttrib(WGL_RED_BITS_ARB);
        addAttrib(WGL_RED_SHIFT_ARB);
        addAttrib(WGL_GREEN_BITS_ARB);
        addAttrib(WGL_GREEN_SHIFT_ARB);
        addAttrib(WGL_BLUE_BITS_ARB);
        addAttrib(WGL_BLUE_SHIFT_ARB);
        addAttrib(WGL_ALPHA_BITS_ARB);
        addAttrib(WGL_ALPHA_SHIFT_ARB);
        addAttrib(WGL_DEPTH_BITS_ARB);
        addAttrib(WGL_STENCIL_BITS_ARB);
        addAttrib(WGL_ACCUM_BITS_ARB);
        addAttrib(WGL_ACCUM_RED_BITS_ARB);
        addAttrib(WGL_ACCUM_GREEN_BITS_ARB);
        addAttrib(WGL_ACCUM_BLUE_BITS_ARB);
        addAttrib(WGL_ACCUM_ALPHA_BITS_ARB);
        addAttrib(WGL_AUX_BUFFERS_ARB);
        addAttrib(WGL_STEREO_ARB);
        addAttrib(WGL_DOUBLE_BUFFER_ARB);

        if (_glfw.wgl.ARB_multisample)
            addAttrib(WGL_SAMPLES_ARB);

        if (ctxconfig.client == GLFW_OPENGL_API)
        {
            if (_glfw.wgl.ARB_framebuffer_sRGB || _glfw.wgl.EXT_framebuffer_sRGB)
                addAttrib(WGL_FRAMEBUFFER_SRGB_CAPABLE_ARB);
        }
        else
        {
            if (_glfw.wgl.EXT_colorspace)
                addAttrib(WGL_COLORSPACE_EXT);
        }
    }
    else
    {
        nativeCount = DescribePixelFormat(window.context.wgl.dc,
                                          1,
                                          PIXELFORMATDESCRIPTOR.sizeof,
                                          null);
    }

    usableConfigs = cast(_GLFWfbconfig*) calloc(nativeCount, _GLFWfbconfig.sizeof);

    for (i = 0;  i < nativeCount;  i++)
    {
        _GLFWfbconfig* u = usableConfigs + usableCount;
        pixelFormat = i + 1;

        if (_glfw.wgl.ARB_pixel_format)
        {
            // Get pixel format attributes through "modern" extension

            if (!_glfw.wgl.GetPixelFormatAttribivARB(window.context.wgl.dc,
                                              pixelFormat, 0,
                                              attribCount,
                                              attribs.ptr, values.ptr))
            {
                _glfwInputErrorWin32(GLFW_PLATFORM_ERROR,
                                    "WGL: Failed to retrieve pixel format attributes");

                free(usableConfigs);
                return 0;
            }

            if (!findAttribValue(WGL_SUPPORT_OPENGL_ARB) ||
                !findAttribValue(WGL_DRAW_TO_WINDOW_ARB))
            {
                continue;
            }

            if (findAttribValue(WGL_PIXEL_TYPE_ARB) != WGL_TYPE_RGBA_ARB)
                continue;

            if (findAttribValue(WGL_ACCELERATION_ARB) == WGL_NO_ACCELERATION_ARB)
                continue;

            u.redBits = findAttribValue(WGL_RED_BITS_ARB);
            u.greenBits = findAttribValue(WGL_GREEN_BITS_ARB);
            u.blueBits = findAttribValue(WGL_BLUE_BITS_ARB);
            u.alphaBits = findAttribValue(WGL_ALPHA_BITS_ARB);

            u.depthBits = findAttribValue(WGL_DEPTH_BITS_ARB);
            u.stencilBits = findAttribValue(WGL_STENCIL_BITS_ARB);

            u.accumRedBits = findAttribValue(WGL_ACCUM_RED_BITS_ARB);
            u.accumGreenBits = findAttribValue(WGL_ACCUM_GREEN_BITS_ARB);
            u.accumBlueBits = findAttribValue(WGL_ACCUM_BLUE_BITS_ARB);
            u.accumAlphaBits = findAttribValue(WGL_ACCUM_ALPHA_BITS_ARB);

            u.auxBuffers = findAttribValue(WGL_AUX_BUFFERS_ARB);

            if (findAttribValue(WGL_STEREO_ARB))
                u.stereo = GLFW_TRUE;
            if (findAttribValue(WGL_DOUBLE_BUFFER_ARB))
                u.doublebuffer = GLFW_TRUE;

            if (_glfw.wgl.ARB_multisample)
                u.samples = findAttribValue(WGL_SAMPLES_ARB);

            if (ctxconfig.client == GLFW_OPENGL_API)
            {
                if (_glfw.wgl.ARB_framebuffer_sRGB ||
                    _glfw.wgl.EXT_framebuffer_sRGB)
                {
                    if (findAttribValue(WGL_FRAMEBUFFER_SRGB_CAPABLE_ARB))
                        u.sRGB = GLFW_TRUE;
                }
            }
            else
            {
                if (_glfw.wgl.EXT_colorspace)
                {
                    if (findAttribValue(WGL_COLORSPACE_EXT) == WGL_COLORSPACE_SRGB_EXT)
                        u.sRGB = GLFW_TRUE;
                }
            }
        }
        else
        {
            // Get pixel format attributes through legacy PFDs

            PIXELFORMATDESCRIPTOR pfd;

            if (!DescribePixelFormat(window.context.wgl.dc,
                                     pixelFormat,
                                     PIXELFORMATDESCRIPTOR.sizeof,
                                     &pfd))
            {
                _glfwInputErrorWin32(GLFW_PLATFORM_ERROR,
                                    "WGL: Failed to describe pixel format");

                free(usableConfigs);
                return 0;
            }

            if (!(pfd.dwFlags & PFD_DRAW_TO_WINDOW) ||
                !(pfd.dwFlags & PFD_SUPPORT_OPENGL))
            {
                continue;
            }

            if (!(pfd.dwFlags & PFD_GENERIC_ACCELERATED) &&
                (pfd.dwFlags & PFD_GENERIC_FORMAT))
            {
                continue;
            }

            if (pfd.iPixelType != PFD_TYPE_RGBA)
                continue;

            u.redBits = pfd.cRedBits;
            u.greenBits = pfd.cGreenBits;
            u.blueBits = pfd.cBlueBits;
            u.alphaBits = pfd.cAlphaBits;

            u.depthBits = pfd.cDepthBits;
            u.stencilBits = pfd.cStencilBits;

            u.accumRedBits = pfd.cAccumRedBits;
            u.accumGreenBits = pfd.cAccumGreenBits;
            u.accumBlueBits = pfd.cAccumBlueBits;
            u.accumAlphaBits = pfd.cAccumAlphaBits;

            u.auxBuffers = pfd.cAuxBuffers;

            if (pfd.dwFlags & PFD_STEREO)
                u.stereo = GLFW_TRUE;
            if (pfd.dwFlags & PFD_DOUBLEBUFFER)
                u.doublebuffer = GLFW_TRUE;
        }

        u.handle = pixelFormat;
        usableCount++;
    }

    if (!usableCount)
    {
        _glfwInputError(GLFW_API_UNAVAILABLE,
                        "WGL: The driver does not appear to support OpenGL");

        free(usableConfigs);
        return 0;
    }

    closest = _glfwChooseFBConfig(fbconfig, usableConfigs, usableCount);
    if (!closest)
    {
        _glfwInputError(GLFW_FORMAT_UNAVAILABLE,
                        "WGL: Failed to find a suitable pixel format");

        free(usableConfigs);
        return 0;
    }

    pixelFormat = cast(int) closest.handle;
    free(usableConfigs);

    return pixelFormat;
}

private void makeContextCurrentWGL(_GLFWwindow* window) {
    if (window)
    {
        if (_glfw.wgl.MakeCurrent(window.context.wgl.dc, window.context.wgl.handle))
            _glfwPlatformSetTls(&_glfw.contextSlot, window);
        else
        {
            _glfwInputErrorWin32(GLFW_PLATFORM_ERROR,
                                 "WGL: Failed to make context current");
            _glfwPlatformSetTls(&_glfw.contextSlot, null);
        }
    }
    else
    {
        if (!_glfw.wgl.MakeCurrent(null, null))
        {
            _glfwInputErrorWin32(GLFW_PLATFORM_ERROR,
                                 "WGL: Failed to clear current context");
        }

        _glfwPlatformSetTls(&_glfw.contextSlot, null);
    }
}

private void swapBuffersWGL(_GLFWwindow* window) {
    if (!window.monitor)
    {
        if (IsWindowsVistaOrGreater())
        {
            // DWM Composition is always enabled on Win8+
            BOOL enabled = IsWindows8OrGreater();

            // HACK: Use DwmFlush when desktop composition is enabled
            if (enabled ||
                (SUCCEEDED(_glfw.win32.dwmapi.IsCompositionEnabled(&enabled)) && enabled))
            {
                int count = abs(window.context.wgl.interval);
                while (count--)
                    _glfw.win32.dwmapi.Flush();
            }
        }
    }

    SwapBuffers(window.context.wgl.dc);
}

private void swapIntervalWGL(int interval) {
    auto window = cast(_GLFWwindow*) _glfwPlatformGetTls(&_glfw.contextSlot);

    window.context.wgl.interval = interval;

    if (!window.monitor)
    {
        if (IsWindowsVistaOrGreater())
        {
            // DWM Composition is always enabled on Win8+
            BOOL enabled = IsWindows8OrGreater();

            // HACK: Disable WGL swap interval when desktop composition is enabled to
            //       avoid interfering with DWM vsync
            if (enabled ||
                (SUCCEEDED(_glfw.win32.dwmapi.IsCompositionEnabled(&enabled)) && enabled))
                interval = 0;
        }
    }

    if (_glfw.wgl.EXT_swap_control)
        _glfw.wgl.SwapIntervalEXT(interval);
}

private int extensionSupportedWGL(const(char)* extension) {
    const(char)* extensions = null;

    if (_glfw.wgl.GetExtensionsStringARB)
        extensions = _glfw.wgl.GetExtensionsStringARB(_glfw.wgl.GetCurrentDC());
    else if (_glfw.wgl.GetExtensionsStringEXT)
        extensions = _glfw.wgl.GetExtensionsStringEXT();

    if (!extensions)
        return GLFW_FALSE;

    return _glfwStringInExtensionString(extension, extensions);
}

private GLFWglproc getProcAddressWGL(const(char)* procname) {
    const(GLFWglproc) proc = cast(GLFWglproc) _glfw.wgl.GetProcAddress(procname);
    if (proc)
        return proc;

    return cast(GLFWglproc) GetProcAddress(_glfw.wgl.instance, procname);
}

private void destroyContextWGL(_GLFWwindow* window) {
    if (window.context.wgl.handle)
    {
        _glfw.wgl.DeleteContext(window.context.wgl.handle);
        window.context.wgl.handle = null;
    }
}


//////////////////////////////////////////////////////////////////////////
//////                       GLFW internal API                      //////
//////////////////////////////////////////////////////////////////////////

// Initialize WGL
//
GLFWbool _glfwInitWGL() {
    PIXELFORMATDESCRIPTOR pfd;
    HGLRC prc;HGLRC rc;
    HDC pdc;HDC dc;

    if (_glfw.wgl.instance)
        return GLFW_TRUE;

    _glfw.wgl.instance = LoadLibraryA("opengl32.dll");
    if (!_glfw.wgl.instance)
    {
        _glfwInputErrorWin32(GLFW_PLATFORM_ERROR,
                             "WGL: Failed to load opengl32.dll");
        return GLFW_FALSE;
    }

    _glfw.wgl.CreateContext = cast(PFN_wglCreateContext)
        GetProcAddress(_glfw.wgl.instance, "wglCreateContext");
    _glfw.wgl.DeleteContext = cast(PFN_wglDeleteContext)
        GetProcAddress(_glfw.wgl.instance, "wglDeleteContext");
    _glfw.wgl.GetProcAddress = cast(PFN_wglGetProcAddress)
        GetProcAddress(_glfw.wgl.instance, "wglGetProcAddress");
    _glfw.wgl.GetCurrentDC = cast(PFN_wglGetCurrentDC)
        GetProcAddress(_glfw.wgl.instance, "wglGetCurrentDC");
    _glfw.wgl.GetCurrentContext = cast(PFN_wglGetCurrentContext)
        GetProcAddress(_glfw.wgl.instance, "wglGetCurrentContext");
    _glfw.wgl.MakeCurrent = cast(PFN_wglMakeCurrent)
        GetProcAddress(_glfw.wgl.instance, "wglMakeCurrent");
    _glfw.wgl.ShareLists = cast(PFN_wglShareLists)
        GetProcAddress(_glfw.wgl.instance, "wglShareLists");

    // NOTE: A dummy context has to be created for opengl32.dll to load the
    //       OpenGL ICD, from which we can then query WGL extensions
    // NOTE: This code will accept the Microsoft GDI ICD; accelerated context
    //       creation failure occurs during manual pixel format enumeration

    dc = GetDC(_glfw.win32.helperWindowHandle);

    memset(&pfd, 0, typeof(pfd).sizeof);
    pfd.nSize = typeof(pfd).sizeof;
    pfd.nVersion = 1;
    pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER;
    pfd.iPixelType = PFD_TYPE_RGBA;
    pfd.cColorBits = 24;

    if (!SetPixelFormat(dc, ChoosePixelFormat(dc, &pfd), &pfd))
    {
        _glfwInputErrorWin32(GLFW_PLATFORM_ERROR,
                             "WGL: Failed to set pixel format for dummy context");
        return GLFW_FALSE;
    }

    rc = _glfw.wgl.CreateContext(dc);
    if (!rc)
    {
        _glfwInputErrorWin32(GLFW_PLATFORM_ERROR,
                             "WGL: Failed to create dummy context");
        return GLFW_FALSE;
    }

    pdc = _glfw.wgl.GetCurrentDC();
    prc = _glfw.wgl.GetCurrentContext();

    if (!_glfw.wgl.MakeCurrent(dc, rc))
    {
        _glfwInputErrorWin32(GLFW_PLATFORM_ERROR,
                             "WGL: Failed to make dummy context current");
        _glfw.wgl.MakeCurrent(pdc, prc);
        _glfw.wgl.DeleteContext(rc);
        return GLFW_FALSE;
    }

    // NOTE: Functions must be loaded first as they're needed to retrieve the
    //       extension string that tells us whether the functions are supported
    _glfw.wgl.GetExtensionsStringEXT = cast(PFNWGLGETEXTENSIONSSTRINGEXTPROC)
        _glfw.wgl.GetProcAddress("wglGetExtensionsStringEXT");
    _glfw.wgl.GetExtensionsStringARB = cast(PFNWGLGETEXTENSIONSSTRINGARBPROC)
        _glfw.wgl.GetProcAddress("wglGetExtensionsStringARB");
    _glfw.wgl.CreateContextAttribsARB = cast(PFNWGLCREATECONTEXTATTRIBSARBPROC)
        _glfw.wgl.GetProcAddress("wglCreateContextAttribsARB");
    _glfw.wgl.SwapIntervalEXT = cast(PFNWGLSWAPINTERVALEXTPROC)
        _glfw.wgl.GetProcAddress("wglSwapIntervalEXT");
    _glfw.wgl.GetPixelFormatAttribivARB = cast(PFNWGLGETPIXELFORMATATTRIBIVARBPROC)
        _glfw.wgl.GetProcAddress("wglGetPixelFormatAttribivARB");

    // NOTE: WGL_ARB_extensions_string and WGL_EXT_extensions_string are not
    //       checked below as we are already using them
    _glfw.wgl.ARB_multisample =
        extensionSupportedWGL("WGL_ARB_multisample");
    _glfw.wgl.ARB_framebuffer_sRGB =
        extensionSupportedWGL("WGL_ARB_framebuffer_sRGB");
    _glfw.wgl.EXT_framebuffer_sRGB =
        extensionSupportedWGL("WGL_EXT_framebuffer_sRGB");
    _glfw.wgl.ARB_create_context =
        extensionSupportedWGL("WGL_ARB_create_context");
    _glfw.wgl.ARB_create_context_profile =
        extensionSupportedWGL("WGL_ARB_create_context_profile");
    _glfw.wgl.EXT_create_context_es2_profile =
        extensionSupportedWGL("WGL_EXT_create_context_es2_profile");
    _glfw.wgl.ARB_create_context_robustness =
        extensionSupportedWGL("WGL_ARB_create_context_robustness");
    _glfw.wgl.ARB_create_context_no_error =
        extensionSupportedWGL("WGL_ARB_create_context_no_error");
    _glfw.wgl.EXT_swap_control =
        extensionSupportedWGL("WGL_EXT_swap_control");
    _glfw.wgl.EXT_colorspace =
        extensionSupportedWGL("WGL_EXT_colorspace");
    _glfw.wgl.ARB_pixel_format =
        extensionSupportedWGL("WGL_ARB_pixel_format");
    _glfw.wgl.ARB_context_flush_control =
        extensionSupportedWGL("WGL_ARB_context_flush_control");

    _glfw.wgl.MakeCurrent(pdc, prc);
    _glfw.wgl.DeleteContext(rc);
    return GLFW_TRUE;
}

// Terminate WGL
//
void _glfwTerminateWGL() {
    if (_glfw.wgl.instance)
        FreeLibrary(_glfw.wgl.instance);
}

// Create the OpenGL or OpenGL ES context
//
GLFWbool _glfwCreateContextWGL(_GLFWwindow* window, const(_GLFWctxconfig)* ctxconfig, const(_GLFWfbconfig)* fbconfig) {
    int[40] attribs;
    int pixelFormat;
    PIXELFORMATDESCRIPTOR pfd;
    HGLRC share = null;

    if (ctxconfig.share)
        share = cast(void*) ctxconfig.share.context.wgl.handle;

    window.context.wgl.dc = GetDC(window.win32.handle);
    if (!window.context.wgl.dc)
    {
        _glfwInputError(GLFW_PLATFORM_ERROR,
                        "WGL: Failed to retrieve DC for window");
        return GLFW_FALSE;
    }

    pixelFormat = choosePixelFormat(window, ctxconfig, fbconfig);
    if (!pixelFormat)
        return GLFW_FALSE;

    if (!DescribePixelFormat(window.context.wgl.dc,
                             pixelFormat, typeof(pfd).sizeof, &pfd))
    {
        _glfwInputErrorWin32(GLFW_PLATFORM_ERROR,
                             "WGL: Failed to retrieve PFD for selected pixel format");
        return GLFW_FALSE;
    }

    if (!SetPixelFormat(window.context.wgl.dc, pixelFormat, &pfd))
    {
        _glfwInputErrorWin32(GLFW_PLATFORM_ERROR,
                             "WGL: Failed to set selected pixel format");
        return GLFW_FALSE;
    }

    if (ctxconfig.client == GLFW_OPENGL_API)
    {
        if (ctxconfig.forward)
        {
            if (!_glfw.wgl.ARB_create_context)
            {
                _glfwInputError(GLFW_VERSION_UNAVAILABLE,
                                "WGL: A forward compatible OpenGL context requested but WGL_ARB_create_context is unavailable");
                return GLFW_FALSE;
            }
        }

        if (ctxconfig.profile)
        {
            if (!_glfw.wgl.ARB_create_context_profile)
            {
                _glfwInputError(GLFW_VERSION_UNAVAILABLE,
                                "WGL: OpenGL profile requested but WGL_ARB_create_context_profile is unavailable");
                return GLFW_FALSE;
            }
        }
    }
    else
    {
        if (!_glfw.wgl.ARB_create_context ||
            !_glfw.wgl.ARB_create_context_profile ||
            !_glfw.wgl.EXT_create_context_es2_profile)
        {
            _glfwInputError(GLFW_API_UNAVAILABLE,
                            "WGL: OpenGL ES requested but WGL_ARB_create_context_es2_profile is unavailable");
            return GLFW_FALSE;
        }
    }

    if (_glfw.wgl.ARB_create_context)
    {
        int index = 0;int mask = 0;int flags = 0;

        void setAttrib(int a, int v) {
            assert((cast(size_t) index + 1) < attribs.length);
            attribs[index++] = a;
            attribs[index++] = v;
        }

        if (ctxconfig.client == GLFW_OPENGL_API)
        {
            if (ctxconfig.forward)
                flags |= WGL_CONTEXT_FORWARD_COMPATIBLE_BIT_ARB;

            if (ctxconfig.profile == GLFW_OPENGL_CORE_PROFILE)
                mask |= WGL_CONTEXT_CORE_PROFILE_BIT_ARB;
            else if (ctxconfig.profile == GLFW_OPENGL_COMPAT_PROFILE)
                mask |= WGL_CONTEXT_COMPATIBILITY_PROFILE_BIT_ARB;
        }
        else
            mask |= WGL_CONTEXT_ES2_PROFILE_BIT_EXT;

        if (ctxconfig.debug_)
            flags |= WGL_CONTEXT_DEBUG_BIT_ARB;

        if (ctxconfig.robustness)
        {
            if (_glfw.wgl.ARB_create_context_robustness)
            {
                if (ctxconfig.robustness == GLFW_NO_RESET_NOTIFICATION)
                {
                    setAttrib(WGL_CONTEXT_RESET_NOTIFICATION_STRATEGY_ARB,
                              WGL_NO_RESET_NOTIFICATION_ARB);
                }
                else if (ctxconfig.robustness == GLFW_LOSE_CONTEXT_ON_RESET)
                {
                    setAttrib(WGL_CONTEXT_RESET_NOTIFICATION_STRATEGY_ARB,
                              WGL_LOSE_CONTEXT_ON_RESET_ARB);
                }

                flags |= WGL_CONTEXT_ROBUST_ACCESS_BIT_ARB;
            }
        }

        if (ctxconfig.release)
        {
            if (_glfw.wgl.ARB_context_flush_control)
            {
                if (ctxconfig.release == GLFW_RELEASE_BEHAVIOR_NONE)
                {
                    setAttrib(WGL_CONTEXT_RELEASE_BEHAVIOR_ARB,
                              WGL_CONTEXT_RELEASE_BEHAVIOR_NONE_ARB);
                }
                else if (ctxconfig.release == GLFW_RELEASE_BEHAVIOR_FLUSH)
                {
                    setAttrib(WGL_CONTEXT_RELEASE_BEHAVIOR_ARB,
                              WGL_CONTEXT_RELEASE_BEHAVIOR_FLUSH_ARB);
                }
            }
        }

        if (ctxconfig.noerror)
        {
            if (_glfw.wgl.ARB_create_context_no_error)
                setAttrib(WGL_CONTEXT_OPENGL_NO_ERROR_ARB, GLFW_TRUE);
        }

        // NOTE: Only request an explicitly versioned context when necessary, as
        //       explicitly requesting version 1.0 does not always return the
        //       highest version supported by the driver
        if (ctxconfig.major != 1 || ctxconfig.minor != 0)
        {
            setAttrib(WGL_CONTEXT_MAJOR_VERSION_ARB, ctxconfig.major);
            setAttrib(WGL_CONTEXT_MINOR_VERSION_ARB, ctxconfig.minor);
        }

        if (flags)
            setAttrib(WGL_CONTEXT_FLAGS_ARB, flags);

        if (mask)
            setAttrib(WGL_CONTEXT_PROFILE_MASK_ARB, mask);

        setAttrib(0, 0);

        window.context.wgl.handle =
            _glfw.wgl.CreateContextAttribsARB(window.context.wgl.dc, share, attribs.ptr);
        if (!window.context.wgl.handle)
        {
            const(DWORD) error = GetLastError();

            if (error == (0xc0070000 | ERROR_INVALID_VERSION_ARB))
            {
                if (ctxconfig.client == GLFW_OPENGL_API)
                {
                    _glfwInputError(GLFW_VERSION_UNAVAILABLE,
                                    "WGL: Driver does not support OpenGL version %i.%i",
                                    ctxconfig.major,
                                    ctxconfig.minor);
                }
                else
                {
                    _glfwInputError(GLFW_VERSION_UNAVAILABLE,
                                    "WGL: Driver does not support OpenGL ES version %i.%i",
                                    ctxconfig.major,
                                    ctxconfig.minor);
                }
            }
            else if (error == (0xc0070000 | ERROR_INVALID_PROFILE_ARB))
            {
                _glfwInputError(GLFW_VERSION_UNAVAILABLE,
                                "WGL: Driver does not support the requested OpenGL profile");
            }
            else if (error == (0xc0070000 | ERROR_INCOMPATIBLE_DEVICE_CONTEXTS_ARB))
            {
                _glfwInputError(GLFW_INVALID_VALUE,
                                "WGL: The share context is not compatible with the requested context");
            }
            else
            {
                if (ctxconfig.client == GLFW_OPENGL_API)
                {
                    _glfwInputError(GLFW_VERSION_UNAVAILABLE,
                                    "WGL: Failed to create OpenGL context");
                }
                else
                {
                    _glfwInputError(GLFW_VERSION_UNAVAILABLE,
                                    "WGL: Failed to create OpenGL ES context");
                }
            }

            return GLFW_FALSE;
        }
    }
    else
    {
        window.context.wgl.handle = _glfw.wgl.CreateContext(window.context.wgl.dc);
        if (!window.context.wgl.handle)
        {
            _glfwInputErrorWin32(GLFW_VERSION_UNAVAILABLE,
                                 "WGL: Failed to create OpenGL context");
            return GLFW_FALSE;
        }

        if (share)
        {
            if (!_glfw.wgl.ShareLists(share, window.context.wgl.handle))
            {
                _glfwInputErrorWin32(GLFW_PLATFORM_ERROR,
                                     "WGL: Failed to enable sharing with specified OpenGL context");
                return GLFW_FALSE;
            }
        }
    }

    window.context.makeCurrent = &makeContextCurrentWGL;
    window.context.swapBuffers = &swapBuffersWGL;
    window.context.swapInterval = &swapIntervalWGL;
    window.context.extensionSupported = &extensionSupportedWGL;
    window.context.getProcAddress = &getProcAddressWGL;
    window.context.destroy = &destroyContextWGL;

    return GLFW_TRUE;
}

//////////////////////////////////////////////////////////////////////////
//////                        GLFW native API                       //////
//////////////////////////////////////////////////////////////////////////

export HGLRC glfwGetWGLContext(GLFWwindow* handle) {
    _GLFWwindow* window = cast(_GLFWwindow*) handle;
    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"null");

    if (window.context.client == GLFW_NO_API)
    {
        _glfwInputError(GLFW_NO_WINDOW_CONTEXT, null);
        return null;
    }

    return window.context.wgl.handle;
}
