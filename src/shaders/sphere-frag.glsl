varying vec2 vUv;
varying vec3 vNormal;
varying float vNoise;
uniform sampler2D image;

vec3 lerp(vec3 a, vec3 b, float t){
	return (a * (1.0 - t) + b * t);
}

void main() {
  vec2 uv = vec2(1,1) - vUv;
  vec3 noise_col = vec3(vNoise,vNoise,vNoise);  
  
  vec3 start_col = vec3(255.0,255.0,0.0);
  vec3 end_col = vec3(255.0,0.0,0.0);

  noise_col = lerp(start_col, end_col, vNoise*3.0);
  
  gl_FragColor = vec4( noise_col.rgb, 1.0 );
}