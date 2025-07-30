/// Translated from C to D
module glfw3.egl_context;

nothrow:
extern(C): __gshared:

//========================================================================
// GLFW 3.3 EGL - www.glfw.org
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

// HEADER
version(_GLFW_WAYLAND) {
    alias EGLNativeDisplayType = wl_display*;
    alias EGLNativeWindowType = wl_egl_window*;
} else version(Windows) {
    alias EGLNativeDisplayType = HDC;
    alias EGLNativeWindowType = HWND;
} else version(OSX) {
    alias EGLNativeDisplayType = void*;
    alias EGLNativeWindowType = id ;
} else version(linux) {
    alias EGLNativeDisplayType = Display*;
    alias EGLNativeWindowType = Window;
} else {
    static assert(0, "No supported EGL platform selected");
}

enum EGL_SUCCESS = 0x3000;
enum EGL_NOT_INITIALIZED = 0x3001;
enum EGL_BAD_ACCESS = 0x3002;
enum EGL_BAD_ALLOC = 0x3003;
enum EGL_BAD_ATTRIBUTE = 0x3004;
enum EGL_BAD_CONFIG = 0x3005;
enum EGL_BAD_CONTEXT = 0x3006;
enum EGL_BAD_CURRENT_SURFACE = 0x3007;
enum EGL_BAD_DISPLAY = 0x3008;
enum EGL_BAD_MATCH = 0x3009;
enum EGL_BAD_NATIVE_PIXMAP = 0x300a;
enum EGL_BAD_NATIVE_WINDOW = 0x300b;
enum EGL_BAD_PARAMETER = 0x300c;
enum EGL_BAD_SURFACE = 0x300d;
enum EGL_CONTEXT_LOST = 0x300e;
enum EGL_COLOR_BUFFER_TYPE = 0x303f;
enum EGL_RGB_BUFFER = 0x308e;
enum EGL_SURFACE_TYPE = 0x3033;
enum EGL_WINDOW_BIT = 0x0004;
enum EGL_RENDERABLE_TYPE = 0x3040;
enum EGL_OPENGL_ES_BIT = 0x0001;
enum EGL_OPENGL_ES2_BIT = 0x0004;
enum EGL_OPENGL_BIT = 0x0008;
enum EGL_ALPHA_SIZE = 0x3021;
enum EGL_BLUE_SIZE = 0x3022;
enum EGL_GREEN_SIZE = 0x3023;
enum EGL_RED_SIZE = 0x3024;
enum EGL_DEPTH_SIZE = 0x3025;
enum EGL_STENCIL_SIZE = 0x3026;
enum EGL_SAMPLES = 0x3031;
enum EGL_OPENGL_ES_API = 0x30a0;
enum EGL_OPENGL_API = 0x30a2;
enum EGL_NONE = 0x3038;
enum EGL_EXTENSIONS = 0x3055;
enum EGL_CONTEXT_CLIENT_VERSION = 0x3098;
enum EGL_NATIVE_VISUAL_ID = 0x302e;
enum EGL_NO_SURFACE = (cast(EGLSurface) 0);
enum EGL_NO_DISPLAY = (cast(EGLDisplay) 0);
enum EGL_NO_CONTEXT = (cast(EGLContext) 0);
enum EGL_DEFAULT_DISPLAY = (cast(EGLNativeDisplayType) 0);

enum EGL_CONTEXT_OPENGL_FORWARD_COMPATIBLE_BIT_KHR = 0x00000002;
enum EGL_CONTEXT_OPENGL_CORE_PROFILE_BIT_KHR = 0x00000001;
enum EGL_CONTEXT_OPENGL_COMPATIBILITY_PROFILE_BIT_KHR = 0x00000002;
enum EGL_CONTEXT_OPENGL_DEBUG_BIT_KHR = 0x00000001;
enum EGL_CONTEXT_OPENGL_RESET_NOTIFICATION_STRATEGY_KHR = 0x31bd;
enum EGL_NO_RESET_NOTIFICATION_KHR = 0x31be;
enum EGL_LOSE_CONTEXT_ON_RESET_KHR = 0x31bf;
enum EGL_CONTEXT_OPENGL_ROBUST_ACCESS_BIT_KHR = 0x00000004;
enum EGL_CONTEXT_MAJOR_VERSION_KHR = 0x3098;
enum EGL_CONTEXT_MINOR_VERSION_KHR = 0x30fb;
enum EGL_CONTEXT_OPENGL_PROFILE_MASK_KHR = 0x30fd;
enum EGL_CONTEXT_FLAGS_KHR = 0x30fc;
enum EGL_CONTEXT_OPENGL_NO_ERROR_KHR = 0x31b3;
enum EGL_GL_COLORSPACE_KHR = 0x309d;
enum EGL_GL_COLORSPACE_SRGB_KHR = 0x3089;
enum EGL_CONTEXT_RELEASE_BEHAVIOR_KHR = 0x2097;
enum EGL_CONTEXT_RELEASE_BEHAVIOR_NONE_KHR = 0;
enum EGL_CONTEXT_RELEASE_BEHAVIOR_FLUSH_KHR = 0x2098;

alias int EGLint;
alias uint EGLBoolean;
alias uint EGLenum;
alias void* EGLConfig;
alias void* EGLContext;
alias void* EGLDisplay;
alias void* EGLSurface;

// EGL function pointer typedefs
extern(System) {
    alias EGLBoolean function(EGLDisplay, EGLConfig, EGLint, EGLint*) PFN_eglGetConfigAttrib;
    alias EGLBoolean function(EGLDisplay, EGLConfig*, EGLint, EGLint*) PFN_eglGetConfigs;
    alias EGLDisplay function(EGLNativeDisplayType) PFN_eglGetDisplay;
    alias EGLint function() PFN_eglGetError;
    alias EGLBoolean function(EGLDisplay, EGLint*, EGLint*) PFN_eglInitialize;
    alias EGLBoolean function(EGLDisplay) PFN_eglTerminate;
    alias EGLBoolean function(EGLenum) PFN_eglBindAPI;
    alias EGLContext function(EGLDisplay, EGLConfig, EGLContext, const(EGLint)*) PFN_eglCreateContext;
    alias EGLBoolean function(EGLDisplay, EGLSurface) PFN_eglDestroySurface;
    alias EGLBoolean function(EGLDisplay, EGLContext) PFN_eglDestroyContext;
    alias EGLSurface function(EGLDisplay, EGLConfig, EGLNativeWindowType, const(EGLint)*) PFN_eglCreateWindowSurface;
    alias EGLBoolean function(EGLDisplay, EGLSurface, EGLSurface, EGLContext) PFN_eglMakeCurrent;
    alias EGLBoolean function(EGLDisplay, EGLSurface) PFN_eglSwapBuffers;
    alias EGLBoolean function(EGLDisplay, EGLint) PFN_eglSwapInterval;
    alias const(char)* function(EGLDisplay, EGLint) PFN_eglQueryString;
    alias GLFWglproc function(const(char)*) PFN_eglGetProcAddress;
}
alias eglGetConfigAttrib = _glfw.egl.GetConfigAttrib;
alias eglGetConfigs = _glfw.egl.GetConfigs;
alias eglGetDisplay = _glfw.egl.GetDisplay;
alias eglGetError = _glfw.egl.GetError;
alias eglInitialize = _glfw.egl.Initialize;
alias eglTerminate = _glfw.egl.Terminate;
alias eglBindAPI = _glfw.egl.BindAPI;
alias eglCreateContext = _glfw.egl.CreateContext;
alias eglDestroySurface = _glfw.egl.DestroySurface;
alias eglDestroyContext = _glfw.egl.DestroyContext;
alias eglCreateWindowSurface = _glfw.egl.CreateWindowSurface;
alias eglMakeCurrent = _glfw.egl.MakeCurrent;
alias eglSwapBuffers = _glfw.egl.SwapBuffers;
alias eglSwapInterval = _glfw.egl.SwapInterval;
alias eglQueryString = _glfw.egl.QueryString;
alias eglGetProcAddress = _glfw.egl.GetProcAddress;

mixin template _GLFW_EGL_CONTEXT_STATE() {        _GLFWcontextEGL egl;}
mixin template _GLFW_EGL_LIBRARY_CONTEXT_STATE() {_GLFWlibraryEGL egl;}

// EGL-specific per-context data
//
struct _GLFWcontextEGL {
   EGLConfig config;
   EGLContext handle;
   EGLSurface surface;

   void* client;

}

// EGL-specific global data
//
struct _GLFWlibraryEGL {
    EGLDisplay display;
    EGLint major;EGLint minor;
    GLFWbool prefix;

    GLFWbool KHR_create_context;
    GLFWbool KHR_create_context_no_error;
    GLFWbool KHR_gl_colorspace;
    GLFWbool KHR_get_all_proc_addresses;
    GLFWbool KHR_context_flush_control;

    void* handle;

    PFN_eglGetConfigAttrib GetConfigAttrib;
    PFN_eglGetConfigs GetConfigs;
    PFN_eglGetDisplay GetDisplay;
    PFN_eglGetError GetError;
    PFN_eglInitialize Initialize;
    PFN_eglTerminate Terminate;
    PFN_eglBindAPI BindAPI;
    PFN_eglCreateContext CreateContext;
    PFN_eglDestroySurface DestroySurface;
    PFN_eglDestroyContext DestroyContext;
    PFN_eglCreateWindowSurface CreateWindowSurface;
    PFN_eglMakeCurrent MakeCurrent;
    PFN_eglSwapBuffers SwapBuffers;
    PFN_eglSwapInterval SwapInterval;
    PFN_eglQueryString QueryString;
    PFN_eglGetProcAddress GetProcAddress;

}


GLFWbool _glfwInitEGL();
void _glfwTerminateEGL();
GLFWbool _glfwCreateContextEGL(_GLFWwindow* window, const(_GLFWctxconfig)* ctxconfig, const(_GLFWfbconfig)* fbconfig);
version(linux) {
    GLFWbool _glfwChooseVisualEGL(const(_GLFWwndconfig)* wndconfig, const(_GLFWctxconfig)* ctxconfig, const(_GLFWfbconfig)* fbconfig, Visual** visual, int* depth);
} /*linux*/

//////////////////////

import glfw3.internal;

import core.stdc.stdio;
import core.stdc.string;
import core.stdc.stdlib;
import core.stdc.assert_;
import core.stdc.stdint;

// Return a description of the specified EGL error
//
private const(char)* getEGLErrorString(EGLint error) {
    switch (error)
    {
        case EGL_SUCCESS:
            return "Success";
        case EGL_NOT_INITIALIZED:
            return "EGL is not or could not be initialized";
        case EGL_BAD_ACCESS:
            return "EGL cannot access a requested resource";
        case EGL_BAD_ALLOC:
            return "EGL failed to allocate resources for the requested operation";
        case EGL_BAD_ATTRIBUTE:
            return "An unrecognized attribute or attribute value was passed in the attribute list";
        case EGL_BAD_CONTEXT:
            return "An EGLContext argument does not name a valid EGL rendering context";
        case EGL_BAD_CONFIG:
            return "An EGLConfig argument does not name a valid EGL frame buffer configuration";
        case EGL_BAD_CURRENT_SURFACE:
            return "The current surface of the calling thread is a window, pixel buffer or pixmap that is no longer valid";
        case EGL_BAD_DISPLAY:
            return "An EGLDisplay argument does not name a valid EGL display connection";
        case EGL_BAD_SURFACE:
            return "An EGLSurface argument does not name a valid surface configured for GL rendering";
        case EGL_BAD_MATCH:
            return "Arguments are inconsistent";
        case EGL_BAD_PARAMETER:
            return "One or more argument values are invalid";
        case EGL_BAD_NATIVE_PIXMAP:
            return "A NativePixmapType argument does not refer to a valid native pixmap";
        case EGL_BAD_NATIVE_WINDOW:
            return "A NativeWindowType argument does not refer to a valid native window";
        case EGL_CONTEXT_LOST:
            return "The application must destroy all contexts and reinitialise";
        default:
            return "ERROR: UNKNOWN EGL ERROR";
    }
}

// Returns the specified attribute of the specified EGLConfig
//
private int getEGLConfigAttrib(EGLConfig config, int attrib) {
    int value;
    _glfw.egl.GetConfigAttrib(_glfw.egl.display, config, attrib, &value);
    return value;
}

// Return the EGLConfig most closely matching the specified hints
//
private GLFWbool chooseEGLConfig(const(_GLFWctxconfig)* ctxconfig, const(_GLFWfbconfig)* desired, EGLConfig* result) {
    EGLConfig* nativeConfigs;
    _GLFWfbconfig* usableConfigs;
    const(_GLFWfbconfig)* closest;
    int i;int nativeCount;int usableCount;

    _glfw.egl.GetConfigs(_glfw.egl.display, null, 0, &nativeCount);
    if (!nativeCount)
    {
        _glfwInputError(GLFW_API_UNAVAILABLE, "EGL: No EGLConfigs returned");
        return GLFW_FALSE;
    }

    nativeConfigs = cast(typeof(nativeConfigs)) calloc(nativeCount, EGLConfig.sizeof);
    _glfw.egl.GetConfigs(_glfw.egl.display, nativeConfigs, nativeCount, &nativeCount);

    usableConfigs = cast(typeof(usableConfigs)) calloc(nativeCount, _GLFWfbconfig.sizeof);
    usableCount = 0;

    for (i = 0;  i < nativeCount;  i++)
    {
        EGLConfig n = nativeConfigs[i];
        _GLFWfbconfig* u = usableConfigs + usableCount;

        // Only consider RGB(A) EGLConfigs
        if (getEGLConfigAttrib(n, EGL_COLOR_BUFFER_TYPE) != EGL_RGB_BUFFER)
            continue;

        // Only consider window EGLConfigs
        if (!(getEGLConfigAttrib(n, EGL_SURFACE_TYPE) & EGL_WINDOW_BIT))
            continue;

        version(linux)
        {
            XVisualInfo vi = XVisualInfo(null);

            // Only consider EGLConfigs with associated Visuals
            vi.visualid = getEGLConfigAttrib(n, EGL_NATIVE_VISUAL_ID);
            if (!vi.visualid)
                continue;

            if (desired.transparent)
            {
                int count;
                XVisualInfo* vis = XGetVisualInfo(_glfw.x11.display, VisualIDMask, &vi, &count);
                if (vis)
                {
                    u.transparent = _glfwIsVisualTransparentX11(vis[0].visual);
                    XFree(vis);
                }
            }
        }

        if (ctxconfig.client == GLFW_OPENGL_ES_API)
        {
            if (ctxconfig.major == 1)
            {
                if (!(getEGLConfigAttrib(n, EGL_RENDERABLE_TYPE) & EGL_OPENGL_ES_BIT))
                    continue;
            }
            else
            {
                if (!(getEGLConfigAttrib(n, EGL_RENDERABLE_TYPE) & EGL_OPENGL_ES2_BIT))
                    continue;
            }
        }
        else if (ctxconfig.client == GLFW_OPENGL_API)
        {
            if (!(getEGLConfigAttrib(n, EGL_RENDERABLE_TYPE) & EGL_OPENGL_BIT))
                continue;
        }

        u.redBits = getEGLConfigAttrib(n, EGL_RED_SIZE);
        u.greenBits = getEGLConfigAttrib(n, EGL_GREEN_SIZE);
        u.blueBits = getEGLConfigAttrib(n, EGL_BLUE_SIZE);

        u.alphaBits = getEGLConfigAttrib(n, EGL_ALPHA_SIZE);
        u.depthBits = getEGLConfigAttrib(n, EGL_DEPTH_SIZE);
        u.stencilBits = getEGLConfigAttrib(n, EGL_STENCIL_SIZE);

        u.samples = getEGLConfigAttrib(n, EGL_SAMPLES);
        u.doublebuffer = GLFW_TRUE;

        u.handle = cast(uintptr_t) n;
        usableCount++;
    }

    closest = _glfwChooseFBConfig(desired, usableConfigs, usableCount);
    if (closest)
        *result = cast(EGLConfig) closest.handle;

    free(nativeConfigs);
    free(usableConfigs);

    return closest != null;
}

private void makeContextCurrentEGL(_GLFWwindow* window) {
    if (window)
    {
        if (!_glfw.egl.MakeCurrent(_glfw.egl.display,
                            window.context.egl.surface,
                            window.context.egl.surface,
                            window.context.egl.handle))
        {
            _glfwInputError(GLFW_PLATFORM_ERROR,
                            "EGL: Failed to make context current: %s",
                            getEGLErrorString(_glfw.egl.GetError()));
            return;
        }
    }
    else
    {
        if (!_glfw.egl.MakeCurrent(_glfw.egl.display,
                            EGL_NO_SURFACE,
                            EGL_NO_SURFACE,
                            EGL_NO_CONTEXT))
        {
            _glfwInputError(GLFW_PLATFORM_ERROR,
                            "EGL: Failed to clear current context: %s",
                            getEGLErrorString(_glfw.egl.GetError()));
            return;
        }
    }

    _glfwPlatformSetTls(&_glfw.contextSlot, window);
}

private void swapBuffersEGL(_GLFWwindow* window) {
    if (window != _glfwPlatformGetTls(&_glfw.contextSlot))
    {
        _glfwInputError(GLFW_PLATFORM_ERROR,
                        "EGL: The context must be current on the calling thread when swapping buffers");
        return;
    }

    _glfw.egl.SwapBuffers(_glfw.egl.display, window.context.egl.surface);
}

private void swapIntervalEGL(int interval) {
    _glfw.egl.SwapInterval(_glfw.egl.display, interval);
}

private int extensionSupportedEGL(const(char)* extension) {
    const(char)* extensions = _glfw.egl.QueryString(_glfw.egl.display, EGL_EXTENSIONS);
    if (extensions)
    {
        if (_glfwStringInExtensionString(extension, extensions))
            return GLFW_TRUE;
    }

    return GLFW_FALSE;
}

private GLFWglproc getProcAddressEGL(const(char)* procname) {
    auto window = cast(_GLFWwindow*) _glfwPlatformGetTls(&_glfw.contextSlot);

    if (window.context.egl.client)
    {
        GLFWglproc proc = cast(GLFWglproc) _glfw_dlsym(window.context.egl.client,
                                                   procname);
        if (proc)
            return proc;
    }

    return _glfw.egl.GetProcAddress(procname);
}

private void destroyContextEGL(_GLFWwindow* window) {
    // NOTE: Do not unload libGL.so.1 while the X11 display is still open,
    //       as it will make XCloseDisplay segfault
    version(linux) {
        const bool condition = window.context.client != GLFW_OPENGL_API;
    } else {
        const bool condition = true;
    }
    if (condition)
    {
        if (window.context.egl.client)
        {
            _glfw_dlclose(window.context.egl.client);
            window.context.egl.client = null;
        }
    }

    if (window.context.egl.surface)
    {
        _glfw.egl.DestroySurface(_glfw.egl.display, window.context.egl.surface);
        window.context.egl.surface = EGL_NO_SURFACE;
    }

    if (window.context.egl.handle)
    {
        _glfw.egl.DestroyContext(_glfw.egl.display, window.context.egl.handle);
        window.context.egl.handle = EGL_NO_CONTEXT;
    }
}


//////////////////////////////////////////////////////////////////////////
//////                       GLFW internal API                      //////
//////////////////////////////////////////////////////////////////////////

// Initialize EGL
//
GLFWbool _glfwInitEGL() {
    int i;
    version(Windows) {
        static immutable char*[] sonames = ["libEGL.dll", "EGL.dll", null];
    } else version(OSX) {
        static immutable char*[] sonames = ["libEGL.dylib", null];
    } else version(Cygwin) {
        static immutable char*[] sonames = ["libEGL-1.so", null];
    } else {
        static immutable char*[] sonames = ["libEGL.so.1",null];
    }

    if (_glfw.egl.handle)
        return GLFW_TRUE;

    for (i = 0;  sonames[i];  i++)
    {
        _glfw.egl.handle = _glfw_dlopen(sonames[i]);
        if (_glfw.egl.handle)
            break;
    }

    if (!_glfw.egl.handle)
    {
        _glfwInputError(GLFW_API_UNAVAILABLE, "EGL: Library not found");
        return GLFW_FALSE;
    }

    _glfw.egl.prefix = (strncmp(sonames[i], "lib", 3) == 0);

    _glfw.egl.GetConfigAttrib = cast(PFN_eglGetConfigAttrib)
        _glfw_dlsym(_glfw.egl.handle, "eglGetConfigAttrib");
    _glfw.egl.GetConfigs = cast(PFN_eglGetConfigs)
        _glfw_dlsym(_glfw.egl.handle, "eglGetConfigs");
    _glfw.egl.GetDisplay = cast(PFN_eglGetDisplay)
        _glfw_dlsym(_glfw.egl.handle, "eglGetDisplay");
    _glfw.egl.GetError = cast(PFN_eglGetError)
        _glfw_dlsym(_glfw.egl.handle, "eglGetError");
    _glfw.egl.Initialize = cast(PFN_eglInitialize)
        _glfw_dlsym(_glfw.egl.handle, "eglInitialize");
    _glfw.egl.Terminate = cast(PFN_eglTerminate)
        _glfw_dlsym(_glfw.egl.handle, "eglTerminate");
    _glfw.egl.BindAPI = cast(PFN_eglBindAPI)
        _glfw_dlsym(_glfw.egl.handle, "eglBindAPI");
    _glfw.egl.CreateContext = cast(PFN_eglCreateContext)
        _glfw_dlsym(_glfw.egl.handle, "eglCreateContext");
    _glfw.egl.DestroySurface = cast(PFN_eglDestroySurface)
        _glfw_dlsym(_glfw.egl.handle, "eglDestroySurface");
    _glfw.egl.DestroyContext = cast(PFN_eglDestroyContext)
        _glfw_dlsym(_glfw.egl.handle, "eglDestroyContext");
    _glfw.egl.CreateWindowSurface = cast(PFN_eglCreateWindowSurface)
        _glfw_dlsym(_glfw.egl.handle, "eglCreateWindowSurface");
    _glfw.egl.MakeCurrent = cast(PFN_eglMakeCurrent)
        _glfw_dlsym(_glfw.egl.handle, "eglMakeCurrent");
    _glfw.egl.SwapBuffers = cast(PFN_eglSwapBuffers)
        _glfw_dlsym(_glfw.egl.handle, "eglSwapBuffers");
    _glfw.egl.SwapInterval = cast(PFN_eglSwapInterval)
        _glfw_dlsym(_glfw.egl.handle, "eglSwapInterval");
    _glfw.egl.QueryString = cast(PFN_eglQueryString)
        _glfw_dlsym(_glfw.egl.handle, "eglQueryString");
    _glfw.egl.GetProcAddress = cast(PFN_eglGetProcAddress)
        _glfw_dlsym(_glfw.egl.handle, "eglGetProcAddress");

    if (!_glfw.egl.GetConfigAttrib ||
        !_glfw.egl.GetConfigs ||
        !_glfw.egl.GetDisplay ||
        !_glfw.egl.GetError ||
        !_glfw.egl.Initialize ||
        !_glfw.egl.Terminate ||
        !_glfw.egl.BindAPI ||
        !_glfw.egl.CreateContext ||
        !_glfw.egl.DestroySurface ||
        !_glfw.egl.DestroyContext ||
        !_glfw.egl.CreateWindowSurface ||
        !_glfw.egl.MakeCurrent ||
        !_glfw.egl.SwapBuffers ||
        !_glfw.egl.SwapInterval ||
        !_glfw.egl.QueryString ||
        !_glfw.egl.GetProcAddress)
    {
        _glfwInputError(GLFW_PLATFORM_ERROR,
                        "EGL: Failed to load required entry points");

        _glfwTerminateEGL();
        return GLFW_FALSE;
    }

    _glfw.egl.display = _glfw.egl.GetDisplay(mixin(_GLFW_EGL_NATIVE_DISPLAY));
    if (_glfw.egl.display == EGL_NO_DISPLAY)
    {
        _glfwInputError(GLFW_API_UNAVAILABLE,
                        "EGL: Failed to get EGL display: %s",
                        getEGLErrorString(_glfw.egl.GetError()));

        _glfwTerminateEGL();
        return GLFW_FALSE;
    }

    if (!_glfw.egl.Initialize(_glfw.egl.display, &_glfw.egl.major, &_glfw.egl.minor))
    {
        _glfwInputError(GLFW_API_UNAVAILABLE,
                        "EGL: Failed to initialize EGL: %s",
                        getEGLErrorString(_glfw.egl.GetError()));

        _glfwTerminateEGL();
        return GLFW_FALSE;
    }

    _glfw.egl.KHR_create_context =
        extensionSupportedEGL("EGL_KHR_create_context");
    _glfw.egl.KHR_create_context_no_error =
        extensionSupportedEGL("EGL_KHR_create_context_no_error");
    _glfw.egl.KHR_gl_colorspace =
        extensionSupportedEGL("EGL_KHR_gl_colorspace");
    _glfw.egl.KHR_get_all_proc_addresses =
        extensionSupportedEGL("EGL_KHR_get_all_proc_addresses");
    _glfw.egl.KHR_context_flush_control =
        extensionSupportedEGL("EGL_KHR_context_flush_control");

    return GLFW_TRUE;
}

// Terminate EGL
//
void _glfwTerminateEGL() {
    if (_glfw.egl.display)
    {
        _glfw.egl.Terminate(_glfw.egl.display);
        _glfw.egl.display = EGL_NO_DISPLAY;
    }

    if (_glfw.egl.handle)
    {
        _glfw_dlclose(_glfw.egl.handle);
        _glfw.egl.handle = null;
    }
}


// Create the OpenGL or OpenGL ES context
//
GLFWbool _glfwCreateContextEGL(_GLFWwindow* window, const(_GLFWctxconfig)* ctxconfig, const(_GLFWfbconfig)* fbconfig) {
    EGLint[40] attribs;
    int index = 0;
    void setAttrib(EGLint a, EGLint v) {
        assert((cast(size_t) index + 1) < attribs.length);
        attribs[index++] = a;
        attribs[index++] = v;
    }
    EGLConfig config;
    EGLContext share = null;

    if (!_glfw.egl.display)
    {
        _glfwInputError(GLFW_API_UNAVAILABLE, "EGL: API not available");
        return GLFW_FALSE;
    }

    if (ctxconfig.share)
        share = cast(void*) ctxconfig.share.context.egl.handle;

    if (!chooseEGLConfig(ctxconfig, fbconfig, &config))
    {
        _glfwInputError(GLFW_FORMAT_UNAVAILABLE,
                        "EGL: Failed to find a suitable EGLConfig");
        return GLFW_FALSE;
    }

    if (ctxconfig.client == GLFW_OPENGL_ES_API)
    {
        if (!_glfw.egl.BindAPI(EGL_OPENGL_ES_API))
        {
            _glfwInputError(GLFW_API_UNAVAILABLE,
                            "EGL: Failed to bind OpenGL ES: %s",
                            getEGLErrorString(_glfw.egl.GetError()));
            return GLFW_FALSE;
        }
    }
    else
    {
        if (!_glfw.egl.BindAPI(EGL_OPENGL_API))
        {
            _glfwInputError(GLFW_API_UNAVAILABLE,
                            "EGL: Failed to bind OpenGL: %s",
                            getEGLErrorString(_glfw.egl.GetError()));
            return GLFW_FALSE;
        }
    }

    if (_glfw.egl.KHR_create_context)
    {
        int mask = 0;int flags = 0;

        if (ctxconfig.client == GLFW_OPENGL_API)
        {
            if (ctxconfig.forward)
                flags |= EGL_CONTEXT_OPENGL_FORWARD_COMPATIBLE_BIT_KHR;

            if (ctxconfig.profile == GLFW_OPENGL_CORE_PROFILE)
                mask |= EGL_CONTEXT_OPENGL_CORE_PROFILE_BIT_KHR;
            else if (ctxconfig.profile == GLFW_OPENGL_COMPAT_PROFILE)
                mask |= EGL_CONTEXT_OPENGL_COMPATIBILITY_PROFILE_BIT_KHR;
        }

        if (ctxconfig.debug_)
            flags |= EGL_CONTEXT_OPENGL_DEBUG_BIT_KHR;

        if (ctxconfig.robustness)
        {
            if (ctxconfig.robustness == GLFW_NO_RESET_NOTIFICATION)
            {
                setAttrib(EGL_CONTEXT_OPENGL_RESET_NOTIFICATION_STRATEGY_KHR,
                          EGL_NO_RESET_NOTIFICATION_KHR);
            }
            else if (ctxconfig.robustness == GLFW_LOSE_CONTEXT_ON_RESET)
            {
                setAttrib(EGL_CONTEXT_OPENGL_RESET_NOTIFICATION_STRATEGY_KHR,
                          EGL_LOSE_CONTEXT_ON_RESET_KHR);
            }

            flags |= EGL_CONTEXT_OPENGL_ROBUST_ACCESS_BIT_KHR;
        }

        if (ctxconfig.noerror)
        {
            if (_glfw.egl.KHR_create_context_no_error)
                setAttrib(EGL_CONTEXT_OPENGL_NO_ERROR_KHR, GLFW_TRUE);
        }

        if (ctxconfig.major != 1 || ctxconfig.minor != 0)
        {
            setAttrib(EGL_CONTEXT_MAJOR_VERSION_KHR, ctxconfig.major);
            setAttrib(EGL_CONTEXT_MINOR_VERSION_KHR, ctxconfig.minor);
        }

        if (mask)
            setAttrib(EGL_CONTEXT_OPENGL_PROFILE_MASK_KHR, mask);

        if (flags)
            setAttrib(EGL_CONTEXT_FLAGS_KHR, flags);
    }
    else
    {
        if (ctxconfig.client == GLFW_OPENGL_ES_API)
            setAttrib(EGL_CONTEXT_CLIENT_VERSION, ctxconfig.major);
    }

    if (_glfw.egl.KHR_context_flush_control)
    {
        if (ctxconfig.release == GLFW_RELEASE_BEHAVIOR_NONE)
        {
            setAttrib(EGL_CONTEXT_RELEASE_BEHAVIOR_KHR,
                      EGL_CONTEXT_RELEASE_BEHAVIOR_NONE_KHR);
        }
        else if (ctxconfig.release == GLFW_RELEASE_BEHAVIOR_FLUSH)
        {
            setAttrib(EGL_CONTEXT_RELEASE_BEHAVIOR_KHR,
                      EGL_CONTEXT_RELEASE_BEHAVIOR_FLUSH_KHR);
        }
    }

    setAttrib(EGL_NONE, EGL_NONE);

    window.context.egl.handle = _glfw.egl.CreateContext(_glfw.egl.display,
                                                  config, share, attribs.ptr);

    if (window.context.egl.handle == EGL_NO_CONTEXT)
    {
        _glfwInputError(GLFW_VERSION_UNAVAILABLE,
                        "EGL: Failed to create context: %s",
                        getEGLErrorString(_glfw.egl.GetError()));
        return GLFW_FALSE;
    }

    // Set up attributes for surface creation
    {
        index = 0;

        if (fbconfig.sRGB)
        {
            if (_glfw.egl.KHR_gl_colorspace)
                setAttrib(EGL_GL_COLORSPACE_KHR, EGL_GL_COLORSPACE_SRGB_KHR);
        }

        setAttrib(EGL_NONE, EGL_NONE);
    }

    window.context.egl.surface =
        _glfw.egl.CreateWindowSurface(_glfw.egl.display,
                               config,
                               mixin(_GLFW_EGL_NATIVE_WINDOW),
                               attribs.ptr);
    if (window.context.egl.surface == EGL_NO_SURFACE)
    {
        _glfwInputError(GLFW_PLATFORM_ERROR,
                        "EGL: Failed to create window surface: %s",
                        getEGLErrorString(_glfw.egl.GetError()));
        return GLFW_FALSE;
    }

    window.context.egl.config = config;

    // Load the appropriate client library
    if (!_glfw.egl.KHR_get_all_proc_addresses)
    {
        int i;
        const(char*)* sonames;

        version(Windows) {
            static immutable char*[3] es1sonames = ["GLESv1_CM.dll","libGLES_CM.dll", null];
        } else version(OSX) {
            static immutable char*[2] es1sonames = ["libGLESv1_CM.dylib", null];
        } else {
            static immutable char*[3] es1sonames = ["libGLESv1_CM.so.1","libGLES_CM.so.1", null];
        }

        version(Windows) {
            static immutable char*[3] es2sonames = ["GLESv2.dll","libGLESv2.dll", null];
        } else version(OSX) {
            static immutable char*[2] es2sonames = ["libGLESv2.dylib", null];
        } else version(Cygwin) {
            static immutable char*[2] es2sonames = ["libGLESv2-2.so", null];
        } else {
            static immutable char*[2] es2sonames = ["libGLESv2.so.2", null];
        }

        version(Windows) {
            static immutable char*[1] glsonames = [null];
        } else version(OSX) {
            static immutable char*[1] glsonames = [null];
        } else {
            static immutable char*[2] glsonames = ["libGL.so.1", null];
        }

        if (ctxconfig.client == GLFW_OPENGL_ES_API)
        {
            if (ctxconfig.major == 1)
                sonames = es1sonames.ptr;
            else
                sonames = es2sonames.ptr;
        }
        else
            sonames = glsonames.ptr;

        for (i = 0;  sonames[i];  i++)
        {
            // HACK: Match presence of lib prefix to increase chance of finding
            //       a matching pair in the jungle that is Win32 EGL/GLES
            if (_glfw.egl.prefix != (strncmp(sonames[i], "lib", 3) == 0))
                continue;

            window.context.egl.client = _glfw_dlopen(sonames[i]);
            if (window.context.egl.client)
                break;
        }

        if (!window.context.egl.client)
        {
            _glfwInputError(GLFW_API_UNAVAILABLE,
                            "EGL: Failed to load client library");
            return GLFW_FALSE;
        }
    }

    window.context.makeCurrent = &makeContextCurrentEGL;
    window.context.swapBuffers = &swapBuffersEGL;
    window.context.swapInterval = &swapIntervalEGL;
    window.context.extensionSupported = &extensionSupportedEGL;
    window.context.getProcAddress = &getProcAddressEGL;
    window.context.destroy = &destroyContextEGL;

    return GLFW_TRUE;
}

// Returns the Visual and depth of the chosen EGLConfig
//
version(linux) {
GLFWbool _glfwChooseVisualEGL(
    const(_GLFWwndconfig)* wndconfig, const(_GLFWctxconfig)* ctxconfig,
    const(_GLFWfbconfig)* fbconfig, Visual** visual, int* depth
) {
    XVisualInfo* result;
    XVisualInfo desired;
    EGLConfig native;
    EGLint visualID = 0;EGLint count = 0;
    const(int) vimask = VisualScreenMask | VisualIDMask;

    if (!chooseEGLConfig(ctxconfig, fbconfig, &native))
    {
        _glfwInputError(GLFW_FORMAT_UNAVAILABLE,
                        "EGL: Failed to find a suitable EGLConfig");
        return GLFW_FALSE;
    }

    _glfw.egl.GetConfigAttrib(_glfw.egl.display, native,
                       EGL_NATIVE_VISUAL_ID, &visualID);

    desired.screen = _glfw.x11.screen;
    desired.visualid = visualID;

    result = XGetVisualInfo(_glfw.x11.display, vimask, &desired, &count);
    if (!result)
    {
        _glfwInputError(GLFW_PLATFORM_ERROR,
                        "EGL: Failed to retrieve Visual for EGLConfig");
        return GLFW_FALSE;
    }

    *visual = result.visual;
    *depth = result.depth;

    XFree(result);
    return GLFW_TRUE;
}
} // linux


//////////////////////////////////////////////////////////////////////////
//////                        GLFW native API                       //////
//////////////////////////////////////////////////////////////////////////

EGLDisplay glfwGetEGLDisplay() {
    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!("EGL_NO_DISPLAY"));
    return _glfw.egl.display;
}

EGLContext glfwGetEGLContext(GLFWwindow* handle) {
    _GLFWwindow* window = cast(_GLFWwindow*) handle;
    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!("EGL_NO_CONTEXT"));

    if (window.context.client == GLFW_NO_API)
    {
        _glfwInputError(GLFW_NO_WINDOW_CONTEXT, null);
        return EGL_NO_CONTEXT;
    }

    return window.context.egl.handle;
}

EGLSurface glfwGetEGLSurface(GLFWwindow* handle) {
    _GLFWwindow* window = cast(_GLFWwindow*) handle;
    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!("EGL_NO_SURFACE"));

    if (window.context.client == GLFW_NO_API)
    {
        _glfwInputError(GLFW_NO_WINDOW_CONTEXT, null);
        return EGL_NO_SURFACE;
    }

    return window.context.egl.surface;
}
