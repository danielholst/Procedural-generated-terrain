#include "camera.hpp"

Camera::Camera(glm::mat4 proj, glm::vec3 pos, glm::vec3 dir, glm::vec3 up)
{
	projection = proj;
	position = pos;
	direction = dir;
	upDirection = up;
	startDirection = dir;
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

void Camera::movePosUp()
{
	position = glm::vec3(position.x, position.y + 0.01, position.z);
}

void Camera::movePosDown()
{
	position = glm::vec3(position.x, position.y - 0.01, position.z);
}

void Camera::movePosLeft()
{
	position = glm::vec3(position.x + 0.01, position.y, position.z);
}

void Camera::movePosRight()
{
	position = glm::vec3(position.x - 0.01, position.y, position.z);
}

void Camera::movePosBack()
{
	position = glm::vec3(position.x, position.y, position.z - 0.01);
}

void Camera::movePosForth()
{
	position = glm::vec3(position.x, position.y, position.z + 0.01);
}

void Camera::rotateRight()
{
	std::cout << "rot right" << std::endl;
	// get angle between start dir and current dir and add small rot angle
	float v = glm::acos( glm::dot(direction, startDirection));
	std::cout << "v = " << v << std::endl;
	v += 0.0001;
	direction = glm::vec3(direction.x*cos(v) + direction.z * sin(v),
						  direction.y,
						  direction.x*(-sin(v)) + direction.z * cos(v));

	std::cout << "dir: " << direction.x 
				<< " " << direction.y
				<< " " << direction.z << std::endl;
}

void Camera::rotateLeft()
{
	std::cout << "rot left" << std::endl;
	// get angle between start dir and current dir and add small rot angle
	float v = glm::acos( glm::dot(direction, startDirection));
	std::cout << "v = " << v << std::endl;
	v -= 0.0001;
	direction = glm::vec3(direction.x*cos(v) + direction.z * sin(v),
						  direction.y,
						  direction.x*(-sin(v)) + direction.z * cos(v));

	std::cout << "dir: " << direction.x 
				<< " " << direction.y
				<< " " << direction.z << std::endl;
}

glm::mat4 Camera::getMVPMatrix(glm::mat4 model) const
{
	return projection * this->getViewMatrix() * model;
}