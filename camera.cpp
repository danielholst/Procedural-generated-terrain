#include "camera.hpp"

Camera::Camera(glm::mat4 proj, glm::vec3 pos, glm::vec3 dir, glm::vec3 up)
{
	projection = proj;
	position = pos;
	direction = dir;
	upDirection = up;
}

glm::mat4 Camera::getProj() const
{
	return projection;
}

glm::vec3 Camera::getPos() const
{
	return position;
}
glm::vec3 Camera::getDir() const
{
	return direction;
}
	
glm::vec3 Camera::getUp() const
{
	return upDirection;
}

glm::mat4 Camera::getViewMatrix() const
{
	return glm::lookAt(
    		position,
    		direction,
    		upDirection
    		);
}

glm::mat4 Camera::getMVPMatrix(glm::mat4 model) const
{
	return projection * this->getViewMatrix() * model;
}