/*
 * A C++ framework for OpenGL programming in TNM046 for MT1 2014.
 *
 * This is a small, limited framework, designed to be easy to use
 * for students in an introductory computer graphics course in
 * the first year of a M Sc curriculum. It uses custom code
 * for some things that are better solved by external libraries
 * like GLEW and GLM, but the emphasis is on simplicity and
 * readability, not generality.
 * For the window management, GLFW 3.0 is used for convenience.
 * The framework should work in Windows, MacOS X and Linux.
 * Some Windows-specific stuff for extension loading is still
 * here. GLEW could have been used instead, but for clarity
 * and minimal dependence on other code, we rolled our own extension
 * loading for the things we need. That code is short-circuited on
 * platforms other than Windows. This code is dependent only on
 * the GLFW and OpenGL libraries. OpenGL 3.3 or higher is required.
 *
 * Author: Stefan Gustavson (stegu@itn.liu.se) 2013-2014
 * This code is in the public domain.
 */

// File and console I/O for logging and error reporting
#include <iostream>
#include "TriangleSoup.hpp"
#include "Utilities.hpp"
#include "Shader.hpp"
#include "glm/glm.hpp"
#include "glm/gtc/matrix_transform.hpp"
#include "glm/gtx/transform.hpp"
#include "glm/gtc/type_ptr.hpp"
#include "camera.hpp"
#include "noise1234.hpp"

// In MacOS X, tell GLFW to include the modern OpenGL headers.
// Windows does not want this, so we make this Mac-only.
#ifdef __APPLE__
#define GLFW_INCLUDE_GLCOREARB
#endif

// GLFW 3.x, to handle the OpenGL window
#include <GLFW/glfw3.h>

using namespace std;

int width = 800;
int height = 600;

/*
 * main(argc, argv) - the standard C++ entry point for the program
 */
int main(int argc, char *argv[]) {

    // shaders
    Shader sphereShader;
    Shader planeShader;
    Shader waterShader;

    // ID
    GLuint sphereID;
    GLuint planeID;
    GLuint waterID;
    GLint location_time;
    GLint location_rotMat1;
    GLint location_rotMat2;
    GLint location_rotMat3;
    GLint light_pos1;
    GLint light_pos2;
    GLint light_pos3;
    GLint eye_pos1;
    GLint eye_pos2;
    GLint eye_pos3;
    
    //objects
    TriangleSoup sphere;
    TriangleSoup water;
    TriangleSoup terrain;

    // time
    float time;  
    
    // rotation
    glm::vec3 myRotationAxis;
    glm::mat4 rotMat (1.0f);

    const GLFWvidmode *vidmode;  // GLFW struct to hold information about the display
	GLFWwindow *window;    // GLFW struct to hold information about the window

    // Initialise GLFW
    glfwInit();

    // Determine the desktop size
    vidmode = glfwGetVideoMode(glfwGetPrimaryMonitor());

	// Make sure we are getting a GL context of at least version 3.3
	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
	// Exclude old legacy cruft from the context. We don't need it, and we don't want it.
	glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
	glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);

    // Open a square window (aspect 1:1) to fill half the screen height
    window = glfwCreateWindow(width, height, "Scene", NULL, NULL);
    if (!window)
    {
        cout << "Unable to open window. Terminating." << endl;
        glfwTerminate(); // No window was opened, so we can't continue in any useful way
        return -1;
    }

    // Make the newly created window the "current context" for OpenGL
    glfwMakeContextCurrent(window);

    // create shaders
    sphereShader.createShader("sphereShaderVert.glsl", "sphereShaderFrag.glsl");
    planeShader.createShader("planeShaderVert.glsl", "planeShaderFrag.glsl");
    waterShader.createShader("waterShaderVert.glsl", "waterShaderFrag.glsl");

    // load objects
    sphere.createSphere(15, 40);
    terrain.readOBJ("plane2.obj");
    water.readOBJ("plane2.obj");

    // define light position
    float lightPos[3] = {0.0, 4.0, 14.0};

    //camera
    Camera camera(glm::perspective(glm::radians(45.0f),
                 (float)width / (float)height, 0.1f, 100.0f),
                  glm::vec3(0.0, 0.3, -5.0), glm::vec3(0, 0, 1), glm::vec3(0.0f, 1.0f, 0.0f));

    // transformation of objects
    glm::mat4 Model = glm::translate(glm::vec3(0, 0.0, 0));
    glm::mat4 sphereMVP;
    glm::mat4 waterTrans = glm::translate(glm::vec3(0, -0.4, -8.0));
    waterTrans += glm::scale(glm::vec3(3.0, 1.0, 1.5));
    glm::mat4 waterMVP;
    
    glm::mat4 planeTrans = glm::translate(glm::vec3(0, 0, 4.0));
    planeTrans += glm::scale(glm::vec3(1.5, 1.0, 3.0));
    glm::mat4 planeMVP;

    // set uniforms
    sphereID = glGetUniformLocation(sphereShader.programID, "MVP");
    planeID = glGetUniformLocation(planeShader.programID, "MVP");
    waterID = glGetUniformLocation(waterShader.programID, "MVP");

    location_rotMat1 = glGetUniformLocation(sphereShader.programID, "rotMat");
    location_rotMat2 = glGetUniformLocation(planeShader.programID, "rotMat");
    location_rotMat3 = glGetUniformLocation(waterShader.programID, "rotMat");
    
    light_pos1 = glGetUniformLocation(sphereShader.programID, "lightPos");
    light_pos2 = glGetUniformLocation(planeShader.programID, "lightPos");
    light_pos3 = glGetUniformLocation(waterShader.programID, "lightPos");

    eye_pos1 = glGetUniformLocation(sphereShader.programID, "eyePosition");
    eye_pos2 = glGetUniformLocation(planeShader.programID, "eyePosition");
    eye_pos3 = glGetUniformLocation(waterShader.programID, "eyePosition");

    location_time = glGetUniformLocation(waterShader.programID, "time");

    // Show some useful information on the GL context
    cout << "GL vendor:       " << glGetString(GL_VENDOR) << endl;
    cout << "GL renderer:     " << glGetString(GL_RENDERER) << endl;
    cout << "GL version:      " << glGetString(GL_VERSION) << endl;
    cout << "Desktop size:    " << width << "x" << height << " pixels" << endl;


    glfwSwapInterval(0); 
    glEnable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    // Main loop
    while(!glfwWindowShouldClose(window))
    {
         // Get window size. It may start out different from the requested
        // size, and will change if the user resizes the window.
        glfwGetWindowSize( window, &width, &height );
        // Set viewport. This is the pixel rectangle we want to draw into.
        glViewport( 0, 0, width, height ); // The entire window
		// Set the clear color and depth, and clear the buffers for drawing
        glClearColor(0.3f, 0.3f, 0.3f, 0.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        //glEnable(GL_CULL_FACE);

        /* ---- Rendering code should go here ---- */
		Utilities :: displayFPS ( window );
        time = (float)glfwGetTime(); // Number of seconds since the program was started

        //rotation for skydome
        myRotationAxis = glm::vec3(-1.0f, 0.0f, 0.0f);
        rotMat = glm::rotate(rotMat,0.001f, myRotationAxis);
        
        //rotate camera with left and right keys
        if (glfwGetKey( window, GLFW_KEY_RIGHT ) == GLFW_PRESS){
            camera.rotateRight();
        }
        if (glfwGetKey( window, GLFW_KEY_LEFT ) == GLFW_PRESS){
            camera.rotateLeft();
        }

        // move camera
        if (glfwGetKey( window, GLFW_KEY_W ) == GLFW_PRESS){
            camera.movePosForth();
        }
        if (glfwGetKey( window, GLFW_KEY_S ) == GLFW_PRESS){
            camera.movePosBack();
        }
        if (glfwGetKey( window, GLFW_KEY_A ) == GLFW_PRESS){
            camera.movePosLeft();
        }
        if (glfwGetKey( window, GLFW_KEY_D ) == GLFW_PRESS){
            camera.movePosRight();
        }
        if (glfwGetKey( window, GLFW_KEY_Q ) == GLFW_PRESS){
            camera.movePosDown();
        }
        if (glfwGetKey( window, GLFW_KEY_E ) == GLFW_PRESS){
            camera.movePosUp();
        }

        // draw sphere
        glUseProgram(sphereShader.programID);
        sphereMVP = camera.getMVPMatrix(Model);
        
        //glUniform1f(location_time , time); // Copy the value to the shader program
        glUniform3fv(light_pos1, 1, lightPos);
        glUniform3fv(eye_pos1, 1, glm::value_ptr(camera.getPos()));
        glUniformMatrix4fv(location_rotMat1, 1, GL_FALSE, &rotMat[0][0]);
        glUniformMatrix4fv(sphereID, 1, GL_FALSE, &sphereMVP[0][0]);
        
        sphere.render();
        glUseProgram(0);

        // draw plane
        glUseProgram(planeShader.programID);
        planeMVP = camera.getMVPMatrix(planeTrans);
        glUniformMatrix4fv(planeID, 1, GL_FALSE, &planeMVP[0][0]);
        glUniform3fv(light_pos2, 1, lightPos);
        glUniform3fv(eye_pos2, 1, glm::value_ptr(camera.getPos()));
        glUniformMatrix4fv(location_rotMat2, 1, GL_FALSE, &rotMat[0][0]);

        terrain.render();
        glUseProgram(0);

        // draw water
        glUseProgram(waterShader.programID);
        waterMVP = camera.getMVPMatrix(waterTrans);
        glUniformMatrix4fv(waterID, 1, GL_FALSE, &waterMVP[0][0]);
        glUniform3fv(light_pos3, 1, lightPos);
        glUniform1f(location_time , time); 
        glUniform3fv(eye_pos3, 1, glm::value_ptr(camera.getPos()));
        glUniformMatrix4fv(location_rotMat3, 1, GL_FALSE, &rotMat[0][0]);
        water.render();

        glUseProgram(0);
        
        // Swap buffers, i.e. display the image and prepare for next frame.
        glfwSwapBuffers(window);

		// Poll events (read keyboard and mouse input)
		glfwPollEvents();

        // Exit if the ESC key is pressed (and also if the window is closed).
        if(glfwGetKey(window, GLFW_KEY_ESCAPE)) {
          glfwSetWindowShouldClose(window, GL_TRUE);
        }

    }

    // Close the OpenGL window and terminate GLFW.
    glfwDestroyWindow(window);
    glfwTerminate();

    return 0;
}
