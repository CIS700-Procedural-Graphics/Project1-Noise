varying vec2 vUv;
varying float dprod;
varying float noise;
uniform sampler2D image;

varying vec3 test;

vec3 lerpvec(in vec3 a, in vec3 b, in float t)
{
	float tx = t * b[0] + (1.0 - t) * a[0];
	float ty = t * b[1] + (1.0 - t) * a[1];
	float tz = t * b[2] + (1.0 - t) * a[2];
	return vec3(tx, ty, tz);
}

void main() {
	float brightness =  (noise + 1.0 / 2.0);
    vec4 color = texture2D( image, vUv );
    vec3 newcol = lerpvec(vec3(0.4, 0.5, 0.9), vec3(brightness, brightness, brightness), 0.99);
    gl_FragColor = vec4( newcol, 1.0 );

}