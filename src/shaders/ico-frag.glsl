varying vec2 vUv;
varying float noise;
uniform sampler2D image;
varying vec3 color; 

void main() {

  vec4 color = vec4(color, 1.0);

  gl_FragColor = vec4( color.rgb, 1.0 );

}

