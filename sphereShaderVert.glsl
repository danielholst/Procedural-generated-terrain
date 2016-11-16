#version 330 core

layout(location = 0) in vec3 Position;
layout ( location =1) in vec3 Normal;
layout ( location =2) in vec2 TexCoord;

//uniform float time;
uniform mat4 MVP;
uniform mat4 rotMat;
uniform vec3 lightPos;

out vec3 interpolatedNormal;
out vec2 st;

vec3 viewPos = vec3(0.0, 0.0, 1.0);
//vec3 lightPos = vec3(4.0, 2.0, 2.0);

void main () {
		
		interpolatedNormal = Normal;
		st = TexCoord;
		gl_Position = MVP * rotMat * vec4 ( vec3(Position.x, Position.y, Position.z) , 1.0);
}