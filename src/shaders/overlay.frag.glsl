varying vec2 vUv;

uniform float fullscreenFlash;
uniform float size;
uniform float intensityMultiplier;
uniform float time;
uniform vec2 SCREEN_SIZE;


uniform sampler2D gradientTexture;

void main() 
{
    float aspect = SCREEN_SIZE.x / SCREEN_SIZE.y;
    vec2 uv = vUv * 2.0 - 1.0;
    uv.x *= aspect;
	
	float r = 1.0 - (length(uv * size));

	float intensity = saturate(time * .1 - 1.0) * .85 * intensityMultiplier;

	gl_FragColor = mix(texture2D(gradientTexture, vec2(r, r)) * intensity, vec4(1.0), fullscreenFlash);
}