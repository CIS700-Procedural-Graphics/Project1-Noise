varying vec2 vUv;
varying float noise;
varying vec3 vNormal;

uniform sampler2D sphereLit;

void main() 
{	
	gl_FragColor = texture2D(sphereLit, (vNormal.xy * .5 + vec2(.5)));
}