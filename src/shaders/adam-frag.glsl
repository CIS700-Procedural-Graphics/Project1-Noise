varying vec2 vUv;
varying float dprod;
varying float noise;
uniform sampler2D image;
uniform sampler2D blinnimage;

varying vec3 newNormal;
varying float lighting;
varying float shininess;

vec3 lerpvec(in vec3 a, in vec3 b, in float t)
{
	float tx = t * b[0] + (1.0 - t) * a[0];
	float ty = t * b[1] + (1.0 - t) * a[1];
	float tz = t * b[2] + (1.0 - t) * a[2];
	return vec3(tx, ty, tz);
}

void main() {
	float brightness =  noise * 0.5 + 0.5;
	vec4 col = texture2D(image, vUv);
	vec4 shine = texture2D(blinnimage, vec2(0.0, brightness));

	vec3 lightCol = lerpvec(vec3(0.2, 0.2, 0.4), vec3(1.0, 1.0, 1.0), lighting);

	vec3 col2 = min(0.8 * shininess * shine.xyz + lightCol * col.xyz, vec3(1.0, 1.0, 1.0));
	vec3 aerialPersp = lightCol * vec3(0.5, 0.82, 0.95);
    gl_FragColor = vec4( lerpvec(col2, aerialPersp, dprod), 1.0 );

}