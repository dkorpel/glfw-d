/// Simple example of a GLFW application that opens a window and draws a colored triangle
module app;

private: nothrow: @nogc:

import glfw3.api;
import bindbc.opengl;
import core.stdc.stdio;

int main() {
	GLFWwindow* window;
	glfwSetErrorCallback(&errorCallback);

	if (!glfwInit()) {
		return -1;
	}
	scope(exit) glfwTerminate();

	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);

	window = glfwCreateWindow(800, 600, "OpenGL Triangle", null, null);
	scope(exit) glfwDestroyWindow(window);
	if (!window) {
		return -1;
	}

	glfwMakeContextCurrent(window);
	glfwSwapInterval(1); // Set vsync on so glfwSwapBuffers will wait for monitor updates.
	// note: 1 is not a boolean! Set e.g. to 2 to run at half the monitor refresh rate.

	GLSupport retVal = loadOpenGL();
	if (retVal == GLSupport.badLibrary || retVal == GLSupport.noLibrary) {
		return -1;
	}

	const GLuint program = getProgram();
	const GLuint vaoTriangle = getTriangleVao();
	const GLint mvp_location = glGetUniformLocation(program, "MVP");

	double oldTime = glfwGetTime();
	while (!glfwWindowShouldClose(window)) {
		const newTime = glfwGetTime();
		const elapsedTime = newTime - oldTime;
		oldTime = newTime;

		int width, height;
		glfwGetFramebufferSize(window, &width, &height);
		const float ratio = width / cast(float) height;
		glViewport(0, 0, width, height);

		glUseProgram(program);
		glBindVertexArray(vaoTriangle);
		glDrawArrays(GL_TRIANGLES, 0, 3);

		glfwSwapBuffers(window);
		glfwPollEvents();
	}
	return 0;
}

extern(C) @nogc nothrow void errorCallback(int error, const(char)* description) {
	fprintf(stderr, "Error: %s\n", description);
}

// SHADER PROGRAM /////////////////////////

immutable string vertexShaderSource = "#version 330
uniform mat4 MVP;
layout(location = 0) in vec2 position;
layout(location = 1) in vec3 color;
out vec3 fragColor;
void main() {
	gl_Position = vec4(position, 0.0, 1.0); // MVP *
	fragColor = color;
}";

immutable string fragmentShaderSource = "#version 330
in vec3 fragColor;
out vec4 outColor;
void main() {
	outColor = vec4(fragColor, 1.0);
}";

GLuint getProgram() {
	const GLint vertexShader = glCreateShader(GL_VERTEX_SHADER);
	{
		const GLint[1] lengths = [vertexShaderSource.length];
		const(char)*[1] sources = [vertexShaderSource.ptr];
		glShaderSource(vertexShader, 1, sources.ptr, lengths.ptr);
		glCompileShader(vertexShader);
	}
	const GLint fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
	{
		const GLint[1] lengths = [fragmentShaderSource.length];
		const(char)*[1] sources = [fragmentShaderSource.ptr];
		glShaderSource(fragmentShader, 1, sources.ptr, lengths.ptr);
		glCompileShader(fragmentShader);
	}

	const GLuint program = glCreateProgram();
	glAttachShader(program, vertexShader);
	glAttachShader(program, fragmentShader);
	glLinkProgram(program);
	return program;
}

// MODEL /////////////////////////

struct Vertex {
	float[2] position;
	float[3] color;
}

immutable Vertex[3] vertices = [
	Vertex([-0.6f, -0.4f], [1.0f, 0.0f, 0.0f]),
	Vertex([ 0.6f, -0.4f], [0.0f, 1.0f, 0.0f]),
	Vertex([ 0.0f,  0.6f], [0.0f, 0.0f, 1.0f]),
];

GLuint getTriangleVao() {
	// Upload data to GPU
	GLuint vbo;
	glGenBuffers(1, &vbo);
	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	glBufferData(GL_ARRAY_BUFFER, vertices.sizeof, vertices.ptr, /*usage hint*/ GL_STATIC_DRAW);

	// Describe layout of data for the shader program
	GLuint vao;
	glGenVertexArrays(1, &vao);
	glBindVertexArray(vao);

	glEnableVertexAttribArray(0);
	glVertexAttribPointer(
		/*location*/ 0, /*num elements*/ 2, /*base type*/ GL_FLOAT, /*normalized*/ GL_FALSE,
		Vertex.sizeof, cast(void*) Vertex.position.offsetof
	);
	glEnableVertexAttribArray(1);
	glVertexAttribPointer(
		/*location*/ 1, /*num elements*/ 3, /*base type*/ GL_FLOAT, /*normalized*/ GL_FALSE,
		Vertex.sizeof, cast(void*) Vertex.color.offsetof
	);

	return vao;
}
