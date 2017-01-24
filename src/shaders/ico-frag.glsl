varying vec2 vUv;
varying float noise;
varying float noise2;
uniform sampler2D image;
varying vec3 color; 
uniform float time;
uniform vec3 baseColor;
uniform vec3 outerColor;
uniform vec3 innerColor;
uniform bool stripes;
uniform float stripeDensity;
uniform bool pattern;
uniform vec3 patternColor;
uniform vec3 stripeColor;
uniform float patternDensity;

void main() {
  vec4 color =  texture2D( image, vUv );
  vec4 base_color = vec4(baseColor, 1.0);
  color += base_color / 1.5;

  vec4 outer = vec4(outerColor, 1.0);
  vec4 inner = vec4(innerColor, 1.0);

  color += outer * noise / 40.0;
  color -= (vec4(1,1,1,1) - outer) / 1.5;
  color += inner *  5.0 / noise;

  if (pattern) {
	  if (mod(floor(noise * patternDensity * 8.0), floor(noise2 * 50.0)) < 4.0){
	  	color = vec4(patternColor, 1.0);
	  }
	}

	if (stripes) {
	  if(mod(floor(noise * stripeDensity * 30.0), 8.0) == 0.0 ) {
	  	color = vec4(stripeColor, 1.0);
	  }
	}

  gl_FragColor = vec4( color.rgb, 1.0 );

}

