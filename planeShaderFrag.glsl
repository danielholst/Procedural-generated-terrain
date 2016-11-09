#version 330 core



in vec3 interpolatedNormal;
in vec2 st;

out vec4 finalcolor;
void main () {
	finalcolor = vec4 (vec3(interpolatedNormal), 1.0) ;
}