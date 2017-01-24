varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPosition;
varying float noise;
uniform sampler2D image;
varying float vTime;

void main() {
  gl_FragColor = vec4(vNormal, 1.0);

  // vec4 color = texture2D( image, vUv );
  // gl_FragColor = vec4( color.rgb, 1.0 );


  //gl_FragColor = vec4(vTime, (1.0-vTime) * 0.5 + noise, 0.0, 1.0);
  //gl_FragColor = vec4((length(vPosition) * vec3(1.0, 1.0, 1.0) * 0.01), 1.0);

  // float test = gl_Position;
  // float displacement = fnoise(gl_Position[0], gl_Position[1], gl_Position[2]);
}

