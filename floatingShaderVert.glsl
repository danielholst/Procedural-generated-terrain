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
	float waveAltitude = sin(-2.0*time);
	interpolatedNormal = Normal;
	st = TexCoord;
	pos = Position + vec3(0.0, waveAltitude/20-0.04, 0.0);
	
	gl_Position =  MVP * (vec4 (pos, 1.0));
}