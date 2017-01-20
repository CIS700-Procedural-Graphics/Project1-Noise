varying vec2 vUv;
varying float noise;
varying vec4 colorV;
void main() {
    vec2 uv = vec2(1,1) - vUv;
    gl_FragColor = vec4( colorV.rgb, 1.0 );
}
