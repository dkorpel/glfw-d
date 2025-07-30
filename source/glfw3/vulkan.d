/// Translated from C to D
module glfw3.vulkan;

nothrow:
extern(C): __gshared:

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

import core.stdc.assert_;
import core.stdc.string;
import core.stdc.stdlib;

enum _GLFW_FIND_LOADER =    1;
enum _GLFW_REQUIRE_LOADER = 2;


//////////////////////////////////////////////////////////////////////////
//////                       GLFW internal API                      //////
//////////////////////////////////////////////////////////////////////////

GLFWbool _glfwInitVulkan(int mode) {
    VkResult err;
    VkExtensionProperties* ep;
    uint i;uint count;

    if (_glfw.vk.available)
        return GLFW_TRUE;

version(_GLFW_VULKAN_STATIC) {} else {
version(Windows) {
    _glfw.vk.handle = _glfw_dlopen("vulkan-1.dll");
} else version(OSX) {
    _glfw.vk.handle = _glfw_dlopen("libvulkan.1.dylib");
    if (!_glfw.vk.handle)
        _glfw.vk.handle = _glfwLoadLocalVulkanLoaderNS();
} else {
    _glfw.vk.handle = _glfw_dlopen("libvulkan.so.1");
}
    if (!_glfw.vk.handle)
    {
        if (mode == _GLFW_REQUIRE_LOADER)
            _glfwInputError(GLFW_API_UNAVAILABLE, "Vulkan: Loader not found");

        return GLFW_FALSE;
    }

    _glfw.vk.GetInstanceProcAddr = cast(PFN_vkGetInstanceProcAddr)
        _glfw_dlsym(_glfw.vk.handle, "vkGetInstanceProcAddr");
    if (!_glfw.vk.GetInstanceProcAddr)
    {
        _glfwInputError(GLFW_API_UNAVAILABLE,
                        "Vulkan: Loader does not export vkGetInstanceProcAddr");

        _glfwTerminateVulkan();
        return GLFW_FALSE;
    }

    _glfw.vk.EnumerateInstanceExtensionProperties = cast(PFN_vkEnumerateInstanceExtensionProperties)
        _glfw.vk.GetInstanceProcAddr(null, "vkEnumerateInstanceExtensionProperties");
    if (!_glfw.vk.EnumerateInstanceExtensionProperties)
    {
        _glfwInputError(GLFW_API_UNAVAILABLE,
                        "Vulkan: Failed to retrieve vkEnumerateInstanceExtensionProperties");

        _glfwTerminateVulkan();
        return GLFW_FALSE;
    }
} // _GLFW_VULKAN_STATIC

    err = _glfw.vk.EnumerateInstanceExtensionProperties(null, &count, null);
    if (err)
    {
        // NOTE: This happens on systems with a loader but without any Vulkan ICD
        if (mode == _GLFW_REQUIRE_LOADER)
        {
            _glfwInputError(GLFW_API_UNAVAILABLE,
                            "Vulkan: Failed to query instance extension count: %s",
                            _glfwGetVulkanResultString(err));
        }

        _glfwTerminateVulkan();
        return GLFW_FALSE;
    }

    ep = cast(VkExtensionProperties*) calloc(count, VkExtensionProperties.sizeof);

    err = _glfw.vk.EnumerateInstanceExtensionProperties(null, &count, ep);
    if (err)
    {
        _glfwInputError(GLFW_API_UNAVAILABLE,
                        "Vulkan: Failed to query instance extensions: %s",
                        _glfwGetVulkanResultString(err));

        free(ep);
        _glfwTerminateVulkan();
        return GLFW_FALSE;
    }

    for (i = 0;  i < count;  i++)
    {
        if (strcmp(ep[i].extensionName.ptr, "VK_KHR_surface") == 0) {
            _glfw.vk.KHR_surface = GLFW_TRUE;
        } else {
            version(Windows) {
                if (strcmp(ep[i].extensionName.ptr, "VK_KHR_win32_surface") == 0) {
                    _glfw.vk.KHR_win32_surface = GLFW_TRUE;
                }
            } else version(OSX) {
                if (strcmp(ep[i].extensionName.ptr, "VK_MVK_macos_surface") == 0)
                    _glfw.vk.MVK_macos_surface = GLFW_TRUE;
                else if (strcmp(ep[i].extensionName.ptr, "VK_EXT_metal_surface") == 0)
                    _glfw.vk.EXT_metal_surface = GLFW_TRUE;
            } else version(_GLFW_WAYLAND) {
                if (strcmp(ep[i].extensionName.ptr, "VK_KHR_wayland_surface") == 0)
                    _glfw.vk.KHR_wayland_surface = GLFW_TRUE;
            } else version(linux) {
                if (strcmp(ep[i].extensionName.ptr, "VK_KHR_xlib_surface") == 0)
                    _glfw.vk.KHR_xlib_surface = GLFW_TRUE;
                else if (strcmp(ep[i].extensionName.ptr, "VK_KHR_xcb_surface") == 0)
                    _glfw.vk.KHR_xcb_surface = GLFW_TRUE;
            }
        }
    }

    free(ep);

    _glfw.vk.available = GLFW_TRUE;

    _glfwPlatformGetRequiredInstanceExtensions(_glfw.vk.extensions.ptr);

    return GLFW_TRUE;
}

void _glfwTerminateVulkan() {
version(_GLFW_VULKAN_STATIC) {} else {
    if (_glfw.vk.handle)
        _glfw_dlclose(_glfw.vk.handle);
}
}

const(char)* _glfwGetVulkanResultString(VkResult result) {
    switch (result)
    {
        case VkResult.VK_SUCCESS:
            return "Success";
        case VkResult.VK_NOT_READY:
            return "A fence or query has not yet completed";
        case VkResult.VK_TIMEOUT:
            return "A wait operation has not completed in the specified time";
        case VkResult.VK_EVENT_SET:
            return "An event is signaled";
        case VkResult.VK_EVENT_RESET:
            return "An event is unsignaled";
        case VkResult.VK_INCOMPLETE:
            return "A return array was too small for the result";
        case VkResult.VK_ERROR_OUT_OF_HOST_MEMORY:
            return "A host memory allocation has failed";
        case VkResult.VK_ERROR_OUT_OF_DEVICE_MEMORY:
            return "A device memory allocation has failed";
        case VkResult.VK_ERROR_INITIALIZATION_FAILED:
            return "Initialization of an object could not be completed for implementation-specific reasons";
        case VkResult.VK_ERROR_DEVICE_LOST:
            return "The logical or physical device has been lost";
        case VkResult.VK_ERROR_MEMORY_MAP_FAILED:
            return "Mapping of a memory object has failed";
        case VkResult.VK_ERROR_LAYER_NOT_PRESENT:
            return "A requested layer is not present or could not be loaded";
        case VkResult.VK_ERROR_EXTENSION_NOT_PRESENT:
            return "A requested extension is not supported";
        case VkResult.VK_ERROR_FEATURE_NOT_PRESENT:
            return "A requested feature is not supported";
        case VkResult.VK_ERROR_INCOMPATIBLE_DRIVER:
            return "The requested version of Vulkan is not supported by the driver or is otherwise incompatible";
        case VkResult.VK_ERROR_TOO_MANY_OBJECTS:
            return "Too many objects of the type have already been created";
        case VkResult.VK_ERROR_FORMAT_NOT_SUPPORTED:
            return "A requested format is not supported on this device";
        case VkResult.VK_ERROR_SURFACE_LOST_KHR:
            return "A surface is no longer available";
        case VkResult.VK_SUBOPTIMAL_KHR:
            return "A swapchain no longer matches the surface properties exactly, but can still be used";
        case VkResult.VK_ERROR_OUT_OF_DATE_KHR:
            return "A surface has changed in such a way that it is no longer compatible with the swapchain";
        case VkResult.VK_ERROR_INCOMPATIBLE_DISPLAY_KHR:
            return "The display used by a swapchain does not use the same presentable image layout";
        case VkResult.VK_ERROR_NATIVE_WINDOW_IN_USE_KHR:
            return "The requested window is already connected to a VkSurfaceKHR, or to some other non-Vulkan API";
        case VkResult.VK_ERROR_VALIDATION_FAILED_EXT:
            return "A validation layer found an error";
        default:
            return "ERROR: UNKNOWN VULKAN ERROR";
    }
}


//////////////////////////////////////////////////////////////////////////
//////                        GLFW public API                       //////
//////////////////////////////////////////////////////////////////////////

int glfwVulkanSupported() {
    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"GLFW_FALSE");
    return _glfwInitVulkan(_GLFW_FIND_LOADER);
}

const(char)** glfwGetRequiredInstanceExtensions(uint* count) {
    assert(count != null);

    *count = 0;

    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"null");

    if (!_glfwInitVulkan(_GLFW_REQUIRE_LOADER))
        return null;

    if (!_glfw.vk.extensions[0])
        return null;

    *count = 2;
    return cast(const(char)**) _glfw.vk.extensions;
}

GLFWvkproc glfwGetInstanceProcAddress(VkInstance instance, const(char)* procname) {
    GLFWvkproc proc;
    assert(procname != null);

    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"null");

    if (!_glfwInitVulkan(_GLFW_REQUIRE_LOADER))
        return null;

    proc = cast(GLFWvkproc) _glfw.vk.GetInstanceProcAddr(instance, procname);
version(_GLFW_VULKAN_STATIC) {
    if (!proc)
    {
        if (strcmp(procname, "vkGetInstanceProcAddr") == 0)
            return cast(GLFWvkproc) vkGetInstanceProcAddr;
    }
} else {
    if (!proc)
        proc = cast(GLFWvkproc) _glfw_dlsym(_glfw.vk.handle, procname);
}

    return proc;
}

int glfwGetPhysicalDevicePresentationSupport(VkInstance instance, VkPhysicalDevice device, uint queuefamily) {
    assert(instance != null);
    assert(device != null);

    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"GLFW_FALSE");

    if (!_glfwInitVulkan(_GLFW_REQUIRE_LOADER))
        return GLFW_FALSE;

    if (!_glfw.vk.extensions[0])
    {
        _glfwInputError(GLFW_API_UNAVAILABLE,
                        "Vulkan: Window surface creation extensions not found");
        return GLFW_FALSE;
    }

    return _glfwPlatformGetPhysicalDevicePresentationSupport(instance,
                                                             device,
                                                             queuefamily);
}

VkResult glfwCreateWindowSurface(VkInstance instance, GLFWwindow* handle, const(VkAllocationCallbacks)* allocator, VkSurfaceKHR* surface) {
    _GLFWwindow* window = cast(_GLFWwindow*) handle;
    assert(instance != null);
    assert(window != null);
    assert(surface != null);

    *surface = VK_NULL_HANDLE;

    mixin(_GLFW_REQUIRE_INIT_OR_RETURN!"VkResult.VK_ERROR_INITIALIZATION_FAILED");

    if (!_glfwInitVulkan(_GLFW_REQUIRE_LOADER))
        return VkResult.VK_ERROR_INITIALIZATION_FAILED;

    if (!_glfw.vk.extensions[0])
    {
        _glfwInputError(GLFW_API_UNAVAILABLE,
                        "Vulkan: Window surface creation extensions not found");
        return VkResult.VK_ERROR_EXTENSION_NOT_PRESENT;
    }

    if (window.context.client != GLFW_NO_API)
    {
        _glfwInputError(GLFW_INVALID_VALUE,
                        "Vulkan: Window surface creation requires the window to have the client API set to GLFW_NO_API");
        return VkResult.VK_ERROR_NATIVE_WINDOW_IN_USE_KHR;
    }

    return _glfwPlatformCreateWindowSurface(instance, window, allocator, surface);
}
