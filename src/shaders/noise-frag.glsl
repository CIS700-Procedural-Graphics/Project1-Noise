//Texture file
uniform sampler2D image;

//Equal to 0 or 1, decides whether or not we shade using the texture or in black and white
uniform int useTexture;

varying vec2 vUv;
varying vec3 color;

void main() {

  vec4 texColor = texture2D( image, vUv );
  texColor *= float(useTexture);
  vec3 noiseColor = color * float(1 - useTexture);
  
  //Weighted sum effectively colors using only the texture or only the color vector
  gl_FragColor = vec4( vec3(texColor) + noiseColor , 1.0);
}