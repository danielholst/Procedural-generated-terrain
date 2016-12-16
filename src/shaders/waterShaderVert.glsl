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

vec3 getNewPos(vec2 pos)
{

	vec3 newPos = vec3(pos.x,
		 		  (sin(pos.y - 2.0*time)/8.0)/(length(pos) + cos(Position.x + time)), 
		 	      pos.y);
	return newPos;
}

vec4 getOffset(vec3 P) {
  vec4 offset;
  vec3 grad;
  offset = vec4(0.0, sin(P.z - 2.0*time)/15.0 + cos(P.x + time)/25, 0.0, 0.0);
  return offset;

}

void main () {

	vec4 offset;

  	// to recalculate normals, check neighbors in x and z and get dx, dy.
  	// then N^ =  normalize(N0 - g -(g dot N0)N0)
  
/*
  	vec2 currPos = vec2(Position.x, Position.z);
	vec2 posXp = vec2(Position.x + delta, Position.z);
	//vec2 posXm = vec2(Position.x - delta, Position.z);
	vec2 posZp = vec2(Position.x, Position.z + delta);
	//vec2 posZm = vec2(Position.x, Position.z - delta);

	vec3 dx = normalize(getNewPos(posXp) - getNewPos(currPos));
	vec3 dz = normalize(getNewPos(posZp) - getNewPos(currPos));

	vec3 normal = normalize(cross(dx, dz));

	normal = normalize(normal);

	vec3 g = dot(dx, Normal)*Normal;
	vec3 g2 = dx - g;
	vec3 newN = normalize((Normal - g2));

	// distance to center
	//float rand = fract(sin(dot(vec2(Position.x,Position.z) ,vec2(12.9898,78.233))) * 43758.5453);
	
	offset = vec4(0.0, sin(Position.z - 2.0*time)/8.0, 0.0, 1.0);
	offset += vec4(0.0, cos(Position.x + time)/20, 0.0, 1.0);
	

*/


	float delta = 0.05;
  vec4 offX = getOffset(Position + vec3(delta, 0.0, 0.0));
  vec4 offZ = getOffset(Position + vec3(0.0, 0.0, delta));
  offset = getOffset(Position);

  vec3 dx = normalize(vec3(vec3(delta, 0.0, 0.0) + vec3(offX)) - vec3(offset));
  vec3 dz = normalize(vec3(vec3(0.0, 0.0, delta) + vec3(offZ)) + vec3(offset));

  vec3 normal = normalize(cross(dx, dz)*vec3(1.0, 2.0, 1.0));

  if( normal.y < 0 )
  	normal = vec3(normal.x, -normal.y, normal.z);

	interpolatedNormal = normal;
	st = TexCoord;
	pos = Position+vec3(offset);
	
	gl_Position =  MVP * (vec4 (Position, 1.0)+ offset);
}