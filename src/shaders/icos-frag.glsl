varying float randTime;
varying float randAudio;
varying vec3 vNormal;

uniform float time;
uniform vec3 color;

vec3 rgb(vec3 v) {
  return v / 255.0;
}

vec3 lerp(vec3 a, vec3 b, float t) {
    return (a * (1.0 - t)) + (b * t);
}

vec3 cosinterp(vec3 a, vec3 b, float t) {
    const float PI = 3.14159265358979323;
    float tCos = (1.0 - cos(t * PI)) * 0.5;
    return lerp(a, b, tCos);
}

void main() {
  gl_FragColor = vec4(cosinterp(vNormal, vec3(0.9, 0.9, 0.9), randTime), 1.0);
}