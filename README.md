# GLFW-D
A translation from C to D of [GLFW](https://github.com/glfw/glfw) version 3.3.2 ([commit 0a49ef0](https://github.com/glfw/glfw/commit/0a49ef0a00baa3ab520ddc452f0e3b1e099c5589)).

GLFW is a multi-platform library for OpenGL, OpenGL ES, Vulkan, window and input.
(See also: [what is GLFW](https://www.glfw.org/faq.html#11---what-is-glfw))

GLFW has 5 targets, but currently only three are availabe in this translation.

| GLFW Target                                                                    | Translated | Primarily used for       |
|--------------------------------------------------------------------------------|------------|--------------------------|
| Win32                                                                          | ✔️ Yes     | Windows                  |
| [X11](https://en.wikipedia.org/wiki/X_Window_System)                           | ✔️ Yes     | Linux (older)            |
| [Cocoa](https://en.wikipedia.org/wiki/Cocoa_(API))                             | ❌ No       | macOS                    |
| [Wayland](https://en.wikipedia.org/wiki/Wayland_%28display_server_protocol%29) | ❌ No       | Linux (newer)            |
| Osmesa                                                                         | ✔️ Yes     | Off-screen rendering (?) |

The translation sticks close to the C source code, so all uses of e.g. `memcpy`, `printf` and pointer arithmetic are intact and not replaced with idiomatic D.
The Doxygen documentation in `glfw.h` and `glfwnative.h` (here `glfw3/api.d` and `glfw3/apinative.d`) is translated to use DDoc `Params:` and `Returns:` sections.

The translation is licensed under the [zlib/libpng license](http://www.glfw.org/license.html) like the original code.
The translation is not affiliated with the original project.

## Basic usage

If you are using dub, add this package as a dependency.
In `dub.sdl`:
```
dependency "glfw-d" version="~>1.1.0"
```
In `dub.json`:
```
"dependencies": {
	"glfw-d": "~>1.1.0"
}
```

Then you should be ready to go.
```D
import glfw3.api;

void main() {
	// call GLFW functions, such as:
	glfwInit();
	glfwTerminate();
}
```
Example GLFW projects can be found in the [examples folder](https://github.com/dkorpel/glfw-d/tree/master/examples/).
You can run them from the root of this repository using:
```
dub run glfw-d:empty-window
dub run glfw-d:triangle-gl
dub run glfw-d:triangle-vulkan
```

See also: the [tutorial on glfw.org](https://www.glfw.org/docs/latest/quick.html) for a quick introduction.

If you have any trouble, feel free to open an [Issue](https://github.com/dkorpel/glfw-d/issues) or [Discussion](https://github.com/dkorpel/glfw-d/discussions).

## Reasons for using it
Using GLFW in your D project usually involves depending on a binding to the C-library, (such as [bindbc-glfw](https://github.com/BindBC/bindbc-glfw) or [derelict-glfw3](https://github.com/DerelictOrg/DerelictGLFW3)).
You'd then include a `glfw3.dll` with your releases for Windows users, and ask Linux users to install glfw using their package manager.
Your application then has to call a function that loads the function pointers at runtime, and then you check whether that succeeded or whether the shared library was missing or corrupted.

If you statically linked to GLFW, you don't have the hassle of run-time loading: everything you need is in the executable itself.
You could add pre-compiled static libraries to your repository, but you need to have one for each combination of settings you want: Windows / Linux, 32-bit / 64-bit, debug / release, etc.
You also need to make sure to link the correct C runtime library (e.g. `libcmt.lib` / `msvcrt.dll`).
It's very easy for issues to arise:
- [linker warnings and errors with bindbc-glfw](https://forum.dlang.org/post/sfihgdqopuwkqsvpsvos@forum.dlang.org)
- [Static link of glfw3 library fails for me](https://forum.dlang.org/post/vhttrhodifisvtgsrizz@forum.dlang.org)

With this translation, you can simply use Dub, and your D compiler settings (C runtime, optimization flags, debug info) also apply to GLFW.

Compile times are pretty short.
I get these results from the 'total' time of `time dub build glfw-d --force` on my Debian Linux box:

| build type   | time (s) |
|--------------|----------|
| dmd debug    | 0.5      |
| dmd release  | 1.1      |
| ldc2 debug   | 1.0      |
| ldc2 release | 2.7      |

Dub caches builds, so these compile times only apply the first time.

### Disadvantages
- The C sources are more battle-tested.
There is a chance the translation introduced new bugs.
- While GLFW is pretty stable, it is still being maintained by a group of contributors and new releases with new features and fixes come out.
Once GLFW 3.4 comes out, this translation might get behind.
However, you can easily switch back to compiling the C sources if this becomes an issue.

### Todo
- Thoroughly test on platforms
So far I used this library for my own OpenGL application and succesfully ran it on Debian Linux with X11 and Windows 7, but there are aspects that are not yet tested.
I have not used this with OpenGL ES.
I haven't used the native api (`glfw3/apinative.d` here) or functions for custom cursor creation yet.

- Add Wayland support
This platform needs to be translated still.

- Add Cocoa support.
This is low priority though since I don't have a computer that runs macOS and have little personal interest in this platform.

## Advanced usage

### Adding glfw-d to an existing D application using GLFW
If you are already using different static bindings to GLFW (e.g. [bindbc-glfw](https://code.dlang.org/packages/bindbc-glfw) with `BindGLFW_Static`), you can still use those with this package:
You don't have to change `import bindbc.glfw;` to `import glfw3.api;`.
Simply add the dependency to glfw-d and remove the linkage with the C library from `libs`, `sourceFiles` or `lflags` in your dub file.

### Configurations
Dub should automatically pick a configuration based on your operating system.
If you are on Linux but don't want to use the x11 target, you can e.g. add to your `dub.sdl`:
```
subConfiguration "glfw-d" "osmesa"
```
Or `dub.json`:
```
"subConfigurations": {
	"glfw-d": "osmesa"
}
```

To expose the native API, set the appropriate version identifiers.
The available window API versions are:
- `GLFW_EXPOSE_NATIVE_WIN32`
- `GLFW_EXPOSE_NATIVE_COCOA`
- `GLFW_EXPOSE_NATIVE_X11`
- `GLFW_EXPOSE_NATIVE_WAYLAND`

The available context API versions are:
- `GLFW_EXPOSE_NATIVE_WGL`
- `GLFW_EXPOSE_NATIVE_NSGL`
- `GLFW_EXPOSE_NATIVE_GLX`
- `GLFW_EXPOSE_NATIVE_EGL`
- `GLFW_EXPOSE_NATIVE_OSMESA`

Example `dub.sdl`:
```
versions "GLFW_EXPOSE_NATIVE_WIN32" "GLFW_EXPOSE_NATIVE_WGL"
```

`dub.json`:
```
"versions": ["GLFW_EXPOSE_NATIVE_WIN32", "GLFW_EXPOSE_NATIVE_WGL"]
```

### Compiling manually
If you don't want to use dub, it is not hard to compile it manually since all source files you need are in a single folder: `source/glfw3`.
Look in `dub.sdl` which source files and version identifier your desired platform uses, then pass them to a D compiler:
```
# From the root of this repository, enter the source folder
cd source/glfw3

# Windows example:
dmd -version=_GLFW_WIN32 -I../ -m64 -lib -of=../../build/glfw.lib context.d init.d input.d monitor.d vulkan.d window.d mappings.d internal.d api.d win32_platform.d win32_init.d win32_joystick.d win32_monitor.d win32_time.d win32_thread.d win32_window.d wgl_context.d egl_context.d osmesa_context.d directinput8.d

# Linux example:
dmd -version=_GLFW_X11 -L=X11 -I../ -lib -of=../../build/glfw.a context.d init.d input.d monitor.d vulkan.d window.d mappings.d internal.d api.d x11_platform.d x11_init.d x11_monitor.d x11_window.d xkb_unicode.d posix_time.d posix_thread.d glx_context.d egl_context.d osmesa_context.d linux_joystick.d linuxinput.d
```

### BetterC
Since it's a direct translation of a C codebase, it compiles [with `-betterC`](https://dlang.org/spec/betterc.html), but there might be linking errors because of certain C macros that are functions in druntime, such as:
```
core.sys.posix.sys.select.FD_SET
core.sys.posix.sys.select.FD_ZERO
```
This might or might not give linker errors in your application, depending on your compiler and settings.

## Building a shared library DLL
Building a shared library from the D sources could be possible, but it's not a supported use-case currently.
You're welcome to try it, but I can't guide you here.
