#version 330 core

//uniform float time;
uniform vec3 lightPos;
uniform vec3 eyePosition;
uniform mat4 rotMat;
uniform mat4 MVP;

in vec3 interpolatedNormal;
in vec2 st;
in vec3 pos;

vec3 LightColor = vec3(0.6,0.7,0.6);
float LightPower = 10.0;

out vec3 color;

void main () {

	vec4 mat = vec4(0.1, 0.1, 0.8, 1.0) + vec4 (vec3(interpolatedNormal)*vec3(0,0,1), 1.0) ;

	vec4 light = vec4(lightPos, 1);
	light =  rotMat * light;

	// Material properties
	vec3 MaterialDiffuseColor = vec3(mat);
	vec3 MaterialAmbientColor = vec3(0.2, 0.2, 0.2) * MaterialDiffuseColor;
	vec3 MaterialSpecularColor = vec3(0.8, 0.8, 0.8) * MaterialDiffuseColor;
	
	// Distance to the light
	float distance = length(vec3(light) - pos);

	// Normal of the computed fragment, in camera space
	vec3 n = normalize(interpolatedNormal);
	// Direction of the light (from the fragment to the light)
	vec3 l = normalize(pos-vec3(light));
	// Cosine of the angle between the normal and the light direction, 
	float cosTheta = clamp( dot( n,l ), 0,1 );

	// Eye vector (towards the camera)
	vec3 E = normalize(pos - eyePosition);
	// Direction in which the triangle reflects the light
	vec3 R = reflect(-l,n);
	// Cosine of the angle between the Eye vector and the Reflect vector,
	float cosAlpha = clamp( dot( E,R ), 0,1 );

	color = MaterialAmbientColor
	+ MaterialDiffuseColor * LightColor * LightPower * cosTheta / (distance)
	+ MaterialSpecularColor * LightColor * LightPower * pow(cosAlpha,5) / (distance*distance);
}