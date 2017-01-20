varying vec2 vUv;
varying vec4 colorV;
uniform float time;
float random(float a, float b, float c) {
    return sin (a + pow(b, 11.0) - c * 1511.0);
}

float lerp(float a, float b, float t) {
    return a * (1.0 - t) + b * t;
}

float cerp(float a, float b, float t) {
    float cos_t = (1.0 - cos(t*3.14159)) * 0.5;
    return lerp(a, b, cos_t);
}

float interpolateNoise(float x, float y, float z, float freq) {
    float x0, y0, z0, x1, y1, z1;
    
    // Find the grid voxel that this point falls in
    x0 = floor(x);
    x1 = x0 + 1.0*freq;
    y0 = floor(y);
    y1 = y0 + 1.0*freq;
    z0 = floor(z);
    z1 = z0 + 1.0*freq;
    
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
    
    // Lerp in the x direction
    float n0, n1, m0, m1, v;
    float tx = x - x0;
    float ty = y - y0;
    float tz = z - z0;
    
    n0 = cerp(FUL, FUR, tx);
    n1 = cerp(FLL, FLR, tx);
    m0 = cerp(n0, n1, ty);
    
    n0 = cerp(BUL, BUR, tx);
    n1 = cerp(BLL, BLR, tx);
    m1 = cerp(n0, n1, ty);
    
    v = cerp(m0, m1, tz);
    
    return v;
}

float generateNoise(float x, float y, float z) {
    float total = 0.0;
    float persistence = 1.0 / 2.0;
    for (int i = 0; i < 8; i++) {
        float freq = pow(2.0, float(i));
        float ampl = pow(persistence, float(i));
        total += interpolateNoise(x, y, z, freq)*ampl;
    }
    return total;
}

void main() {
    vUv = uv;
    float s = sin(time)*generateNoise(position.x, position.y, position.z);
    vec4 offset = vec4(s*normal.x, s*normal.y, s*normal.z, 1);
    vec4 pos = vec4(position, 1) + offset;
    gl_Position = projectionMatrix * modelViewMatrix * pos;
    colorV = vec4(normal, 1);
}



