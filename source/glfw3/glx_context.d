/// Translated from C to D
module glfw3.glx_context;

nothrow:
extern(C): __gshared:
version(linux):

//========================================================================
// GLFW 3.3 GLX - www.glfw.org
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

// HEADER

enum GLX_VENDOR = 1;
enum GLX_RGBA_BIT = 0x00000001;
enum GLX_WINDOW_BIT = 0x00000001;
enum GLX_DRAWABLE_TYPE = 0x8010;
enum GLX_RENDER_TYPE = 0x8011;
enum GLX_RGBA_TYPE = 0x8014;
enum GLX_DOUBLEBUFFER = 5;
enum GLX_STEREO = 6;
enum GLX_AUX_BUFFERS = 7;
enum GLX_RED_SIZE = 8;
enum GLX_GREEN_SIZE = 9;
enum GLX_BLUE_SIZE = 10;
enum GLX_ALPHA_SIZE = 11;
enum GLX_DEPTH_SIZE = 12;
enum GLX_STENCIL_SIZE = 13;
enum GLX_ACCUM_RED_SIZE = 14;
enum GLX_ACCUM_GREEN_SIZE = 15;
enum GLX_ACCUM_BLUE_SIZE = 16;
enum GLX_ACCUM_ALPHA_SIZE = 17;
enum GLX_SAMPLES = 0x186a1;
enum GLX_VISUAL_ID = 0x800b;

enum GLX_FRAMEBUFFER_SRGB_CAPABLE_ARB = 0x20b2;
enum GLX_CONTEXT_DEBUG_BIT_ARB = 0x00000001;
enum GLX_CONTEXT_COMPATIBILITY_PROFILE_BIT_ARB = 0x00000002;
enum GLX_CONTEXT_CORE_PROFILE_BIT_ARB = 0x00000001;
enum GLX_CONTEXT_PROFILE_MASK_ARB = 0x9126;
enum GLX_CONTEXT_FORWARD_COMPATIBLE_BIT_ARB = 0x00000002;
enum GLX_CONTEXT_MAJOR_VERSION_ARB = 0x2091;
enum GLX_CONTEXT_MINOR_VERSION_ARB = 0x2092;
enum GLX_CONTEXT_FLAGS_ARB = 0x2094;
enum GLX_CONTEXT_ES2_PROFILE_BIT_EXT = 0x00000004;
enum GLX_CONTEXT_ROBUST_ACCESS_BIT_ARB = 0x00000004;
enum GLX_LOSE_CONTEXT_ON_RESET_ARB = 0x8252;
enum GLX_CONTEXT_RESET_NOTIFICATION_STRATEGY_ARB = 0x8256;
enum GLX_NO_RESET_NOTIFICATION_ARB = 0x8261;
enum GLX_CONTEXT_RELEASE_BEHAVIOR_ARB = 0x2097;
enum GLX_CONTEXT_RELEASE_BEHAVIOR_NONE_ARB = 0;
enum GLX_CONTEXT_RELEASE_BEHAVIOR_FLUSH_ARB = 0x2098;
enum GLX_CONTEXT_OPENGL_NO_ERROR_ARB = 0x31b3;

alias XID GLXWindow;
alias XID GLXDrawable;
struct __GLXFBConfig ;alias const(__GLXFBConfig)* GLXFBConfig;
struct __GLXcontext ; alias const(__GLXcontext)* GLXContext;
alias void function() __GLXextproc;

alias int function(Display*, GLXFBConfig, int, int*) PFNGLXGETFBCONFIGATTRIBPROC;
alias const(char)* function(Display*, int) PFNGLXGETCLIENTSTRINGPROC;
alias Bool function(Display*, int*, int*) PFNGLXQUERYEXTENSIONPROC;
alias Bool function(Display*, int*, int*) PFNGLXQUERYVERSIONPROC;
alias void function(Display*, GLXContext) PFNGLXDESTROYCONTEXTPROC;
alias Bool function(Display*, GLXDrawable, GLXContext) PFNGLXMAKECURRENTPROC;
alias void function(Display*, GLXDrawable) PFNGLXSWAPBUFFERSPROC;
alias const(char)* function(Display*, int) PFNGLXQUERYEXTENSIONSSTRINGPROC;
alias GLXFBConfig* function(Display*, int, int*) PFNGLXGETFBCONFIGSPROC;
alias GLXContext function(Display*, GLXFBConfig, int, GLXContext, Bool) PFNGLXCREATENEWCONTEXTPROC;
alias __GLXextproc function(const(GLubyte)* procName) PFNGLXGETPROCADDRESSPROC;
alias void function(Display*, GLXDrawable, int) PFNGLXSWAPINTERVALEXTPROC;
alias XVisualInfo* function(Display*, GLXFBConfig) PFNGLXGETVISUALFROMFBCONFIGPROC;
alias GLXWindow function(Display*, GLXFBConfig, Window, const(int)*) PFNGLXCREATEWINDOWPROC;
alias void function(Display*, GLXWindow) PFNGLXDESTROYWINDOWPROC;

alias int function(int) PFNGLXSWAPINTERVALMESAPROC;
alias int function(int) PFNGLXSWAPINTERVALSGIPROC;
alias GLXContext function(Display*, GLXFBConfig, GLXContext, Bool, const(int)*) PFNGLXCREATECONTEXTATTRIBSARBPROC;

// libGL.so function pointer typedefs
alias glXGetFBConfigs = _glfw.glx.GetFBConfigs;
alias glXGetFBConfigAttrib = _glfw.glx.GetFBConfigAttrib;
alias glXGetClientString = _glfw.glx.GetClientString;
alias glXQueryExtension = _glfw.glx.QueryExtension;
alias glXQueryVersion = _glfw.glx.QueryVersion;
alias glXDestroyContext = _glfw.glx.DestroyContext;
alias glXMakeCurrent = _glfw.glx.MakeCurrent;
alias glXSwapBuffers = _glfw.glx.SwapBuffers;
alias glXQueryExtensionsString = _glfw.glx.QueryExtensionsString;
alias glXCreateNewContext = _glfw.glx.CreateNewContext;
alias glXGetVisualFromFBConfig = _glfw.glx.GetVisualFromFBConfig;
alias glXCreateWindow = _glfw.glx.CreateWindow;
alias glXDestroyWindow = _glfw.glx.DestroyWindow;

mixin template _GLFW_PLATFORM_CONTEXT_STATE() {        _GLFWcontextGLX glx;}
mixin template _GLFW_PLATFORM_LIBRARY_CONTEXT_STATE() {_GLFWlibraryGLX glx;}

// GLX-specific per-context data
//
struct _GLFWcontextGLX {
    GLXContext handle;
    GLXWindow window;

}

// GLX-specific global data
//
struct _GLFWlibraryGLX {
    int major;int minor;
    int eventBase;
    int errorBase;

    // dlopen handle for libGL.so.1
    void* handle;

    // GLX 1.3 functions
    PFNGLXGETFBCONFIGSPROC GetFBConfigs;
    PFNGLXGETFBCONFIGATTRIBPROC GetFBConfigAttrib;
    PFNGLXGETCLIENTSTRINGPROC GetClientString;
    PFNGLXQUERYEXTENSIONPROC QueryExtension;
    PFNGLXQUERYVERSIONPROC QueryVersion;
    PFNGLXDESTROYCONTEXTPROC DestroyContext;
    PFNGLXMAKECURRENTPROC MakeCurrent;
    PFNGLXSWAPBUFFERSPROC SwapBuffers;
    PFNGLXQUERYEXTENSIONSSTRINGPROC QueryExtensionsString;
    PFNGLXCREATENEWCONTEXTPROC CreateNewContext;
    PFNGLXGETVISUALFROMFBCONFIGPROC GetVisualFromFBConfig;
    PFNGLXCREATEWINDOWPROC CreateWindow;
    PFNGLXDESTROYWINDOWPROC DestroyWindow;

    // GLX 1.4 and extension functions
    PFNGLXGETPROCADDRESSPROC GetProcAddress;
    PFNGLXGETPROCADDRESSPROC GetProcAddressARB;
    PFNGLXSWAPINTERVALSGIPROC SwapIntervalSGI;
    PFNGLXSWAPINTERVALEXTPROC SwapIntervalEXT;
    PFNGLXSWAPINTERVALMESAPROC SwapIntervalMESA;
    PFNGLXCREATECONTEXTATTRIBSARBPROC CreateContextAttribsARB;
    GLFWbool SGI_swap_control;
    GLFWbool EXT_swap_control;
    GLFWbool MESA_swap_control;
    GLFWbool ARB_multisample;
    GLFWbool ARB_framebuffer_sRGB;
    GLFWbool EXT_framebuffer_sRGB;
    GLFWbool ARB_create_context;
    GLFWbool ARB_create_context_profile;
    GLFWbool ARB_create_context_robustness;
    GLFWbool EXT_create_context_es2_profile;
    GLFWbool ARB_create_context_no_error;
    GLFWbool ARB_context_flush_control;

}

GLFWbool _glfwInitGLX();
void _glfwTerminateGLX();
GLFWbool _glfwCreateContextGLX(_GLFWwindow* window, const(_GLFWctxconfig)* ctxconfig, const(_GLFWfbconfig)* fbconfig);
void _glfwDestroyContextGLX(_GLFWwindow* window);
GLFWbool _glfwChooseVisualGLX(const(_GLFWwndconfig)* wndconfig, const(_GLFWctxconfig)* ctxconfig, const(_GLFWfbconfig)* fbconfig, Visual** visual, int* depth);

/////////////////////////////////

import glfw3.internal;

import core.stdc.string;
import core.stdc.stdlib;
import core.stdc.assert_;
import core.stdc.stdint;

enum GLXBadProfileARB = 13;

// Returns the specified attribute of the specified GLXFBConfig
//
private int getGLXFBConfigAttrib(GLXFBConfig fbconfig, int attrib) {
    int value;
    _glfw.glx.GetFBConfigAttrib(_glfw.x11.display, fbconfig, attrib, &value);
    return value;
}

// Return the GLXFBConfig most closely matching the specified hints
//
private GLFWbool chooseGLXFBConfig(const(_GLFWfbconfig)* desired, GLXFBConfig* result) {
    GLXFBConfig* nativeConfigs;
    _GLFWfbconfig* usableConfigs;
    const(_GLFWfbconfig)* closest;
    int i;int nativeCount;int usableCount;
    const(char)* vendor;
    GLFWbool trustWindowBit = GLFW_TRUE;

    // HACK: This is a (hopefully temporary) workaround for Chromium
    //       (VirtualBox GL) not setting the window bit on any GLXFBConfigs
    vendor = _glfw.glx.GetClientString(_glfw.x11.display, GLX_VENDOR);
    if (vendor && strcmp(vendor, "Chromium") == 0)
        trustWindowBit = GLFW_FALSE;

    nativeConfigs =
        _glfw.glx.GetFBConfigs(_glfw.x11.display, _glfw.x11.screen, &nativeCount);
    if (!nativeConfigs || !nativeCount)
    {
        _glfwInputError(GLFW_API_UNAVAILABLE, "GLX: No GLXFBConfigs returned");
        return GLFW_FALSE;
    }

    usableConfigs = cast(typeof(usableConfigs)) calloc(nativeCount, _GLFWfbconfig.sizeof);
    usableCount = 0;

    for (i = 0;  i < nativeCount;  i++)
    {
        GLXFBConfig n = nativeConfigs[i];
        _GLFWfbconfig* u = usableConfigs + usableCount;

        // Only consider RGBA GLXFBConfigs
        if (!(getGLXFBConfigAttrib(n, GLX_RENDER_TYPE) & GLX_RGBA_BIT))
            continue;

        // Only consider window GLXFBConfigs
        if (!(getGLXFBConfigAttrib(n, GLX_DRAWABLE_TYPE) & GLX_WINDOW_BIT))
        {
            if (trustWindowBit)
                continue;
        }

        if (desired.transparent)
        {
            XVisualInfo* vi = _glfw.glx.GetVisualFromFBConfig(_glfw.x11.display, n);
            if (vi)
            {
                u.transparent = _glfwIsVisualTransparentX11(vi.visual);
                XFree(vi);
            }
        }

        u.redBits = getGLXFBConfigAttrib(n, GLX_RED_SIZE);
        u.greenBits = getGLXFBConfigAttrib(n, GLX_GREEN_SIZE);
        u.blueBits = getGLXFBConfigAttrib(n, GLX_BLUE_SIZE);

        u.alphaBits = getGLXFBConfigAttrib(n, GLX_ALPHA_SIZE);
        u.depthBits = getGLXFBConfigAttrib(n, GLX_DEPTH_SIZE);
        u.stencilBits = getGLXFBConfigAttrib(n, GLX_STENCIL_SIZE);

        u.accumRedBits = getGLXFBConfigAttrib(n, GLX_ACCUM_RED_SIZE);
        u.accumGreenBits = getGLXFBConfigAttrib(n, GLX_ACCUM_GREEN_SIZE);
        u.accumBlueBits = getGLXFBConfigAttrib(n, GLX_ACCUM_BLUE_SIZE);
        u.accumAlphaBits = getGLXFBConfigAttrib(n, GLX_ACCUM_ALPHA_SIZE);

        u.auxBuffers = getGLXFBConfigAttrib(n, GLX_AUX_BUFFERS);

        if (getGLXFBConfigAttrib(n, GLX_STEREO))
            u.stereo = GLFW_TRUE;
        if (getGLXFBConfigAttrib(n, GLX_DOUBLEBUFFER))
            u.doublebuffer = GLFW_TRUE;

        if (_glfw.glx.ARB_multisample)
            u.samples = getGLXFBConfigAttrib(n, GLX_SAMPLES);

        if (_glfw.glx.ARB_framebuffer_sRGB || _glfw.glx.EXT_framebuffer_sRGB)
            u.sRGB = getGLXFBConfigAttrib(n, GLX_FRAMEBUFFER_SRGB_CAPABLE_ARB);

        u.handle = cast(uintptr_t) n;
        usableCount++;
    }

    closest = _glfwChooseFBConfig(desired, usableConfigs, usableCount);
    if (closest)
        *result = cast(GLXFBConfig) closest.handle;

    XFree(nativeConfigs);
    free(usableConfigs);

    return closest != null;
}

// Create the OpenGL context using legacy API
//
private GLXContext createLegacyContextGLX(_GLFWwindow* window, GLXFBConfig fbconfig, GLXContext share) {
    return _glfw.glx.CreateNewContext(_glfw.x11.display,
                               fbconfig,
                               GLX_RGBA_TYPE,
                               share,
                               True);
}

private void makeContextCurrentGLX(_GLFWwindow* window) {
    if (window)
    {
        if (!_glfw.glx.MakeCurrent(_glfw.x11.display,
                            window.context.glx.window,
                            window.context.glx.handle))
        {
            _glfwInputError(GLFW_PLATFORM_ERROR,
                            "GLX: Failed to make context current");
            return;
        }
    }
    else
    {
        if (!_glfw.glx.MakeCurrent(_glfw.x11.display, None, null))
        {
            _glfwInputError(GLFW_PLATFORM_ERROR,
                            "GLX: Failed to clear current context");
            return;
        }
    }

    _glfwPlatformSetTls(&_glfw.contextSlot, window);
}

private void swapBuffersGLX(_GLFWwindow* window) {
    _glfw.glx.SwapBuffers(_glfw.x11.display, window.context.glx.window);
}

private void swapIntervalGLX(int interval) {
    auto window = cast(_GLFWwindow*) _glfwPlatformGetTls(&_glfw.contextSlot);

    if (_glfw.glx.EXT_swap_control)
    {
        _glfw.glx.SwapIntervalEXT(_glfw.x11.display,
                                  window.context.glx.window,
                                  interval);
    }
    else if (_glfw.glx.MESA_swap_control)
        _glfw.glx.SwapIntervalMESA(interval);
    else if (_glfw.glx.SGI_swap_control)
    {
        if (interval > 0)
            _glfw.glx.SwapIntervalSGI(interval);
    }
}

private int extensionSupportedGLX(const(char)* extension) {
    const(char)* extensions = _glfw.glx.QueryExtensionsString(_glfw.x11.display, _glfw.x11.screen);
    if (extensions)
    {
        if (_glfwStringInExtensionString(extension, extensions))
            return GLFW_TRUE;
    }

    return GLFW_FALSE;
}

private GLFWglproc getProcAddressGLX(const(char)* procname) {
    if (_glfw.glx.GetProcAddress)
        return cast(typeof(return)) _glfw.glx.GetProcAddress(cast(const(GLubyte)*) procname);
    else if (_glfw.glx.GetProcAddressARB)
        return cast(typeof(return)) _glfw.glx.GetProcAddressARB(cast(const(GLubyte)*) procname);
    else
        return cast(typeof(return)) _glfw_dlsym(_glfw.glx.handle, procname);
}

private void destroyContextGLX(_GLFWwindow* window) {
    if (window.context.glx.window)
    {
        _glfw.glx.DestroyWindow(_glfw.x11.display, window.context.glx.window);
        window.context.glx.window = None;
    }

    if (window.context.glx.handle)
    {
        _glfw.glx.DestroyContext(_glfw.x11.display, window.context.glx.handle);
        window.context.glx.handle = null;
    }
}


//////////////////////////////////////////////////////////////////////////
//////                       GLFW internal API                      //////
//////////////////////////////////////////////////////////////////////////

// Initialize GLX
//
GLFWbool _glfwInitGLX() {
    int i;
    version(Cygwin) {
        static immutable const(char)*[] sonames = ["libGL-1.so", "libGL.so.1","libGL.so",null];
    } else {
        static immutable const(char)*[] sonames = ["libGL.so.1","libGL.so",null];
    }

    if (_glfw.glx.handle)
        return GLFW_TRUE;

    for (i = 0;  sonames[i];  i++)
    {
        _glfw.glx.handle = _glfw_dlopen(sonames[i]);
        if (_glfw.glx.handle)
            break;
    }

    if (!_glfw.glx.handle)
    {
        _glfwInputError(GLFW_API_UNAVAILABLE, "GLX: Failed to load GLX");
        return GLFW_FALSE;
    }

    _glfw.glx.GetFBConfigs = cast(PFNGLXGETFBCONFIGSPROC) _glfw_dlsym(_glfw.glx.handle, "glXGetFBConfigs");
    _glfw.glx.GetFBConfigAttrib = cast(PFNGLXGETFBCONFIGATTRIBPROC) _glfw_dlsym(_glfw.glx.handle, "glXGetFBConfigAttrib");
    _glfw.glx.GetClientString = cast(PFNGLXGETCLIENTSTRINGPROC) _glfw_dlsym(_glfw.glx.handle, "glXGetClientString");
    _glfw.glx.QueryExtension = cast(PFNGLXQUERYEXTENSIONPROC) _glfw_dlsym(_glfw.glx.handle, "glXQueryExtension");
    _glfw.glx.QueryVersion = cast(PFNGLXQUERYVERSIONPROC) _glfw_dlsym(_glfw.glx.handle, "glXQueryVersion");
    _glfw.glx.DestroyContext = cast(PFNGLXDESTROYCONTEXTPROC) _glfw_dlsym(_glfw.glx.handle, "glXDestroyContext");
    _glfw.glx.MakeCurrent = cast(PFNGLXMAKECURRENTPROC) _glfw_dlsym(_glfw.glx.handle, "glXMakeCurrent");
    _glfw.glx.SwapBuffers = cast(PFNGLXSWAPBUFFERSPROC) _glfw_dlsym(_glfw.glx.handle, "glXSwapBuffers");
    _glfw.glx.QueryExtensionsString = cast(PFNGLXQUERYEXTENSIONSSTRINGPROC) _glfw_dlsym(_glfw.glx.handle, "glXQueryExtensionsString");
    _glfw.glx.CreateNewContext = cast(PFNGLXCREATENEWCONTEXTPROC) _glfw_dlsym(_glfw.glx.handle, "glXCreateNewContext");
    _glfw.glx.CreateWindow = cast(PFNGLXCREATEWINDOWPROC) _glfw_dlsym(_glfw.glx.handle, "glXCreateWindow");
    _glfw.glx.DestroyWindow = cast(PFNGLXDESTROYWINDOWPROC) _glfw_dlsym(_glfw.glx.handle, "glXDestroyWindow");

    _glfw.glx.GetProcAddress = cast(PFNGLXGETPROCADDRESSPROC) _glfw_dlsym(_glfw.glx.handle, "glXGetProcAddress");
    _glfw.glx.GetProcAddressARB = cast(PFNGLXGETPROCADDRESSPROC) _glfw_dlsym(_glfw.glx.handle, "glXGetProcAddressARB");
    _glfw.glx.GetVisualFromFBConfig = cast(PFNGLXGETVISUALFROMFBCONFIGPROC) _glfw_dlsym(_glfw.glx.handle, "glXGetVisualFromFBConfig");

    if (!_glfw.glx.GetFBConfigs ||
        !_glfw.glx.GetFBConfigAttrib ||
        !_glfw.glx.GetClientString ||
        !_glfw.glx.QueryExtension ||
        !_glfw.glx.QueryVersion ||
        !_glfw.glx.DestroyContext ||
        !_glfw.glx.MakeCurrent ||
        !_glfw.glx.SwapBuffers ||
        !_glfw.glx.QueryExtensionsString ||
        !_glfw.glx.CreateNewContext ||
        !_glfw.glx.CreateWindow ||
        !_glfw.glx.DestroyWindow ||
        !_glfw.glx.GetProcAddress ||
        !_glfw.glx.GetProcAddressARB ||
        !_glfw.glx.GetVisualFromFBConfig)
    {
        _glfwInputError(GLFW_PLATFORM_ERROR,
                        "GLX: Failed to load required entry points");
        return GLFW_FALSE;
    }

    if (!_glfw.glx.QueryExtension(_glfw.x11.display,
                           &_glfw.glx.errorBase,
                           &_glfw.glx.eventBase))
    {
        _glfwInputError(GLFW_API_UNAVAILABLE, "GLX: GLX extension not found");
        return GLFW_FALSE;
    }

    if (!_glfw.glx.QueryVersion(_glfw.x11.display, &_glfw.glx.major, &_glfw.glx.minor))
    {
        _glfwInputError(GLFW_API_UNAVAILABLE,
                        "GLX: Failed to query GLX version");
        return GLFW_FALSE;
    }

    if (_glfw.glx.major == 1 && _glfw.glx.minor < 3)
    {
        _glfwInputError(GLFW_API_UNAVAILABLE,
                        "GLX: GLX version 1.3 is required");
        return GLFW_FALSE;
    }

    if (extensionSupportedGLX("GLX_EXT_swap_control"))
    {
        _glfw.glx.SwapIntervalEXT = cast(PFNGLXSWAPINTERVALEXTPROC)
            getProcAddressGLX("glXSwapIntervalEXT");

        if (_glfw.glx.SwapIntervalEXT)
            _glfw.glx.EXT_swap_control = GLFW_TRUE;
    }

    if (extensionSupportedGLX("GLX_SGI_swap_control"))
    {
        _glfw.glx.SwapIntervalSGI = cast(PFNGLXSWAPINTERVALSGIPROC)
            getProcAddressGLX("glXSwapIntervalSGI");

        if (_glfw.glx.SwapIntervalSGI)
            _glfw.glx.SGI_swap_control = GLFW_TRUE;
    }

    if (extensionSupportedGLX("GLX_MESA_swap_control"))
    {
        _glfw.glx.SwapIntervalMESA = cast(PFNGLXSWAPINTERVALMESAPROC)
            getProcAddressGLX("glXSwapIntervalMESA");

        if (_glfw.glx.SwapIntervalMESA)
            _glfw.glx.MESA_swap_control = GLFW_TRUE;
    }

    if (extensionSupportedGLX("GLX_ARB_multisample"))
        _glfw.glx.ARB_multisample = GLFW_TRUE;

    if (extensionSupportedGLX("GLX_ARB_framebuffer_sRGB"))
        _glfw.glx.ARB_framebuffer_sRGB = GLFW_TRUE;

    if (extensionSupportedGLX("GLX_EXT_framebuffer_sRGB"))
        _glfw.glx.EXT_framebuffer_sRGB = GLFW_TRUE;

    if (extensionSupportedGLX("GLX_ARB_create_context"))
    {
        _glfw.glx.CreateContextAttribsARB = cast(PFNGLXCREATECONTEXTATTRIBSARBPROC)
            getProcAddressGLX("glXCreateContextAttribsARB");

        if (_glfw.glx.CreateContextAttribsARB)
            _glfw.glx.ARB_create_context = GLFW_TRUE;
    }

    if (extensionSupportedGLX("GLX_ARB_create_context_robustness"))
        _glfw.glx.ARB_create_context_robustness = GLFW_TRUE;

    if (extensionSupportedGLX("GLX_ARB_create_context_profile"))
        _glfw.glx.ARB_create_context_profile = GLFW_TRUE;

    if (extensionSupportedGLX("GLX_EXT_create_context_es2_profile"))
        _glfw.glx.EXT_create_context_es2_profile = GLFW_TRUE;

    if (extensionSupportedGLX("GLX_ARB_create_context_no_error"))
        _glfw.glx.ARB_create_context_no_error = GLFW_TRUE;

    if (extensionSupportedGLX("GLX_ARB_context_flush_control"))
        _glfw.glx.ARB_context_flush_control = GLFW_TRUE;

    return GLFW_TRUE;
}

// Terminate GLX
//
void _glfwTerminateGLX() {
    // NOTE: This function must not call any X11 functions, as it is called
    //       after XCloseDisplay (see _glfwPlatformTerminate for details)

    if (_glfw.glx.handle)
    {
        _glfw_dlclose(_glfw.glx.handle);
        _glfw.glx.handle = null;
    }
}


// Create the OpenGL or OpenGL ES context
//
GLFWbool _glfwCreateContextGLX(_GLFWwindow* window, const(_GLFWctxconfig)* ctxconfig, const(_GLFWfbconfig)* fbconfig) {
    int[40] attribs;
    int index;
    void setAttrib(int a, int v) {
        assert((cast(size_t) index + 1) < attribs.length);
        attribs[index++] = a;
        attribs[index++] = v;
    }
    GLXFBConfig native = null;
    GLXContext share = null;

    if (ctxconfig.share)
        share = ctxconfig.share.context.glx.handle;

    if (!chooseGLXFBConfig(fbconfig, &native))
    {
        _glfwInputError(GLFW_FORMAT_UNAVAILABLE,
                        "GLX: Failed to find a suitable GLXFBConfig");
        return GLFW_FALSE;
    }

    if (ctxconfig.client == GLFW_OPENGL_ES_API)
    {
        if (!_glfw.glx.ARB_create_context ||
            !_glfw.glx.ARB_create_context_profile ||
            !_glfw.glx.EXT_create_context_es2_profile)
        {
            _glfwInputError(GLFW_API_UNAVAILABLE,
                            "GLX: OpenGL ES requested but GLX_EXT_create_context_es2_profile is unavailable");
            return GLFW_FALSE;
        }
    }

    if (ctxconfig.forward)
    {
        if (!_glfw.glx.ARB_create_context)
        {
            _glfwInputError(GLFW_VERSION_UNAVAILABLE,
                            "GLX: Forward compatibility requested but GLX_ARB_create_context_profile is unavailable");
            return GLFW_FALSE;
        }
    }

    if (ctxconfig.profile)
    {
        if (!_glfw.glx.ARB_create_context ||
            !_glfw.glx.ARB_create_context_profile)
        {
            _glfwInputError(GLFW_VERSION_UNAVAILABLE,
                            "GLX: An OpenGL profile requested but GLX_ARB_create_context_profile is unavailable");
            return GLFW_FALSE;
        }
    }

    _glfwGrabErrorHandlerX11();

    if (_glfw.glx.ARB_create_context)
    {
        index = 0;
        int mask = 0;int flags = 0;

        if (ctxconfig.client == GLFW_OPENGL_API)
        {
            if (ctxconfig.forward)
                flags |= GLX_CONTEXT_FORWARD_COMPATIBLE_BIT_ARB;

            if (ctxconfig.profile == GLFW_OPENGL_CORE_PROFILE)
                mask |= GLX_CONTEXT_CORE_PROFILE_BIT_ARB;
            else if (ctxconfig.profile == GLFW_OPENGL_COMPAT_PROFILE)
                mask |= GLX_CONTEXT_COMPATIBILITY_PROFILE_BIT_ARB;
        }
        else
            mask |= GLX_CONTEXT_ES2_PROFILE_BIT_EXT;

        if (ctxconfig.debug_)
            flags |= GLX_CONTEXT_DEBUG_BIT_ARB;

        if (ctxconfig.robustness)
        {
            if (_glfw.glx.ARB_create_context_robustness)
            {
                if (ctxconfig.robustness == GLFW_NO_RESET_NOTIFICATION)
                {
                    setAttrib(GLX_CONTEXT_RESET_NOTIFICATION_STRATEGY_ARB,
                              GLX_NO_RESET_NOTIFICATION_ARB);
                }
                else if (ctxconfig.robustness == GLFW_LOSE_CONTEXT_ON_RESET)
                {
                    setAttrib(GLX_CONTEXT_RESET_NOTIFICATION_STRATEGY_ARB,
                              GLX_LOSE_CONTEXT_ON_RESET_ARB);
                }

                flags |= GLX_CONTEXT_ROBUST_ACCESS_BIT_ARB;
            }
        }

        if (ctxconfig.release)
        {
            if (_glfw.glx.ARB_context_flush_control)
            {
                if (ctxconfig.release == GLFW_RELEASE_BEHAVIOR_NONE)
                {
                    setAttrib(GLX_CONTEXT_RELEASE_BEHAVIOR_ARB,
                              GLX_CONTEXT_RELEASE_BEHAVIOR_NONE_ARB);
                }
                else if (ctxconfig.release == GLFW_RELEASE_BEHAVIOR_FLUSH)
                {
                    setAttrib(GLX_CONTEXT_RELEASE_BEHAVIOR_ARB,
                              GLX_CONTEXT_RELEASE_BEHAVIOR_FLUSH_ARB);
                }
            }
        }

        if (ctxconfig.noerror)
        {
            if (_glfw.glx.ARB_create_context_no_error)
                setAttrib(GLX_CONTEXT_OPENGL_NO_ERROR_ARB, GLFW_TRUE);
        }

        // NOTE: Only request an explicitly versioned context when necessary, as
        //       explicitly requesting version 1.0 does not always return the
        //       highest version supported by the driver
        if (ctxconfig.major != 1 || ctxconfig.minor != 0)
        {
            setAttrib(GLX_CONTEXT_MAJOR_VERSION_ARB, ctxconfig.major);
            setAttrib(GLX_CONTEXT_MINOR_VERSION_ARB, ctxconfig.minor);
        }

        if (mask)
            setAttrib(GLX_CONTEXT_PROFILE_MASK_ARB, mask);

        if (flags)
            setAttrib(GLX_CONTEXT_FLAGS_ARB, flags);

        setAttrib(None, None);

        window.context.glx.handle =
            _glfw.glx.CreateContextAttribsARB(_glfw.x11.display,
                                              native,
                                              share,
                                              True,
                                              attribs.ptr);

        // HACK: This is a fallback for broken versions of the Mesa
        //       implementation of GLX_ARB_create_context_profile that fail
        //       default 1.0 context creation with a GLXBadProfileARB error in
        //       violation of the extension spec
        if (!window.context.glx.handle)
        {
            if (_glfw.x11.errorCode == _glfw.glx.errorBase + GLXBadProfileARB &&
                ctxconfig.client == GLFW_OPENGL_API &&
                ctxconfig.profile == GLFW_OPENGL_ANY_PROFILE &&
                ctxconfig.forward == GLFW_FALSE)
            {
                window.context.glx.handle =
                    createLegacyContextGLX(window, native, share);
            }
        }
    }
    else
    {
        window.context.glx.handle =
            createLegacyContextGLX(window, native, share);
    }

    _glfwReleaseErrorHandlerX11();

    if (!window.context.glx.handle)
    {
        _glfwInputErrorX11(GLFW_VERSION_UNAVAILABLE, "GLX: Failed to create context");
        return GLFW_FALSE;
    }

    window.context.glx.window =
        _glfw.glx.CreateWindow(_glfw.x11.display, native, window.x11.handle, null);
    if (!window.context.glx.window)
    {
        _glfwInputError(GLFW_PLATFORM_ERROR, "GLX: Failed to create window");
        return GLFW_FALSE;
    }

    window.context.makeCurrent = &makeContextCurrentGLX;
    window.context.swapBuffers = &swapBuffersGLX;
    window.context.swapInterval = &swapIntervalGLX;
    window.context.extensionSupported = &extensionSupportedGLX;
    window.context.getProcAddress = &getProcAddressGLX;
    window.context.destroy = &destroyContextGLX;

    return GLFW_TRUE;
}

// Returns the Visual and depth of the chosen GLXFBConfig
//
GLFWbool _glfwChooseVisualGLX(const(_GLFWwndconfig)* wndconfig, const(_GLFWctxconfig)* ctxconfig, const(_GLFWfbconfig)* fbconfig, Visual** visual, int* depth) {
    GLXFBConfig native;
    XVisualInfo* result;

    if (!chooseGLXFBConfig(fbconfig, &native))
    {
        _glfwInputError(GLFW_FORMAT_UNAVAILABLE,
                        "GLX: Failed to find a suitable GLXFBConfig");
        return GLFW_FALSE;
    }

    result = _glfw.glx.GetVisualFromFBConfig(_glfw.x11.display, native);
    if (!result)
    {
        _glfwInputError(GLFW_PLATFORM_ERROR,
                        "GLX: Failed to retrieve Visual for GLXFBConfig");
        return GLFW_FALSE;
    }

    *visual = result.visual;
    *depth  = result.depth;

    XFree(result);
    return GLFW_TRUE;
}


//////////////////////////////////////////////////////////////////////////
//////                        GLFW native API                       //////
//////////////////////////////////////////////////////////////////////////

 GLXContext glfwGetGLXContext(GLFWwindow* handle) {
    _GLFWwindow* window = cast(_GLFWwindow*) handle;
    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!("null"));

    if (window.context.client == GLFW_NO_API)
    {
        _glfwInputError(GLFW_NO_WINDOW_CONTEXT, null);
        return null;
    }

    return window.context.glx.handle;
}

GLXWindow glfwGetGLXWindow(GLFWwindow* handle) {
    _GLFWwindow* window = cast(_GLFWwindow*) handle;
    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!("None"));

    if (window.context.client == GLFW_NO_API)
    {
        _glfwInputError(GLFW_NO_WINDOW_CONTEXT, null);
        return None;
    }

    return window.context.glx.window;
}
