#version 330 core

layout(location = 0) in vec3 Position;
layout ( location =1) in vec3 Normal;
layout ( location =2) in vec2 TexCoord;

uniform float time;
uniform mat4 MVP;
uniform vec3 lightPos;
uniform vec3 eyePosition;

out vec3 interpolatedNormal;
out vec2 st;
out vec3 pos;

void main()
{
	float waveAltitude = sin(2.0 + Position.z - 2.0*time)/15.0 + cos(2.0 + Position.x + time)/25.0;
	st = TexCoord;
	interpolatedNormal = Normal;
	pos = Position + vec3(0.0, waveAltitude-0.15, 0.0);
	
	gl_Position =  MVP * (vec4 (pos, 1.0));
}