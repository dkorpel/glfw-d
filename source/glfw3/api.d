/**
 * The cross-platform GLFW 3 API, translated from `glfw3.h`
 *
 * This is the header file of the GLFW 3 API.
 * It defines all types and functions that are used on all platforms.
 * For platform-specific public definitions, refer to `glfw3.apinative`.
 */
module glfw3.api;

@nogc nothrow:
extern(C): __gshared:

/*************************************************************************
 * GLFW 3.3 - www.glfw.org
 * A library for OpenGL, window and input
 *------------------------------------------------------------------------
 * Copyright (c) 2002-2006 Marcus Geelnard
 * Copyright (c) 2006-2019 Camilla Löwy <elmindreda@glfw.org>
 *
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would
 *    be appreciated but is not required.
 *
 * 2. Altered source versions must be plainly marked as such, and must not
 *    be misrepresented as being the original software.
 *
 * 3. This notice may not be removed or altered from any source
 *    distribution.
 *
 *************************************************************************/

/** @defgroup context Context reference
 *  Functions and types related to OpenGL and OpenGL ES contexts.
 *
 *  This is the reference documentation for OpenGL and OpenGL ES context related
 *  functions.  For more task-oriented information, see the @ref context_guide.
 */
/** @defgroup vulkan Vulkan reference
 *  Functions and types related to Vulkan.
 *
 *  This is the reference documentation for Vulkan related functions and types.
 *  For more task-oriented information, see the @ref vulkan_guide.
 */
/** @defgroup init Initialization, version and error reference
 *  Functions and types related to initialization and error handling.
 *
 *  This is the reference documentation for initialization and termination of
 *  the library, version management and error handling.  For more task-oriented
 *  information, see the @ref intro_guide.
 */
/** @defgroup input Input reference
 *  Functions and types related to input handling.
 *
 *  This is the reference documentation for input related functions and types.
 *  For more task-oriented information, see the @ref input_guide.
 */
/** @defgroup monitor Monitor reference
 *  Functions and types related to monitors.
 *
 *  This is the reference documentation for monitor related functions and types.
 *  For more task-oriented information, see the @ref monitor_guide.
 */
/** @defgroup window Window reference
 *  Functions and types related to windows.
 *
 *  This is the reference documentation for window related functions and types,
 *  including creation, deletion and event polling.  For more task-oriented
 *  information, see the @ref window_guide.
 */


/*************************************************************************
 * Compiler- and platform-specific preprocessor work
 *************************************************************************/

/* Include because most Windows GLU headers need wchar_t and
 * the macOS OpenGL header blocks the definition of ptrdiff_t by glext.h.
 * Include it unconditionally to avoid surprising side-effects.
 */
import core.stdc.stddef;

/* Include because it is needed by Vulkan and related functions.
 * Include it unconditionally to avoid surprising side-effects.
 */
import core.stdc.stdint;

/*************************************************************************
 * GLFW API tokens
 *************************************************************************/

/** @name GLFW version macros
 *  @{ */
/** The major version number of the GLFW library.
 *
 *  This is incremented when the API is changed in non-compatible ways.
 *  Ingroup: init
 */
enum GLFW_VERSION_MAJOR =          3;
/** The minor version number of the GLFW library.
 *
 *  This is incremented when features are added to the API but it remains
 *  backward-compatible.
 *  Ingroup: init
 */
enum GLFW_VERSION_MINOR =          3;
/** The revision number of the GLFW library.
 *
 *  This is incremented when a bug fix release is made that does not contain any
 *  API changes.
 *  Ingroup: init
 */
enum GLFW_VERSION_REVISION =       2;
/** @} */

/** One.
 *
 *  This is only semantic sugar for the number 1.  You can instead use `1` or
 *  `true` or `_True` or `GL_TRUE` or `VK_TRUE` or anything else that is equal
 *  to one.
 *
 *  Ingroup: init
 */
enum GLFW_TRUE =                   1;
/** Zero.
 *
 *  This is only semantic sugar for the number 0.  You can instead use `0` or
 *  `false` or `_False` or `GL_FALSE` or `VK_FALSE` or anything else that is
 *  equal to zero.
 *
 *  Ingroup: init
 */
enum GLFW_FALSE =                  0;

/** @name Key and button actions
 *  @{ */
/** The key or mouse button was released.
 *
 *  The key or mouse button was released.
 *
 *  Ingroup: input
 */
enum GLFW_RELEASE =                0;
/** The key or mouse button was pressed.
 *
 *  The key or mouse button was pressed.
 *
 *  Ingroup: input
 */
enum GLFW_PRESS =                  1;
/** The key was held down until it repeated.
 *
 *  The key was held down until it repeated.
 *
 *  Ingroup: input
 */
enum GLFW_REPEAT =                 2;
/** @} */

/** @defgroup hat_state Joystick hat states
 *  Joystick hat states.
 *
 *  See [joystick hat input](@ref joystick_hat) for how these are used.
 *
 *  Ingroup: input
 *  @{ */
enum GLFW_HAT_CENTERED =           0;
enum GLFW_HAT_UP =                 1;
enum GLFW_HAT_RIGHT =              2;
enum GLFW_HAT_DOWN =               4;
enum GLFW_HAT_LEFT =               8;
enum GLFW_HAT_RIGHT_UP =           (GLFW_HAT_RIGHT | GLFW_HAT_UP);
enum GLFW_HAT_RIGHT_DOWN =         (GLFW_HAT_RIGHT | GLFW_HAT_DOWN);
enum GLFW_HAT_LEFT_UP =            (GLFW_HAT_LEFT  | GLFW_HAT_UP);
enum GLFW_HAT_LEFT_DOWN =          (GLFW_HAT_LEFT  | GLFW_HAT_DOWN);
/** @} */

/** @defgroup keys Keyboard keys
 *  Keyboard key IDs.
 *
 *  See [key input](@ref input_key) for how these are used.
 *
 *  These key codes are inspired by the _USB HID Usage Tables v1.12_ (p. 53-60),
 *  but re-arranged to map to 7-bit ASCII for printable keys (function keys are
 *  put in the 256+ range).
 *
 *  The naming of the key codes follow these rules:
 *   - The US keyboard layout is used
 *   - Names of printable alpha-numeric characters are used (e.g. "A", "R",
 *     "3", etc.)
 *   - For non-alphanumeric characters, Unicode:ish names are used (e.g.
 *     "COMMA", "LEFT_SQUARE_BRACKET", etc.). Note that some names do not
 *     correspond to the Unicode standard (usually for brevity)
 *   - Keys that lack a clear US mapping are named "WORLD_x"
 *   - For non-printable keys, custom names are used (e.g. "F4",
 *     "BACKSPACE", etc.)
 *
 *  Ingroup: input
 *  @{
 */

/* The unknown key */
enum GLFW_KEY_UNKNOWN =            -1;

/** Printable keys */
enum GLFW_KEY_SPACE =              32;
enum GLFW_KEY_APOSTROPHE =         39  /* ' */;
enum GLFW_KEY_COMMA =              44  /* , */;
enum GLFW_KEY_MINUS =              45  /* - */;
enum GLFW_KEY_PERIOD =             46  /* . */;
enum GLFW_KEY_SLASH =              47  /* / */;
enum GLFW_KEY_0 =                  48;
enum GLFW_KEY_1 =                  49;
enum GLFW_KEY_2 =                  50;
enum GLFW_KEY_3 =                  51;
enum GLFW_KEY_4 =                  52;
enum GLFW_KEY_5 =                  53;
enum GLFW_KEY_6 =                  54;
enum GLFW_KEY_7 =                  55;
enum GLFW_KEY_8 =                  56;
enum GLFW_KEY_9 =                  57;
enum GLFW_KEY_SEMICOLON =          59  /* ; */;
enum GLFW_KEY_EQUAL =              61  /* = */;
enum GLFW_KEY_A =                  65;
enum GLFW_KEY_B =                  66;
enum GLFW_KEY_C =                  67;
enum GLFW_KEY_D =                  68;
enum GLFW_KEY_E =                  69;
enum GLFW_KEY_F =                  70;
enum GLFW_KEY_G =                  71;
enum GLFW_KEY_H =                  72;
enum GLFW_KEY_I =                  73;
enum GLFW_KEY_J =                  74;
enum GLFW_KEY_K =                  75;
enum GLFW_KEY_L =                  76;
enum GLFW_KEY_M =                  77;
enum GLFW_KEY_N =                  78;
enum GLFW_KEY_O =                  79;
enum GLFW_KEY_P =                  80;
enum GLFW_KEY_Q =                  81;
enum GLFW_KEY_R =                  82;
enum GLFW_KEY_S =                  83;
enum GLFW_KEY_T =                  84;
enum GLFW_KEY_U =                  85;
enum GLFW_KEY_V =                  86;
enum GLFW_KEY_W =                  87;
enum GLFW_KEY_X =                  88;
enum GLFW_KEY_Y =                  89;
enum GLFW_KEY_Z =                  90;
enum GLFW_KEY_LEFT_BRACKET =       91  /* [ */;
enum GLFW_KEY_BACKSLASH =          92  /* \ */;
enum GLFW_KEY_RIGHT_BRACKET =      93  /* ] */;
enum GLFW_KEY_GRAVE_ACCENT =       96  /* ` */;
enum GLFW_KEY_WORLD_1 =            161 /* non-US #1 */;
enum GLFW_KEY_WORLD_2 =            162 /* non-US #2 */;

/* Function keys */
enum GLFW_KEY_ESCAPE =             256;
enum GLFW_KEY_ENTER =              257;
enum GLFW_KEY_TAB =                258;
enum GLFW_KEY_BACKSPACE =          259;
enum GLFW_KEY_INSERT =             260;
enum GLFW_KEY_DELETE =             261;
enum GLFW_KEY_RIGHT =              262;
enum GLFW_KEY_LEFT =               263;
enum GLFW_KEY_DOWN =               264;
enum GLFW_KEY_UP =                 265;
enum GLFW_KEY_PAGE_UP =            266;
enum GLFW_KEY_PAGE_DOWN =          267;
enum GLFW_KEY_HOME =               268;
enum GLFW_KEY_END =                269;
enum GLFW_KEY_CAPS_LOCK =          280;
enum GLFW_KEY_SCROLL_LOCK =        281;
enum GLFW_KEY_NUM_LOCK =           282;
enum GLFW_KEY_PRINT_SCREEN =       283;
enum GLFW_KEY_PAUSE =              284;
enum GLFW_KEY_F1 =                 290;
enum GLFW_KEY_F2 =                 291;
enum GLFW_KEY_F3 =                 292;
enum GLFW_KEY_F4 =                 293;
enum GLFW_KEY_F5 =                 294;
enum GLFW_KEY_F6 =                 295;
enum GLFW_KEY_F7 =                 296;
enum GLFW_KEY_F8 =                 297;
enum GLFW_KEY_F9 =                 298;
enum GLFW_KEY_F10 =                299;
enum GLFW_KEY_F11 =                300;
enum GLFW_KEY_F12 =                301;
enum GLFW_KEY_F13 =                302;
enum GLFW_KEY_F14 =                303;
enum GLFW_KEY_F15 =                304;
enum GLFW_KEY_F16 =                305;
enum GLFW_KEY_F17 =                306;
enum GLFW_KEY_F18 =                307;
enum GLFW_KEY_F19 =                308;
enum GLFW_KEY_F20 =                309;
enum GLFW_KEY_F21 =                310;
enum GLFW_KEY_F22 =                311;
enum GLFW_KEY_F23 =                312;
enum GLFW_KEY_F24 =                313;
enum GLFW_KEY_F25 =                314;
enum GLFW_KEY_KP_0 =               320;
enum GLFW_KEY_KP_1 =               321;
enum GLFW_KEY_KP_2 =               322;
enum GLFW_KEY_KP_3 =               323;
enum GLFW_KEY_KP_4 =               324;
enum GLFW_KEY_KP_5 =               325;
enum GLFW_KEY_KP_6 =               326;
enum GLFW_KEY_KP_7 =               327;
enum GLFW_KEY_KP_8 =               328;
enum GLFW_KEY_KP_9 =               329;
enum GLFW_KEY_KP_DECIMAL =         330;
enum GLFW_KEY_KP_DIVIDE =          331;
enum GLFW_KEY_KP_MULTIPLY =        332;
enum GLFW_KEY_KP_SUBTRACT =        333;
enum GLFW_KEY_KP_ADD =             334;
enum GLFW_KEY_KP_ENTER =           335;
enum GLFW_KEY_KP_EQUAL =           336;
enum GLFW_KEY_LEFT_SHIFT =         340;
enum GLFW_KEY_LEFT_CONTROL =       341;
enum GLFW_KEY_LEFT_ALT =           342;
enum GLFW_KEY_LEFT_SUPER =         343;
enum GLFW_KEY_RIGHT_SHIFT =        344;
enum GLFW_KEY_RIGHT_CONTROL =      345;
enum GLFW_KEY_RIGHT_ALT =          346;
enum GLFW_KEY_RIGHT_SUPER =        347;
enum GLFW_KEY_MENU =               348;

enum GLFW_KEY_LAST =               GLFW_KEY_MENU;

/** @} */

/** @defgroup mods Modifier key flags
 *  Modifier key flags.
 *
 *  See [key input](@ref input_key) for how these are used.
 *
 *  Ingroup: input
 *  @{ */

/** If this bit is set one or more Shift keys were held down.
 *
 *  If this bit is set one or more Shift keys were held down.
 */
enum GLFW_MOD_SHIFT =           0x0001;
/** If this bit is set one or more Control keys were held down.
 *
 *  If this bit is set one or more Control keys were held down.
 */
enum GLFW_MOD_CONTROL =         0x0002;
/** If this bit is set one or more Alt keys were held down.
 *
 *  If this bit is set one or more Alt keys were held down.
 */
enum GLFW_MOD_ALT =             0x0004;
/** If this bit is set one or more Super keys were held down.
 *
 *  If this bit is set one or more Super keys were held down.
 */
enum GLFW_MOD_SUPER =           0x0008;
/** If this bit is set the Caps Lock key is enabled.
 *
 *  If this bit is set the Caps Lock key is enabled and the @ref
 *  GLFW_LOCK_KEY_MODS input mode is set.
 */
enum GLFW_MOD_CAPS_LOCK =       0x0010;
/** If this bit is set the Num Lock key is enabled.
 *
 *  If this bit is set the Num Lock key is enabled and the @ref
 *  GLFW_LOCK_KEY_MODS input mode is set.
 */
enum GLFW_MOD_NUM_LOCK =        0x0020;

/** @} */

/** @defgroup buttons Mouse buttons
 *  Mouse button IDs.
 *
 *  See [mouse button input](@ref input_mouse_button) for how these are used.
 *
 *  Ingroup: input
 *  @{ */
enum GLFW_MOUSE_BUTTON_1 =         0;
enum GLFW_MOUSE_BUTTON_2 =         1;
enum GLFW_MOUSE_BUTTON_3 =         2;
enum GLFW_MOUSE_BUTTON_4 =         3;
enum GLFW_MOUSE_BUTTON_5 =         4;
enum GLFW_MOUSE_BUTTON_6 =         5;
enum GLFW_MOUSE_BUTTON_7 =         6;
enum GLFW_MOUSE_BUTTON_8 =         7;
enum GLFW_MOUSE_BUTTON_LAST =      GLFW_MOUSE_BUTTON_8;
enum GLFW_MOUSE_BUTTON_LEFT =      GLFW_MOUSE_BUTTON_1;
enum GLFW_MOUSE_BUTTON_RIGHT =     GLFW_MOUSE_BUTTON_2;
enum GLFW_MOUSE_BUTTON_MIDDLE =    GLFW_MOUSE_BUTTON_3;
/** @} */

/** @defgroup joysticks Joysticks
 *  Joystick IDs.
 *
 *  See [joystick input](@ref joystick) for how these are used.
 *
 *  Ingroup: input
 *  @{ */
enum GLFW_JOYSTICK_1 =             0;
enum GLFW_JOYSTICK_2 =             1;
enum GLFW_JOYSTICK_3 =             2;
enum GLFW_JOYSTICK_4 =             3;
enum GLFW_JOYSTICK_5 =             4;
enum GLFW_JOYSTICK_6 =             5;
enum GLFW_JOYSTICK_7 =             6;
enum GLFW_JOYSTICK_8 =             7;
enum GLFW_JOYSTICK_9 =             8;
enum GLFW_JOYSTICK_10 =            9;
enum GLFW_JOYSTICK_11 =            10;
enum GLFW_JOYSTICK_12 =            11;
enum GLFW_JOYSTICK_13 =            12;
enum GLFW_JOYSTICK_14 =            13;
enum GLFW_JOYSTICK_15 =            14;
enum GLFW_JOYSTICK_16 =            15;
enum GLFW_JOYSTICK_LAST =          GLFW_JOYSTICK_16;
/** @} */

/** @defgroup gamepad_buttons Gamepad buttons
 *  Gamepad buttons.
 *
 *  See @ref gamepad for how these are used.
 *
 *  Ingroup: input
 *  @{ */
enum GLFW_GAMEPAD_BUTTON_A =               0;
enum GLFW_GAMEPAD_BUTTON_B =               1;
enum GLFW_GAMEPAD_BUTTON_X =               2;
enum GLFW_GAMEPAD_BUTTON_Y =               3;
enum GLFW_GAMEPAD_BUTTON_LEFT_BUMPER =     4;
enum GLFW_GAMEPAD_BUTTON_RIGHT_BUMPER =    5;
enum GLFW_GAMEPAD_BUTTON_BACK =            6;
enum GLFW_GAMEPAD_BUTTON_START =           7;
enum GLFW_GAMEPAD_BUTTON_GUIDE =           8;
enum GLFW_GAMEPAD_BUTTON_LEFT_THUMB =      9;
enum GLFW_GAMEPAD_BUTTON_RIGHT_THUMB =     10;
enum GLFW_GAMEPAD_BUTTON_DPAD_UP =         11;
enum GLFW_GAMEPAD_BUTTON_DPAD_RIGHT =      12;
enum GLFW_GAMEPAD_BUTTON_DPAD_DOWN =       13;
enum GLFW_GAMEPAD_BUTTON_DPAD_LEFT =       14;
enum GLFW_GAMEPAD_BUTTON_LAST =            GLFW_GAMEPAD_BUTTON_DPAD_LEFT;

enum GLFW_GAMEPAD_BUTTON_CROSS =       GLFW_GAMEPAD_BUTTON_A;
enum GLFW_GAMEPAD_BUTTON_CIRCLE =      GLFW_GAMEPAD_BUTTON_B;
enum GLFW_GAMEPAD_BUTTON_SQUARE =      GLFW_GAMEPAD_BUTTON_X;
enum GLFW_GAMEPAD_BUTTON_TRIANGLE =    GLFW_GAMEPAD_BUTTON_Y;
/** @} */

/** @defgroup gamepad_axes Gamepad axes
 *  Gamepad axes.
 *
 *  See @ref gamepad for how these are used.
 *
 *  Ingroup: input
 *  @{ */
enum GLFW_GAMEPAD_AXIS_LEFT_X =        0;
enum GLFW_GAMEPAD_AXIS_LEFT_Y =        1;
enum GLFW_GAMEPAD_AXIS_RIGHT_X =       2;
enum GLFW_GAMEPAD_AXIS_RIGHT_Y =       3;
enum GLFW_GAMEPAD_AXIS_LEFT_TRIGGER =  4;
enum GLFW_GAMEPAD_AXIS_RIGHT_TRIGGER = 5;
enum GLFW_GAMEPAD_AXIS_LAST =          GLFW_GAMEPAD_AXIS_RIGHT_TRIGGER;
/** @} */

/** @defgroup errors Error codes
 *  Error codes.
 *
 *  See [error handling](@ref error_handling) for how these are used.
 *
 *  Ingroup: init
 *  @{ */
/** No error has occurred.
 *
 *  No error has occurred.
 *
 *  @analysis Yay.
 */
enum GLFW_NO_ERROR =               0;
/** GLFW has not been initialized.
 *
 *  This occurs if a GLFW function was called that must not be called unless the
 *  library is [initialized](@ref intro_init).
 *
 *  @analysis Application programmer error.  Initialize GLFW before calling any
 *  function that requires initialization.
 */
enum GLFW_NOT_INITIALIZED =        0x00010001;
/** No context is current for this thread.
 *
 *  This occurs if a GLFW function was called that needs and operates on the
 *  current OpenGL or OpenGL ES context but no context is current on the calling
 *  thread.  One such function is @ref glfwSwapInterval.
 *
 *  @analysis Application programmer error.  Ensure a context is current before
 *  calling functions that require a current context.
 */
enum GLFW_NO_CURRENT_CONTEXT =     0x00010002;
/** One of the arguments to the function was an invalid enum value.
 *
 *  One of the arguments to the function was an invalid enum value, for example
 *  requesting @ref GLFW_RED_BITS with @ref glfwGetWindowAttrib.
 *
 *  @analysis Application programmer error.  Fix the offending call.
 */
enum GLFW_INVALID_ENUM =           0x00010003;
/** One of the arguments to the function was an invalid value.
 *
 *  One of the arguments to the function was an invalid value, for example
 *  requesting a non-existent OpenGL or OpenGL ES version like 2.7.
 *
 *  Requesting a valid but unavailable OpenGL or OpenGL ES version will instead
 *  result in a @ref GLFW_VERSION_UNAVAILABLE error.
 *
 *  @analysis Application programmer error.  Fix the offending call.
 */
enum GLFW_INVALID_VALUE =          0x00010004;
/** A memory allocation failed.
 *
 *  A memory allocation failed.
 *
 *  @analysis A bug in GLFW or the underlying operating system.  Report the bug
 *  to our [issue tracker](https://github.com/glfw/glfw/issues).
 */
enum GLFW_OUT_OF_MEMORY =          0x00010005;
/** GLFW could not find support for the requested API on the system.
 *
 *  GLFW could not find support for the requested API on the system.
 *
 *  @analysis The installed graphics driver does not support the requested
 *  API, or does not support it via the chosen context creation backend.
 *  Below are a few examples.
 *
 *  @par
 *  Some pre-installed Windows graphics drivers do not support OpenGL.  AMD only
 *  supports OpenGL ES via EGL, while Nvidia and Intel only support it via
 *  a WGL or GLX extension.  macOS does not provide OpenGL ES at all.  The Mesa
 *  EGL, OpenGL and OpenGL ES libraries do not interface with the Nvidia binary
 *  driver.  Older graphics drivers do not support Vulkan.
 */
enum GLFW_API_UNAVAILABLE =        0x00010006;
/** The requested OpenGL or OpenGL ES version is not available.
 *
 *  The requested OpenGL or OpenGL ES version (including any requested context
 *  or framebuffer hints) is not available on this machine.
 *
 *  @analysis The machine does not support your requirements.  If your
 *  application is sufficiently flexible, downgrade your requirements and try
 *  again.  Otherwise, inform the user that their machine does not match your
 *  requirements.
 *
 *  @par
 *  Future invalid OpenGL and OpenGL ES versions, for example OpenGL 4.8 if 5.0
 *  comes out before the 4.x series gets that far, also fail with this error and
 *  not @ref GLFW_INVALID_VALUE, because GLFW cannot know what future versions
 *  will exist.
 */
enum GLFW_VERSION_UNAVAILABLE =    0x00010007;
/** A platform-specific error occurred that does not match any of the
 *  more specific categories.
 *
 *  A platform-specific error occurred that does not match any of the more
 *  specific categories.
 *
 *  @analysis A bug or configuration error in GLFW, the underlying operating
 *  system or its drivers, or a lack of required resources.  Report the issue to
 *  our [issue tracker](https://github.com/glfw/glfw/issues).
 */
enum GLFW_PLATFORM_ERROR =         0x00010008;
/** The requested format is not supported or available.
 *
 *  If emitted during window creation, the requested pixel format is not
 *  supported.
 *
 *  If emitted when querying the clipboard, the contents of the clipboard could
 *  not be converted to the requested format.
 *
 *  @analysis If emitted during window creation, one or more
 *  [hard constraints](@ref window_hints_hard) did not match any of the
 *  available pixel formats.  If your application is sufficiently flexible,
 *  downgrade your requirements and try again.  Otherwise, inform the user that
 *  their machine does not match your requirements.
 *
 *  @par
 *  If emitted when querying the clipboard, ignore the error or report it to
 *  the user, as appropriate.
 */
enum GLFW_FORMAT_UNAVAILABLE =     0x00010009;
/** The specified window does not have an OpenGL or OpenGL ES context.
 *
 *  A window that does not have an OpenGL or OpenGL ES context was passed to
 *  a function that requires it to have one.
 *
 *  @analysis Application programmer error.  Fix the offending call.
 */
enum GLFW_NO_WINDOW_CONTEXT =      0x0001000A;
/** @} */

/** @addtogroup window
 *  @{ */
/** Input focus window hint and attribute
 *
 *  Input focus [window hint](@ref GLFW_FOCUSED_hint) or
 *  [window attribute](@ref GLFW_FOCUSED_attrib).
 */
enum GLFW_FOCUSED =                0x00020001;
/** Window iconification window attribute
 *
 *  Window iconification [window attribute](@ref GLFW_ICONIFIED_attrib).
 */
enum GLFW_ICONIFIED =              0x00020002;
/** Window resize-ability window hint and attribute
 *
 *  Window resize-ability [window hint](@ref GLFW_RESIZABLE_hint) and
 *  [window attribute](@ref GLFW_RESIZABLE_attrib).
 */
enum GLFW_RESIZABLE =              0x00020003;
/** Window visibility window hint and attribute
 *
 *  Window visibility [window hint](@ref GLFW_VISIBLE_hint) and
 *  [window attribute](@ref GLFW_VISIBLE_attrib).
 */
enum GLFW_VISIBLE =                0x00020004;
/** Window decoration window hint and attribute
 *
 *  Window decoration [window hint](@ref GLFW_DECORATED_hint) and
 *  [window attribute](@ref GLFW_DECORATED_attrib).
 */
enum GLFW_DECORATED =              0x00020005;
/** Window auto-iconification window hint and attribute
 *
 *  Window auto-iconification [window hint](@ref GLFW_AUTO_ICONIFY_hint) and
 *  [window attribute](@ref GLFW_AUTO_ICONIFY_attrib).
 */
enum GLFW_AUTO_ICONIFY =           0x00020006;
/** Window decoration window hint and attribute
 *
 *  Window decoration [window hint](@ref GLFW_FLOATING_hint) and
 *  [window attribute](@ref GLFW_FLOATING_attrib).
 */
enum GLFW_FLOATING =               0x00020007;
/** Window maximization window hint and attribute
 *
 *  Window maximization [window hint](@ref GLFW_MAXIMIZED_hint) and
 *  [window attribute](@ref GLFW_MAXIMIZED_attrib).
 */
enum GLFW_MAXIMIZED =              0x00020008;
/** Cursor centering window hint
 *
 *  Cursor centering [window hint](@ref GLFW_CENTER_CURSOR_hint).
 */
enum GLFW_CENTER_CURSOR =          0x00020009;
/** Window framebuffer transparency hint and attribute
 *
 *  Window framebuffer transparency
 *  [window hint](@ref GLFW_TRANSPARENT_FRAMEBUFFER_hint) and
 *  [window attribute](@ref GLFW_TRANSPARENT_FRAMEBUFFER_attrib).
 */
enum GLFW_TRANSPARENT_FRAMEBUFFER = 0x0002000A;
/** Mouse cursor hover window attribute.
 *
 *  Mouse cursor hover [window attribute](@ref GLFW_HOVERED_attrib).
 */
enum GLFW_HOVERED =                0x0002000B;
/** Input focus on calling show window hint and attribute
 *
 *  Input focus [window hint](@ref GLFW_FOCUS_ON_SHOW_hint) or
 *  [window attribute](@ref GLFW_FOCUS_ON_SHOW_attrib).
 */
enum GLFW_FOCUS_ON_SHOW =          0x0002000C;

/** Framebuffer bit depth hint.
 *
 *  Framebuffer bit depth [hint](@ref GLFW_RED_BITS).
 */
enum GLFW_RED_BITS =               0x00021001;
/** Framebuffer bit depth hint.
 *
 *  Framebuffer bit depth [hint](@ref GLFW_GREEN_BITS).
 */
enum GLFW_GREEN_BITS =             0x00021002;
/** Framebuffer bit depth hint.
 *
 *  Framebuffer bit depth [hint](@ref GLFW_BLUE_BITS).
 */
enum GLFW_BLUE_BITS =              0x00021003;
/** Framebuffer bit depth hint.
 *
 *  Framebuffer bit depth [hint](@ref GLFW_ALPHA_BITS).
 */
enum GLFW_ALPHA_BITS =             0x00021004;
/** Framebuffer bit depth hint.
 *
 *  Framebuffer bit depth [hint](@ref GLFW_DEPTH_BITS).
 */
enum GLFW_DEPTH_BITS =             0x00021005;
/** Framebuffer bit depth hint.
 *
 *  Framebuffer bit depth [hint](@ref GLFW_STENCIL_BITS).
 */
enum GLFW_STENCIL_BITS =           0x00021006;
/** Framebuffer bit depth hint.
 *
 *  Framebuffer bit depth [hint](@ref GLFW_ACCUM_RED_BITS).
 */
enum GLFW_ACCUM_RED_BITS =         0x00021007;
/** Framebuffer bit depth hint.
 *
 *  Framebuffer bit depth [hint](@ref GLFW_ACCUM_GREEN_BITS).
 */
enum GLFW_ACCUM_GREEN_BITS =       0x00021008;
/** Framebuffer bit depth hint.
 *
 *  Framebuffer bit depth [hint](@ref GLFW_ACCUM_BLUE_BITS).
 */
enum GLFW_ACCUM_BLUE_BITS =        0x00021009;
/** Framebuffer bit depth hint.
 *
 *  Framebuffer bit depth [hint](@ref GLFW_ACCUM_ALPHA_BITS).
 */
enum GLFW_ACCUM_ALPHA_BITS =       0x0002100A;
/** Framebuffer auxiliary buffer hint.
 *
 *  Framebuffer auxiliary buffer [hint](@ref GLFW_AUX_BUFFERS).
 */
enum GLFW_AUX_BUFFERS =            0x0002100B;
/** OpenGL stereoscopic rendering hint.
 *
 *  OpenGL stereoscopic rendering [hint](@ref GLFW_STEREO).
 */
enum GLFW_STEREO =                 0x0002100C;
/** Framebuffer MSAA samples hint.
 *
 *  Framebuffer MSAA samples [hint](@ref GLFW_SAMPLES).
 */
enum GLFW_SAMPLES =                0x0002100D;
/** Framebuffer sRGB hint.
 *
 *  Framebuffer sRGB [hint](@ref GLFW_SRGB_CAPABLE).
 */
enum GLFW_SRGB_CAPABLE =           0x0002100E;
/** Monitor refresh rate hint.
 *
 *  Monitor refresh rate [hint](@ref GLFW_REFRESH_RATE).
 */
enum GLFW_REFRESH_RATE =           0x0002100F;
/** Framebuffer double buffering hint.
 *
 *  Framebuffer double buffering [hint](@ref GLFW_DOUBLEBUFFER).
 */
enum GLFW_DOUBLEBUFFER =           0x00021010;

/** Context client API hint and attribute.
 *
 *  Context client API [hint](@ref GLFW_CLIENT_API_hint) and
 *  [attribute](@ref GLFW_CLIENT_API_attrib).
 */
enum GLFW_CLIENT_API =             0x00022001;
/** Context client API major version hint and attribute.
 *
 *  Context client API major version [hint](@ref GLFW_CONTEXT_VERSION_MAJOR_hint)
 *  and [attribute](@ref GLFW_CONTEXT_VERSION_MAJOR_attrib).
 */
enum GLFW_CONTEXT_VERSION_MAJOR =  0x00022002;
/** Context client API minor version hint and attribute.
 *
 *  Context client API minor version [hint](@ref GLFW_CONTEXT_VERSION_MINOR_hint)
 *  and [attribute](@ref GLFW_CONTEXT_VERSION_MINOR_attrib).
 */
enum GLFW_CONTEXT_VERSION_MINOR =  0x00022003;
/** Context client API revision number hint and attribute.
 *
 *  Context client API revision number
 *  [attribute](@ref GLFW_CONTEXT_REVISION_attrib).
 */
enum GLFW_CONTEXT_REVISION =       0x00022004;
/** Context robustness hint and attribute.
 *
 *  Context client API revision number [hint](@ref GLFW_CONTEXT_ROBUSTNESS_hint)
 *  and [attribute](@ref GLFW_CONTEXT_ROBUSTNESS_attrib).
 */
enum GLFW_CONTEXT_ROBUSTNESS =     0x00022005;
/** OpenGL forward-compatibility hint and attribute.
 *
 *  OpenGL forward-compatibility [hint](@ref GLFW_OPENGL_FORWARD_COMPAT_hint)
 *  and [attribute](@ref GLFW_OPENGL_FORWARD_COMPAT_attrib).
 */
enum GLFW_OPENGL_FORWARD_COMPAT =  0x00022006;
/** OpenGL debug context hint and attribute.
 *
 *  OpenGL debug context [hint](@ref GLFW_OPENGL_DEBUG_CONTEXT_hint) and
 *  [attribute](@ref GLFW_OPENGL_DEBUG_CONTEXT_attrib).
 */
enum GLFW_OPENGL_DEBUG_CONTEXT =   0x00022007;
/** OpenGL profile hint and attribute.
 *
 *  OpenGL profile [hint](@ref GLFW_OPENGL_PROFILE_hint) and
 *  [attribute](@ref GLFW_OPENGL_PROFILE_attrib).
 */
enum GLFW_OPENGL_PROFILE =         0x00022008;
/** Context flush-on-release hint and attribute.
 *
 *  Context flush-on-release [hint](@ref GLFW_CONTEXT_RELEASE_BEHAVIOR_hint) and
 *  [attribute](@ref GLFW_CONTEXT_RELEASE_BEHAVIOR_attrib).
 */
enum GLFW_CONTEXT_RELEASE_BEHAVIOR = 0x00022009;
/** Context error suppression hint and attribute.
 *
 *  Context error suppression [hint](@ref GLFW_CONTEXT_NO_ERROR_hint) and
 *  [attribute](@ref GLFW_CONTEXT_NO_ERROR_attrib).
 */
enum GLFW_CONTEXT_NO_ERROR =       0x0002200A;
/** Context creation API hint and attribute.
 *
 *  Context creation API [hint](@ref GLFW_CONTEXT_CREATION_API_hint) and
 *  [attribute](@ref GLFW_CONTEXT_CREATION_API_attrib).
 */
enum GLFW_CONTEXT_CREATION_API =   0x0002200B;
/** Window content area scaling window
 *  [window hint](@ref GLFW_SCALE_TO_MONITOR).
 */
enum GLFW_SCALE_TO_MONITOR =       0x0002200C;
/** macOS specific
 *  [window hint](@ref GLFW_COCOA_RETINA_FRAMEBUFFER_hint).
 */
enum GLFW_COCOA_RETINA_FRAMEBUFFER = 0x00023001;
/** macOS specific
 *  [window hint](@ref GLFW_COCOA_FRAME_NAME_hint).
 */
enum GLFW_COCOA_FRAME_NAME =         0x00023002;
/** macOS specific
 *  [window hint](@ref GLFW_COCOA_GRAPHICS_SWITCHING_hint).
 */
enum GLFW_COCOA_GRAPHICS_SWITCHING = 0x00023003;
/** X11 specific
 *  [window hint](@ref GLFW_X11_CLASS_NAME_hint).
 */
enum GLFW_X11_CLASS_NAME =         0x00024001;
/** X11 specific
 *  [window hint](@ref GLFW_X11_CLASS_NAME_hint).
 */
enum GLFW_X11_INSTANCE_NAME =      0x00024002;
/** @} */

enum GLFW_NO_API =                          0;
enum GLFW_OPENGL_API =             0x00030001;
enum GLFW_OPENGL_ES_API =          0x00030002;

enum GLFW_NO_ROBUSTNESS =                   0;
enum GLFW_NO_RESET_NOTIFICATION =  0x00031001;
enum GLFW_LOSE_CONTEXT_ON_RESET =  0x00031002;

enum GLFW_OPENGL_ANY_PROFILE =              0;
enum GLFW_OPENGL_CORE_PROFILE =    0x00032001;
enum GLFW_OPENGL_COMPAT_PROFILE =  0x00032002;

enum GLFW_CURSOR =                 0x00033001;
enum GLFW_STICKY_KEYS =            0x00033002;
enum GLFW_STICKY_MOUSE_BUTTONS =   0x00033003;
enum GLFW_LOCK_KEY_MODS =          0x00033004;
enum GLFW_RAW_MOUSE_MOTION =       0x00033005;

enum GLFW_CURSOR_NORMAL =          0x00034001;
enum GLFW_CURSOR_HIDDEN =          0x00034002;
enum GLFW_CURSOR_DISABLED =        0x00034003;

enum GLFW_ANY_RELEASE_BEHAVIOR =            0;
enum GLFW_RELEASE_BEHAVIOR_FLUSH = 0x00035001;
enum GLFW_RELEASE_BEHAVIOR_NONE =  0x00035002;

enum GLFW_NATIVE_CONTEXT_API =     0x00036001;
enum GLFW_EGL_CONTEXT_API =        0x00036002;
enum GLFW_OSMESA_CONTEXT_API =     0x00036003;

/** @defgroup shapes Standard cursor shapes
 *  Standard system cursor shapes.
 *
 *  See [standard cursor creation](@ref cursor_standard) for how these are used.
 *
 *  Ingroup: input
 *  @{ */

/** The regular arrow cursor shape.
 *
 *  The regular arrow cursor.
 */
enum GLFW_ARROW_CURSOR =           0x00036001;
/** The text input I-beam cursor shape.
 *
 *  The text input I-beam cursor shape.
 */
enum GLFW_IBEAM_CURSOR =           0x00036002;
/** The crosshair shape.
 *
 *  The crosshair shape.
 */
enum GLFW_CROSSHAIR_CURSOR =       0x00036003;
/** The hand shape.
 *
 *  The hand shape.
 */
enum GLFW_HAND_CURSOR =            0x00036004;
/** The horizontal resize arrow shape.
 *
 *  The horizontal resize arrow shape.
 */
enum GLFW_HRESIZE_CURSOR =         0x00036005;
/** The vertical resize arrow shape.
 *
 *  The vertical resize arrow shape.
 */
enum GLFW_VRESIZE_CURSOR =         0x00036006;
/** @} */

enum GLFW_CONNECTED =              0x00040001;
enum GLFW_DISCONNECTED =           0x00040002;

/** @addtogroup init
 *  @{ */
/** Joystick hat buttons init hint.
 *
 *  Joystick hat buttons [init hint](@ref GLFW_JOYSTICK_HAT_BUTTONS).
 */
enum GLFW_JOYSTICK_HAT_BUTTONS =   0x00050001;
/** macOS specific init hint.
 *
 *  macOS specific [init hint](@ref GLFW_COCOA_CHDIR_RESOURCES_hint).
 */
enum GLFW_COCOA_CHDIR_RESOURCES =  0x00051001;
/** macOS specific init hint.
 *
 *  macOS specific [init hint](@ref GLFW_COCOA_MENUBAR_hint).
 */
enum GLFW_COCOA_MENUBAR =          0x00051002;
/** @} */

enum GLFW_DONT_CARE =              -1;


/*************************************************************************
 * GLFW API types
 *************************************************************************/

/** Client API function pointer type.
 *
 *  Generic function pointer used for returning client API function pointers
 *  without forcing a cast from a regular pointer.
 *
 *  @sa @ref context_glext
 *  @sa @ref glfwGetProcAddress
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: context
 */
alias void function() GLFWglproc;

/** Vulkan API function pointer type.
 *
 *  Generic function pointer used for returning Vulkan API function pointers
 *  without forcing a cast from a regular pointer.
 *
 *  @sa @ref vulkan_proc
 *  @sa @ref glfwGetInstanceProcAddress
 *
 *  Since: Added in version 3.2.
 *
 *  Ingroup: vulkan
 */
alias void function() GLFWvkproc;

/** Opaque monitor object.
 *
 *  Opaque monitor object.
 *
 *  @see @ref monitor_object
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: monitor
 */
struct GLFWmonitor;

/** Opaque window object.
 *
 *  Opaque window object.
 *
 *  @see @ref window_object
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: window
 */
struct GLFWwindow;

/** Opaque cursor object.
 *
 *  Opaque cursor object.
 *
 *  @see @ref cursor_object
 *
 *  Since: Added in version 3.1.
 *
 *  Ingroup: input
 */
struct GLFWcursor;

/** The function pointer type for error callbacks.
 *
 *  This is the function pointer type for error callbacks.  An error callback
 *  function has the following signature:
 *  ```
 *  void callback_name(int error_code, const char* description)
 *  ```
 *
 * Params:
 *  error_code = An [error code](@ref errors).  Future releases may add
 *  more error codes.
 *  description = A UTF-8 encoded string describing the error.
 *
 *  Pointer_lifetime: The error description string is valid until the callback
 *  function returns.
 *
 *  @sa @ref error_handling
 *  @sa @ref glfwSetErrorCallback
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: init
 */
alias void function(int, const(char)*) GLFWerrorfun;

/** The function pointer type for window position callbacks.
 *
 *  This is the function pointer type for window position callbacks.  A window
 *  position callback function has the following signature:
 *  ```
 *  void callback_name(GLFWwindow* window, int xpos, int ypos)
 *  ```
 *
 * Params:
 *  window = The window that was moved.
 *  xpos = The new x-coordinate, in screen coordinates, of the
 *  upper-left corner of the content area of the window.
 *  ypos = The new y-coordinate, in screen coordinates, of the
 *  upper-left corner of the content area of the window.
 *
 *  @sa @ref window_pos
 *  @sa @ref glfwSetWindowPosCallback
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: window
 */
alias void function(GLFWwindow*, int, int) GLFWwindowposfun;

/** The function pointer type for window size callbacks.
 *
 *  This is the function pointer type for window size callbacks.  A window size
 *  callback function has the following signature:
 *  ```
 *  void callback_name(GLFWwindow* window, int width, int height)
 *  ```
 *
 * Params:
 *  window = The window that was resized.
 *  width = The new width, in screen coordinates, of the window.
 *  height = The new height, in screen coordinates, of the window.
 *
 *  @sa @ref window_size
 *  @sa @ref glfwSetWindowSizeCallback
 *
 *  Since: Added in version 1.0.
 *  @glfw3 Added window handle parameter.
 *
 *  Ingroup: window
 */
alias void function(GLFWwindow*, int, int) GLFWwindowsizefun;

/** The function pointer type for window close callbacks.
 *
 *  This is the function pointer type for window close callbacks.  A window
 *  close callback function has the following signature:
 *  ```
 *  void function_name(GLFWwindow* window)
 *  ```
 *
 * Params:
 *  window = The window that the user attempted to close.
 *
 *  @sa @ref window_close
 *  @sa @ref glfwSetWindowCloseCallback
 *
 *  Since: Added in version 2.5.
 *  @glfw3 Added window handle parameter.
 *
 *  Ingroup: window
 */
alias void function(GLFWwindow*) GLFWwindowclosefun;

/** The function pointer type for window content refresh callbacks.
 *
 *  This is the function pointer type for window content refresh callbacks.
 *  A window content refresh callback function has the following signature:
 *  ```
 *  void function_name(GLFWwindow* window);
 *  ```
 *
 * Params:
 *  window = The window whose content needs to be refreshed.
 *
 *  @sa @ref window_refresh
 *  @sa @ref glfwSetWindowRefreshCallback
 *
 *  Since: Added in version 2.5.
 *  @glfw3 Added window handle parameter.
 *
 *  Ingroup: window
 */
alias void function(GLFWwindow*) GLFWwindowrefreshfun;

/** The function pointer type for window focus callbacks.
 *
 *  This is the function pointer type for window focus callbacks.  A window
 *  focus callback function has the following signature:
 *  ```
 *  void function_name(GLFWwindow* window, int focused)
 *  ```
 *
 * Params:
 *  window = The window that gained or lost input focus.
 *  focused = `GLFW_TRUE` if the window was given input focus, or
 *  `GLFW_FALSE` if it lost it.
 *
 *  @sa @ref window_focus
 *  @sa @ref glfwSetWindowFocusCallback
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: window
 */
alias void function(GLFWwindow*, int) GLFWwindowfocusfun;

/** The function pointer type for window iconify callbacks.
 *
 *  This is the function pointer type for window iconify callbacks.  A window
 *  iconify callback function has the following signature:
 *  ```
 *  void function_name(GLFWwindow* window, int iconified)
 *  ```
 *
 * Params:
 *  window = The window that was iconified or restored.
 *  iconified = `GLFW_TRUE` if the window was iconified, or
 *  `GLFW_FALSE` if it was restored.
 *
 *  @sa @ref window_iconify
 *  @sa @ref glfwSetWindowIconifyCallback
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: window
 */
alias void function(GLFWwindow*, int) GLFWwindowiconifyfun;

/** The function pointer type for window maximize callbacks.
 *
 *  This is the function pointer type for window maximize callbacks.  A window
 *  maximize callback function has the following signature:
 *  ```
 *  void function_name(GLFWwindow* window, int maximized)
 *  ```
 *
 * Params:
 *  window = The window that was maximized or restored.
 *  iconified = `GLFW_TRUE` if the window was maximized, or
 *  `GLFW_FALSE` if it was restored.
 *
 *  @sa @ref window_maximize
 *  @sa glfwSetWindowMaximizeCallback
 *
 *  Since: Added in version 3.3.
 *
 *  Ingroup: window
 */
alias void function(GLFWwindow*, int) GLFWwindowmaximizefun;

/** The function pointer type for framebuffer size callbacks.
 *
 *  This is the function pointer type for framebuffer size callbacks.
 *  A framebuffer size callback function has the following signature:
 *  ```
 *  void function_name(GLFWwindow* window, int width, int height)
 *  ```
 *
 * Params:
 *  window = The window whose framebuffer was resized.
 *  width = The new width, in pixels, of the framebuffer.
 *  height = The new height, in pixels, of the framebuffer.
 *
 *  @sa @ref window_fbsize
 *  @sa @ref glfwSetFramebufferSizeCallback
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: window
 */
alias void function(GLFWwindow*, int, int) GLFWframebuffersizefun;

/** The function pointer type for window content scale callbacks.
 *
 *  This is the function pointer type for window content scale callbacks.
 *  A window content scale callback function has the following signature:
 *  ```
 *  void function_name(GLFWwindow* window, float xscale, float yscale)
 *  ```
 *
 * Params:
 *  window = The window whose content scale changed.
 *  xscale = The new x-axis content scale of the window.
 *  yscale = The new y-axis content scale of the window.
 *
 *  @sa @ref window_scale
 *  @sa @ref glfwSetWindowContentScaleCallback
 *
 *  Since: Added in version 3.3.
 *
 *  Ingroup: window
 */
alias void function(GLFWwindow*, float, float) GLFWwindowcontentscalefun;

/** The function pointer type for mouse button callbacks.
 *
 *  This is the function pointer type for mouse button callback functions.
 *  A mouse button callback function has the following signature:
 *  ```
 *  void function_name(GLFWwindow* window, int button, int action, int mods)
 *  ```
 *
 * Params:
 *  window = The window that received the event.
 *  button = The [mouse button](@ref buttons) that was pressed or
 *  released.
 *  action = One of `GLFW_PRESS` or `GLFW_RELEASE`.  Future releases
 *  may add more actions.
 *  mods = Bit field describing which [modifier keys](@ref mods) were
 *  held down.
 *
 *  @sa @ref input_mouse_button
 *  @sa @ref glfwSetMouseButtonCallback
 *
 *  Since: Added in version 1.0.
 *  @glfw3 Added window handle and modifier mask parameters.
 *
 *  Ingroup: input
 */
alias void function(GLFWwindow*, int, int, int) GLFWmousebuttonfun;

/** The function pointer type for cursor position callbacks.
 *
 *  This is the function pointer type for cursor position callbacks.  A cursor
 *  position callback function has the following signature:
 *  ```
 *  void function_name(GLFWwindow* window, double xpos, double ypos);
 *  ```
 *
 * Params:
 *  window = The window that received the event.
 *  xpos = The new cursor x-coordinate, relative to the left edge of
 *  the content area.
 *  ypos = The new cursor y-coordinate, relative to the top edge of the
 *  content area.
 *
 *  @sa @ref cursor_pos
 *  @sa @ref glfwSetCursorPosCallback
 *
 *  Since: Added in version 3.0.  Replaces `GLFWmouseposfun`.
 *
 *  Ingroup: input
 */
alias void function(GLFWwindow*, double, double) GLFWcursorposfun;

/** The function pointer type for cursor enter/leave callbacks.
 *
 *  This is the function pointer type for cursor enter/leave callbacks.
 *  A cursor enter/leave callback function has the following signature:
 *  ```
 *  void function_name(GLFWwindow* window, int entered)
 *  ```
 *
 * Params:
 *  window = The window that received the event.
 *  entered = `GLFW_TRUE` if the cursor entered the window's content
 *  area, or `GLFW_FALSE` if it left it.
 *
 *  @sa @ref cursor_enter
 *  @sa @ref glfwSetCursorEnterCallback
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: input
 */
alias void function(GLFWwindow*, int) GLFWcursorenterfun;

/** The function pointer type for scroll callbacks.
 *
 *  This is the function pointer type for scroll callbacks.  A scroll callback
 *  function has the following signature:
 *  ```
 *  void function_name(GLFWwindow* window, double xoffset, double yoffset)
 *  ```
 *
 * Params:
 *  window = The window that received the event.
 *  xoffset = The scroll offset along the x-axis.
 *  yoffset = The scroll offset along the y-axis.
 *
 *  @sa @ref scrolling
 *  @sa @ref glfwSetScrollCallback
 *
 *  Since: Added in version 3.0.  Replaces `GLFWmousewheelfun`.
 *
 *  Ingroup: input
 */
alias void function(GLFWwindow*, double, double) GLFWscrollfun;

/** The function pointer type for keyboard key callbacks.
 *
 *  This is the function pointer type for keyboard key callbacks.  A keyboard
 *  key callback function has the following signature:
 *  ```
 *  void function_name(GLFWwindow* window, int key, int scancode, int action, int mods)
 *  ```
 *
 * Params:
 *  window = The window that received the event.
 *  key = The [keyboard key](@ref keys) that was pressed or released.
 *  scancode = The system-specific scancode of the key.
 *  action = `GLFW_PRESS`, `GLFW_RELEASE` or `GLFW_REPEAT`.  Future
 *  releases may add more actions.
 *  mods = Bit field describing which [modifier keys](@ref mods) were
 *  held down.
 *
 *  @sa @ref input_key
 *  @sa @ref glfwSetKeyCallback
 *
 *  Since: Added in version 1.0.
 *  @glfw3 Added window handle, scancode and modifier mask parameters.
 *
 *  Ingroup: input
 */
alias void function(GLFWwindow*, int, int, int, int) GLFWkeyfun;

/** The function pointer type for Unicode character callbacks.
 *
 *  This is the function pointer type for Unicode character callbacks.
 *  A Unicode character callback function has the following signature:
 *  ```
 *  void function_name(GLFWwindow* window, unsigned int codepoint)
 *  ```
 *
 * Params:
 *  window = The window that received the event.
 *  codepoint = The Unicode code point of the character.
 *
 *  @sa @ref input_char
 *  @sa @ref glfwSetCharCallback
 *
 *  Since: Added in version 2.4.
 *  @glfw3 Added window handle parameter.
 *
 *  Ingroup: input
 */
alias void function(GLFWwindow*, uint) GLFWcharfun;

/** The function pointer type for Unicode character with modifiers
 *  callbacks.
 *
 *  This is the function pointer type for Unicode character with modifiers
 *  callbacks.  It is called for each input character, regardless of what
 *  modifier keys are held down.  A Unicode character with modifiers callback
 *  function has the following signature:
 *  ```
 *  void function_name(GLFWwindow* window, unsigned int codepoint, int mods)
 *  ```
 *
 * Params:
 *  window = The window that received the event.
 *  codepoint = The Unicode code point of the character.
 *  mods = Bit field describing which [modifier keys](@ref mods) were
 *  held down.
 *
 *  @sa @ref input_char
 *  @sa @ref glfwSetCharModsCallback
 *
 *  @deprecated Scheduled for removal in version 4.0.
 *
 *  Since: Added in version 3.1.
 *
 *  Ingroup: input
 */
alias void function(GLFWwindow*, uint, int) GLFWcharmodsfun;

/** The function pointer type for path drop callbacks.
 *
 *  This is the function pointer type for path drop callbacks.  A path drop
 *  callback function has the following signature:
 *  ```
 *  void function_name(GLFWwindow* window, int path_count, const char* paths[])
 *  ```
 *
 * Params:
 *  window = The window that received the event.
 *  path_count = The number of dropped paths.
 *  paths = The UTF-8 encoded file and/or directory path names.
 *
 *  Pointer_lifetime: The path array and its strings are valid until the
 *  callback function returns.
 *
 *  @sa @ref path_drop
 *  @sa @ref glfwSetDropCallback
 *
 *  Since: Added in version 3.1.
 *
 *  Ingroup: input
 */
alias void function(GLFWwindow*, int, const(char)**) GLFWdropfun;

/** The function pointer type for monitor configuration callbacks.
 *
 *  This is the function pointer type for monitor configuration callbacks.
 *  A monitor callback function has the following signature:
 *  ```
 *  void function_name(GLFWmonitor* monitor, int event)
 *  ```
 *
 * Params:
 *  monitor = The monitor that was connected or disconnected.
 *  event = One of `GLFW_CONNECTED` or `GLFW_DISCONNECTED`.  Future
 *  releases may add more events.
 *
 *  @sa @ref monitor_event
 *  @sa @ref glfwSetMonitorCallback
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: monitor
 */
alias void function(GLFWmonitor*, int) GLFWmonitorfun;

/** The function pointer type for joystick configuration callbacks.
 *
 *  This is the function pointer type for joystick configuration callbacks.
 *  A joystick configuration callback function has the following signature:
 *  ```
 *  void function_name(int jid, int event)
 *  ```
 *
 * Params:
 *  jid = The joystick that was connected or disconnected.
 *  event = One of `GLFW_CONNECTED` or `GLFW_DISCONNECTED`.  Future
 *  releases may add more events.
 *
 *  @sa @ref joystick_event
 *  @sa @ref glfwSetJoystickCallback
 *
 *  Since: Added in version 3.2.
 *
 *  Ingroup: input
 */
alias void function(int, int) GLFWjoystickfun;

/** Video mode type.
 *
 *  This describes a single video mode.
 *
 *  @sa @ref monitor_modes
 *  @sa @ref glfwGetVideoMode
 *  @sa @ref glfwGetVideoModes
 *
 *  Since: Added in version 1.0.
 *  @glfw3 Added refresh rate member.
 *
 *  Ingroup: monitor
 */
struct GLFWvidmode {
    /** The width, in screen coordinates, of the video mode.
     */
    int width;
    /** The height, in screen coordinates, of the video mode.
     */
    int height;
    /** The bit depth of the red channel of the video mode.
     */
    int redBits;
    /** The bit depth of the green channel of the video mode.
     */
    int greenBits;
    /** The bit depth of the blue channel of the video mode.
     */
    int blueBits;
    /** The refresh rate, in Hz, of the video mode.
     */
    int refreshRate;
}

/** Gamma ramp.
 *
 *  This describes the gamma ramp for a monitor.
 *
 *  @sa @ref monitor_gamma
 *  @sa @ref glfwGetGammaRamp
 *  @sa @ref glfwSetGammaRamp
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: monitor
 */
struct GLFWgammaramp {
    /** An array of value describing the response of the red channel.
     */
    ushort* red;
    /** An array of value describing the response of the green channel.
     */
    ushort* green;
    /** An array of value describing the response of the blue channel.
     */
    ushort* blue;
    /** The number of elements in each array.
     */
    uint size;
}

/** Image data.
 *
 *  This describes a single 2D image.  See the documentation for each related
 *  function what the expected pixel format is.
 *
 *  @sa @ref cursor_custom
 *  @sa @ref window_icon
 *
 *  Since: Added in version 2.1.
 *  @glfw3 Removed format and bytes-per-pixel members.
 *
 *  Ingroup: window
 */
struct GLFWimage {
    /** The width, in pixels, of this image.
     */
    int width;
    /** The height, in pixels, of this image.
     */
    int height;
    /** The pixel data of this image, arranged left-to-right, top-to-bottom.
     */
    ubyte* pixels;
}

/** Gamepad input state
 *
 *  This describes the input state of a gamepad.
 *
 *  @sa @ref gamepad
 *  @sa @ref glfwGetGamepadState
 *
 *  Since: Added in version 3.3.
 *
 *  Ingroup: input
 */
struct GLFWgamepadstate {
    /** The states of each [gamepad button](@ref gamepad_buttons), `GLFW_PRESS`
     *  or `GLFW_RELEASE`.
     */
    ubyte[15] buttons;
    /** The states of each [gamepad axis](@ref gamepad_axes), in the range -1.0
     *  to 1.0 inclusive.
     */
    float[6] axes = 0.0;
}


/*************************************************************************
 * GLFW API functions
 *************************************************************************/

/** Initializes the GLFW library.
 *
 *  This function initializes the GLFW library.  Before most GLFW functions can
 *  be used, GLFW must be initialized, and before an application terminates GLFW
 *  should be terminated in order to free any resources allocated during or
 *  after initialization.
 *
 *  If this function fails, it calls @ref glfwTerminate before returning.  If it
 *  succeeds, you should call @ref glfwTerminate before the application exits.
 *
 *  Additional calls to this function after successful initialization but before
 *  termination will return `GLFW_TRUE` immediately.
 *
 *  Returns: `GLFW_TRUE` if successful, or `GLFW_FALSE` if an
 *  [error](@ref error_handling) occurred.
 *
 *  Errors: Possible errors include @ref GLFW_PLATFORM_ERROR.
 *
 *  @remark @macos This function will change the current directory of the
 *  application to the `Contents/Resources` subdirectory of the application's
 *  bundle, if present.  This can be disabled with the @ref
 *  GLFW_COCOA_CHDIR_RESOURCES init hint.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref intro_init
 *  @sa @ref glfwTerminate
 *
 *  Since: Added in version 1.0.
 *
 *  Ingroup: init
 */
int glfwInit();

/** Terminates the GLFW library.
 *
 *  This function destroys all remaining windows and cursors, restores any
 *  modified gamma ramps and frees any other allocated resources.  Once this
 *  function is called, you must again call @ref glfwInit successfully before
 *  you will be able to use most GLFW functions.
 *
 *  If GLFW has been successfully initialized, this function should be called
 *  before the application exits.  If initialization fails, there is no need to
 *  call this function, as it is called by @ref glfwInit before it returns
 *  failure.
 *
 *  Errors: Possible errors include @ref GLFW_PLATFORM_ERROR.
 *
 *  @remark This function may be called before @ref glfwInit.
 *
 *  @warning The contexts of any remaining windows must not be current on any
 *  other thread when this function is called.
 *
 *  @reentrancy This function must not be called from a callback.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref intro_init
 *  @sa @ref glfwInit
 *
 *  Since: Added in version 1.0.
 *
 *  Ingroup: init
 */
void glfwTerminate();

/** Sets the specified init hint to the desired value.
 *
 *  This function sets hints for the next initialization of GLFW.
 *
 *  The values you set hints to are never reset by GLFW, but they only take
 *  effect during initialization.  Once GLFW has been initialized, any values
 *  you set will be ignored until the library is terminated and initialized
 *  again.
 *
 *  Some hints are platform specific.  These may be set on any platform but they
 *  will only affect their specific platform.  Other platforms will ignore them.
 *  Setting these hints requires no platform specific headers or functions.
 *
 * Params:
 *  hint = The [init hint](@ref init_hints) to set.
 *  value = The new value of the init hint.
 *
 *  Errors: Possible errors include @ref GLFW_INVALID_ENUM and @ref
 *  GLFW_INVALID_VALUE.
 *
 *  @remarks This function may be called before @ref glfwInit.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa init_hints
 *  @sa glfwInit
 *
 *  Since: Added in version 3.3.
 *
 *  Ingroup: init
 */
void glfwInitHint(int hint, int value);

/** Retrieves the version of the GLFW library.
 *
 *  This function retrieves the major, minor and revision numbers of the GLFW
 *  library.  It is intended for when you are using GLFW as a shared library and
 *  want to ensure that you are using the minimum required version.
 *
 *  Any or all of the version arguments may be `null`.
 *
 * Params:
 *  major = Where to store the major version number, or `null`.
 *  minor = Where to store the minor version number, or `null`.
 *  rev = Where to store the revision number, or `null`.
 *
 *  Errors: None.
 *
 *  @remark This function may be called before @ref glfwInit.
 *
 *  Thread_Safety: This function may be called from any thread.
 *
 *  @sa @ref intro_version
 *  @sa @ref glfwGetVersionString
 *
 *  Since: Added in version 1.0.
 *
 *  Ingroup: init
 */
void glfwGetVersion(int* major, int* minor, int* rev);

/** Returns a string describing the compile-time configuration.
 *
 *  This function returns the compile-time generated
 *  [version string](@ref intro_version_string) of the GLFW library binary.  It
 *  describes the version, platform, compiler and any platform-specific
 *  compile-time options.  It should not be confused with the OpenGL or OpenGL
 *  ES version string, queried with `glGetString`.
 *
 *  __Do not use the version string__ to parse the GLFW library version.  The
 *  @ref glfwGetVersion function provides the version of the running library
 *  binary in numerical format.
 *
 *  Returns: The ASCII encoded GLFW version string.
 *
 *  Errors: None.
 *
 *  @remark This function may be called before @ref glfwInit.
 *
 *  Pointer_lifetime: The returned string is static and compile-time generated.
 *
 *  Thread_Safety: This function may be called from any thread.
 *
 *  @sa @ref intro_version
 *  @sa @ref glfwGetVersion
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: init
 */
const(char)* glfwGetVersionString();

/** Returns and clears the last error for the calling thread.
 *
 *  This function returns and clears the [error code](@ref errors) of the last
 *  error that occurred on the calling thread, and optionally a UTF-8 encoded
 *  human-readable description of it.  If no error has occurred since the last
 *  call, it returns @ref GLFW_NO_ERROR (zero) and the description pointer is
 *  set to `null`.
 *
 * Params:
 *  description = Where to store the error description pointer, or `null`.
 *  Returns: The last error code for the calling thread, or @ref GLFW_NO_ERROR
 *  (zero).
 *
 *  Errors: None.
 *
 *  Pointer_lifetime: The returned string is allocated and freed by GLFW.  You
 *  should not free it yourself.  It is guaranteed to be valid only until the
 *  next error occurs or the library is terminated.
 *
 *  @remark This function may be called before @ref glfwInit.
 *
 *  Thread_Safety: This function may be called from any thread.
 *
 *  @sa @ref error_handling
 *  @sa @ref glfwSetErrorCallback
 *
 *  Since: Added in version 3.3.
 *
 *  Ingroup: init
 */
int glfwGetError(const(char)** description);

/** Sets the error callback.
 *
 *  This function sets the error callback, which is called with an error code
 *  and a human-readable description each time a GLFW error occurs.
 *
 *  The error code is set before the callback is called.  Calling @ref
 *  glfwGetError from the error callback will return the same value as the error
 *  code argument.
 *
 *  The error callback is called on the thread where the error occurred.  If you
 *  are using GLFW from multiple threads, your error callback needs to be
 *  written accordingly.
 *
 *  Because the description string may have been generated specifically for that
 *  error, it is not guaranteed to be valid after the callback has returned.  If
 *  you wish to use it after the callback returns, you need to make a copy.
 *
 *  Once set, the error callback remains set even after the library has been
 *  terminated.
 *
 * Params:
 *  callback = The new callback, or `null` to remove the currently set
 *  callback.
 *  Returns: The previously set callback, or `null` if no callback was set.
 *
 *  @callback_signature
 *  ```
 *  void callback_name(int error_code, const char* description)
 *  ```
 *  For more information about the callback parameters, see the
 *  [callback pointer type](@ref GLFWerrorfun).
 *
 *  Errors: None.
 *
 *  @remark This function may be called before @ref glfwInit.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref error_handling
 *  @sa @ref glfwGetError
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: init
 */
GLFWerrorfun glfwSetErrorCallback(GLFWerrorfun callback);

/** Returns the currently connected monitors.
 *
 *  This function returns an array of handles for all currently connected
 *  monitors.  The primary monitor is always first in the returned array.  If no
 *  monitors were found, this function returns `null`.
 *
 * Params:
 *  count = Where to store the number of monitors in the returned
 *  array.  This is set to zero if an error occurred.
 *  Returns: An array of monitor handles, or `null` if no monitors were found or
 *  if an [error](@ref error_handling) occurred.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED.
 *
 *  Pointer_lifetime: The returned array is allocated and freed by GLFW.  You
 *  should not free it yourself.  It is guaranteed to be valid only until the
 *  monitor configuration changes or the library is terminated.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref monitor_monitors
 *  @sa @ref monitor_event
 *  @sa @ref glfwGetPrimaryMonitor
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: monitor
 */
GLFWmonitor** glfwGetMonitors(int* count);

/** Returns the primary monitor.
 *
 *  This function returns the primary monitor.  This is usually the monitor
 *  where elements like the task bar or global menu bar are located.
 *
 *  Returns: The primary monitor, or `null` if no monitors were found or if an
 *  [error](@ref error_handling) occurred.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @remark The primary monitor is always first in the array returned by @ref
 *  glfwGetMonitors.
 *
 *  @sa @ref monitor_monitors
 *  @sa @ref glfwGetMonitors
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: monitor
 */
GLFWmonitor* glfwGetPrimaryMonitor();

/** Returns the position of the monitor's viewport on the virtual screen.
 *
 *  This function returns the position, in screen coordinates, of the upper-left
 *  corner of the specified monitor.
 *
 *  Any or all of the position arguments may be `null`.  If an error occurs, all
 *  non-`null` position arguments will be set to zero.
 *
 * Params:
 *  monitor = The monitor to query.
 *  xpos = Where to store the monitor x-coordinate, or `null`.
 *  ypos = Where to store the monitor y-coordinate, or `null`.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref monitor_properties
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: monitor
 */
void glfwGetMonitorPos(GLFWmonitor* monitor, int* xpos, int* ypos);

/** Retrieves the work area of the monitor.
 *
 *  This function returns the position, in screen coordinates, of the upper-left
 *  corner of the work area of the specified monitor along with the work area
 *  size in screen coordinates. The work area is defined as the area of the
 *  monitor not occluded by the operating system task bar where present. If no
 *  task bar exists then the work area is the monitor resolution in screen
 *  coordinates.
 *
 *  Any or all of the position and size arguments may be `null`.  If an error
 *  occurs, all non-`null` position and size arguments will be set to zero.
 *
 * Params:
 *  monitor = The monitor to query.
 *  xpos = Where to store the monitor x-coordinate, or `null`.
 *  ypos = Where to store the monitor y-coordinate, or `null`.
 *  width = Where to store the monitor width, or `null`.
 *  height = Where to store the monitor height, or `null`.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref monitor_workarea
 *
 *  Since: Added in version 3.3.
 *
 *  Ingroup: monitor
 */
void glfwGetMonitorWorkarea(GLFWmonitor* monitor, int* xpos, int* ypos, int* width, int* height);

/** Returns the physical size of the monitor.
 *
 *  This function returns the size, in millimetres, of the display area of the
 *  specified monitor.
 *
 *  Some systems do not provide accurate monitor size information, either
 *  because the monitor
 *  [EDID](https://en.wikipedia.org/wiki/Extended_display_identification_data)
 *  data is incorrect or because the driver does not report it accurately.
 *
 *  Any or all of the size arguments may be `null`.  If an error occurs, all
 *  non-`null` size arguments will be set to zero.
 *
 * Params:
 *  monitor = The monitor to query.
 *  widthMM = Where to store the width, in millimetres, of the
 *  monitor's display area, or `null`.
 *  heightMM = Where to store the height, in millimetres, of the
 *  monitor's display area, or `null`.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED.
 *
 *  @remark @win32 calculates the returned physical size from the
 *  current resolution and system DPI instead of querying the monitor EDID data.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref monitor_properties
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: monitor
 */
void glfwGetMonitorPhysicalSize(GLFWmonitor* monitor, int* widthMM, int* heightMM);

/** Retrieves the content scale for the specified monitor.
 *
 *  This function retrieves the content scale for the specified monitor.  The
 *  content scale is the ratio between the current DPI and the platform's
 *  default DPI.  This is especially important for text and any UI elements.  If
 *  the pixel dimensions of your UI scaled by this look appropriate on your
 *  machine then it should appear at a reasonable size on other machines
 *  regardless of their DPI and scaling settings.  This relies on the system DPI
 *  and scaling settings being somewhat correct.
 *
 *  The content scale may depend on both the monitor resolution and pixel
 *  density and on user settings.  It may be very different from the raw DPI
 *  calculated from the physical size and current resolution.
 *
 * Params:
 *  monitor = The monitor to query.
 *  xscale = Where to store the x-axis content scale, or `null`.
 *  yscale = Where to store the y-axis content scale, or `null`.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref monitor_scale
 *  @sa @ref glfwGetWindowContentScale
 *
 *  Since: Added in version 3.3.
 *
 *  Ingroup: monitor
 */
void glfwGetMonitorContentScale(GLFWmonitor* monitor, float* xscale, float* yscale);

/** Returns the name of the specified monitor.
 *
 *  This function returns a human-readable name, encoded as UTF-8, of the
 *  specified monitor.  The name typically reflects the make and model of the
 *  monitor and is not guaranteed to be unique among the connected monitors.
 *
 * Params:
 *  monitor = The monitor to query.
 *  Returns: The UTF-8 encoded name of the monitor, or `null` if an
 *  [error](@ref error_handling) occurred.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED.
 *
 *  Pointer_lifetime: The returned string is allocated and freed by GLFW.  You
 *  should not free it yourself.  It is valid until the specified monitor is
 *  disconnected or the library is terminated.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref monitor_properties
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: monitor
 */
const(char)* glfwGetMonitorName(GLFWmonitor* monitor);

/** Sets the user pointer of the specified monitor.
 *
 *  This function sets the user-defined pointer of the specified monitor.  The
 *  current value is retained until the monitor is disconnected.  The initial
 *  value is `null`.
 *
 *  This function may be called from the monitor callback, even for a monitor
 *  that is being disconnected.
 *
 * Params:
 *  monitor = The monitor whose pointer to set.
 *  pointer = The new value.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED.
 *
 *  Thread_Safety: This function may be called from any thread.  Access is not
 *  synchronized.
 *
 *  @sa @ref monitor_userptr
 *  @sa @ref glfwGetMonitorUserPointer
 *
 *  Since: Added in version 3.3.
 *
 *  Ingroup: monitor
 */
void glfwSetMonitorUserPointer(GLFWmonitor* monitor, void* pointer);

/** Returns the user pointer of the specified monitor.
 *
 *  This function returns the current value of the user-defined pointer of the
 *  specified monitor.  The initial value is `null`.
 *
 *  This function may be called from the monitor callback, even for a monitor
 *  that is being disconnected.
 *
 * Params:
 *  monitor = The monitor whose pointer to return.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED.
 *
 *  Thread_Safety: This function may be called from any thread.  Access is not
 *  synchronized.
 *
 *  @sa @ref monitor_userptr
 *  @sa @ref glfwSetMonitorUserPointer
 *
 *  Since: Added in version 3.3.
 *
 *  Ingroup: monitor
 */
void* glfwGetMonitorUserPointer(GLFWmonitor* monitor);

/** Sets the monitor configuration callback.
 *
 *  This function sets the monitor configuration callback, or removes the
 *  currently set callback.  This is called when a monitor is connected to or
 *  disconnected from the system.
 *
 * Params:
 *  callback = The new callback, or `null` to remove the currently set
 *  callback.
 *  Returns: The previously set callback, or `null` if no callback was set or the
 *  library had not been [initialized](@ref intro_init).
 *
 *  @callback_signature
 *  ```
 *  void function_name(GLFWmonitor* monitor, int event)
 *  ```
 *  For more information about the callback parameters, see the
 *  [function pointer type](@ref GLFWmonitorfun).
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref monitor_event
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: monitor
 */
GLFWmonitorfun glfwSetMonitorCallback(GLFWmonitorfun callback);

/** Returns the available video modes for the specified monitor.
 *
 *  This function returns an array of all video modes supported by the specified
 *  monitor.  The returned array is sorted in ascending order, first by color
 *  bit depth (the sum of all channel depths) and then by resolution area (the
 *  product of width and height).
 *
 * Params:
 *  monitor = The monitor to query.
 *  count = Where to store the number of video modes in the returned
 *  array.  This is set to zero if an error occurred.
 *  Returns: An array of video modes, or `null` if an
 *  [error](@ref error_handling) occurred.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  Pointer_lifetime: The returned array is allocated and freed by GLFW.  You
 *  should not free it yourself.  It is valid until the specified monitor is
 *  disconnected, this function is called again for that monitor or the library
 *  is terminated.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref monitor_modes
 *  @sa @ref glfwGetVideoMode
 *
 *  Since: Added in version 1.0.
 *  @glfw3 Changed to return an array of modes for a specific monitor.
 *
 *  Ingroup: monitor
 */
const(GLFWvidmode)* glfwGetVideoModes(GLFWmonitor* monitor, int* count);

/** Returns the current mode of the specified monitor.
 *
 *  This function returns the current video mode of the specified monitor.  If
 *  you have created a full screen window for that monitor, the return value
 *  will depend on whether that window is iconified.
 *
 * Params:
 *  monitor = The monitor to query.
 *  Returns: The current mode of the monitor, or `null` if an
 *  [error](@ref error_handling) occurred.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  Pointer_lifetime: The returned array is allocated and freed by GLFW.  You
 *  should not free it yourself.  It is valid until the specified monitor is
 *  disconnected or the library is terminated.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref monitor_modes
 *  @sa @ref glfwGetVideoModes
 *
 *  Since: Added in version 3.0.  Replaces `glfwGetDesktopMode`.
 *
 *  Ingroup: monitor
 */
const(GLFWvidmode)* glfwGetVideoMode(GLFWmonitor* monitor);

/** Generates a gamma ramp and sets it for the specified monitor.
 *
 *  This function generates an appropriately sized gamma ramp from the specified
 *  exponent and then calls @ref glfwSetGammaRamp with it.  The value must be
 *  a finite number greater than zero.
 *
 *  The software controlled gamma ramp is applied _in addition_ to the hardware
 *  gamma correction, which today is usually an approximation of sRGB gamma.
 *  This means that setting a perfectly linear ramp, or gamma 1.0, will produce
 *  the default (usually sRGB-like) behavior.
 *
 *  For gamma correct rendering with OpenGL or OpenGL ES, see the @ref
 *  GLFW_SRGB_CAPABLE hint.
 *
 * Params:
 *  monitor = The monitor whose gamma ramp to set.
 *  gamma = The desired exponent.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED, @ref
 *  GLFW_INVALID_VALUE and @ref GLFW_PLATFORM_ERROR.
 *
 *  @remark @wayland Gamma handling is a privileged protocol, this function
 *  will thus never be implemented and emits @ref GLFW_PLATFORM_ERROR.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref monitor_gamma
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: monitor
 */
void glfwSetGamma(GLFWmonitor* monitor, float gamma);

/** Returns the current gamma ramp for the specified monitor.
 *
 *  This function returns the current gamma ramp of the specified monitor.
 *
 * Params:
 *  monitor = The monitor to query.
 *  Returns: The current gamma ramp, or `null` if an
 *  [error](@ref error_handling) occurred.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  @remark @wayland Gamma handling is a privileged protocol, this function
 *  will thus never be implemented and emits @ref GLFW_PLATFORM_ERROR while
 *  returning `null`.
 *
 *  Pointer_lifetime: The returned structure and its arrays are allocated and
 *  freed by GLFW.  You should not free them yourself.  They are valid until the
 *  specified monitor is disconnected, this function is called again for that
 *  monitor or the library is terminated.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref monitor_gamma
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: monitor
 */
const(GLFWgammaramp)* glfwGetGammaRamp(GLFWmonitor* monitor);

/** Sets the current gamma ramp for the specified monitor.
 *
 *  This function sets the current gamma ramp for the specified monitor.  The
 *  original gamma ramp for that monitor is saved by GLFW the first time this
 *  function is called and is restored by @ref glfwTerminate.
 *
 *  The software controlled gamma ramp is applied _in addition_ to the hardware
 *  gamma correction, which today is usually an approximation of sRGB gamma.
 *  This means that setting a perfectly linear ramp, or gamma 1.0, will produce
 *  the default (usually sRGB-like) behavior.
 *
 *  For gamma correct rendering with OpenGL or OpenGL ES, see the @ref
 *  GLFW_SRGB_CAPABLE hint.
 *
 * Params:
 *  monitor = The monitor whose gamma ramp to set.
 *  ramp = The gamma ramp to use.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  @remark The size of the specified gamma ramp should match the size of the
 *  current ramp for that monitor.
 *
 *  @remark @win32 The gamma ramp size must be 256.
 *
 *  @remark @wayland Gamma handling is a privileged protocol, this function
 *  will thus never be implemented and emits @ref GLFW_PLATFORM_ERROR.
 *
 *  Pointer_lifetime: The specified gamma ramp is copied before this function
 *  returns.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref monitor_gamma
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: monitor
 */
void glfwSetGammaRamp(GLFWmonitor* monitor, const(GLFWgammaramp)* ramp);

/** Resets all window hints to their default values.
 *
 *  This function resets all window hints to their
 *  [default values](@ref window_hints_values).
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref window_hints
 *  @sa @ref glfwWindowHint
 *  @sa @ref glfwWindowHintString
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: window
 */
void glfwDefaultWindowHints();

/** Sets the specified window hint to the desired value.
 *
 *  This function sets hints for the next call to @ref glfwCreateWindow.  The
 *  hints, once set, retain their values until changed by a call to this
 *  function or @ref glfwDefaultWindowHints, or until the library is terminated.
 *
 *  Only integer value hints can be set with this function.  String value hints
 *  are set with @ref glfwWindowHintString.
 *
 *  This function does not check whether the specified hint values are valid.
 *  If you set hints to invalid values this will instead be reported by the next
 *  call to @ref glfwCreateWindow.
 *
 *  Some hints are platform specific.  These may be set on any platform but they
 *  will only affect their specific platform.  Other platforms will ignore them.
 *  Setting these hints requires no platform specific headers or functions.
 *
 * Params:
 *  hint = The [window hint](@ref window_hints) to set.
 *  value = The new value of the window hint.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_INVALID_ENUM.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref window_hints
 *  @sa @ref glfwWindowHintString
 *  @sa @ref glfwDefaultWindowHints
 *
 *  Since: Added in version 3.0.  Replaces `glfwOpenWindowHint`.
 *
 *  Ingroup: window
 */
void glfwWindowHint(int hint, int value);

/** Sets the specified window hint to the desired value.
 *
 *  This function sets hints for the next call to @ref glfwCreateWindow.  The
 *  hints, once set, retain their values until changed by a call to this
 *  function or @ref glfwDefaultWindowHints, or until the library is terminated.
 *
 *  Only string type hints can be set with this function.  Integer value hints
 *  are set with @ref glfwWindowHint.
 *
 *  This function does not check whether the specified hint values are valid.
 *  If you set hints to invalid values this will instead be reported by the next
 *  call to @ref glfwCreateWindow.
 *
 *  Some hints are platform specific.  These may be set on any platform but they
 *  will only affect their specific platform.  Other platforms will ignore them.
 *  Setting these hints requires no platform specific headers or functions.
 *
 * Params:
 *  hint = The [window hint](@ref window_hints) to set.
 *  value = The new value of the window hint.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_INVALID_ENUM.
 *
 *  Pointer_lifetime: The specified string is copied before this function
 *  returns.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref window_hints
 *  @sa @ref glfwWindowHint
 *  @sa @ref glfwDefaultWindowHints
 *
 *  Since: Added in version 3.3.
 *
 *  Ingroup: window
 */
void glfwWindowHintString(int hint, const(char)* value);

/** Creates a window and its associated context.
 *
 *  This function creates a window and its associated OpenGL or OpenGL ES
 *  context.  Most of the options controlling how the window and its context
 *  should be created are specified with [window hints](@ref window_hints).
 *
 *  Successful creation does not change which context is current.  Before you
 *  can use the newly created context, you need to
 *  [make it current](@ref context_current).  For information about the `share`
 *  parameter, see @ref context_sharing.
 *
 *  The created window, framebuffer and context may differ from what you
 *  requested, as not all parameters and hints are
 *  [hard constraints](@ref window_hints_hard).  This includes the size of the
 *  window, especially for full screen windows.  To query the actual attributes
 *  of the created window, framebuffer and context, see @ref
 *  glfwGetWindowAttrib, @ref glfwGetWindowSize and @ref glfwGetFramebufferSize.
 *
 *  To create a full screen window, you need to specify the monitor the window
 *  will cover.  If no monitor is specified, the window will be windowed mode.
 *  Unless you have a way for the user to choose a specific monitor, it is
 *  recommended that you pick the primary monitor.  For more information on how
 *  to query connected monitors, see @ref monitor_monitors.
 *
 *  For full screen windows, the specified size becomes the resolution of the
 *  window's _desired video mode_.  As long as a full screen window is not
 *  iconified, the supported video mode most closely matching the desired video
 *  mode is set for the specified monitor.  For more information about full
 *  screen windows, including the creation of so called _windowed full screen_
 *  or _borderless full screen_ windows, see @ref window_windowed_full_screen.
 *
 *  Once you have created the window, you can switch it between windowed and
 *  full screen mode with @ref glfwSetWindowMonitor.  This will not affect its
 *  OpenGL or OpenGL ES context.
 *
 *  By default, newly created windows use the placement recommended by the
 *  window system.  To create the window at a specific position, make it
 *  initially invisible using the [GLFW_VISIBLE](@ref GLFW_VISIBLE_hint) window
 *  hint, set its [position](@ref window_pos) and then [show](@ref window_hide)
 *  it.
 *
 *  As long as at least one full screen window is not iconified, the screensaver
 *  is prohibited from starting.
 *
 *  Window systems put limits on window sizes.  Very large or very small window
 *  dimensions may be overridden by the window system on creation.  Check the
 *  actual [size](@ref window_size) after creation.
 *
 *  The [swap interval](@ref buffer_swap) is not set during window creation and
 *  the initial value may vary depending on driver settings and defaults.
 *
 * Params:
 *  width = The desired width, in screen coordinates, of the window.
 *  This must be greater than zero.
 *  height = The desired height, in screen coordinates, of the window.
 *  This must be greater than zero.
 *  title = The initial, UTF-8 encoded window title.
 *  monitor = The monitor to use for full screen mode, or `null` for
 *  windowed mode.
 *  share = The window whose context to share resources with, or `null`
 *  to not share resources.
 *  Returns: The handle of the created window, or `null` if an
 *  [error](@ref error_handling) occurred.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED, @ref
 *  GLFW_INVALID_ENUM, @ref GLFW_INVALID_VALUE, @ref GLFW_API_UNAVAILABLE, @ref
 *  GLFW_VERSION_UNAVAILABLE, @ref GLFW_FORMAT_UNAVAILABLE and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  @remark @win32 Window creation will fail if the Microsoft GDI software
 *  OpenGL implementation is the only one available.
 *
 *  @remark @win32 If the executable has an icon resource named `GLFW_ICON,` it
 *  will be set as the initial icon for the window.  If no such icon is present,
 *  the `IDI_APPLICATION` icon will be used instead.  To set a different icon,
 *  see @ref glfwSetWindowIcon.
 *
 *  @remark @win32 The context to share resources with must not be current on
 *  any other thread.
 *
 *  @remark @macos The OS only supports forward-compatible core profile contexts
 *  for OpenGL versions 3.2 and later.  Before creating an OpenGL context of
 *  version 3.2 or later you must set the
 *  [GLFW_OPENGL_FORWARD_COMPAT](@ref GLFW_OPENGL_FORWARD_COMPAT_hint) and
 *  [GLFW_OPENGL_PROFILE](@ref GLFW_OPENGL_PROFILE_hint) hints accordingly.
 *  OpenGL 3.0 and 3.1 contexts are not supported at all on macOS.
 *
 *  @remark @macos The GLFW window has no icon, as it is not a document
 *  window, but the dock icon will be the same as the application bundle's icon.
 *  For more information on bundles, see the
 *  [Bundle Programming Guide](https://developer.apple.com/library/mac/documentation/CoreFoundation/Conceptual/CFBundles/)
 *  in the Mac Developer Library.
 *
 *  @remark @macos The first time a window is created the menu bar is created.
 *  If GLFW finds a `MainMenu.nib` it is loaded and assumed to contain a menu
 *  bar.  Otherwise a minimal menu bar is created manually with common commands
 *  like Hide, Quit and About.  The About entry opens a minimal about dialog
 *  with information from the application's bundle.  Menu bar creation can be
 *  disabled entirely with the @ref GLFW_COCOA_MENUBAR init hint.
 *
 *  @remark @macos On OS X 10.10 and later the window frame will not be rendered
 *  at full resolution on Retina displays unless the
 *  [GLFW_COCOA_RETINA_FRAMEBUFFER](@ref GLFW_COCOA_RETINA_FRAMEBUFFER_hint)
 *  hint is `GLFW_TRUE` and the `NSHighResolutionCapable` key is enabled in the
 *  application bundle's `Info.plist`.  For more information, see
 *  [High Resolution Guidelines for OS X](https://developer.apple.com/library/mac/documentation/GraphicsAnimation/Conceptual/HighResolutionOSX/Explained/Explained.html)
 *  in the Mac Developer Library.  The GLFW test and example programs use
 *  a custom `Info.plist` template for this, which can be found as
 *  `CMake/MacOSXBundleInfo.plist.in` in the source tree.
 *
 *  @remark @macos When activating frame autosaving with
 *  [GLFW_COCOA_FRAME_NAME](@ref GLFW_COCOA_FRAME_NAME_hint), the specified
 *  window size and position may be overridden by previously saved values.
 *
 *  @remark @x11 Some window managers will not respect the placement of
 *  initially hidden windows.
 *
 *  @remark @x11 Due to the asynchronous nature of X11, it may take a moment for
 *  a window to reach its requested state.  This means you may not be able to
 *  query the final size, position or other attributes directly after window
 *  creation.
 *
 *  @remark @x11 The class part of the `WM_CLASS` window property will by
 *  default be set to the window title passed to this function.  The instance
 *  part will use the contents of the `RESOURCE_NAME` environment variable, if
 *  present and not empty, or fall back to the window title.  Set the
 *  [GLFW_X11_CLASS_NAME](@ref GLFW_X11_CLASS_NAME_hint) and
 *  [GLFW_X11_INSTANCE_NAME](@ref GLFW_X11_INSTANCE_NAME_hint) window hints to
 *  override this.
 *
 *  @remark @wayland Compositors should implement the xdg-decoration protocol
 *  for GLFW to decorate the window properly.  If this protocol isn't
 *  supported, or if the compositor prefers client-side decorations, a very
 *  simple fallback frame will be drawn using the wp_viewporter protocol.  A
 *  compositor can still emit close, maximize or fullscreen events, using for
 *  instance a keybind mechanism.  If neither of these protocols is supported,
 *  the window won't be decorated.
 *
 *  @remark @wayland A full screen window will not attempt to change the mode,
 *  no matter what the requested size or refresh rate.
 *
 *  @remark @wayland Screensaver inhibition requires the idle-inhibit protocol
 *  to be implemented in the user's compositor.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref window_creation
 *  @sa @ref glfwDestroyWindow
 *
 *  Since: Added in version 3.0.  Replaces `glfwOpenWindow`.
 *
 *  Ingroup: window
 */
GLFWwindow* glfwCreateWindow(int width, int height, const(char)* title, GLFWmonitor* monitor, GLFWwindow* share);

/** Destroys the specified window and its context.
 *
 *  This function destroys the specified window and its context.  On calling
 *  this function, no further callbacks will be called for that window.
 *
 *  If the context of the specified window is current on the main thread, it is
 *  detached before being destroyed.
 *
 * Params:
 *  window = The window to destroy.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  @note The context of the specified window must not be current on any other
 *  thread when this function is called.
 *
 *  @reentrancy This function must not be called from a callback.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref window_creation
 *  @sa @ref glfwCreateWindow
 *
 *  Since: Added in version 3.0.  Replaces `glfwCloseWindow`.
 *
 *  Ingroup: window
 */
void glfwDestroyWindow(GLFWwindow* window);

/** Checks the close flag of the specified window.
 *
 *  This function returns the value of the close flag of the specified window.
 *
 * Params:
 *  window = The window to query.
 *  Returns: The value of the close flag.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED.
 *
 *  Thread_Safety: This function may be called from any thread.  Access is not
 *  synchronized.
 *
 *  @sa @ref window_close
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: window
 */
int glfwWindowShouldClose(GLFWwindow* window);

/** Sets the close flag of the specified window.
 *
 *  This function sets the value of the close flag of the specified window.
 *  This can be used to override the user's attempt to close the window, or
 *  to signal that it should be closed.
 *
 * Params:
 *  window = The window whose flag to change.
 *  value = The new value.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED.
 *
 *  Thread_Safety: This function may be called from any thread.  Access is not
 *  synchronized.
 *
 *  @sa @ref window_close
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: window
 */
void glfwSetWindowShouldClose(GLFWwindow* window, int value);

/** Sets the title of the specified window.
 *
 *  This function sets the window title, encoded as UTF-8, of the specified
 *  window.
 *
 * Params:
 *  window = The window whose title to change.
 *  title = The UTF-8 encoded window title.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  @remark @macos The window title will not be updated until the next time you
 *  process events.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref window_title
 *
 *  Since: Added in version 1.0.
 *  @glfw3 Added window handle parameter.
 *
 *  Ingroup: window
 */
void glfwSetWindowTitle(GLFWwindow* window, const(char)* title);

/** Sets the icon for the specified window.
 *
 *  This function sets the icon of the specified window.  If passed an array of
 *  candidate images, those of or closest to the sizes desired by the system are
 *  selected.  If no images are specified, the window reverts to its default
 *  icon.
 *
 *  The pixels are 32-bit, little-endian, non-premultiplied RGBA, i.e. eight
 *  bits per channel with the red channel first.  They are arranged canonically
 *  as packed sequential rows, starting from the top-left corner.
 *
 *  The desired image sizes varies depending on platform and system settings.
 *  The selected images will be rescaled as needed.  Good sizes include 16x16,
 *  32x32 and 48x48.
 *
 * Params:
 *  window = The window whose icon to set.
 *  count = The number of images in the specified array, or zero to
 *  revert to the default window icon.
 *  images = The images to create the icon from.  This is ignored if
 *  count is zero.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  Pointer_lifetime: The specified image data is copied before this function
 *  returns.
 *
 *  @remark @macos The GLFW window has no icon, as it is not a document
 *  window, so this function does nothing.  The dock icon will be the same as
 *  the application bundle's icon.  For more information on bundles, see the
 *  [Bundle Programming Guide](https://developer.apple.com/library/mac/documentation/CoreFoundation/Conceptual/CFBundles/)
 *  in the Mac Developer Library.
 *
 *  @remark @wayland There is no existing protocol to change an icon, the
 *  window will thus inherit the one defined in the application's desktop file.
 *  This function always emits @ref GLFW_PLATFORM_ERROR.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref window_icon
 *
 *  Since: Added in version 3.2.
 *
 *  Ingroup: window
 */
void glfwSetWindowIcon(GLFWwindow* window, int count, const(GLFWimage)* images);

/** Retrieves the position of the content area of the specified window.
 *
 *  This function retrieves the position, in screen coordinates, of the
 *  upper-left corner of the content area of the specified window.
 *
 *  Any or all of the position arguments may be `null`.  If an error occurs, all
 *  non-`null` position arguments will be set to zero.
 *
 * Params:
 *  window = The window to query.
 *  xpos = Where to store the x-coordinate of the upper-left corner of
 *  the content area, or `null`.
 *  ypos = Where to store the y-coordinate of the upper-left corner of
 *  the content area, or `null`.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  @remark @wayland There is no way for an application to retrieve the global
 *  position of its windows, this function will always emit @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref window_pos
 *  @sa @ref glfwSetWindowPos
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: window
 */
void glfwGetWindowPos(GLFWwindow* window, int* xpos, int* ypos);

/** Sets the position of the content area of the specified window.
 *
 *  This function sets the position, in screen coordinates, of the upper-left
 *  corner of the content area of the specified windowed mode window.  If the
 *  window is a full screen window, this function does nothing.
 *
 *  __Do not use this function__ to move an already visible window unless you
 *  have very good reasons for doing so, as it will confuse and annoy the user.
 *
 *  The window manager may put limits on what positions are allowed.  GLFW
 *  cannot and should not override these limits.
 *
 * Params:
 *  window = The window to query.
 *  xpos = The x-coordinate of the upper-left corner of the content area.
 *  ypos = The y-coordinate of the upper-left corner of the content area.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  @remark @wayland There is no way for an application to set the global
 *  position of its windows, this function will always emit @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref window_pos
 *  @sa @ref glfwGetWindowPos
 *
 *  Since: Added in version 1.0.
 *  @glfw3 Added window handle parameter.
 *
 *  Ingroup: window
 */
void glfwSetWindowPos(GLFWwindow* window, int xpos, int ypos);

/** Retrieves the size of the content area of the specified window.
 *
 *  This function retrieves the size, in screen coordinates, of the content area
 *  of the specified window.  If you wish to retrieve the size of the
 *  framebuffer of the window in pixels, see @ref glfwGetFramebufferSize.
 *
 *  Any or all of the size arguments may be `null`.  If an error occurs, all
 *  non-`null` size arguments will be set to zero.
 *
 * Params:
 *  window = The window whose size to retrieve.
 *  width = Where to store the width, in screen coordinates, of the
 *  content area, or `null`.
 *  height = Where to store the height, in screen coordinates, of the
 *  content area, or `null`.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref window_size
 *  @sa @ref glfwSetWindowSize
 *
 *  Since: Added in version 1.0.
 *  @glfw3 Added window handle parameter.
 *
 *  Ingroup: window
 */
void glfwGetWindowSize(GLFWwindow* window, int* width, int* height);

/** Sets the size limits of the specified window.
 *
 *  This function sets the size limits of the content area of the specified
 *  window.  If the window is full screen, the size limits only take effect
 *  once it is made windowed.  If the window is not resizable, this function
 *  does nothing.
 *
 *  The size limits are applied immediately to a windowed mode window and may
 *  cause it to be resized.
 *
 *  The maximum dimensions must be greater than or equal to the minimum
 *  dimensions and all must be greater than or equal to zero.
 *
 * Params:
 *  window = The window to set limits for.
 *  minwidth = The minimum width, in screen coordinates, of the content
 *  area, or `GLFW_DONT_CARE`.
 *  minheight = The minimum height, in screen coordinates, of the
 *  content area, or `GLFW_DONT_CARE`.
 *  maxwidth = The maximum width, in screen coordinates, of the content
 *  area, or `GLFW_DONT_CARE`.
 *  maxheight = The maximum height, in screen coordinates, of the
 *  content area, or `GLFW_DONT_CARE`.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED, @ref
 *  GLFW_INVALID_VALUE and @ref GLFW_PLATFORM_ERROR.
 *
 *  @remark If you set size limits and an aspect ratio that conflict, the
 *  results are undefined.
 *
 *  @remark @wayland The size limits will not be applied until the window is
 *  actually resized, either by the user or by the compositor.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref window_sizelimits
 *  @sa @ref glfwSetWindowAspectRatio
 *
 *  Since: Added in version 3.2.
 *
 *  Ingroup: window
 */
void glfwSetWindowSizeLimits(GLFWwindow* window, int minwidth, int minheight, int maxwidth, int maxheight);

/** Sets the aspect ratio of the specified window.
 *
 *  This function sets the required aspect ratio of the content area of the
 *  specified window.  If the window is full screen, the aspect ratio only takes
 *  effect once it is made windowed.  If the window is not resizable, this
 *  function does nothing.
 *
 *  The aspect ratio is specified as a numerator and a denominator and both
 *  values must be greater than zero.  For example, the common 16:9 aspect ratio
 *  is specified as 16 and 9, respectively.
 *
 *  If the numerator and denominator is set to `GLFW_DONT_CARE` then the aspect
 *  ratio limit is disabled.
 *
 *  The aspect ratio is applied immediately to a windowed mode window and may
 *  cause it to be resized.
 *
 * Params:
 *  window = The window to set limits for.
 *  numer = The numerator of the desired aspect ratio, or
 *  `GLFW_DONT_CARE`.
 *  denom = The denominator of the desired aspect ratio, or
 *  `GLFW_DONT_CARE`.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED, @ref
 *  GLFW_INVALID_VALUE and @ref GLFW_PLATFORM_ERROR.
 *
 *  @remark If you set size limits and an aspect ratio that conflict, the
 *  results are undefined.
 *
 *  @remark @wayland The aspect ratio will not be applied until the window is
 *  actually resized, either by the user or by the compositor.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref window_sizelimits
 *  @sa @ref glfwSetWindowSizeLimits
 *
 *  Since: Added in version 3.2.
 *
 *  Ingroup: window
 */
void glfwSetWindowAspectRatio(GLFWwindow* window, int numer, int denom);

/** Sets the size of the content area of the specified window.
 *
 *  This function sets the size, in screen coordinates, of the content area of
 *  the specified window.
 *
 *  For full screen windows, this function updates the resolution of its desired
 *  video mode and switches to the video mode closest to it, without affecting
 *  the window's context.  As the context is unaffected, the bit depths of the
 *  framebuffer remain unchanged.
 *
 *  If you wish to update the refresh rate of the desired video mode in addition
 *  to its resolution, see @ref glfwSetWindowMonitor.
 *
 *  The window manager may put limits on what sizes are allowed.  GLFW cannot
 *  and should not override these limits.
 *
 * Params:
 *  window = The window to resize.
 *  width = The desired width, in screen coordinates, of the window
 *  content area.
 *  height = The desired height, in screen coordinates, of the window
 *  content area.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  @remark @wayland A full screen window will not attempt to change the mode,
 *  no matter what the requested size.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref window_size
 *  @sa @ref glfwGetWindowSize
 *  @sa @ref glfwSetWindowMonitor
 *
 *  Since: Added in version 1.0.
 *  @glfw3 Added window handle parameter.
 *
 *  Ingroup: window
 */
void glfwSetWindowSize(GLFWwindow* window, int width, int height);

/** Retrieves the size of the framebuffer of the specified window.
 *
 *  This function retrieves the size, in pixels, of the framebuffer of the
 *  specified window.  If you wish to retrieve the size of the window in screen
 *  coordinates, see @ref glfwGetWindowSize.
 *
 *  Any or all of the size arguments may be `null`.  If an error occurs, all
 *  non-`null` size arguments will be set to zero.
 *
 * Params:
 *  window = The window whose framebuffer to query.
 *  width = Where to store the width, in pixels, of the framebuffer,
 *  or `null`.
 *  height = Where to store the height, in pixels, of the framebuffer,
 *  or `null`.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref window_fbsize
 *  @sa @ref glfwSetFramebufferSizeCallback
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: window
 */
void glfwGetFramebufferSize(GLFWwindow* window, int* width, int* height);

/** Retrieves the size of the frame of the window.
 *
 *  This function retrieves the size, in screen coordinates, of each edge of the
 *  frame of the specified window.  This size includes the title bar, if the
 *  window has one.  The size of the frame may vary depending on the
 *  [window-related hints](@ref window_hints_wnd) used to create it.
 *
 *  Because this function retrieves the size of each window frame edge and not
 *  the offset along a particular coordinate axis, the retrieved values will
 *  always be zero or positive.
 *
 *  Any or all of the size arguments may be `null`.  If an error occurs, all
 *  non-`null` size arguments will be set to zero.
 *
 * Params:
 *  window = The window whose frame size to query.
 *  left = Where to store the size, in screen coordinates, of the left
 *  edge of the window frame, or `null`.
 *  top = Where to store the size, in screen coordinates, of the top
 *  edge of the window frame, or `null`.
 *  right = Where to store the size, in screen coordinates, of the
 *  right edge of the window frame, or `null`.
 *  bottom = Where to store the size, in screen coordinates, of the
 *  bottom edge of the window frame, or `null`.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref window_size
 *
 *  Since: Added in version 3.1.
 *
 *  Ingroup: window
 */
void glfwGetWindowFrameSize(GLFWwindow* window, int* left, int* top, int* right, int* bottom);

/** Retrieves the content scale for the specified window.
 *
 *  This function retrieves the content scale for the specified window.  The
 *  content scale is the ratio between the current DPI and the platform's
 *  default DPI.  This is especially important for text and any UI elements.  If
 *  the pixel dimensions of your UI scaled by this look appropriate on your
 *  machine then it should appear at a reasonable size on other machines
 *  regardless of their DPI and scaling settings.  This relies on the system DPI
 *  and scaling settings being somewhat correct.
 *
 *  On systems where each monitors can have its own content scale, the window
 *  content scale will depend on which monitor the system considers the window
 *  to be on.
 *
 * Params:
 *  window = The window to query.
 *  xscale = Where to store the x-axis content scale, or `null`.
 *  yscale = Where to store the y-axis content scale, or `null`.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref window_scale
 *  @sa @ref glfwSetWindowContentScaleCallback
 *  @sa @ref glfwGetMonitorContentScale
 *
 *  Since: Added in version 3.3.
 *
 *  Ingroup: window
 */
void glfwGetWindowContentScale(GLFWwindow* window, float* xscale, float* yscale);

/** Returns the opacity of the whole window.
 *
 *  This function returns the opacity of the window, including any decorations.
 *
 *  The opacity (or alpha) value is a positive finite number between zero and
 *  one, where zero is fully transparent and one is fully opaque.  If the system
 *  does not support whole window transparency, this function always returns one.
 *
 *  The initial opacity value for newly created windows is one.
 *
 * Params:
 *  window = The window to query.
 *  Returns: The opacity value of the specified window.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref window_transparency
 *  @sa @ref glfwSetWindowOpacity
 *
 *  Since: Added in version 3.3.
 *
 *  Ingroup: window
 */
float glfwGetWindowOpacity(GLFWwindow* window);

/** Sets the opacity of the whole window.
 *
 *  This function sets the opacity of the window, including any decorations.
 *
 *  The opacity (or alpha) value is a positive finite number between zero and
 *  one, where zero is fully transparent and one is fully opaque.
 *
 *  The initial opacity value for newly created windows is one.
 *
 *  A window created with framebuffer transparency may not use whole window
 *  transparency.  The results of doing this are undefined.
 *
 * Params:
 *  window = The window to set the opacity for.
 *  opacity = The desired opacity of the specified window.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref window_transparency
 *  @sa @ref glfwGetWindowOpacity
 *
 *  Since: Added in version 3.3.
 *
 *  Ingroup: window
 */
void glfwSetWindowOpacity(GLFWwindow* window, float opacity);

/** Iconifies the specified window.
 *
 *  This function iconifies (minimizes) the specified window if it was
 *  previously restored.  If the window is already iconified, this function does
 *  nothing.
 *
 *  If the specified window is a full screen window, the original monitor
 *  resolution is restored until the window is restored.
 *
 * Params:
 *  window = The window to iconify.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  @remark @wayland There is no concept of iconification in wl_shell, this
 *  function will emit @ref GLFW_PLATFORM_ERROR when using this deprecated
 *  protocol.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref window_iconify
 *  @sa @ref glfwRestoreWindow
 *  @sa @ref glfwMaximizeWindow
 *
 *  Since: Added in version 2.1.
 *  @glfw3 Added window handle parameter.
 *
 *  Ingroup: window
 */
void glfwIconifyWindow(GLFWwindow* window);

/** Restores the specified window.
 *
 *  This function restores the specified window if it was previously iconified
 *  (minimized) or maximized.  If the window is already restored, this function
 *  does nothing.
 *
 *  If the specified window is a full screen window, the resolution chosen for
 *  the window is restored on the selected monitor.
 *
 * Params:
 *  window = The window to restore.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref window_iconify
 *  @sa @ref glfwIconifyWindow
 *  @sa @ref glfwMaximizeWindow
 *
 *  Since: Added in version 2.1.
 *  @glfw3 Added window handle parameter.
 *
 *  Ingroup: window
 */
void glfwRestoreWindow(GLFWwindow* window);

/** Maximizes the specified window.
 *
 *  This function maximizes the specified window if it was previously not
 *  maximized.  If the window is already maximized, this function does nothing.
 *
 *  If the specified window is a full screen window, this function does nothing.
 *
 * Params:
 *  window = The window to maximize.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  @par Thread Safety
 *  This function may only be called from the main thread.
 *
 *  @sa @ref window_iconify
 *  @sa @ref glfwIconifyWindow
 *  @sa @ref glfwRestoreWindow
 *
 *  Since: Added in GLFW 3.2.
 *
 *  Ingroup: window
 */
void glfwMaximizeWindow(GLFWwindow* window);

/** Makes the specified window visible.
 *
 *  This function makes the specified window visible if it was previously
 *  hidden.  If the window is already visible or is in full screen mode, this
 *  function does nothing.
 *
 *  By default, windowed mode windows are focused when shown
 *  Set the [GLFW_FOCUS_ON_SHOW](@ref GLFW_FOCUS_ON_SHOW_hint) window hint
 *  to change this behavior for all newly created windows, or change the
 *  behavior for an existing window with @ref glfwSetWindowAttrib.
 *
 * Params:
 *  window = The window to make visible.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref window_hide
 *  @sa @ref glfwHideWindow
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: window
 */
void glfwShowWindow(GLFWwindow* window);

/** Hides the specified window.
 *
 *  This function hides the specified window if it was previously visible.  If
 *  the window is already hidden or is in full screen mode, this function does
 *  nothing.
 *
 * Params:
 *  window = The window to hide.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref window_hide
 *  @sa @ref glfwShowWindow
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: window
 */
void glfwHideWindow(GLFWwindow* window);

/** Brings the specified window to front and sets input focus.
 *
 *  This function brings the specified window to front and sets input focus.
 *  The window should already be visible and not iconified.
 *
 *  By default, both windowed and full screen mode windows are focused when
 *  initially created.  Set the [GLFW_FOCUSED](@ref GLFW_FOCUSED_hint) to
 *  disable this behavior.
 *
 *  Also by default, windowed mode windows are focused when shown
 *  with @ref glfwShowWindow. Set the
 *  [GLFW_FOCUS_ON_SHOW](@ref GLFW_FOCUS_ON_SHOW_hint) to disable this behavior.
 *
 *  __Do not use this function__ to steal focus from other applications unless
 *  you are certain that is what the user wants.  Focus stealing can be
 *  extremely disruptive.
 *
 *  For a less disruptive way of getting the user's attention, see
 *  [attention requests](@ref window_attention).
 *
 * Params:
 *  window = The window to give input focus.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  @remark @wayland It is not possible for an application to bring its windows
 *  to front, this function will always emit @ref GLFW_PLATFORM_ERROR.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref window_focus
 *  @sa @ref window_attention
 *
 *  Since: Added in version 3.2.
 *
 *  Ingroup: window
 */
void glfwFocusWindow(GLFWwindow* window);

/** Requests user attention to the specified window.
 *
 *  This function requests user attention to the specified window.  On
 *  platforms where this is not supported, attention is requested to the
 *  application as a whole.
 *
 *  Once the user has given attention, usually by focusing the window or
 *  application, the system will end the request automatically.
 *
 * Params:
 *  window = The window to request attention to.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  @remark @macos Attention is requested to the application as a whole, not the
 *  specific window.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref window_attention
 *
 *  Since: Added in version 3.3.
 *
 *  Ingroup: window
 */
void glfwRequestWindowAttention(GLFWwindow* window);

/** Returns the monitor that the window uses for full screen mode.
 *
 *  This function returns the handle of the monitor that the specified window is
 *  in full screen on.
 *
 * Params:
 *  window = The window to query.
 *  Returns: The monitor, or `null` if the window is in windowed mode or an
 *  [error](@ref error_handling) occurred.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref window_monitor
 *  @sa @ref glfwSetWindowMonitor
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: window
 */
GLFWmonitor* glfwGetWindowMonitor(GLFWwindow* window);

/** Sets the mode, monitor, video mode and placement of a window.
 *
 *  This function sets the monitor that the window uses for full screen mode or,
 *  if the monitor is `null`, makes it windowed mode.
 *
 *  When setting a monitor, this function updates the width, height and refresh
 *  rate of the desired video mode and switches to the video mode closest to it.
 *  The window position is ignored when setting a monitor.
 *
 *  When the monitor is `null`, the position, width and height are used to
 *  place the window content area.  The refresh rate is ignored when no monitor
 *  is specified.
 *
 *  If you only wish to update the resolution of a full screen window or the
 *  size of a windowed mode window, see @ref glfwSetWindowSize.
 *
 *  When a window transitions from full screen to windowed mode, this function
 *  restores any previous window settings such as whether it is decorated,
 *  floating, resizable, has size or aspect ratio limits, etc.
 *
 * Params:
 *  window = The window whose monitor, size or video mode to set.
 *  monitor = The desired monitor, or `null` to set windowed mode.
 *  xpos = The desired x-coordinate of the upper-left corner of the
 *  content area.
 *  ypos = The desired y-coordinate of the upper-left corner of the
 *  content area.
 *  width = The desired with, in screen coordinates, of the content
 *  area or video mode.
 *  height = The desired height, in screen coordinates, of the content
 *  area or video mode.
 *  refreshRate = The desired refresh rate, in Hz, of the video mode,
 *  or `GLFW_DONT_CARE`.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  @remark The OpenGL or OpenGL ES context will not be destroyed or otherwise
 *  affected by any resizing or mode switching, although you may need to update
 *  your viewport if the framebuffer size has changed.
 *
 *  @remark @wayland The desired window position is ignored, as there is no way
 *  for an application to set this property.
 *
 *  @remark @wayland Setting the window to full screen will not attempt to
 *  change the mode, no matter what the requested size or refresh rate.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref window_monitor
 *  @sa @ref window_full_screen
 *  @sa @ref glfwGetWindowMonitor
 *  @sa @ref glfwSetWindowSize
 *
 *  Since: Added in version 3.2.
 *
 *  Ingroup: window
 */
void glfwSetWindowMonitor(GLFWwindow* window, GLFWmonitor* monitor, int xpos, int ypos, int width, int height, int refreshRate);

/** Returns an attribute of the specified window.
 *
 *  This function returns the value of an attribute of the specified window or
 *  its OpenGL or OpenGL ES context.
 *
 * Params:
 *  window = The window to query.
 *  attrib = The [window attribute](@ref window_attribs) whose value to
 *  return.
 *  Returns: The value of the attribute, or zero if an
 *  [error](@ref error_handling) occurred.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED, @ref
 *  GLFW_INVALID_ENUM and @ref GLFW_PLATFORM_ERROR.
 *
 *  @remark Framebuffer related hints are not window attributes.  See @ref
 *  window_attribs_fb for more information.
 *
 *  @remark Zero is a valid value for many window and context related
 *  attributes so you cannot use a return value of zero as an indication of
 *  errors.  However, this function should not fail as long as it is passed
 *  valid arguments and the library has been [initialized](@ref intro_init).
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref window_attribs
 *  @sa @ref glfwSetWindowAttrib
 *
 *  Since: Added in version 3.0.  Replaces `glfwGetWindowParam` and
 *  `glfwGetGLVersion`.
 *
 *  Ingroup: window
 */
int glfwGetWindowAttrib(GLFWwindow* window, int attrib);

/** Sets an attribute of the specified window.
 *
 *  This function sets the value of an attribute of the specified window.
 *
 *  The supported attributes are [GLFW_DECORATED](@ref GLFW_DECORATED_attrib),
 *  [GLFW_RESIZABLE](@ref GLFW_RESIZABLE_attrib),
 *  [GLFW_FLOATING](@ref GLFW_FLOATING_attrib),
 *  [GLFW_AUTO_ICONIFY](@ref GLFW_AUTO_ICONIFY_attrib) and
 *  [GLFW_FOCUS_ON_SHOW](@ref GLFW_FOCUS_ON_SHOW_attrib).
 *
 *  Some of these attributes are ignored for full screen windows.  The new
 *  value will take effect if the window is later made windowed.
 *
 *  Some of these attributes are ignored for windowed mode windows.  The new
 *  value will take effect if the window is later made full screen.
 *
 * Params:
 *  window = The window to set the attribute for.
 *  attrib = A supported window attribute.
 *  value = `GLFW_TRUE` or `GLFW_FALSE`.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED, @ref
 *  GLFW_INVALID_ENUM, @ref GLFW_INVALID_VALUE and @ref GLFW_PLATFORM_ERROR.
 *
 *  @remark Calling @ref glfwGetWindowAttrib will always return the latest
 *  value, even if that value is ignored by the current mode of the window.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref window_attribs
 *  @sa @ref glfwGetWindowAttrib
 *
 *  Since: Added in version 3.3.
 *
 *  Ingroup: window
 */
void glfwSetWindowAttrib(GLFWwindow* window, int attrib, int value);

/** Sets the user pointer of the specified window.
 *
 *  This function sets the user-defined pointer of the specified window.  The
 *  current value is retained until the window is destroyed.  The initial value
 *  is `null`.
 *
 * Params:
 *  window = The window whose pointer to set.
 *  pointer = The new value.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED.
 *
 *  Thread_Safety: This function may be called from any thread.  Access is not
 *  synchronized.
 *
 *  @sa @ref window_userptr
 *  @sa @ref glfwGetWindowUserPointer
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: window
 */
void glfwSetWindowUserPointer(GLFWwindow* window, void* pointer);

/** Returns the user pointer of the specified window.
 *
 *  This function returns the current value of the user-defined pointer of the
 *  specified window.  The initial value is `null`.
 *
 * Params:
 *  window = The window whose pointer to return.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED.
 *
 *  Thread_Safety: This function may be called from any thread.  Access is not
 *  synchronized.
 *
 *  @sa @ref window_userptr
 *  @sa @ref glfwSetWindowUserPointer
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: window
 */
void* glfwGetWindowUserPointer(GLFWwindow* window);

/** Sets the position callback for the specified window.
 *
 *  This function sets the position callback of the specified window, which is
 *  called when the window is moved.  The callback is provided with the
 *  position, in screen coordinates, of the upper-left corner of the content
 *  area of the window.
 *
 * Params:
 *  window = The window whose callback to set.
 *  callback = The new callback, or `null` to remove the currently set
 *  callback.
 *  Returns: The previously set callback, or `null` if no callback was set or the
 *  library had not been [initialized](@ref intro_init).
 *
 *  @callback_signature
 *  ```
 *  void function_name(GLFWwindow* window, int xpos, int ypos)
 *  ```
 *  For more information about the callback parameters, see the
 *  [function pointer type](@ref GLFWwindowposfun).
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED.
 *
 *  @remark @wayland This callback will never be called, as there is no way for
 *  an application to know its global position.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref window_pos
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: window
 */
GLFWwindowposfun glfwSetWindowPosCallback(GLFWwindow* window, GLFWwindowposfun callback);

/** Sets the size callback for the specified window.
 *
 *  This function sets the size callback of the specified window, which is
 *  called when the window is resized.  The callback is provided with the size,
 *  in screen coordinates, of the content area of the window.
 *
 * Params:
 *  window = The window whose callback to set.
 *  callback = The new callback, or `null` to remove the currently set
 *  callback.
 *  Returns: The previously set callback, or `null` if no callback was set or the
 *  library had not been [initialized](@ref intro_init).
 *
 *  @callback_signature
 *  ```
 *  void function_name(GLFWwindow* window, int width, int height)
 *  ```
 *  For more information about the callback parameters, see the
 *  [function pointer type](@ref GLFWwindowsizefun).
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref window_size
 *
 *  Since: Added in version 1.0.
 *  @glfw3 Added window handle parameter and return value.
 *
 *  Ingroup: window
 */
GLFWwindowsizefun glfwSetWindowSizeCallback(GLFWwindow* window, GLFWwindowsizefun callback);

/** Sets the close callback for the specified window.
 *
 *  This function sets the close callback of the specified window, which is
 *  called when the user attempts to close the window, for example by clicking
 *  the close widget in the title bar.
 *
 *  The close flag is set before this callback is called, but you can modify it
 *  at any time with @ref glfwSetWindowShouldClose.
 *
 *  The close callback is not triggered by @ref glfwDestroyWindow.
 *
 * Params:
 *  window = The window whose callback to set.
 *  callback = The new callback, or `null` to remove the currently set
 *  callback.
 *  Returns: The previously set callback, or `null` if no callback was set or the
 *  library had not been [initialized](@ref intro_init).
 *
 *  @callback_signature
 *  ```
 *  void function_name(GLFWwindow* window)
 *  ```
 *  For more information about the callback parameters, see the
 *  [function pointer type](@ref GLFWwindowclosefun).
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED.
 *
 *  @remark @macos Selecting Quit from the application menu will trigger the
 *  close callback for all windows.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref window_close
 *
 *  Since: Added in version 2.5.
 *  @glfw3 Added window handle parameter and return value.
 *
 *  Ingroup: window
 */
GLFWwindowclosefun glfwSetWindowCloseCallback(GLFWwindow* window, GLFWwindowclosefun callback);

/** Sets the refresh callback for the specified window.
 *
 *  This function sets the refresh callback of the specified window, which is
 *  called when the content area of the window needs to be redrawn, for example
 *  if the window has been exposed after having been covered by another window.
 *
 *  On compositing window systems such as Aero, Compiz, Aqua or Wayland, where
 *  the window contents are saved off-screen, this callback may be called only
 *  very infrequently or never at all.
 *
 * Params:
 *  window = The window whose callback to set.
 *  callback = The new callback, or `null` to remove the currently set
 *  callback.
 *  Returns: The previously set callback, or `null` if no callback was set or the
 *  library had not been [initialized](@ref intro_init).
 *
 *  @callback_signature
 *  ```
 *  void function_name(GLFWwindow* window);
 *  ```
 *  For more information about the callback parameters, see the
 *  [function pointer type](@ref GLFWwindowrefreshfun).
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref window_refresh
 *
 *  Since: Added in version 2.5.
 *  @glfw3 Added window handle parameter and return value.
 *
 *  Ingroup: window
 */
GLFWwindowrefreshfun glfwSetWindowRefreshCallback(GLFWwindow* window, GLFWwindowrefreshfun callback);

/** Sets the focus callback for the specified window.
 *
 *  This function sets the focus callback of the specified window, which is
 *  called when the window gains or loses input focus.
 *
 *  After the focus callback is called for a window that lost input focus,
 *  synthetic key and mouse button release events will be generated for all such
 *  that had been pressed.  For more information, see @ref glfwSetKeyCallback
 *  and @ref glfwSetMouseButtonCallback.
 *
 * Params:
 *  window = The window whose callback to set.
 *  callback = The new callback, or `null` to remove the currently set
 *  callback.
 *  Returns: The previously set callback, or `null` if no callback was set or the
 *  library had not been [initialized](@ref intro_init).
 *
 *  @callback_signature
 *  ```
 *  void function_name(GLFWwindow* window, int focused)
 *  ```
 *  For more information about the callback parameters, see the
 *  [function pointer type](@ref GLFWwindowfocusfun).
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref window_focus
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: window
 */
GLFWwindowfocusfun glfwSetWindowFocusCallback(GLFWwindow* window, GLFWwindowfocusfun callback);

/** Sets the iconify callback for the specified window.
 *
 *  This function sets the iconification callback of the specified window, which
 *  is called when the window is iconified or restored.
 *
 * Params:
 *  window = The window whose callback to set.
 *  callback = The new callback, or `null` to remove the currently set
 *  callback.
 *  Returns: The previously set callback, or `null` if no callback was set or the
 *  library had not been [initialized](@ref intro_init).
 *
 *  @callback_signature
 *  ```
 *  void function_name(GLFWwindow* window, int iconified)
 *  ```
 *  For more information about the callback parameters, see the
 *  [function pointer type](@ref GLFWwindowiconifyfun).
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED.
 *
 *  @remark @wayland The wl_shell protocol has no concept of iconification,
 *  this callback will never be called when using this deprecated protocol.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref window_iconify
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: window
 */
GLFWwindowiconifyfun glfwSetWindowIconifyCallback(GLFWwindow* window, GLFWwindowiconifyfun callback);

/** Sets the maximize callback for the specified window.
 *
 *  This function sets the maximization callback of the specified window, which
 *  is called when the window is maximized or restored.
 *
 * Params:
 *  window = The window whose callback to set.
 *  callback = The new callback, or `null` to remove the currently set
 *  callback.
 *  Returns: The previously set callback, or `null` if no callback was set or the
 *  library had not been [initialized](@ref intro_init).
 *
 *  @callback_signature
 *  ```
 *  void function_name(GLFWwindow* window, int maximized)
 *  ```
 *  For more information about the callback parameters, see the
 *  [function pointer type](@ref GLFWwindowmaximizefun).
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref window_maximize
 *
 *  Since: Added in version 3.3.
 *
 *  Ingroup: window
 */
GLFWwindowmaximizefun glfwSetWindowMaximizeCallback(GLFWwindow* window, GLFWwindowmaximizefun callback);

/** Sets the framebuffer resize callback for the specified window.
 *
 *  This function sets the framebuffer resize callback of the specified window,
 *  which is called when the framebuffer of the specified window is resized.
 *
 * Params:
 *  window = The window whose callback to set.
 *  callback = The new callback, or `null` to remove the currently set
 *  callback.
 *  Returns: The previously set callback, or `null` if no callback was set or the
 *  library had not been [initialized](@ref intro_init).
 *
 *  @callback_signature
 *  ```
 *  void function_name(GLFWwindow* window, int width, int height)
 *  ```
 *  For more information about the callback parameters, see the
 *  [function pointer type](@ref GLFWframebuffersizefun).
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref window_fbsize
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: window
 */
GLFWframebuffersizefun glfwSetFramebufferSizeCallback(GLFWwindow* window, GLFWframebuffersizefun callback);

/** Sets the window content scale callback for the specified window.
 *
 *  This function sets the window content scale callback of the specified window,
 *  which is called when the content scale of the specified window changes.
 *
 * Params:
 *  window = The window whose callback to set.
 *  callback = The new callback, or `null` to remove the currently set
 *  callback.
 *  Returns: The previously set callback, or `null` if no callback was set or the
 *  library had not been [initialized](@ref intro_init).
 *
 *  @callback_signature
 *  ```
 *  void function_name(GLFWwindow* window, float xscale, float yscale)
 *  ```
 *  For more information about the callback parameters, see the
 *  [function pointer type](@ref GLFWwindowcontentscalefun).
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref window_scale
 *  @sa @ref glfwGetWindowContentScale
 *
 *  Since: Added in version 3.3.
 *
 *  Ingroup: window
 */
GLFWwindowcontentscalefun glfwSetWindowContentScaleCallback(GLFWwindow* window, GLFWwindowcontentscalefun callback);

/** Processes all pending events.
 *
 *  This function processes only those events that are already in the event
 *  queue and then returns immediately.  Processing events will cause the window
 *  and input callbacks associated with those events to be called.
 *
 *  On some platforms, a window move, resize or menu operation will cause event
 *  processing to block.  This is due to how event processing is designed on
 *  those platforms.  You can use the
 *  [window refresh callback](@ref window_refresh) to redraw the contents of
 *  your window when necessary during such operations.
 *
 *  Do not assume that callbacks you set will _only_ be called in response to
 *  event processing functions like this one.  While it is necessary to poll for
 *  events, window systems that require GLFW to register callbacks of its own
 *  can pass events to GLFW in response to many window system function calls.
 *  GLFW will pass those events on to the application callbacks before
 *  returning.
 *
 *  Event processing is not required for joystick input to work.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  @reentrancy This function must not be called from a callback.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref events
 *  @sa @ref glfwWaitEvents
 *  @sa @ref glfwWaitEventsTimeout
 *
 *  Since: Added in version 1.0.
 *
 *  Ingroup: window
 */
void glfwPollEvents();

/** Waits until events are queued and processes them.
 *
 *  This function puts the calling thread to sleep until at least one event is
 *  available in the event queue.  Once one or more events are available,
 *  it behaves exactly like @ref glfwPollEvents, i.e. the events in the queue
 *  are processed and the function then returns immediately.  Processing events
 *  will cause the window and input callbacks associated with those events to be
 *  called.
 *
 *  Since not all events are associated with callbacks, this function may return
 *  without a callback having been called even if you are monitoring all
 *  callbacks.
 *
 *  On some platforms, a window move, resize or menu operation will cause event
 *  processing to block.  This is due to how event processing is designed on
 *  those platforms.  You can use the
 *  [window refresh callback](@ref window_refresh) to redraw the contents of
 *  your window when necessary during such operations.
 *
 *  Do not assume that callbacks you set will _only_ be called in response to
 *  event processing functions like this one.  While it is necessary to poll for
 *  events, window systems that require GLFW to register callbacks of its own
 *  can pass events to GLFW in response to many window system function calls.
 *  GLFW will pass those events on to the application callbacks before
 *  returning.
 *
 *  Event processing is not required for joystick input to work.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  @reentrancy This function must not be called from a callback.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref events
 *  @sa @ref glfwPollEvents
 *  @sa @ref glfwWaitEventsTimeout
 *
 *  Since: Added in version 2.5.
 *
 *  Ingroup: window
 */
void glfwWaitEvents();

/** Waits with timeout until events are queued and processes them.
 *
 *  This function puts the calling thread to sleep until at least one event is
 *  available in the event queue, or until the specified timeout is reached.  If
 *  one or more events are available, it behaves exactly like @ref
 *  glfwPollEvents, i.e. the events in the queue are processed and the function
 *  then returns immediately.  Processing events will cause the window and input
 *  callbacks associated with those events to be called.
 *
 *  The timeout value must be a positive finite number.
 *
 *  Since not all events are associated with callbacks, this function may return
 *  without a callback having been called even if you are monitoring all
 *  callbacks.
 *
 *  On some platforms, a window move, resize or menu operation will cause event
 *  processing to block.  This is due to how event processing is designed on
 *  those platforms.  You can use the
 *  [window refresh callback](@ref window_refresh) to redraw the contents of
 *  your window when necessary during such operations.
 *
 *  Do not assume that callbacks you set will _only_ be called in response to
 *  event processing functions like this one.  While it is necessary to poll for
 *  events, window systems that require GLFW to register callbacks of its own
 *  can pass events to GLFW in response to many window system function calls.
 *  GLFW will pass those events on to the application callbacks before
 *  returning.
 *
 *  Event processing is not required for joystick input to work.
 *
 * Params:
 *  timeout = The maximum amount of time, in seconds, to wait.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED, @ref
 *  GLFW_INVALID_VALUE and @ref GLFW_PLATFORM_ERROR.
 *
 *  @reentrancy This function must not be called from a callback.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref events
 *  @sa @ref glfwPollEvents
 *  @sa @ref glfwWaitEvents
 *
 *  Since: Added in version 3.2.
 *
 *  Ingroup: window
 */
void glfwWaitEventsTimeout(double timeout);

/** Posts an empty event to the event queue.
 *
 *  This function posts an empty event from the current thread to the event
 *  queue, causing @ref glfwWaitEvents or @ref glfwWaitEventsTimeout to return.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  Thread_Safety: This function may be called from any thread.
 *
 *  @sa @ref events
 *  @sa @ref glfwWaitEvents
 *  @sa @ref glfwWaitEventsTimeout
 *
 *  Since: Added in version 3.1.
 *
 *  Ingroup: window
 */
void glfwPostEmptyEvent();

/** Returns the value of an input option for the specified window.
 *
 *  This function returns the value of an input option for the specified window.
 *  The mode must be one of @ref GLFW_CURSOR, @ref GLFW_STICKY_KEYS,
 *  @ref GLFW_STICKY_MOUSE_BUTTONS, @ref GLFW_LOCK_KEY_MODS or
 *  @ref GLFW_RAW_MOUSE_MOTION.
 *
 * Params:
 *  window = The window to query.
 *  mode = One of `GLFW_CURSOR`, `GLFW_STICKY_KEYS`,
 *  `GLFW_STICKY_MOUSE_BUTTONS`, `GLFW_LOCK_KEY_MODS` or
 *  `GLFW_RAW_MOUSE_MOTION`.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_INVALID_ENUM.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref glfwSetInputMode
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: input
 */
int glfwGetInputMode(GLFWwindow* window, int mode);

/** Sets an input option for the specified window.
 *
 *  This function sets an input mode option for the specified window.  The mode
 *  must be one of @ref GLFW_CURSOR, @ref GLFW_STICKY_KEYS,
 *  @ref GLFW_STICKY_MOUSE_BUTTONS, @ref GLFW_LOCK_KEY_MODS or
 *  @ref GLFW_RAW_MOUSE_MOTION.
 *
 *  If the mode is `GLFW_CURSOR`, the value must be one of the following cursor
 *  modes:
 *  - `GLFW_CURSOR_NORMAL` makes the cursor visible and behaving normally.
 *  - `GLFW_CURSOR_HIDDEN` makes the cursor invisible when it is over the
 *    content area of the window but does not restrict the cursor from leaving.
 *  - `GLFW_CURSOR_DISABLED` hides and grabs the cursor, providing virtual
 *    and unlimited cursor movement.  This is useful for implementing for
 *    example 3D camera controls.
 *
 *  If the mode is `GLFW_STICKY_KEYS`, the value must be either `GLFW_TRUE` to
 *  enable sticky keys, or `GLFW_FALSE` to disable it.  If sticky keys are
 *  enabled, a key press will ensure that @ref glfwGetKey returns `GLFW_PRESS`
 *  the next time it is called even if the key had been released before the
 *  call.  This is useful when you are only interested in whether keys have been
 *  pressed but not when or in which order.
 *
 *  If the mode is `GLFW_STICKY_MOUSE_BUTTONS`, the value must be either
 *  `GLFW_TRUE` to enable sticky mouse buttons, or `GLFW_FALSE` to disable it.
 *  If sticky mouse buttons are enabled, a mouse button press will ensure that
 *  @ref glfwGetMouseButton returns `GLFW_PRESS` the next time it is called even
 *  if the mouse button had been released before the call.  This is useful when
 *  you are only interested in whether mouse buttons have been pressed but not
 *  when or in which order.
 *
 *  If the mode is `GLFW_LOCK_KEY_MODS`, the value must be either `GLFW_TRUE` to
 *  enable lock key modifier bits, or `GLFW_FALSE` to disable them.  If enabled,
 *  callbacks that receive modifier bits will also have the @ref
 *  GLFW_MOD_CAPS_LOCK bit set when the event was generated with Caps Lock on,
 *  and the @ref GLFW_MOD_NUM_LOCK bit when Num Lock was on.
 *
 *  If the mode is `GLFW_RAW_MOUSE_MOTION`, the value must be either `GLFW_TRUE`
 *  to enable raw (unscaled and unaccelerated) mouse motion when the cursor is
 *  disabled, or `GLFW_FALSE` to disable it.  If raw motion is not supported,
 *  attempting to set this will emit @ref GLFW_PLATFORM_ERROR.  Call @ref
 *  glfwRawMouseMotionSupported to check for support.
 *
 * Params:
 *  window = The window whose input mode to set.
 *  mode = One of `GLFW_CURSOR`, `GLFW_STICKY_KEYS`,
 *  `GLFW_STICKY_MOUSE_BUTTONS`, `GLFW_LOCK_KEY_MODS` or
 *  `GLFW_RAW_MOUSE_MOTION`.
 *  value = The new value of the specified input mode.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED, @ref
 *  GLFW_INVALID_ENUM and @ref GLFW_PLATFORM_ERROR.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref glfwGetInputMode
 *
 *  Since: Added in version 3.0.  Replaces `glfwEnable` and `glfwDisable`.
 *
 *  Ingroup: input
 */
void glfwSetInputMode(GLFWwindow* window, int mode, int value);

/** Returns whether raw mouse motion is supported.
 *
 *  This function returns whether raw mouse motion is supported on the current
 *  system.  This status does not change after GLFW has been initialized so you
 *  only need to check this once.  If you attempt to enable raw motion on
 *  a system that does not support it, @ref GLFW_PLATFORM_ERROR will be emitted.
 *
 *  Raw mouse motion is closer to the actual motion of the mouse across
 *  a surface.  It is not affected by the scaling and acceleration applied to
 *  the motion of the desktop cursor.  That processing is suitable for a cursor
 *  while raw motion is better for controlling for example a 3D camera.  Because
 *  of this, raw mouse motion is only provided when the cursor is disabled.
 *
 *  Returns: `GLFW_TRUE` if raw mouse motion is supported on the current machine,
 *  or `GLFW_FALSE` otherwise.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref raw_mouse_motion
 *  @sa @ref glfwSetInputMode
 *
 *  Since: Added in version 3.3.
 *
 *  Ingroup: input
 */
int glfwRawMouseMotionSupported();

/** Returns the layout-specific name of the specified printable key.
 *
 *  This function returns the name of the specified printable key, encoded as
 *  UTF-8.  This is typically the character that key would produce without any
 *  modifier keys, intended for displaying key bindings to the user.  For dead
 *  keys, it is typically the diacritic it would add to a character.
 *
 *  __Do not use this function__ for [text input](@ref input_char).  You will
 *  break text input for many languages even if it happens to work for yours.
 *
 *  If the key is `GLFW_KEY_UNKNOWN`, the scancode is used to identify the key,
 *  otherwise the scancode is ignored.  If you specify a non-printable key, or
 *  `GLFW_KEY_UNKNOWN` and a scancode that maps to a non-printable key, this
 *  function returns `null` but does not emit an error.
 *
 *  This behavior allows you to always pass in the arguments in the
 *  [key callback](@ref input_key) without modification.
 *
 *  The printable keys are:
 *  - `GLFW_KEY_APOSTROPHE`
 *  - `GLFW_KEY_COMMA`
 *  - `GLFW_KEY_MINUS`
 *  - `GLFW_KEY_PERIOD`
 *  - `GLFW_KEY_SLASH`
 *  - `GLFW_KEY_SEMICOLON`
 *  - `GLFW_KEY_EQUAL`
 *  - `GLFW_KEY_LEFT_BRACKET`
 *  - `GLFW_KEY_RIGHT_BRACKET`
 *  - `GLFW_KEY_BACKSLASH`
 *  - `GLFW_KEY_WORLD_1`
 *  - `GLFW_KEY_WORLD_2`
 *  - `GLFW_KEY_0` to `GLFW_KEY_9`
 *  - `GLFW_KEY_A` to `GLFW_KEY_Z`
 *  - `GLFW_KEY_KP_0` to `GLFW_KEY_KP_9`
 *  - `GLFW_KEY_KP_DECIMAL`
 *  - `GLFW_KEY_KP_DIVIDE`
 *  - `GLFW_KEY_KP_MULTIPLY`
 *  - `GLFW_KEY_KP_SUBTRACT`
 *  - `GLFW_KEY_KP_ADD`
 *  - `GLFW_KEY_KP_EQUAL`
 *
 *  Names for printable keys depend on keyboard layout, while names for
 *  non-printable keys are the same across layouts but depend on the application
 *  language and should be localized along with other user interface text.
 *
 * Params:
 *  key = The key to query, or `GLFW_KEY_UNKNOWN`.
 *  scancode = The scancode of the key to query.
 *  Returns: The UTF-8 encoded, layout-specific name of the key, or `null`.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  @remark The contents of the returned string may change when a keyboard
 *  layout change event is received.
 *
 *  Pointer_lifetime: The returned string is allocated and freed by GLFW.  You
 *  should not free it yourself.  It is valid until the library is terminated.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref input_key_name
 *
 *  Since: Added in version 3.2.
 *
 *  Ingroup: input
 */
const(char)* glfwGetKeyName(int key, int scancode);

/** Returns the platform-specific scancode of the specified key.
 *
 *  This function returns the platform-specific scancode of the specified key.
 *
 *  If the key is `GLFW_KEY_UNKNOWN` or does not exist on the keyboard this
 *  method will return `-1`.
 *
 * Params:
 *  key = Any [named key](@ref keys).
 *  Returns: The platform-specific scancode for the key, or `-1` if an
 *  [error](@ref error_handling) occurred.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED, @ref
 *  GLFW_INVALID_ENUM and @ref GLFW_PLATFORM_ERROR.
 *
 *  Thread_Safety: This function may be called from any thread.
 *
 *  @sa @ref input_key
 *
 *  Since: Added in version 3.3.
 *
 *  Ingroup: input
 */
int glfwGetKeyScancode(int key);

/** Returns the last reported state of a keyboard key for the specified
 *  window.
 *
 *  This function returns the last state reported for the specified key to the
 *  specified window.  The returned state is one of `GLFW_PRESS` or
 *  `GLFW_RELEASE`.  The higher-level action `GLFW_REPEAT` is only reported to
 *  the key callback.
 *
 *  If the @ref GLFW_STICKY_KEYS input mode is enabled, this function returns
 *  `GLFW_PRESS` the first time you call it for a key that was pressed, even if
 *  that key has already been released.
 *
 *  The key functions deal with physical keys, with [key tokens](@ref keys)
 *  named after their use on the standard US keyboard layout.  If you want to
 *  input text, use the Unicode character callback instead.
 *
 *  The [modifier key bit masks](@ref mods) are not key tokens and cannot be
 *  used with this function.
 *
 *  __Do not use this function__ to implement [text input](@ref input_char).
 *
 * Params:
 *  window = The desired window.
 *  key = The desired [keyboard key](@ref keys).  `GLFW_KEY_UNKNOWN` is
 *  not a valid key for this function.
 *  Returns: One of `GLFW_PRESS` or `GLFW_RELEASE`.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_INVALID_ENUM.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref input_key
 *
 *  Since: Added in version 1.0.
 *  @glfw3 Added window handle parameter.
 *
 *  Ingroup: input
 */
int glfwGetKey(GLFWwindow* window, int key);

/** Returns the last reported state of a mouse button for the specified
 *  window.
 *
 *  This function returns the last state reported for the specified mouse button
 *  to the specified window.  The returned state is one of `GLFW_PRESS` or
 *  `GLFW_RELEASE`.
 *
 *  If the @ref GLFW_STICKY_MOUSE_BUTTONS input mode is enabled, this function
 *  returns `GLFW_PRESS` the first time you call it for a mouse button that was
 *  pressed, even if that mouse button has already been released.
 *
 * Params:
 *  window = The desired window.
 *  button = The desired [mouse button](@ref buttons).
 *  Returns: One of `GLFW_PRESS` or `GLFW_RELEASE`.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_INVALID_ENUM.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref input_mouse_button
 *
 *  Since: Added in version 1.0.
 *  @glfw3 Added window handle parameter.
 *
 *  Ingroup: input
 */
int glfwGetMouseButton(GLFWwindow* window, int button);

/** Retrieves the position of the cursor relative to the content area of
 *  the window.
 *
 *  This function returns the position of the cursor, in screen coordinates,
 *  relative to the upper-left corner of the content area of the specified
 *  window.
 *
 *  If the cursor is disabled (with `GLFW_CURSOR_DISABLED`) then the cursor
 *  position is unbounded and limited only by the minimum and maximum values of
 *  a `double`.
 *
 *  The coordinate can be converted to their integer equivalents with the
 *  `floor` function.  Casting directly to an integer type works for positive
 *  coordinates, but fails for negative ones.
 *
 *  Any or all of the position arguments may be `null`.  If an error occurs, all
 *  non-`null` position arguments will be set to zero.
 *
 * Params:
 *  window = The desired window.
 *  xpos = Where to store the cursor x-coordinate, relative to the
 *  left edge of the content area, or `null`.
 *  ypos = Where to store the cursor y-coordinate, relative to the to
 *  top edge of the content area, or `null`.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref cursor_pos
 *  @sa @ref glfwSetCursorPos
 *
 *  Since: Added in version 3.0.  Replaces `glfwGetMousePos`.
 *
 *  Ingroup: input
 */
void glfwGetCursorPos(GLFWwindow* window, double* xpos, double* ypos);

/** Sets the position of the cursor, relative to the content area of the
 *  window.
 *
 *  This function sets the position, in screen coordinates, of the cursor
 *  relative to the upper-left corner of the content area of the specified
 *  window.  The window must have input focus.  If the window does not have
 *  input focus when this function is called, it fails silently.
 *
 *  __Do not use this function__ to implement things like camera controls.  GLFW
 *  already provides the `GLFW_CURSOR_DISABLED` cursor mode that hides the
 *  cursor, transparently re-centers it and provides unconstrained cursor
 *  motion.  See @ref glfwSetInputMode for more information.
 *
 *  If the cursor mode is `GLFW_CURSOR_DISABLED` then the cursor position is
 *  unconstrained and limited only by the minimum and maximum values of
 *  a `double`.
 *
 * Params:
 *  window = The desired window.
 *  xpos = The desired x-coordinate, relative to the left edge of the
 *  content area.
 *  ypos = The desired y-coordinate, relative to the top edge of the
 *  content area.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  @remark @wayland This function will only work when the cursor mode is
 *  `GLFW_CURSOR_DISABLED`, otherwise it will do nothing.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref cursor_pos
 *  @sa @ref glfwGetCursorPos
 *
 *  Since: Added in version 3.0.  Replaces `glfwSetMousePos`.
 *
 *  Ingroup: input
 */
void glfwSetCursorPos(GLFWwindow* window, double xpos, double ypos);

/** Creates a custom cursor.
 *
 *  Creates a new custom cursor image that can be set for a window with @ref
 *  glfwSetCursor.  The cursor can be destroyed with @ref glfwDestroyCursor.
 *  Any remaining cursors are destroyed by @ref glfwTerminate.
 *
 *  The pixels are 32-bit, little-endian, non-premultiplied RGBA, i.e. eight
 *  bits per channel with the red channel first.  They are arranged canonically
 *  as packed sequential rows, starting from the top-left corner.
 *
 *  The cursor hotspot is specified in pixels, relative to the upper-left corner
 *  of the cursor image.  Like all other coordinate systems in GLFW, the X-axis
 *  points to the right and the Y-axis points down.
 *
 * Params:
 *  image = The desired cursor image.
 *  xhot = The desired x-coordinate, in pixels, of the cursor hotspot.
 *  yhot = The desired y-coordinate, in pixels, of the cursor hotspot.
 *  Returns: The handle of the created cursor, or `null` if an
 *  [error](@ref error_handling) occurred.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  Pointer_lifetime: The specified image data is copied before this function
 *  returns.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref cursor_object
 *  @sa @ref glfwDestroyCursor
 *  @sa @ref glfwCreateStandardCursor
 *
 *  Since: Added in version 3.1.
 *
 *  Ingroup: input
 */
GLFWcursor* glfwCreateCursor(const(GLFWimage)* image, int xhot, int yhot);

/** Creates a cursor with a standard shape.
 *
 *  Returns a cursor with a [standard shape](@ref shapes), that can be set for
 *  a window with @ref glfwSetCursor.
 *
 * Params:
 *  shape = One of the [standard shapes](@ref shapes).
 *  Returns: A new cursor ready to use or `null` if an
 *  [error](@ref error_handling) occurred.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED, @ref
 *  GLFW_INVALID_ENUM and @ref GLFW_PLATFORM_ERROR.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref cursor_object
 *  @sa @ref glfwCreateCursor
 *
 *  Since: Added in version 3.1.
 *
 *  Ingroup: input
 */
GLFWcursor* glfwCreateStandardCursor(int shape);

/** Destroys a cursor.
 *
 *  This function destroys a cursor previously created with @ref
 *  glfwCreateCursor.  Any remaining cursors will be destroyed by @ref
 *  glfwTerminate.
 *
 *  If the specified cursor is current for any window, that window will be
 *  reverted to the default cursor.  This does not affect the cursor mode.
 *
 * Params:
 *  cursor = The cursor object to destroy.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  @reentrancy This function must not be called from a callback.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref cursor_object
 *  @sa @ref glfwCreateCursor
 *
 *  Since: Added in version 3.1.
 *
 *  Ingroup: input
 */
void glfwDestroyCursor(GLFWcursor* cursor);

/** Sets the cursor for the window.
 *
 *  This function sets the cursor image to be used when the cursor is over the
 *  content area of the specified window.  The set cursor will only be visible
 *  when the [cursor mode](@ref cursor_mode) of the window is
 *  `GLFW_CURSOR_NORMAL`.
 *
 *  On some platforms, the set cursor may not be visible unless the window also
 *  has input focus.
 *
 * Params:
 *  window = The window to set the cursor for.
 *  cursor = The cursor to set, or `null` to switch back to the default
 *  arrow cursor.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref cursor_object
 *
 *  Since: Added in version 3.1.
 *
 *  Ingroup: input
 */
void glfwSetCursor(GLFWwindow* window, GLFWcursor* cursor);

/** Sets the key callback.
 *
 *  This function sets the key callback of the specified window, which is called
 *  when a key is pressed, repeated or released.
 *
 *  The key functions deal with physical keys, with layout independent
 *  [key tokens](@ref keys) named after their values in the standard US keyboard
 *  layout.  If you want to input text, use the
 *  [character callback](@ref glfwSetCharCallback) instead.
 *
 *  When a window loses input focus, it will generate synthetic key release
 *  events for all pressed keys.  You can tell these events from user-generated
 *  events by the fact that the synthetic ones are generated after the focus
 *  loss event has been processed, i.e. after the
 *  [window focus callback](@ref glfwSetWindowFocusCallback) has been called.
 *
 *  The scancode of a key is specific to that platform or sometimes even to that
 *  machine.  Scancodes are intended to allow users to bind keys that don't have
 *  a GLFW key token.  Such keys have `key` set to `GLFW_KEY_UNKNOWN`, their
 *  state is not saved and so it cannot be queried with @ref glfwGetKey.
 *
 *  Sometimes GLFW needs to generate synthetic key events, in which case the
 *  scancode may be zero.
 *
 * Params:
 *  window = The window whose callback to set.
 *  callback = The new key callback, or `null` to remove the currently
 *  set callback.
 *  Returns: The previously set callback, or `null` if no callback was set or the
 *  library had not been [initialized](@ref intro_init).
 *
 *  @callback_signature
 *  ```
 *  void function_name(GLFWwindow* window, int key, int scancode, int action, int mods)
 *  ```
 *  For more information about the callback parameters, see the
 *  [function pointer type](@ref GLFWkeyfun).
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref input_key
 *
 *  Since: Added in version 1.0.
 *  @glfw3 Added window handle parameter and return value.
 *
 *  Ingroup: input
 */
GLFWkeyfun glfwSetKeyCallback(GLFWwindow* window, GLFWkeyfun callback);

/** Sets the Unicode character callback.
 *
 *  This function sets the character callback of the specified window, which is
 *  called when a Unicode character is input.
 *
 *  The character callback is intended for Unicode text input.  As it deals with
 *  characters, it is keyboard layout dependent, whereas the
 *  [key callback](@ref glfwSetKeyCallback) is not.  Characters do not map 1:1
 *  to physical keys, as a key may produce zero, one or more characters.  If you
 *  want to know whether a specific physical key was pressed or released, see
 *  the key callback instead.
 *
 *  The character callback behaves as system text input normally does and will
 *  not be called if modifier keys are held down that would prevent normal text
 *  input on that platform, for example a Super (Command) key on macOS or Alt key
 *  on Windows.
 *
 * Params:
 *  window = The window whose callback to set.
 *  callback = The new callback, or `null` to remove the currently set
 *  callback.
 *  Returns: The previously set callback, or `null` if no callback was set or the
 *  library had not been [initialized](@ref intro_init).
 *
 *  @callback_signature
 *  ```
 *  void function_name(GLFWwindow* window, unsigned int codepoint)
 *  ```
 *  For more information about the callback parameters, see the
 *  [function pointer type](@ref GLFWcharfun).
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref input_char
 *
 *  Since: Added in version 2.4.
 *  @glfw3 Added window handle parameter and return value.
 *
 *  Ingroup: input
 */
GLFWcharfun glfwSetCharCallback(GLFWwindow* window, GLFWcharfun callback);

/** Sets the Unicode character with modifiers callback.
 *
 *  This function sets the character with modifiers callback of the specified
 *  window, which is called when a Unicode character is input regardless of what
 *  modifier keys are used.
 *
 *  The character with modifiers callback is intended for implementing custom
 *  Unicode character input.  For regular Unicode text input, see the
 *  [character callback](@ref glfwSetCharCallback).  Like the character
 *  callback, the character with modifiers callback deals with characters and is
 *  keyboard layout dependent.  Characters do not map 1:1 to physical keys, as
 *  a key may produce zero, one or more characters.  If you want to know whether
 *  a specific physical key was pressed or released, see the
 *  [key callback](@ref glfwSetKeyCallback) instead.
 *
 * Params:
 *  window = The window whose callback to set.
 *  callback = The new callback, or `null` to remove the currently set
 *  callback.
 *  Returns: The previously set callback, or `null` if no callback was set or an
 *  [error](@ref error_handling) occurred.
 *
 *  @callback_signature
 *  ```
 *  void function_name(GLFWwindow* window, unsigned int codepoint, int mods)
 *  ```
 *  For more information about the callback parameters, see the
 *  [function pointer type](@ref GLFWcharmodsfun).
 *
 *  @deprecated Scheduled for removal in version 4.0.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref input_char
 *
 *  Since: Added in version 3.1.
 *
 *  Ingroup: input
 */
GLFWcharmodsfun glfwSetCharModsCallback(GLFWwindow* window, GLFWcharmodsfun callback);

/** Sets the mouse button callback.
 *
 *  This function sets the mouse button callback of the specified window, which
 *  is called when a mouse button is pressed or released.
 *
 *  When a window loses input focus, it will generate synthetic mouse button
 *  release events for all pressed mouse buttons.  You can tell these events
 *  from user-generated events by the fact that the synthetic ones are generated
 *  after the focus loss event has been processed, i.e. after the
 *  [window focus callback](@ref glfwSetWindowFocusCallback) has been called.
 *
 * Params:
 *  window = The window whose callback to set.
 *  callback = The new callback, or `null` to remove the currently set
 *  callback.
 *  Returns: The previously set callback, or `null` if no callback was set or the
 *  library had not been [initialized](@ref intro_init).
 *
 *  @callback_signature
 *  ```
 *  void function_name(GLFWwindow* window, int button, int action, int mods)
 *  ```
 *  For more information about the callback parameters, see the
 *  [function pointer type](@ref GLFWmousebuttonfun).
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref input_mouse_button
 *
 *  Since: Added in version 1.0.
 *  @glfw3 Added window handle parameter and return value.
 *
 *  Ingroup: input
 */
GLFWmousebuttonfun glfwSetMouseButtonCallback(GLFWwindow* window, GLFWmousebuttonfun callback);

/** Sets the cursor position callback.
 *
 *  This function sets the cursor position callback of the specified window,
 *  which is called when the cursor is moved.  The callback is provided with the
 *  position, in screen coordinates, relative to the upper-left corner of the
 *  content area of the window.
 *
 * Params:
 *  window = The window whose callback to set.
 *  callback = The new callback, or `null` to remove the currently set
 *  callback.
 *  Returns: The previously set callback, or `null` if no callback was set or the
 *  library had not been [initialized](@ref intro_init).
 *
 *  @callback_signature
 *  ```
 *  void function_name(GLFWwindow* window, double xpos, double ypos);
 *  ```
 *  For more information about the callback parameters, see the
 *  [function pointer type](@ref GLFWcursorposfun).
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref cursor_pos
 *
 *  Since: Added in version 3.0.  Replaces `glfwSetMousePosCallback`.
 *
 *  Ingroup: input
 */
GLFWcursorposfun glfwSetCursorPosCallback(GLFWwindow* window, GLFWcursorposfun callback);

/** Sets the cursor enter/leave callback.
 *
 *  This function sets the cursor boundary crossing callback of the specified
 *  window, which is called when the cursor enters or leaves the content area of
 *  the window.
 *
 * Params:
 *  window = The window whose callback to set.
 *  callback = The new callback, or `null` to remove the currently set
 *  callback.
 *  Returns: The previously set callback, or `null` if no callback was set or the
 *  library had not been [initialized](@ref intro_init).
 *
 *  @callback_signature
 *  ```
 *  void function_name(GLFWwindow* window, int entered)
 *  ```
 *  For more information about the callback parameters, see the
 *  [function pointer type](@ref GLFWcursorenterfun).
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref cursor_enter
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: input
 */
GLFWcursorenterfun glfwSetCursorEnterCallback(GLFWwindow* window, GLFWcursorenterfun callback);

/** Sets the scroll callback.
 *
 *  This function sets the scroll callback of the specified window, which is
 *  called when a scrolling device is used, such as a mouse wheel or scrolling
 *  area of a touchpad.
 *
 *  The scroll callback receives all scrolling input, like that from a mouse
 *  wheel or a touchpad scrolling area.
 *
 * Params:
 *  window = The window whose callback to set.
 *  callback = The new scroll callback, or `null` to remove the
 *  currently set callback.
 *  Returns: The previously set callback, or `null` if no callback was set or the
 *  library had not been [initialized](@ref intro_init).
 *
 *  @callback_signature
 *  ```
 *  void function_name(GLFWwindow* window, double xoffset, double yoffset)
 *  ```
 *  For more information about the callback parameters, see the
 *  [function pointer type](@ref GLFWscrollfun).
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref scrolling
 *
 *  Since: Added in version 3.0.  Replaces `glfwSetMouseWheelCallback`.
 *
 *  Ingroup: input
 */
GLFWscrollfun glfwSetScrollCallback(GLFWwindow* window, GLFWscrollfun callback);

/** Sets the path drop callback.
 *
 *  This function sets the path drop callback of the specified window, which is
 *  called when one or more dragged paths are dropped on the window.
 *
 *  Because the path array and its strings may have been generated specifically
 *  for that event, they are not guaranteed to be valid after the callback has
 *  returned.  If you wish to use them after the callback returns, you need to
 *  make a deep copy.
 *
 * Params:
 *  window = The window whose callback to set.
 *  callback = The new file drop callback, or `null` to remove the
 *  currently set callback.
 *  Returns: The previously set callback, or `null` if no callback was set or the
 *  library had not been [initialized](@ref intro_init).
 *
 *  @callback_signature
 *  ```
 *  void function_name(GLFWwindow* window, int path_count, const char* paths[])
 *  ```
 *  For more information about the callback parameters, see the
 *  [function pointer type](@ref GLFWdropfun).
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED.
 *
 *  @remark @wayland File drop is currently unimplemented.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref path_drop
 *
 *  Since: Added in version 3.1.
 *
 *  Ingroup: input
 */
GLFWdropfun glfwSetDropCallback(GLFWwindow* window, GLFWdropfun callback);

/** Returns whether the specified joystick is present.
 *
 *  This function returns whether the specified joystick is present.
 *
 *  There is no need to call this function before other functions that accept
 *  a joystick ID, as they all check for presence before performing any other
 *  work.
 *
 * Params:
 *  jid = The [joystick](@ref joysticks) to query.
 *  Returns: `GLFW_TRUE` if the joystick is present, or `GLFW_FALSE` otherwise.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED, @ref
 *  GLFW_INVALID_ENUM and @ref GLFW_PLATFORM_ERROR.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref joystick
 *
 *  Since: Added in version 3.0.  Replaces `glfwGetJoystickParam`.
 *
 *  Ingroup: input
 */
int glfwJoystickPresent(int jid);

/** Returns the values of all axes of the specified joystick.
 *
 *  This function returns the values of all axes of the specified joystick.
 *  Each element in the array is a value between -1.0 and 1.0.
 *
 *  If the specified joystick is not present this function will return `null`
 *  but will not generate an error.  This can be used instead of first calling
 *  @ref glfwJoystickPresent.
 *
 * Params:
 *  jid = The [joystick](@ref joysticks) to query.
 *  count = Where to store the number of axis values in the returned
 *  array.  This is set to zero if the joystick is not present or an error
 *  occurred.
 *  Returns: An array of axis values, or `null` if the joystick is not present or
 *  an [error](@ref error_handling) occurred.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED, @ref
 *  GLFW_INVALID_ENUM and @ref GLFW_PLATFORM_ERROR.
 *
 *  Pointer_lifetime: The returned array is allocated and freed by GLFW.  You
 *  should not free it yourself.  It is valid until the specified joystick is
 *  disconnected or the library is terminated.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref joystick_axis
 *
 *  Since: Added in version 3.0.  Replaces `glfwGetJoystickPos`.
 *
 *  Ingroup: input
 */
const(float)* glfwGetJoystickAxes(int jid, int* count);

/** Returns the state of all buttons of the specified joystick.
 *
 *  This function returns the state of all buttons of the specified joystick.
 *  Each element in the array is either `GLFW_PRESS` or `GLFW_RELEASE`.
 *
 *  For backward compatibility with earlier versions that did not have @ref
 *  glfwGetJoystickHats, the button array also includes all hats, each
 *  represented as four buttons.  The hats are in the same order as returned by
 *  __glfwGetJoystickHats__ and are in the order _up_, _right_, _down_ and
 *  _left_.  To disable these extra buttons, set the @ref
 *  GLFW_JOYSTICK_HAT_BUTTONS init hint before initialization.
 *
 *  If the specified joystick is not present this function will return `null`
 *  but will not generate an error.  This can be used instead of first calling
 *  @ref glfwJoystickPresent.
 *
 * Params:
 *  jid = The [joystick](@ref joysticks) to query.
 *  count = Where to store the number of button states in the returned
 *  array.  This is set to zero if the joystick is not present or an error
 *  occurred.
 *  Returns: An array of button states, or `null` if the joystick is not present
 *  or an [error](@ref error_handling) occurred.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED, @ref
 *  GLFW_INVALID_ENUM and @ref GLFW_PLATFORM_ERROR.
 *
 *  Pointer_lifetime: The returned array is allocated and freed by GLFW.  You
 *  should not free it yourself.  It is valid until the specified joystick is
 *  disconnected or the library is terminated.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref joystick_button
 *
 *  Since: Added in version 2.2.
 *  @glfw3 Changed to return a dynamic array.
 *
 *  Ingroup: input
 */
const(ubyte)* glfwGetJoystickButtons(int jid, int* count);

/** Returns the state of all hats of the specified joystick.
 *
 *  This function returns the state of all hats of the specified joystick.
 *  Each element in the array is one of the following values:
 *
 *  Name                  | Value
 *  ----                  | -----
 *  `GLFW_HAT_CENTERED`   | 0
 *  `GLFW_HAT_UP`         | 1
 *  `GLFW_HAT_RIGHT`      | 2
 *  `GLFW_HAT_DOWN`       | 4
 *  `GLFW_HAT_LEFT`       | 8
 *  `GLFW_HAT_RIGHT_UP`   | `GLFW_HAT_RIGHT` \| `GLFW_HAT_UP`
 *  `GLFW_HAT_RIGHT_DOWN` | `GLFW_HAT_RIGHT` \| `GLFW_HAT_DOWN`
 *  `GLFW_HAT_LEFT_UP`    | `GLFW_HAT_LEFT` \| `GLFW_HAT_UP`
 *  `GLFW_HAT_LEFT_DOWN`  | `GLFW_HAT_LEFT` \| `GLFW_HAT_DOWN`
 *
 *  The diagonal directions are bitwise combinations of the primary (up, right,
 *  down and left) directions and you can test for these individually by ANDing
 *  it with the corresponding direction.
 *
 *  ```
 *  if (hats[2] & GLFW_HAT_RIGHT)
 *  {
 *      // State of hat 2 could be right-up, right or right-down
 *  }
 *  ```
 *
 *  If the specified joystick is not present this function will return `null`
 *  but will not generate an error.  This can be used instead of first calling
 *  @ref glfwJoystickPresent.
 *
 * Params:
 *  jid = The [joystick](@ref joysticks) to query.
 *  count = Where to store the number of hat states in the returned
 *  array.  This is set to zero if the joystick is not present or an error
 *  occurred.
 *  Returns: An array of hat states, or `null` if the joystick is not present
 *  or an [error](@ref error_handling) occurred.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED, @ref
 *  GLFW_INVALID_ENUM and @ref GLFW_PLATFORM_ERROR.
 *
 *  Pointer_lifetime: The returned array is allocated and freed by GLFW.  You
 *  should not free it yourself.  It is valid until the specified joystick is
 *  disconnected, this function is called again for that joystick or the library
 *  is terminated.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref joystick_hat
 *
 *  Since: Added in version 3.3.
 *
 *  Ingroup: input
 */
const(ubyte)* glfwGetJoystickHats(int jid, int* count);

/** Returns the name of the specified joystick.
 *
 *  This function returns the name, encoded as UTF-8, of the specified joystick.
 *  The returned string is allocated and freed by GLFW.  You should not free it
 *  yourself.
 *
 *  If the specified joystick is not present this function will return `null`
 *  but will not generate an error.  This can be used instead of first calling
 *  @ref glfwJoystickPresent.
 *
 * Params:
 *  jid = The [joystick](@ref joysticks) to query.
 *  Returns: The UTF-8 encoded name of the joystick, or `null` if the joystick
 *  is not present or an [error](@ref error_handling) occurred.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED, @ref
 *  GLFW_INVALID_ENUM and @ref GLFW_PLATFORM_ERROR.
 *
 *  Pointer_lifetime: The returned string is allocated and freed by GLFW.  You
 *  should not free it yourself.  It is valid until the specified joystick is
 *  disconnected or the library is terminated.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref joystick_name
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: input
 */
const(char)* glfwGetJoystickName(int jid);

/** Returns the SDL compatible GUID of the specified joystick.
 *
 *  This function returns the SDL compatible GUID, as a UTF-8 encoded
 *  hexadecimal string, of the specified joystick.  The returned string is
 *  allocated and freed by GLFW.  You should not free it yourself.
 *
 *  The GUID is what connects a joystick to a gamepad mapping.  A connected
 *  joystick will always have a GUID even if there is no gamepad mapping
 *  assigned to it.
 *
 *  If the specified joystick is not present this function will return `null`
 *  but will not generate an error.  This can be used instead of first calling
 *  @ref glfwJoystickPresent.
 *
 *  The GUID uses the format introduced in SDL 2.0.5.  This GUID tries to
 *  uniquely identify the make and model of a joystick but does not identify
 *  a specific unit, e.g. all wired Xbox 360 controllers will have the same
 *  GUID on that platform.  The GUID for a unit may vary between platforms
 *  depending on what hardware information the platform specific APIs provide.
 *
 * Params:
 *  jid = The [joystick](@ref joysticks) to query.
 *  Returns: The UTF-8 encoded GUID of the joystick, or `null` if the joystick
 *  is not present or an [error](@ref error_handling) occurred.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED, @ref
 *  GLFW_INVALID_ENUM and @ref GLFW_PLATFORM_ERROR.
 *
 *  Pointer_lifetime: The returned string is allocated and freed by GLFW.  You
 *  should not free it yourself.  It is valid until the specified joystick is
 *  disconnected or the library is terminated.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref gamepad
 *
 *  Since: Added in version 3.3.
 *
 *  Ingroup: input
 */
const(char)* glfwGetJoystickGUID(int jid);

/** Sets the user pointer of the specified joystick.
 *
 *  This function sets the user-defined pointer of the specified joystick.  The
 *  current value is retained until the joystick is disconnected.  The initial
 *  value is `null`.
 *
 *  This function may be called from the joystick callback, even for a joystick
 *  that is being disconnected.
 *
 * Params:
 *  jid = The joystick whose pointer to set.
 *  pointer = The new value.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED.
 *
 *  Thread_Safety: This function may be called from any thread.  Access is not
 *  synchronized.
 *
 *  @sa @ref joystick_userptr
 *  @sa @ref glfwGetJoystickUserPointer
 *
 *  Since: Added in version 3.3.
 *
 *  Ingroup: input
 */
void glfwSetJoystickUserPointer(int jid, void* pointer);

/** Returns the user pointer of the specified joystick.
 *
 *  This function returns the current value of the user-defined pointer of the
 *  specified joystick.  The initial value is `null`.
 *
 *  This function may be called from the joystick callback, even for a joystick
 *  that is being disconnected.
 *
 * Params:
 *  jid = The joystick whose pointer to return.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED.
 *
 *  Thread_Safety: This function may be called from any thread.  Access is not
 *  synchronized.
 *
 *  @sa @ref joystick_userptr
 *  @sa @ref glfwSetJoystickUserPointer
 *
 *  Since: Added in version 3.3.
 *
 *  Ingroup: input
 */
void* glfwGetJoystickUserPointer(int jid);

/** Returns whether the specified joystick has a gamepad mapping.
 *
 *  This function returns whether the specified joystick is both present and has
 *  a gamepad mapping.
 *
 *  If the specified joystick is present but does not have a gamepad mapping
 *  this function will return `GLFW_FALSE` but will not generate an error.  Call
 *  @ref glfwJoystickPresent to check if a joystick is present regardless of
 *  whether it has a mapping.
 *
 * Params:
 *  jid = The [joystick](@ref joysticks) to query.
 *  Returns: `GLFW_TRUE` if a joystick is both present and has a gamepad mapping,
 *  or `GLFW_FALSE` otherwise.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_INVALID_ENUM.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref gamepad
 *  @sa @ref glfwGetGamepadState
 *
 *  Since: Added in version 3.3.
 *
 *  Ingroup: input
 */
int glfwJoystickIsGamepad(int jid);

/** Sets the joystick configuration callback.
 *
 *  This function sets the joystick configuration callback, or removes the
 *  currently set callback.  This is called when a joystick is connected to or
 *  disconnected from the system.
 *
 *  For joystick connection and disconnection events to be delivered on all
 *  platforms, you need to call one of the [event processing](@ref events)
 *  functions.  Joystick disconnection may also be detected and the callback
 *  called by joystick functions.  The function will then return whatever it
 *  returns if the joystick is not present.
 *
 * Params:
 *  callback = The new callback, or `null` to remove the currently set
 *  callback.
 *  Returns: The previously set callback, or `null` if no callback was set or the
 *  library had not been [initialized](@ref intro_init).
 *
 *  @callback_signature
 *  ```
 *  void function_name(int jid, int event)
 *  ```
 *  For more information about the callback parameters, see the
 *  [function pointer type](@ref GLFWjoystickfun).
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref joystick_event
 *
 *  Since: Added in version 3.2.
 *
 *  Ingroup: input
 */
GLFWjoystickfun glfwSetJoystickCallback(GLFWjoystickfun callback);

/** Adds the specified SDL_GameControllerDB gamepad mappings.
 *
 *  This function parses the specified ASCII encoded string and updates the
 *  internal list with any gamepad mappings it finds.  This string may
 *  contain either a single gamepad mapping or many mappings separated by
 *  newlines.  The parser supports the full format of the `gamecontrollerdb.txt`
 *  source file including empty lines and comments.
 *
 *  See @ref gamepad_mapping for a description of the format.
 *
 *  If there is already a gamepad mapping for a given GUID in the internal list,
 *  it will be replaced by the one passed to this function.  If the library is
 *  terminated and re-initialized the internal list will revert to the built-in
 *  default.
 *
 * Params:
 *  string = The string containing the gamepad mappings.
 *  Returns: `GLFW_TRUE` if successful, or `GLFW_FALSE` if an
 *  [error](@ref error_handling) occurred.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_INVALID_VALUE.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref gamepad
 *  @sa @ref glfwJoystickIsGamepad
 *  @sa @ref glfwGetGamepadName
 *
 *  Since: Added in version 3.3.
 *
 *  Ingroup: input
 */
int glfwUpdateGamepadMappings(const(char)* string);

/** Returns the human-readable gamepad name for the specified joystick.
 *
 *  This function returns the human-readable name of the gamepad from the
 *  gamepad mapping assigned to the specified joystick.
 *
 *  If the specified joystick is not present or does not have a gamepad mapping
 *  this function will return `null` but will not generate an error.  Call
 *  @ref glfwJoystickPresent to check whether it is present regardless of
 *  whether it has a mapping.
 *
 * Params:
 *  jid = The [joystick](@ref joysticks) to query.
 *  Returns: The UTF-8 encoded name of the gamepad, or `null` if the
 *  joystick is not present, does not have a mapping or an
 *  [error](@ref error_handling) occurred.
 *
 *  Pointer_lifetime: The returned string is allocated and freed by GLFW.  You
 *  should not free it yourself.  It is valid until the specified joystick is
 *  disconnected, the gamepad mappings are updated or the library is terminated.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref gamepad
 *  @sa @ref glfwJoystickIsGamepad
 *
 *  Since: Added in version 3.3.
 *
 *  Ingroup: input
 */
const(char)* glfwGetGamepadName(int jid);

/** Retrieves the state of the specified joystick remapped as a gamepad.
 *
 *  This function retrieves the state of the specified joystick remapped to
 *  an Xbox-like gamepad.
 *
 *  If the specified joystick is not present or does not have a gamepad mapping
 *  this function will return `GLFW_FALSE` but will not generate an error.  Call
 *  @ref glfwJoystickPresent to check whether it is present regardless of
 *  whether it has a mapping.
 *
 *  The Guide button may not be available for input as it is often hooked by the
 *  system or the Steam client.
 *
 *  Not all devices have all the buttons or axes provided by @ref
 *  GLFWgamepadstate.  Unavailable buttons and axes will always report
 *  `GLFW_RELEASE` and 0.0 respectively.
 *
 * Params:
 *  jid = The [joystick](@ref joysticks) to query.
 *  state = The gamepad input state of the joystick.
 *  Returns: `GLFW_TRUE` if successful, or `GLFW_FALSE` if no joystick is
 *  connected, it has no gamepad mapping or an [error](@ref error_handling)
 *  occurred.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_INVALID_ENUM.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref gamepad
 *  @sa @ref glfwUpdateGamepadMappings
 *  @sa @ref glfwJoystickIsGamepad
 *
 *  Since: Added in version 3.3.
 *
 *  Ingroup: input
 */
int glfwGetGamepadState(int jid, GLFWgamepadstate* state);

// This version identifier needs to be defined because there might be breaking API changes,
// as of writing the pull request is not merged in the GLFW repository:
// https://github.com/glfw/glfw/pull/1678

/** Sets the intensity of a joystick's rumble effect.
 *
 *  This function sends vibration data to joysticks that implement haptic feedback
 *  effects using two vibration motors: a low-frequency motor, and a
 *  high-frequency motor.
 *
 *  Vibration intensity is a value between 0.0 and 1.0 inclusive, where 0.0 is no
 *  vibration, and 1.0 is maximum vibration. It is set separately for the
 *  joystick's low frequency and high frequency rumble motors.
 *
 *  If the specified joystick is not present or does not support the rumble effect,
 *  this function will return `GLFW_FALSE` but will not generate an error.
 *
 *  Params:
 *   jid = The [joystick](@ref joysticks) to vibrate.
 *   slowMotorIntensity = The low frequency vibration intensity.
 *   fastMotorIntensity = The high frequency vibration intensity.
 *  Returns: `GLFW_TRUE` if successful, or `GLFW_FALSE` if no joystick is connected,
 *  or the joystick does not support the rumble effect.
 *
 *  @errors Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_INVALID_ENUM.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  Note: @win32 This function is only implemented for XInput devices.
 *  Note: @macos This function is not implemented.
 *
 *  Ingroup: input
 */
int glfwSetJoystickRumble(int jid, float slowMotorIntensity, float fastMotorIntensity);

/** Sets the clipboard to the specified string.
 *
 *  This function sets the system clipboard to the specified, UTF-8 encoded
 *  string.
 *
 * Params:
 *  window = Deprecated.  Any valid window or `null`.
 *  string = A UTF-8 encoded string.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  Pointer_lifetime: The specified string is copied before this function
 *  returns.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref clipboard
 *  @sa @ref glfwGetClipboardString
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: input
 */
void glfwSetClipboardString(GLFWwindow* window, const(char)* string);

/** Returns the contents of the clipboard as a string.
 *
 *  This function returns the contents of the system clipboard, if it contains
 *  or is convertible to a UTF-8 encoded string.  If the clipboard is empty or
 *  if its contents cannot be converted, `null` is returned and a @ref
 *  GLFW_FORMAT_UNAVAILABLE error is generated.
 *
 * Params:
 *  window = Deprecated.  Any valid window or `null`.
 *  Returns: The contents of the clipboard as a UTF-8 encoded string, or `null`
 *  if an [error](@ref error_handling) occurred.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  Pointer_lifetime: The returned string is allocated and freed by GLFW.  You
 *  should not free it yourself.  It is valid until the next call to @ref
 *  glfwGetClipboardString or @ref glfwSetClipboardString, or until the library
 *  is terminated.
 *
 *  Thread_Safety: This function must only be called from the main thread.
 *
 *  @sa @ref clipboard
 *  @sa @ref glfwSetClipboardString
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: input
 */
const(char)* glfwGetClipboardString(GLFWwindow* window);

/** Returns the GLFW time.
 *
 *  This function returns the current GLFW time, in seconds.  Unless the time
 *  has been set using @ref glfwSetTime it measures time elapsed since GLFW was
 *  initialized.
 *
 *  This function and @ref glfwSetTime are helper functions on top of @ref
 *  glfwGetTimerFrequency and @ref glfwGetTimerValue.
 *
 *  The resolution of the timer is system dependent, but is usually on the order
 *  of a few micro- or nanoseconds.  It uses the highest-resolution monotonic
 *  time source on each supported platform.
 *
 *  Returns: The current time, in seconds, or zero if an
 *  [error](@ref error_handling) occurred.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED.
 *
 *  Thread_Safety: This function may be called from any thread.  Reading and
 *  writing of the internal base time is not atomic, so it needs to be
 *  externally synchronized with calls to @ref glfwSetTime.
 *
 *  @sa @ref time
 *
 *  Since: Added in version 1.0.
 *
 *  Ingroup: input
 */
double glfwGetTime();

/** Sets the GLFW time.
 *
 *  This function sets the current GLFW time, in seconds.  The value must be
 *  a positive finite number less than or equal to 18446744073.0, which is
 *  approximately 584.5 years.
 *
 *  This function and @ref glfwGetTime are helper functions on top of @ref
 *  glfwGetTimerFrequency and @ref glfwGetTimerValue.
 *
 * Params:
 *  time = The new value, in seconds.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_INVALID_VALUE.
 *
 *  @remark The upper limit of GLFW time is calculated as
 *  floor((2<sup>64</sup> - 1) / 10<sup>9</sup>) and is due to implementations
 *  storing nanoseconds in 64 bits.  The limit may be increased in the future.
 *
 *  Thread_Safety: This function may be called from any thread.  Reading and
 *  writing of the internal base time is not atomic, so it needs to be
 *  externally synchronized with calls to @ref glfwGetTime.
 *
 *  @sa @ref time
 *
 *  Since: Added in version 2.2.
 *
 *  Ingroup: input
 */
void glfwSetTime(double time);

/** Returns the current value of the raw timer.
 *
 *  This function returns the current value of the raw timer, measured in
 *  1&nbsp;/&nbsp;frequency seconds.  To get the frequency, call @ref
 *  glfwGetTimerFrequency.
 *
 *  Returns: The value of the timer, or zero if an
 *  [error](@ref error_handling) occurred.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED.
 *
 *  Thread_Safety: This function may be called from any thread.
 *
 *  @sa @ref time
 *  @sa @ref glfwGetTimerFrequency
 *
 *  Since: Added in version 3.2.
 *
 *  Ingroup: input
 */
ulong glfwGetTimerValue();

/** Returns the frequency, in Hz, of the raw timer.
 *
 *  This function returns the frequency, in Hz, of the raw timer.
 *
 *  Returns: The frequency of the timer, in Hz, or zero if an
 *  [error](@ref error_handling) occurred.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED.
 *
 *  Thread_Safety: This function may be called from any thread.
 *
 *  @sa @ref time
 *  @sa @ref glfwGetTimerValue
 *
 *  Since: Added in version 3.2.
 *
 *  Ingroup: input
 */
ulong glfwGetTimerFrequency();

/** Makes the context of the specified window current for the calling
 *  thread.
 *
 *  This function makes the OpenGL or OpenGL ES context of the specified window
 *  current on the calling thread.  A context must only be made current on
 *  a single thread at a time and each thread can have only a single current
 *  context at a time.
 *
 *  When moving a context between threads, you must make it non-current on the
 *  old thread before making it current on the new one.
 *
 *  By default, making a context non-current implicitly forces a pipeline flush.
 *  On machines that support `GL_KHR_context_flush_control`, you can control
 *  whether a context performs this flush by setting the
 *  [GLFW_CONTEXT_RELEASE_BEHAVIOR](@ref GLFW_CONTEXT_RELEASE_BEHAVIOR_hint)
 *  hint.
 *
 *  The specified window must have an OpenGL or OpenGL ES context.  Specifying
 *  a window without a context will generate a @ref GLFW_NO_WINDOW_CONTEXT
 *  error.
 *
 * Params:
 *  window = The window whose context to make current, or `null` to
 *  detach the current context.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED, @ref
 *  GLFW_NO_WINDOW_CONTEXT and @ref GLFW_PLATFORM_ERROR.
 *
 *  Thread_Safety: This function may be called from any thread.
 *
 *  @sa @ref context_current
 *  @sa @ref glfwGetCurrentContext
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: context
 */
void glfwMakeContextCurrent(GLFWwindow* window);

/** Returns the window whose context is current on the calling thread.
 *
 *  This function returns the window whose OpenGL or OpenGL ES context is
 *  current on the calling thread.
 *
 *  Returns: The window whose context is current, or `null` if no window's
 *  context is current.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED.
 *
 *  Thread_Safety: This function may be called from any thread.
 *
 *  @sa @ref context_current
 *  @sa @ref glfwMakeContextCurrent
 *
 *  Since: Added in version 3.0.
 *
 *  Ingroup: context
 */
GLFWwindow* glfwGetCurrentContext();

/** Swaps the front and back buffers of the specified window.
 *
 *  This function swaps the front and back buffers of the specified window when
 *  rendering with OpenGL or OpenGL ES.  If the swap interval is greater than
 *  zero, the GPU driver waits the specified number of screen updates before
 *  swapping the buffers.
 *
 *  The specified window must have an OpenGL or OpenGL ES context.  Specifying
 *  a window without a context will generate a @ref GLFW_NO_WINDOW_CONTEXT
 *  error.
 *
 *  This function does not apply to Vulkan.  If you are rendering with Vulkan,
 *  see `vkQueuePresentKHR` instead.
 *
 * Params:
 *  window = The window whose buffers to swap.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED, @ref
 *  GLFW_NO_WINDOW_CONTEXT and @ref GLFW_PLATFORM_ERROR.
 *
 *  @remark __EGL:__ The context of the specified window must be current on the
 *  calling thread.
 *
 *  Thread_Safety: This function may be called from any thread.
 *
 *  @sa @ref buffer_swap
 *  @sa @ref glfwSwapInterval
 *
 *  Since: Added in version 1.0.
 *  @glfw3 Added window handle parameter.
 *
 *  Ingroup: window
 */
void glfwSwapBuffers(GLFWwindow* window);

/** Sets the swap interval for the current context.
 *
 *  This function sets the swap interval for the current OpenGL or OpenGL ES
 *  context, i.e. the number of screen updates to wait from the time @ref
 *  glfwSwapBuffers was called before swapping the buffers and returning.  This
 *  is sometimes called _vertical synchronization_, _vertical retrace
 *  synchronization_ or just _vsync_.
 *
 *  A context that supports either of the `WGL_EXT_swap_control_tear` and
 *  `GLX_EXT_swap_control_tear` extensions also accepts _negative_ swap
 *  intervals, which allows the driver to swap immediately even if a frame
 *  arrives a little bit late.  You can check for these extensions with @ref
 *  glfwExtensionSupported.
 *
 *  A context must be current on the calling thread.  Calling this function
 *  without a current context will cause a @ref GLFW_NO_CURRENT_CONTEXT error.
 *
 *  This function does not apply to Vulkan.  If you are rendering with Vulkan,
 *  see the present mode of your swapchain instead.
 *
 * Params:
 *  interval = The minimum number of screen updates to wait for
 *  until the buffers are swapped by @ref glfwSwapBuffers.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED, @ref
 *  GLFW_NO_CURRENT_CONTEXT and @ref GLFW_PLATFORM_ERROR.
 *
 *  @remark This function is not called during context creation, leaving the
 *  swap interval set to whatever is the default on that platform.  This is done
 *  because some swap interval extensions used by GLFW do not allow the swap
 *  interval to be reset to zero once it has been set to a non-zero value.
 *
 *  @remark Some GPU drivers do not honor the requested swap interval, either
 *  because of a user setting that overrides the application's request or due to
 *  bugs in the driver.
 *
 *  Thread_Safety: This function may be called from any thread.
 *
 *  @sa @ref buffer_swap
 *  @sa @ref glfwSwapBuffers
 *
 *  Since: Added in version 1.0.
 *
 *  Ingroup: context
 */
void glfwSwapInterval(int interval);

/** Returns whether the specified extension is available.
 *
 *  This function returns whether the specified
 *  [API extension](@ref context_glext) is supported by the current OpenGL or
 *  OpenGL ES context.  It searches both for client API extension and context
 *  creation API extensions.
 *
 *  A context must be current on the calling thread.  Calling this function
 *  without a current context will cause a @ref GLFW_NO_CURRENT_CONTEXT error.
 *
 *  As this functions retrieves and searches one or more extension strings each
 *  call, it is recommended that you cache its results if it is going to be used
 *  frequently.  The extension strings will not change during the lifetime of
 *  a context, so there is no danger in doing this.
 *
 *  This function does not apply to Vulkan.  If you are using Vulkan, see @ref
 *  glfwGetRequiredInstanceExtensions, `vkEnumerateInstanceExtensionProperties`
 *  and `vkEnumerateDeviceExtensionProperties` instead.
 *
 * Params:
 *  extension = The ASCII encoded name of the extension.
 *  Returns: `GLFW_TRUE` if the extension is available, or `GLFW_FALSE`
 *  otherwise.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED, @ref
 *  GLFW_NO_CURRENT_CONTEXT, @ref GLFW_INVALID_VALUE and @ref
 *  GLFW_PLATFORM_ERROR.
 *
 *  Thread_Safety: This function may be called from any thread.
 *
 *  @sa @ref context_glext
 *  @sa @ref glfwGetProcAddress
 *
 *  Since: Added in version 1.0.
 *
 *  Ingroup: context
 */
int glfwExtensionSupported(const(char)* extension);

/** Returns the address of the specified function for the current
 *  context.
 *
 *  This function returns the address of the specified OpenGL or OpenGL ES
 *  [core or extension function](@ref context_glext), if it is supported
 *  by the current context.
 *
 *  A context must be current on the calling thread.  Calling this function
 *  without a current context will cause a @ref GLFW_NO_CURRENT_CONTEXT error.
 *
 *  This function does not apply to Vulkan.  If you are rendering with Vulkan,
 *  see @ref glfwGetInstanceProcAddress, `vkGetInstanceProcAddr` and
 *  `vkGetDeviceProcAddr` instead.
 *
 * Params:
 *  procname = The ASCII encoded name of the function.
 *  Returns: The address of the function, or `null` if an
 *  [error](@ref error_handling) occurred.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED, @ref
 *  GLFW_NO_CURRENT_CONTEXT and @ref GLFW_PLATFORM_ERROR.
 *
 *  @remark The address of a given function is not guaranteed to be the same
 *  between contexts.
 *
 *  @remark This function may return a non-`null` address despite the
 *  associated version or extension not being available.  Always check the
 *  context version or extension string first.
 *
 *  Pointer_lifetime: The returned function pointer is valid until the context
 *  is destroyed or the library is terminated.
 *
 *  Thread_Safety: This function may be called from any thread.
 *
 *  @sa @ref context_glext
 *  @sa @ref glfwExtensionSupported
 *
 *  Since: Added in version 1.0.
 *
 *  Ingroup: context
 */
GLFWglproc glfwGetProcAddress(const(char)* procname);

/** Returns whether the Vulkan loader and an ICD have been found.
 *
 *  This function returns whether the Vulkan loader and any minimally functional
 *  ICD have been found.
 *
 *  The availability of a Vulkan loader and even an ICD does not by itself
 *  guarantee that surface creation or even instance creation is possible.
 *  For example, on Fermi systems Nvidia will install an ICD that provides no
 *  actual Vulkan support.  Call @ref glfwGetRequiredInstanceExtensions to check
 *  whether the extensions necessary for Vulkan surface creation are available
 *  and @ref glfwGetPhysicalDevicePresentationSupport to check whether a queue
 *  family of a physical device supports image presentation.
 *
 *  Returns: `GLFW_TRUE` if Vulkan is minimally available, or `GLFW_FALSE`
 *  otherwise.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED.
 *
 *  Thread_Safety: This function may be called from any thread.
 *
 *  @sa @ref vulkan_support
 *
 *  Since: Added in version 3.2.
 *
 *  Ingroup: vulkan
 */
int glfwVulkanSupported();

/** Returns the Vulkan instance extensions required by GLFW.
 *
 *  This function returns an array of names of Vulkan instance extensions required
 *  by GLFW for creating Vulkan surfaces for GLFW windows.  If successful, the
 *  list will always contain `VK_KHR_surface`, so if you don't require any
 *  additional extensions you can pass this list directly to the
 *  `VkInstanceCreateInfo` struct.
 *
 *  If Vulkan is not available on the machine, this function returns `null` and
 *  generates a @ref GLFW_API_UNAVAILABLE error.  Call @ref glfwVulkanSupported
 *  to check whether Vulkan is at least minimally available.
 *
 *  If Vulkan is available but no set of extensions allowing window surface
 *  creation was found, this function returns `null`.  You may still use Vulkan
 *  for off-screen rendering and compute work.
 *
 * Params:
 *  count = Where to store the number of extensions in the returned
 *  array.  This is set to zero if an error occurred.
 *  Returns: An array of ASCII encoded extension names, or `null` if an
 *  [error](@ref error_handling) occurred.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_API_UNAVAILABLE.
 *
 *  @remark Additional extensions may be required by future versions of GLFW.
 *  You should check if any extensions you wish to enable are already in the
 *  returned array, as it is an error to specify an extension more than once in
 *  the `VkInstanceCreateInfo` struct.
 *
 *  @remark @macos This function currently supports either the
 *  `VK_MVK_macos_surface` extension from MoltenVK or `VK_EXT_metal_surface`
 *  extension.
 *
 *  Pointer_lifetime: The returned array is allocated and freed by GLFW.  You
 *  should not free it yourself.  It is guaranteed to be valid only until the
 *  library is terminated.
 *
 *  Thread_Safety: This function may be called from any thread.
 *
 *  @sa @ref vulkan_ext
 *  @sa @ref glfwCreateWindowSurface
 *
 *  Since: Added in version 3.2.
 *
 *  Ingroup: vulkan
 */
const(char)** glfwGetRequiredInstanceExtensions(uint* count);

version(VK_VERSION_1_0) {

import glfw3.vulkan;
import glfw3.internal;

/** Returns the address of the specified Vulkan instance function.
 *
 *  This function returns the address of the specified Vulkan core or extension
 *  function for the specified instance.  If instance is set to `null` it can
 *  return any function exported from the Vulkan loader, including at least the
 *  following functions:
 *
 *  - `vkEnumerateInstanceExtensionProperties`
 *  - `vkEnumerateInstanceLayerProperties`
 *  - `vkCreateInstance`
 *  - `vkGetInstanceProcAddr`
 *
 *  If Vulkan is not available on the machine, this function returns `null` and
 *  generates a @ref GLFW_API_UNAVAILABLE error.  Call @ref glfwVulkanSupported
 *  to check whether Vulkan is at least minimally available.
 *
 *  This function is equivalent to calling `vkGetInstanceProcAddr` with
 *  a platform-specific query of the Vulkan loader as a fallback.
 *
 * Params:
 *  instance = The Vulkan instance to query, or `null` to retrieve
 *  functions related to instance creation.
 *  procname = The ASCII encoded name of the function.
 *  Returns: The address of the function, or `null` if an
 *  [error](@ref error_handling) occurred.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED and @ref
 *  GLFW_API_UNAVAILABLE.
 *
 *  Pointer_lifetime: The returned function pointer is valid until the library
 *  is terminated.
 *
 *  Thread_Safety: This function may be called from any thread.
 *
 *  @sa @ref vulkan_proc
 *
 *  Since: Added in version 3.2.
 *
 *  Ingroup: vulkan
 */
GLFWvkproc glfwGetInstanceProcAddress(VkInstance instance, const(char)* procname);

/** Returns whether the specified queue family can present images.
 *
 *  This function returns whether the specified queue family of the specified
 *  physical device supports presentation to the platform GLFW was built for.
 *
 *  If Vulkan or the required window surface creation instance extensions are
 *  not available on the machine, or if the specified instance was not created
 *  with the required extensions, this function returns `GLFW_FALSE` and
 *  generates a @ref GLFW_API_UNAVAILABLE error.  Call @ref glfwVulkanSupported
 *  to check whether Vulkan is at least minimally available and @ref
 *  glfwGetRequiredInstanceExtensions to check what instance extensions are
 *  required.
 *
 * Params:
 *  instance = The instance that the physical device belongs to.
 *  device = The physical device that the queue family belongs to.
 *  queuefamily = The index of the queue family to query.
 *  Returns: `GLFW_TRUE` if the queue family supports presentation, or
 *  `GLFW_FALSE` otherwise.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED, @ref
 *  GLFW_API_UNAVAILABLE and @ref GLFW_PLATFORM_ERROR.
 *
 *  @remark @macos This function currently always returns `GLFW_TRUE`, as the
 *  `VK_MVK_macos_surface` extension does not provide
 *  a `vkGetPhysicalDevice*PresentationSupport` type function.
 *
 *  Thread_Safety: This function may be called from any thread.  For
 *  synchronization details of Vulkan objects, see the Vulkan specification.
 *
 *  @sa @ref vulkan_present
 *
 *  Since: Added in version 3.2.
 *
 *  Ingroup: vulkan
 */
int glfwGetPhysicalDevicePresentationSupport(VkInstance instance, VkPhysicalDevice device, uint queuefamily);

/** Creates a Vulkan surface for the specified window.
 *
 *  This function creates a Vulkan surface for the specified window.
 *
 *  If the Vulkan loader or at least one minimally functional ICD were not found,
 *  this function returns `VK_ERROR_INITIALIZATION_FAILED` and generates a @ref
 *  GLFW_API_UNAVAILABLE error.  Call @ref glfwVulkanSupported to check whether
 *  Vulkan is at least minimally available.
 *
 *  If the required window surface creation instance extensions are not
 *  available or if the specified instance was not created with these extensions
 *  enabled, this function returns `VK_ERROR_EXTENSION_NOT_PRESENT` and
 *  generates a @ref GLFW_API_UNAVAILABLE error.  Call @ref
 *  glfwGetRequiredInstanceExtensions to check what instance extensions are
 *  required.
 *
 *  The window surface cannot be shared with another API so the window must
 *  have been created with the [client api hint](@ref GLFW_CLIENT_API_attrib)
 *  set to `GLFW_NO_API` otherwise it generates a @ref GLFW_INVALID_VALUE error
 *  and returns `VK_ERROR_NATIVE_WINDOW_IN_USE_KHR`.
 *
 *  The window surface must be destroyed before the specified Vulkan instance.
 *  It is the responsibility of the caller to destroy the window surface.  GLFW
 *  does not destroy it for you.  Call `vkDestroySurfaceKHR` to destroy the
 *  surface.
 *
 * Params:
 *  instance = The Vulkan instance to create the surface in.
 *  window = The window to create the surface for.
 *  allocator = The allocator to use, or `null` to use the default
 *  allocator.
 *  surface = Where to store the handle of the surface.  This is set
 *  to `VK_null_HANDLE` if an error occurred.
 *  Returns: `VK_SUCCESS` if successful, or a Vulkan error code if an
 *  [error](@ref error_handling) occurred.
 *
 *  Errors: Possible errors include @ref GLFW_NOT_INITIALIZED, @ref
 *  GLFW_API_UNAVAILABLE, @ref GLFW_PLATFORM_ERROR and @ref GLFW_INVALID_VALUE
 *
 *  @remark If an error occurs before the creation call is made, GLFW returns
 *  the Vulkan error code most appropriate for the error.  Appropriate use of
 *  @ref glfwVulkanSupported and @ref glfwGetRequiredInstanceExtensions should
 *  eliminate almost all occurrences of these errors.
 *
 *  @remark @macos This function currently only supports the
 *  `VK_MVK_macos_surface` extension from MoltenVK.
 *
 *  @remark @macos This function creates and sets a `CAMetalLayer` instance for
 *  the window content view, which is required for MoltenVK to function.
 *
 *  Thread_Safety: This function may be called from any thread.  For
 *  synchronization details of Vulkan objects, see the Vulkan specification.
 *
 *  @sa @ref vulkan_surface
 *  @sa @ref glfwGetRequiredInstanceExtensions
 *
 *  Since: Added in version 3.2.
 *
 *  Ingroup: vulkan
 */
VkResult glfwCreateWindowSurface(VkInstance instance, GLFWwindow* window, const(VkAllocationCallbacks)* allocator, VkSurfaceKHR* surface);

} /*VK_VERSION_1_0*/
