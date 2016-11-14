#version 330 core

//uniform float time;
uniform sampler2D tex;

in vec3 pos;
in vec3 interpolatedNormal;
in vec2 st;

vec3 lightPos = vec3(0.0, 4.0, 2.0);
vec3 LightColor = vec3(0.6,0.7,0.6);
float LightPower = 10.0;
vec3 eyePosition = vec3(0.0, 0.5, 4.0);

//out vec4 finalcolor;
out vec3 color;

void main () {

	// Material properties
	vec3 MaterialDiffuseColor = vec3(0.2,0.6,0.2)*texture(tex, st).rgb;
	vec3 MaterialAmbientColor = vec3(0.2,0.2,0.2) * MaterialDiffuseColor;
	vec3 MaterialSpecularColor = vec3(0.3,0.3,0.3);
	
	// Distance to the light
	float distance = length(lightPos - pos);

	// Normal of the computed fragment, in camera space
	vec3 n = normalize(-interpolatedNormal);
	// Direction of the light (from the fragment to the light)
	vec3 l = normalize(pos-lightPos);
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
	+ MaterialSpecularColor * LightColor * LightPower * pow(cosAlpha,5) / (distance*distance)
	+ vec3(1.0, 1.0, 1.0)*pos.y/2;


	//finalcolor = texture(tex, st) * vec4 (vec3(interpolatedNormal), 1.0);
}