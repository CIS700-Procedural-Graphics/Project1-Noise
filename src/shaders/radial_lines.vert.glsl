varying vec2 vUv;
varying float vColor;

uniform float time;
uniform float doubleSided;


void main() 
{
    vUv = uv;

    vec3 pos = position;    
    // vec4 tPos = vec4(pos + vec3(time), time * .25);

    // float noise = fractal4D(tPos, .8, .707, 2.15, .8);
    // float displ = (1.0 - uv.y) * noise;
    // float spikyness = 5.0;

    // The sound doesnt drive the noise, but the random appearence fools the eye
    // pos.xz += normalize(pos.xz) * abs(pow(displ, spikyness)) * .125;

    // vec4 tPos = vec4(pos + vec3(time), time * .25);

    // float noise = fractal4D(tPos, .8, .707, 2.15, .8);
    // float displ = (1.0 - uv.y) * noise;
    // float spikyness = 5.0;

    // // The sound doesnt drive the noise, but the random appearence fools the eye
    // pos.xz *= normalize(pos.xz) * abs(pow(displ, spikyness)) * .125;

    float t = time * 3.0;
    vec2 dir = vec2(cos(t), sin(t));
    float c = acos(dot(dir, normalize(pos.xz)));
    float a = acos(fract(pos.x));

    vColor = step(abs(a - .5 + c), .5) * 10.0;
    vColor += step(abs(a + .5 - c), .5) * 10.0 * doubleSided;
    
    gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0 );
}