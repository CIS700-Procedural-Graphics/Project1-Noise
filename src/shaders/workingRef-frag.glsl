varying vec2 vUv;
varying float noise;
uniform sampler2D image;

uniform float time; //-HB
varying vec3 nor; //-HB


void main() {

	vec4 color = texture2D( image, vUv );
    // vec4 color = vec4( nor[0], nor[1], nor[2], 1.0); // INITIALLY DOING THIS FOR TESTING WORKS - WILL ADD IN IMAGE LATER - IMG IS CURRENTLY ADAM 

  	gl_FragColor = vec4( color.rgb, 1.0 );
}