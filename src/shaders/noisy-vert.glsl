varying vec2 vUv;
varying vec4 colorV;
uniform float time;
uniform int octaves;
uniform float magnitude;
varying float noise;

float random(float a, float b, float c) {
    return fract(sin(dot(vec3(a, b, c), vec3(12.9898, 78.233, 78.233)))*43758.5453);
}

float lerp(float a, float b, float t) {
    return a * (1.0 - t) + b * t;
}

vec4 lerp(vec4 a, vec4 b, float t) {
    return a * (1.0 - t) + b * t;
}

float cerp(float a, float b, float t) {
    float cos_t = (1.0 - cos(t*3.14159)) * 0.5;
    return lerp(a, b, cos_t);
}

float interpolateNoise(float x, float y, float z) {
    float x0, y0, z0, x1, y1, z1;
    
    // Find the grid voxel that this point falls in
    x0 = floor(x);
    y0 = floor(y);
    z0 = floor(z);
    
    x1 = x0 + 1.0;
    y1 = y0 + 1.0;
    z1 = z0 + 1.0;
    
    // Generate noise at each of the 8 points
    float FUL, FUR, FLL, FLR, BUL, BUR, BLL, BLR;
    
    // front upper left
    FUL = random(x0, y1, z1);
    
    // front upper right
    FUR = random(x1, y1, z1);
    
    // front lower left
    FLL = random(x0, y0, z1);
    
    // front lower right
    FLR = random(x1, y0, z1);
    
    // back upper left
    BUL = random(x0, y1, z0);
    
    // back upper right
    BUR = random(x1, y1, z0);
    
    // back lower left
    BLL = random(x0, y0, z0);
    
    // back lower right
    BLR = random(x1, y0, z0);
    
    // Find the interpolate t values
    float n0, n1, m0, m1, v;
    float tx = fract(x - x0);
    float ty = fract(y - y0);
    float tz = fract(z - z0);
    tx = (x - x0);
    ty = (y - y0);
    tz = (z - z0);
    
    // interpolate along x and y for back
    n0 = cerp(BLL, BLR, tx);
    n1 = cerp(BUL, BUR, tx);
    m0 = cerp(n0, n1, ty);
    
    // interpolate along x and y for front
    n0 = cerp(FLL, FLR, tx);
    n1 = cerp(FUL, FUR, tx);
    m1 = cerp(n0, n1, ty);
    
    // interpolate along z
    v = cerp(m0, m1, tz);
    
    return v;
}

float generateNoise(float x, float y, float z) {
    float total = 0.0;
    float persistence = 1.0 / 2.0;
    int its = 0;
    for (int i = 0; i < 32; i++) {
        if (its >= octaves) {
            break;
        }
        its++;
        float freq = pow(2.0, float(i));
        float ampl = pow(persistence, float(i));
        total += interpolateNoise(freq*x, freq*y, freq*z)*ampl;
    }
    return total;
}

void main() {
    vUv = uv;
    float n = generateNoise(position.x + time, position.y + time, position.z + time);
    float s = magnitude*n;

    // use noise value to scale normal displacement
    vec4 offset = vec4(s*normal.x, s*normal.y, s*normal.z, 1);
    vec4 pos = vec4(position, 1) + offset;
    gl_Position = projectionMatrix * modelViewMatrix * pos;
    noise = n;
}



