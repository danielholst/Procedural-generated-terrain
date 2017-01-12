#version 330 core

in vec3 pos;
in vec3 interpolatedNormal;
in vec2 st;

uniform float time;
uniform sampler2D tex;
uniform mat4 rotMat;
uniform vec3 lightPos;
uniform vec3 eyePosition;

//vec3 lightPos = vec3(0.0, 4.0, 2.0);
vec3 LightColor = vec3(0.9,0.9,0.9);
float LightPower = 1.0;

out vec4 color;

// Cellular noise ("Worley noise") in 2D in GLSL.
// Copyright (c) Stefan Gustavson 2011-04-19. All rights reserved.
// This code is released under the conditions of the MIT license.
// See LICENSE file for details.

// Permutation polynomial: (34x^2 + x) mod 289
vec4 permute(vec4 x) {
  return mod((34.0 * x + 1.0) * x, 289.0);
}
vec3 permute(vec3 x) {
  return mod((34.0 * x + 1.0) * x, 289.0);
}

// Cellular noise, returning F1 and F2 in a vec2.
// Speeded up by using 2x2 search window instead of 3x3,
// at the expense of some strong pattern artifacts.
// F2 is often wrong and has sharp discontinuities.
// If you need a smooth F2, use the slower 3x3 version.
// F1 is sometimes wrong, too, but OK for most purposes.
vec2 cellular2x2(vec2 P) {
#define K 0.142857142857 // 1/7
#define K2 0.0714285714285 // K/2
#define jitter 0.8 // jitter 1.0 makes F1 wrong more often
	vec2 Pi = mod(floor(P), 289.0);
 	vec2 Pf = fract(P);
	vec4 Pfx = Pf.x + vec4(-0.5, -1.5, -0.5, -1.5);
	vec4 Pfy = Pf.y + vec4(-0.5, -0.5, -1.5, -1.5);
	vec4 p = permute(Pi.x + vec4(0.0, 1.0, 0.0, 1.0));
	p = permute(p + Pi.y + vec4(0.0, 0.0, 1.0, 1.0));
	vec4 ox = mod(p, 7.0)*K+K2;
	vec4 oy = mod(floor(p*K),7.0)*K+K2;
	vec4 dx = Pfx + jitter*ox;
	vec4 dy = Pfy + jitter*oy;
	vec4 d = dx * dx + dy * dy; // d11, d12, d21 and d22, squared
	// Sort out the two smallest distances
#if 0
	// Cheat and pick only F1
	d.xy = min(d.xy, d.zw);
	d.x = min(d.x, d.y);
	return d.xx; // F1 duplicated, F2 not computed
#else
	// Do it right and find both F1 and F2
	d.xy = (d.x < d.y) ? d.xy : d.yx; // Swap if smaller
	d.xz = (d.x < d.z) ? d.xz : d.zx;
	d.xw = (d.x < d.w) ? d.xw : d.wx;
	d.y = min(d.y, d.z);
	d.y = min(d.y, d.w);
	return sqrt(d.xy);
#endif
}

/*
// Cellular noise, returning F1 and F2 in a vec2.
// Speeded up by using 2x2x2 search window instead of 3x3x3,
// at the expense of some pattern artifacts.
// F2 is often wrong and has sharp discontinuities.
// If you need a good F2, use the slower 3x3x3 version.
vec2 cellular2x2x2(vec3 P) {
#define K 0.142857142857 // 1/7
#define Ko 0.428571428571 // 1/2-K/2
#define K2 0.020408163265306 // 1/(7*7)
#define Kz 0.166666666667 // 1/6
#define Kzo 0.416666666667 // 1/2-1/6*2
#define jitter 0.8 // smaller jitter gives less errors in F2
	vec3 Pi = mod(floor(P), 289.0);
 	vec3 Pf = fract(P);
	vec4 Pfx = Pf.x + vec4(0.0, -1.0, 0.0, -1.0);
	vec4 Pfy = Pf.y + vec4(0.0, 0.0, -1.0, -1.0);
	vec4 p = permute(Pi.x + vec4(0.0, 1.0, 0.0, 1.0));
	p = permute(p + Pi.y + vec4(0.0, 0.0, 1.0, 1.0));
	vec4 p1 = permute(p + Pi.z); // z+0
	vec4 p2 = permute(p + Pi.z + vec4(1.0)); // z+1
	vec4 ox1 = fract(p1*K) - Ko;
	vec4 oy1 = mod(floor(p1*K), 7.0)*K - Ko;
	vec4 oz1 = floor(p1*K2)*Kz - Kzo; // p1 < 289 guaranteed
	vec4 ox2 = fract(p2*K) - Ko;
	vec4 oy2 = mod(floor(p2*K), 7.0)*K - Ko;
	vec4 oz2 = floor(p2*K2)*Kz - Kzo;
	vec4 dx1 = Pfx + jitter*ox1;
	vec4 dy1 = Pfy + jitter*oy1;
	vec4 dz1 = Pf.z + jitter*oz1;
	vec4 dx2 = Pfx + jitter*ox2;
	vec4 dy2 = Pfy + jitter*oy2;
	vec4 dz2 = Pf.z - 1.0 + jitter*oz2;
	vec4 d1 = dx1 * dx1 + dy1 * dy1 + dz1 * dz1; // z+0
	vec4 d2 = dx2 * dx2 + dy2 * dy2 + dz2 * dz2; // z+1

	// Sort out the two smallest distances (F1, F2)
#if 0
	// Cheat and sort out only F1
	d1 = min(d1, d2);
	d1.xy = min(d1.xy, d1.wz);
	d1.x = min(d1.x, d1.y);
	return sqrt(d1.xx);
#else
	// Do it right and sort out both F1 and F2
	vec4 d = min(d1,d2); // F1 is now in d
	d2 = max(d1,d2); // Make sure we keep all candidates for F2
	d.xy = (d.x < d.y) ? d.xy : d.yx; // Swap smallest to d.x
	d.xz = (d.x < d.z) ? d.xz : d.zx;
	d.xw = (d.x < d.w) ? d.xw : d.wx; // F1 is now in d.x
	d.yzw = min(d.yzw, d2.yzw); // F2 now not in d2.yzw
	d.y = min(d.y, d.z); // nor in d.z
	d.y = min(d.y, d.w); // nor in d.w
	d.y = min(d.y, d2.x); // F2 is now in d.y
	return sqrt(d.xy); // F1 and F2
#endif
}
*/

// main
void main () {

	//vec4 light = vec4(1.0, 10.0, 0.0, 0.1);
	vec4 light = vec4(lightPos, 1);
	//light = light*rotMat;
	vec3 colorBlue = vec3(0.0,0.1,0.3);
	vec3 colorLightBlue = vec3(0.0, 0.04, 0.2);
	vec3 colorWhite = vec3(0.9, 0.9, 0.9);

	//vec2 F = cellular2x2x2(pos * 20.0 + sin(time));
	//float nx = smoothstep(0.4, 0.5, F.x);
	vec2 F = 5.0 * cellular2x2(vec2(pos.x* 20, pos.z*20.0));
	float nx = 1.0-1.5*F.x;
	vec3 grad = vec3(nx,nx,nx);

  // Perturb normal
	vec3 perturbation = grad - dot(grad, interpolatedNormal) * interpolatedNormal;
	vec3 norm = interpolatedNormal -  1.0 * perturbation;

  	vec3 ballPos = vec3(0.0, 0.0, -0.1);
  	ballPos += vec3(0.0, sin(ballPos.z - 2.0*time)/15.0 + cos(ballPos.x + time)/25, 0.0);
  	vec3 shadow = vec3(0.0,0.0,0.0);

  	// fake shadow
  	if( length(pos.xyz-ballPos) < 0.1)
    	LightPower = 0.1;

	// Material properties
	vec3 MaterialDiffuseColor = mix(colorBlue, colorLightBlue, 0.5);
	vec3 MaterialAmbientColor = vec3(0.3,0.3,0.3) * MaterialDiffuseColor;
	vec3 MaterialSpecularColor =  vec3(0.9,0.9,0.9);
	
	// Distance to the light
	float distance = length(vec3(light) - pos);

	// Normal of the computed fragment, in camera space
	vec3 n = normalize(norm);

	// Direction of the light (from the fragment to the light)
	vec3 l = normalize(vec3(light)-pos);

	// Cosine of the angle between the normal and the light direction, 
	float cosTheta = clamp( dot( n,l ), 0,1 );

	// Eye vector (towards the camera)
	vec3 E = normalize(eyePosition - pos);
	// Direction in which the triangle reflects the light
	vec3 R = -reflect(l,n);

  // Cosine of the angle between the Eye vector and the Reflect vector,
	float cosAlpha = clamp( dot( E,R ), 0,1 );

	color = vec4(pow(vec3(MaterialAmbientColor
	+ MaterialDiffuseColor * LightColor * LightPower * pow(cosTheta,2) / (distance*0.1)
	+ MaterialSpecularColor * LightColor * LightPower * pow(cosAlpha,100.0) / (distance*0.1) ), vec3(1.0/2.2)), 0.5);
}
