#version 330 core

//uniform float time;
uniform vec3 lightPos;

in vec3 interpolatedNormal;
in vec2 st;

out vec4 finalcolor;
void main () {
	finalcolor = vec4(0.1, 0.1, 0.8, 1.0) + vec4 (vec3(interpolatedNormal)*vec3(0,0,1), 1.0) ;
}