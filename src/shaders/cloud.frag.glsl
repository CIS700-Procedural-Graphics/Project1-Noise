// Because the vertex shader is so expensive, the noise value is reused instead of recomputed
varying vec2 vUv;
varying vec3 vNormal;

varying float noise;
varying vec3 originalPos;

uniform float time;
uniform float soundFrequency;

uniform sampler2D sphereLit;

float fade1(float t)
{
	float t3 = t * t * t;
	return 6.0 * t3 * t * t - 15.0 * t3 * t + 10.0 * t3;
}

float grid2D(vec2 x)
{
	x.x += x.y * .5; // Skew
	vec2 p = floor(x);
	float fX = fade1(x.x - p.x);
	float fY = fade1(x.y - p.y);

	// Identity line
	x = fract(x);
	float mid = fade1(length(x - vec2(x.x, x.x)));
	return step(fY, .0001) + step(fX, .0001) + step(mid, .0001);
}

// Reference: http://www.iquilezles.org/www/articles/palettes/palettes.htm
vec3 palette( float t, vec3 a, vec3 b, vec3 c, vec3 d)
{
    return saturate(a + b * cos(6.28318 * ( c * t + d)));
}

void main() 
{
	// vec3 color = palette(1.0 - noise, vec3(0.748, 0.638, 0.108), vec3(0.748, 1.008, 0.958), vec3(0.368, 0.528, 0.428), vec3(1.548, -1.602, 0.428));
	// float grid = grid2D(vUv * 32.0 + vec2(noise + time * 10.0));
  	// gl_FragColor = vec4(color * 1.5 + .15, 1.0);// * (1.0 + grid * 3.0);

  	// vec2 nUV = ((vec2(vNormal.x, vNormal.y)) + vec2(noise * 2.0 - 1.0) * .25) * .5 + .5;

  	vec3 n = vNormal;// normalize(vNormal + vec3(cos(time)) + vec3(noise, sqrt(noise), noise * noise) * vNormal.z * vNormal.z *vNormal.z * 2.0 - 1.0);

  	// float diffuse = dot(n, normalize(vec3(1.0,1.0, 1.0))) * (.5 + noise);

  	// gl_FragColor = vec4(nUV, 0.0, 1.0);
  	gl_FragColor = texture2D(sphereLit, (n.xy * .5 + vec2(.5)));//' * (.5 + noise * noise * 2.0);// * vec4(color, 1.0) * 4.0;

  	// gl_FragColor = vec4(abs(vNormal), 1.0);
}