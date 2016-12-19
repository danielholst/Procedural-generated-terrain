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
out vec3 pos;

void main () {
		
		interpolatedNormal = Normal;
		st = TexCoord;
		pos = Position;
		gl_Position = MVP * vec4 (Position , 1.0);
}