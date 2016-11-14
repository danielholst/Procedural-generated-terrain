#version 330 core

layout(location = 0) in vec3 Position;
layout ( location =1) in vec3 Normal;
layout ( location =2) in vec2 TexCoord;

uniform mat4 MVP;

out vec3 interpolatedNormal;
out vec2 st;
out vec3 pos;

vec3 lightPos = vec3(4.0, 4.0, 2.0);
vec3 eyePosition = vec3(0.0, 0.5, 4.0);

void main () {

    vec3 eyeDirection = normalize(eyePosition - Position);
  	vec3 lightDirection = normalize(lightPos - Position);
	vec3 normal = normalize(Normal);

	// distance to center
	float rand = fract(sin(dot(vec2(Position.x,Position.z) ,vec2(12.9898,78.233))) * 43758.5453);
	float dist = abs(pow(Position.x, 2) + pow(Position.z, 2));
	vec4 offset = vec4(0.0, rand*dist/100, 0.0, 1.0);
		
	interpolatedNormal = Normal;
	st = TexCoord;
	pos = Position;
	gl_Position =  MVP * (vec4 (Position, 1.0) + offset);
}