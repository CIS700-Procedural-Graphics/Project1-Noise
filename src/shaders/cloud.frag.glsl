varying vec2 vUv;
varying float noise; // Because the vertex shader is so expensive, we should reuse the noise value

uniform float time;
uniform float bias;
uniform float frequency;
uniform float ratio;
uniform float frequencyRatio;

// Reference: http://www.iquilezles.org/www/articles/palettes/palettes.htm
vec3 palette( float t, vec3 a, vec3 b, vec3 c, vec3 d)
{
    return saturate(a + b * cos(6.28318 * ( c * t + d)));
}

void main() 
{
	vec3 color = palette(1.0 - noise, vec3(0.748, 0.638, -3.142), vec3(0.748, 1.008, 0.000), vec3(0.368, 0.428, 0.000), vec3(1.548, -1.602, 0.000));
  	gl_FragColor = vec4(color * 1.5 + .15, 1.0);
}