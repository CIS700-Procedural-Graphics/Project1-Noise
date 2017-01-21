uniform vec3 bcolor;
uniform vec3 rcolor;
uniform vec3 tcolor;

varying float noise;

vec3 v_lerp(vec3 a, vec3 b, float t) {
  return a * (1.0-t) + b * t;
}

vec3 grad_map(vec3 c1, vec3 c2, vec3 c3, float t) {
	if (t > 0.5) {
		return v_lerp(c2, c3, 2.0 * (t - 0.5));
	} else {
		return v_lerp(c1, c2, 2.0 * t);
	}
}

void main() {
  vec3 color = grad_map(rcolor, 
						bcolor, 
						tcolor, noise);
  gl_FragColor = vec4(color, 1.0 );

}