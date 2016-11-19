#version 330 core

layout(location = 0) in vec3 Position;
layout ( location =1) in vec3 Normal;
layout ( location =2) in vec2 TexCoord;

uniform mat4 MVP;
uniform vec3 lightPos;
uniform vec3 eyePosition;

out vec3 interpolatedNormal;
out vec2 st;
out vec3 pos;

float delta = 0.3;

vec3 getNewPos(vec2 pos)
{
	// distance to center
	float rand = fract(sin(dot(pos ,vec2(12.9898,78.233))) * 43758.5453);
	float dist = abs(pow(pos.x, 2) + pow(pos.y, 2));

	vec3 newPos = vec3(pos.x, rand*dist/100, pos.y);
	return newPos;
}

void main () {

	vec4 offset;
/*
	// Displace surface
	vec3 grad = vec3(0.0); // To store gradient of noise
	float bump = snoise(coord*2.0 + vec3(0.2, 0.13, 0.33)*time, grad);
	grad *= 2.0; // Scale gradient with inner derivative
    f.texCoord3 = coord; // Undisplaced, untransformed position
	coord += displaceamount * bump * f.normal;
	*/
    //f.texCoord3 = coord; // Displaced but untransformed position

    //vec3 eyeDirection = normalize(eyePosition - Position);
  	//vec3 lightDirection = normalize(lightPos - Position);


  	// to recalculate normals, check neighbors in x and z and get dx, dy.
  	// then N^ =  normalize(N0 - g -(g dot N0)N0)
	vec2 posXp = vec2(Position.x + delta, Position.z);
	vec2 posXm = vec2(Position.x - delta, Position.z);
	vec2 posZp = vec2(Position.x, Position.z + delta);
	vec2 posZm = vec2(Position.x, Position.z - delta);

	vec3 dx = (getNewPos(posXp) - getNewPos(posXm))/(2*delta);
	vec3 dz = (getNewPos(posZp) - getNewPos(posZm))/(2*delta);

	vec3 normal = normalize(cross(dx, dz));

	// distance to center
	float rand = fract(sin(dot(vec2(Position.x,Position.z) ,vec2(12.9898,78.233))) * 43758.5453);
	float dist = abs(pow(Position.x, 2) + pow(Position.z, 2));
	

	offset = vec4(0.0, rand*dist/100, 0.0, 1.0);
		
	interpolatedNormal = normal;
	st = TexCoord;
	pos = Position+vec3(offset);
	
	gl_Position =  MVP * (vec4 (Position, 1.0));
}