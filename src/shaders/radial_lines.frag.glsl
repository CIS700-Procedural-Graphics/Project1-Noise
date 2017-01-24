varying vec2 vUv;
varying float vColor;

uniform float time;

void main() 
{	
	// gl_FragColor = texture2D(sphereLit, (vNormal.xy * .5 + vec2(.5)));
	gl_FragColor = vec4(vColor);
}