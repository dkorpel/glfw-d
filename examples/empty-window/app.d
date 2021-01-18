/// Simple example of a GLFW application that creates a black window and reads some input and output
///
/// Does not load OpenGL / Vulkan.
module app;

import glfw3.api;
import core.stdc.stdio;

int main() {
	GLFWwindow* window;
	glfwSetErrorCallback(&errorCallback);

	if (!glfwInit()) {
		return -1;
	}
	scope(exit) glfwTerminate();

	printClipboardState();
	printJoystickState();
	printMonitorState();

	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0);

	WindowData data;
	window = glfwCreateWindow(800, 600, "Black window - press F11 to toggle fullscreen, press ESC to exit", null, null);
	scope(exit) glfwDestroyWindow(window);
	if (!window) {
		glfwTerminate();
		return -1;
	}
	glfwSetWindowUserPointer(window, &data);

	glfwSetKeyCallback(window, &keyCallback);
	glfwMakeContextCurrent(window);
	glfwSwapInterval(1); // Set vsync on so glfwSwapBuffers will wait for monitor updates.
	// note: 1 is not a boolean! Set e.g. to 2 to run at half the monitor refresh rate.

	double oldTime = glfwGetTime();
	while (!glfwWindowShouldClose(window)) {
		const newTime = glfwGetTime();
		const elapsedTime = newTime - oldTime;
		oldTime = newTime;

		glfwSwapBuffers(window);
		glfwPollEvents();
	}
	return 0;
}

/// Data stored in the window's user pointer
///
/// Note: assuming you only have one window, you could make these global variables.
struct WindowData {
	// These are stored in the window's user data so that when exiting fullscreen,
	// the window can be set to the position where it was before entering fullscreen
	// instead of resetting to e.g. (0, 0)
	int xpos;
	int ypos;
	int width;
	int height;

	@nogc nothrow void update(GLFWwindow* window) {
		glfwGetWindowPos(window, &this.xpos, &this.ypos);
		glfwGetWindowSize(window, &this.width, &this.height);
	}
}

extern(C) @nogc nothrow void errorCallback(int error, const(char)* description) {
	fprintf(stderr, "Error: %s\n", description);
}

extern(C) @nogc nothrow void keyCallback(GLFWwindow* window, int key, int scancode, int action, int mods) {
	if (action == GLFW_PRESS) {
		switch (key) {
			case GLFW_KEY_ESCAPE:
				glfwSetWindowShouldClose(window, GLFW_TRUE);
				break;
			case GLFW_KEY_F11:
				toggleFullScreen(window);
				break;
			default: break;
		}
	}
}

@nogc nothrow void toggleFullScreen(GLFWwindow* window) {
	WindowData* wd = cast(WindowData*) glfwGetWindowUserPointer(window);
	assert(wd);
	if (glfwGetWindowMonitor(window)) {
		glfwSetWindowMonitor(window, null, wd.xpos, wd.ypos, wd.width, wd.height, 0);
	} else {
		GLFWmonitor* monitor = glfwGetPrimaryMonitor();
		if (monitor) {
			const GLFWvidmode* mode = glfwGetVideoMode(monitor);
			wd.update(window);
			glfwSetWindowMonitor(window, monitor, 0, 0, mode.width, mode.height, mode.refreshRate);
		}
	}
}

void printClipboardState() {
	printf("Clipboard contents: `%s.80`\n", glfwGetClipboardString(null));
}

void printMonitorState() {
	int monitorsLength;
	GLFWmonitor** monitorsPtr = glfwGetMonitors(&monitorsLength);
	GLFWmonitor*[] monitors = monitorsPtr[0..monitorsLength];

	foreach(GLFWmonitor* mt; monitors) {
		int widthMM, heightMM;
		int xpos, ypos, width, height;
		glfwGetMonitorPos(mt, &xpos, &ypos);
		glfwGetMonitorPhysicalSize(mt, &widthMM, &heightMM);
		const(GLFWvidmode)* mode = glfwGetVideoMode(mt);
		printf("Monitor `%s` has size %dx%d mm\n", glfwGetMonitorName(mt), widthMM, heightMM);
		printf("  current video mode: %dx%d %dHz r%dg%db%d\n", mode.width, mode.height, mode.refreshRate, mode.redBits, mode.greenBits, mode.blueBits);
		printf("  position: %d, %d\n", xpos, ypos);
		glfwGetMonitorWorkarea(mt, &xpos, &ypos, &width, &height);
		printf("  work area: %d, %d to %d, %d\n", xpos, ypos, width, height);
	}
}

void printJoystickState() {
	for (int js = GLFW_JOYSTICK_1; js <= GLFW_JOYSTICK_LAST; js++) {
		if (glfwJoystickPresent(js)) {
			//glfwSetJoystickRumble(js, /*slow*/ 0.25, /*fast*/ 0.25);
			printf("Joystick %d has name `%s` and GUID `%s`\n", js, glfwGetJoystickName(js), glfwGetJoystickGUID(js));
			int buttonsLength, axesLength, hatsLength;
			const(ubyte)* buttonsPtr = glfwGetJoystickButtons(js, &buttonsLength);
			const(float)* axesPtr = glfwGetJoystickAxes(js, &axesLength);
			const(ubyte)* hatsPtr = glfwGetJoystickHats(js, &hatsLength);
			const(ubyte)[] buttons = buttonsPtr[0..buttonsLength];
			const(float)[] axes = axesPtr[0..axesLength];
			const(ubyte)[] hats = hatsPtr[0..hatsLength];

			if (glfwJoystickIsGamepad(js)) {
				printf("  It is a gamepad with name `%s`\n", glfwGetGamepadName(js));
				GLFWgamepadstate state;
				if (glfwGetGamepadState(js, &state)) {
					//
					printf("Left stick: %f,%f\n", state.axes[GLFW_GAMEPAD_AXIS_LEFT_X], state.axes[GLFW_GAMEPAD_AXIS_LEFT_Y]);
					printf("A: %d, B: %d\n", state.buttons[GLFW_GAMEPAD_BUTTON_A], state.buttons[GLFW_GAMEPAD_BUTTON_B]);
				}
			}
		} else {
			//printf("Joystick %d not present\n", js);
		}
	}
}
