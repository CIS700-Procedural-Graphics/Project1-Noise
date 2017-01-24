varying float n;
varying vec2 vUv;
varying vec3 nor;
varying vec3 col;
uniform float time;
uniform float persistance_p;
uniform int audData[1000];

varying float s;

float Noise3D(int x, int y, int z)
{
    float ft = fract(sin(dot(vec3(x,y,z), vec3(12.989, 78.233, 157))) * 43758.5453);
    //int a = int(ft);
    return ft;
}


float SmoothNoise3D(int X, int Y, int Z)
{
    float far = (Noise3D(X-1, Y+1, Z+1) + Noise3D(X+1, Y+1, Z+1) + Noise3D(X-1, Y+1, Z-1) + Noise3D(X+1, Y+1, Z-1) + Noise3D(X-1, Y-1, Z+1) + Noise3D(X+1, Y-1, Z+1) + Noise3D(X-1, Y-1, Z-1) + Noise3D(X+1, Y-1, Z-1)) / 64.0;//80.0;

    float medium = (Noise3D(X-1, Y+1, Z) + Noise3D(X+1, Y+1, Z) + Noise3D(X-1, Y-1, Z) + Noise3D(X+1, Y-1, Z) + Noise3D(X, Y+1, Z+1) + Noise3D(X, Y+1, Z-1) + Noise3D(X, Y-1, Z+1) + Noise3D(X, Y-1, Z-1) + Noise3D(X-1, Y, Z+1) + Noise3D(X+1, Y, Z+1) + Noise3D(X-1, Y, Z-1) + Noise3D(X+1, Y, Z-1)) / 32.0;//60.0;

    float closest = (Noise3D(X-1, Y, Z) + Noise3D(X+1, Y, Z) + Noise3D(X, Y-1, Z) + Noise3D(X, Y+1, Z) + Noise3D(X, Y, Z+1) + Noise3D(X, Y, Z-1)) / 16.0;//19.999;
    
    float self = Noise3D(X, Y, Z) / 4.0;
    
    
    return self + closest + medium + far;  
}


float Interpolate(float a, float b, float x)
{
    float t = (1.0 - cos(x * 3.14159)) * 0.5;
    
    return a * (1.0 - t) + b * t;
}

float InterpolateNoise3D(float x, float y, float z)
{
    int int_X = int(x);
    int int_Y = int(y);
    int int_Z = int(z);
    
    float float_X = x - float(int_X);
    float float_Y = y - float(int_Y);
    float float_Z = z - float(int_Z);
    
    //8 Points on the lattice sorrunding the given point
    float p1 = SmoothNoise3D(int_X, int_Y, int_Z);
    float p2 = SmoothNoise3D(int_X + 1, int_Y, int_Z);
    float p3 = SmoothNoise3D(int_X, int_Y + 1, int_Z);
    float p4 = SmoothNoise3D(int_X + 1, int_Y + 1, int_Z);
    float p5 = SmoothNoise3D(int_X, int_Y, int_Z + 1);
    float p6 = SmoothNoise3D(int_X + 1, int_Y, int_Z + 1);
    float p7 = SmoothNoise3D(int_X, int_Y + 1, int_Z + 1);
    float p8 = SmoothNoise3D(int_X + 1, int_Y + 1, int_Z + 1);
    
    float i1 = Interpolate(p1, p2, float_X);
    float i2 = Interpolate(p3, p4, float_X);
    float i3 = Interpolate(p5, p6, float_X);
    float i4 = Interpolate(p7, p8, float_X);
    
    float n1 = Interpolate(i1, i2, float_Y);
    float n2 = Interpolate(i3, i4, float_Y);
    
    float t1 = Interpolate(n1, n2, float_Z);
    
    return t1;
}


float Generate_Noise3D(vec3 pos, float persistance, int octaves)
{
    float total = 0.0;
    float p = persistance;
    int n = octaves;

    //int i = 0;
    for(int i=0; i < 4; i++) 
    {
    float frequency = pow(float(2), float(i));
    float amplitude = pow(p, float(i));
    
    total = total + InterpolateNoise3D((pos.x + time )* frequency, (pos.y + time) * frequency, (pos.z + time) * frequency) * amplitude;
    
    }
    
    return total;
}

void main() {
    vUv = uv;
    nor = normal;
    
    int index = 200;
    float sound = float(audData[index]) / float(255);
    s = sound;
    float noise = Generate_Noise3D(position, persistance_p, 8);
    n = noise;
    
    
    //float red = vec3(1.0,0.0,0.0);
    //float white = vec3(0.5,0.5,0.5);
    //float tcol = vec3(0.0,0.0,0.0);

    //manuplating the output colors
    //tcol = red * (1.0 - noise) + white * noise;
    //col = mix(normal, vec3(noise * (1.0 - sound) + normal.x, noise * (1.0 - sound) + normal.x, noise * (1.0 - sound) + normal.x), sound);
    
    //manuplating the position
    vec3 pos_new;
    pos_new = position * 10.0 * sound + ((noise * normal));
    
    gl_Position = projectionMatrix * modelViewMatrix * vec4( pos_new, 1.0 );
}