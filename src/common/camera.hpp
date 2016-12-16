#pragma once

//#include <GL/glew.h>
#include <GLFW/glfw3.h>
#include <iostream>
#include "glm/glm.hpp"
#include "glm/gtc/matrix_transform.hpp"

class Camera
{
public:
	Camera(glm::mat4 proj, glm::vec3 pos, glm::vec3 dir, glm::vec3 up);

	glm::mat4 getProj() const;
	glm::vec3 getPos() const;
	glm::vec3 getDir() const;
	glm::vec3 getUp() const;

	void rotateRight();
	void rotateLeft();

	void movePosUp();
	void movePosDown();
	void movePosLeft();
	void movePosRight();
	void movePosBack();
	void movePosForth();

	glm::mat4 getViewMatrix() const;
	glm::mat4 getMVPMatrix(glm::mat4 model) const;

private:

	glm::mat4 projection;
	glm::vec3 position;
	glm::vec3 direction;
	glm::vec3 upDirection;
	glm::vec3 startDirection;
};