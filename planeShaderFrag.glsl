#version 330 core

uniform float time;
uniform sampler2D tex;

in vec3 interpolatedNormal;
in vec2 st;

out vec4 finalcolor;
void main () {
	finalcolor = texture(tex, st); // * vec4 (vec3(interpolatedNormal), 1.0);
}