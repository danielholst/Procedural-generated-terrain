/* Shader.hpp */
/* A class to load and compile GLSL shaders from files. */
/* Usage: call createShader() to load and compile a program object,
 * or use the constructor with two file name arguments.
 * Call glUseProgram() with the public member programID as argument. */
/* Stefan Gustavson (stefan.gustavson@liu.se) 2014-03-27 */

#ifndef SHADER_HPP // Avoid including this header twice
#define SHADER_HPP

#ifdef __APPLE__
#define GLFW_INCLUDE_GLCOREARB
#endif

#include <GLFW/glfw3.h>
#include "Utilities.hpp" // For OpenGL extensions
#include <cstdio>

class Shader {

public:

GLuint programID;

/* Argument-less constructor. Creates an invalid shader program. */
Shader();

/* Constructor to create, load and compile a Shader program in one blow. */
Shader(const char *vertexshaderfile, const char *fragmentshaderfile);

/* Destructor */
~Shader();

/*
 * createShader() - create, load, compile and link the GLSL shader objects.
 */
void createShader(const char *vertexshaderfile, const char *fragmentshaderfile);

private:

/*
 * Override the Win32 filelength() function with
 * a version that takes a Unix-style file handle as
 * input instead of a file ID number, and which works
 * on platforms other than Windows.
 */
long filelength(FILE *file);

/*
 * readShaderFile(filename) - read a shader source string from a file
 */
unsigned char* readShaderFile(const char *filename);

void printError(const char *errtype, const char *errmsg);

};

#endif // SHADER_HPP
