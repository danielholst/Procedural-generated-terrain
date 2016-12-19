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

float delta = 0.1;

vec4 getOffset(vec3 P) {
 	vec4 offset;
    vec3 grad;
  	offset = vec4(0.0, sin(P.z - 2.0*time)/15.0 + cos(P.x + time)/25.0, 0.0, 0.0);
  	return offset;
}

void main () {

	vec4 offset;

	float delta = 0.07;
  	vec4 offX = getOffset(Position + vec3(delta, 0.0, 0.0));
  	vec4 offZ = getOffset(Position + vec3(0.0, 0.0, delta));
  	offset = getOffset(Position);

  	vec3 dx = normalize(vec3(vec3(delta, 0.0, 0.0) + vec3(offX)) - vec3(offset));
  	vec3 dz = normalize(vec3(vec3(0.0, 0.0, delta) + vec3(offZ)) + vec3(offset));

  	vec3 normal = normalize(cross(dx, dz)*vec3(1.0, 1.0, 1.0));

  	if( normal.y < 0 )
  		normal = vec3(normal.x, -normal.y, normal.z);

	interpolatedNormal = normal;
	st = TexCoord;
	pos = Position+vec3(offset);
	
	gl_Position =  MVP * (vec4 (Position, 1.0)+ offset);
}