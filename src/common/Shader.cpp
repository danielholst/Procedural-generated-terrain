#include "Shader.hpp"
#include <iostream>

/*
 * Constructor without arguments.
 * Creates an "empty" (invalid) shader program.
 */
Shader::Shader() {
    this->programID = 0;
}


/*
 * Constructor with two file name arguments:
 * one for the vertex shader, one for the fragment shader.
 * Loads the named files, compiles the shaders and
 * assembles the shader program.
 */
Shader::Shader(const char *vertexshaderfile, const char *fragmentshaderfile) {
    this->createShader(vertexshaderfile, fragmentshaderfile);
}


/*
 * Destructor.
 * Cleans up by deleting the program if it was compiled.
 */
Shader::~Shader() {
    if(programID != 0)
        glDeleteProgram(programID);
}


/*
 * createShader() - create, load, compile and link the GLSL Shader objects.
 */
void Shader::createShader(const char *vertexshaderfile, const char *fragmentshaderfile) {

    GLuint programObject;
    GLuint vertexShader;
    GLuint fragmentShader;
    const char *vertexShaderStrings[1];
    const char *fragmentShaderStrings[1];
	unsigned char *vertexShaderAssembly;
	unsigned char *fragmentShaderAssembly;
    
    GLint vertexCompiled;
    GLint fragmentCompiled;
    GLint shadersLinked;
    char str[4096]; // For error messages from the GLSL compiler and linker

    // If a program is already stored in this object, delete it
    if(programID != 0)
        glDeleteProgram(programID);

    // Create the vertex shader.
    vertexShader = glCreateShader(GL_VERTEX_SHADER);

    vertexShaderAssembly = readShaderFile(vertexshaderfile);
    if(vertexShaderAssembly) { // Don't try to use a NULL pointer
        vertexShaderStrings[0] = (char*)vertexShaderAssembly;
        glShaderSource(vertexShader, 1, vertexShaderStrings, NULL);
        glCompileShader(vertexShader);
        delete[] vertexShaderAssembly;
    }

    glGetShaderiv(vertexShader, GL_COMPILE_STATUS,
                               &vertexCompiled);
    if(vertexCompiled  == GL_FALSE)
  	{
        glGetShaderInfoLog(vertexShader, sizeof(str), NULL, str);
        printError("Vertex shader compile error", str);
  	}

  	// Create the fragment shader.
    fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);

    fragmentShaderAssembly = readShaderFile(fragmentshaderfile);
    if(fragmentShaderAssembly) { // Don't try to use a NULL pointer
    	fragmentShaderStrings[0] = (char*)fragmentShaderAssembly;
        glShaderSource(fragmentShader, 1, fragmentShaderStrings, NULL);
        glCompileShader(fragmentShader);
        delete[] fragmentShaderAssembly;
    }

    glGetProgramiv(fragmentShader, GL_COMPILE_STATUS, &fragmentCompiled);
    if(fragmentCompiled == GL_FALSE)
   	{
        glGetShaderInfoLog(fragmentShader, sizeof(str), NULL, str);
        printError("Fragment shader compile error ", str);
    }

    // Create a program object and attach the two compiled shaders.
    programObject = glCreateProgram();
    glAttachShader(programObject, vertexShader);
    glAttachShader(programObject, fragmentShader);

    // Link the program object and print out the info log.
    glLinkProgram(programObject);
    glGetProgramiv(programObject, GL_LINK_STATUS, &shadersLinked);

    if(shadersLinked == GL_FALSE)
	{
		glGetProgramInfoLog( programObject, sizeof(str), NULL, str );
		printError("Program object linking error", str);
	}
	glDeleteShader(vertexShader);   // After successful linking,
	glDeleteShader(fragmentShader); // these are no longer needed

	programID = programObject; // Save this value in the class variable
}


/*
 * private
 * printError() - Signal an error.
 * Simple printf() to console for portability.
 */
void Shader::printError(const char *errtype, const char *errmsg) {
  fprintf(stderr, "%s: %s\n", errtype, errmsg);
}


/*
 * private
 * filelength()
 * Override the Win32 filelength() function with
 * a version that takes a Unix-style file handle as
 * input instead of a file ID number, and which works
 * on platforms other than Windows.
 */
long Shader::filelength(FILE *file) {
    long numbytes;
    long savedpos = ftell(file); // Remember where we are
    fseek(file, 0, SEEK_END);    // Fast forward to the end
    numbytes = ftell(file);      // Index of last byte in file
    fseek(file, savedpos, SEEK_SET); // Get back to where we were
    return numbytes;             // This is the file length
}


/*
 * private
 * readShaderFile(filename) - read a shader source string from a file
 */
unsigned char* Shader::readShaderFile(const char *filename) {
    FILE *file = fopen(filename, "r");
    if(file == NULL)
    {
        printError("ERROR", "Cannot open shader file!");
  		  return 0;
    }
    int bytesinfile = filelength(file);
    unsigned char *buffer = new unsigned char[bytesinfile+1];
    int bytesread = fread( buffer, 1, bytesinfile, file);
    buffer[bytesread] = 0; // Terminate the string with 0
    fclose(file);

    return buffer;
}
