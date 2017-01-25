varying vec2 vUv;

uniform float time;
uniform float overallFrequency;

uniform vec2 SCREEN_SIZE;

uniform sampler2D gradientTexture;

void main() 
{
    float aspect = SCREEN_SIZE.x / SCREEN_SIZE.y;
    vec2 uv = vUv;
    uv.x = 1.0 - uv.x;
    uv.x *= aspect;
    // uv.y *= 2.0;
	
	float r = length(uv * .25);

	float soundContribution = pow(overallFrequency, 7.0) * 100.0;
	soundContribution += step(fract(r * 10.0 + time * .25 + soundContribution), .5);

	// The second term generates a nice fake specular reflection
	float intensity = saturate(time * .1 - 1.0) * .15;

	intensity *= (1.0 + soundContribution);

	gl_FragColor = texture2D(gradientTexture, vec2(r, r)) * intensity;
}