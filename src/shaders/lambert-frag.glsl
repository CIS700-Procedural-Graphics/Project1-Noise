#version 300 es

// This is a fragment shader. If you've opened this file first, please
// open and read lambert.vert.glsl before reading on.
// Unlike the vertex shader, the fragment shader actually does compute
// the shading of geometry. For every pixel in your program's output
// screen, the fragment shader is run for every bit of geometry that
// particular pixel overlaps. By implicitly interpolating the position
// data passed into the fragment shader by the vertex shader, the fragment shader
// can compute what color to apply to its pixel based on things like vertex
// position, light position, and vertex color.
precision highp float;

uniform vec3 u_Color1;
uniform vec3 u_Color2;
uniform vec3 u_Color3;
uniform vec3 u_Color4;

uniform float u_time;

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;
in float noise_res;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

int repeat = 1;

// so called "canonical" pseudoranom
float random(vec2 co){
  return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float random1d(float x){
    return random(vec2(x, 1.337));
}

float random3d(vec3 inp){
    return random1d(random1d(random1d(inp.x) * inp.y) * inp.z);
}

int inc(int num){
    num++;
    return num;
}

float grad(int hash, float x, float y, float z)
{
    switch(hash & 0xF)
    {
        case 0x0: return  x + y;
        case 0x1: return -x + y;
        case 0x2: return  x - y;
        case 0x3: return -x - y;
        case 0x4: return  x + z;
        case 0x5: return -x + z;
        case 0x6: return  x - z;
        case 0x7: return -x - z;
        case 0x8: return  y + z;
        case 0x9: return -y + z;
        case 0xA: return  y - z;
        case 0xB: return -y - z;
        case 0xC: return  y + x;
        case 0xD: return -y + z;
        case 0xE: return  y - x;
        case 0xF: return -y - z;
        default: return 0.0;
    }
}

float fade(float t) {

    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

int p[512] = int[512](151,160,137,91,90,15,
131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180,151,160,137,91,90,15,
131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180);


// Linear Interpolate
float lerp(float a, float b, float x) {
    return a + x * (b - a);
}

float perlin(float x, float y, float z) {
//    if(repeat > 0) {
//        x = x%repeat;
//        y = y%repeat;
//        z = z%repeat;
//    }


    int xi = int(x) & 255;
    int yi = int(y) & 255;
    int zi = int(z) & 255;
    float xf = x-floor(x);
    float yf = y-floor(y);
    float zf = z-floor(z);
    float u = fade(xf);
    float v = fade(yf);
    float w = fade(zf);

    int aaa, aba, aab, abb, baa, bba, bab, bbb;
    aaa = p[p[p[    xi ]+    yi ]+    zi ];
    aba = p[p[p[    xi ]+inc(yi)]+    zi ];
    aab = p[p[p[    xi ]+    yi ]+inc(zi)];
    abb = p[p[p[    xi ]+inc(yi)]+inc(zi)];
    baa = p[p[p[inc(xi)]+    yi ]+    zi ];
    bba = p[p[p[inc(xi)]+inc(yi)]+    zi ];
    bab = p[p[p[inc(xi)]+    yi ]+inc(zi)];
    bbb = p[p[p[inc(xi)]+inc(yi)]+inc(zi)];

    float x1, x2, y1, y2;
    x1 = lerp(    grad (aaa, xf  , yf  , zf),           // The gradient function calculates the dot product between a pseudorandom
                grad (baa, xf-1.0, yf  , zf),             // gradient vector and the vector from the input coordinate to the 8
                u);                                     // surrounding points in its unit cube.
    x2 = lerp(    grad (aba, xf  , yf-1.0, zf),           // This is all then lerped together as a sort of weighted average based on the faded (u,v,w)
                grad (bba, xf-1.0, yf-1.0, zf),             // values we made earlier.
                  u);
    y1 = lerp(x1, x2, v);

    x1 = lerp(    grad (aab, xf  , yf  , zf-1.0),
                grad (bab, xf-1.0, yf  , zf-1.0),
                u);
    x2 = lerp(    grad (abb, xf  , yf-1.0, zf-1.0),
                  grad (bbb, xf-1.0, yf-1.0, zf-1.0),
                  u);
    y2 = lerp (x1, x2, v);

    return (lerp (y1, y2, w)+1.0)/2.0;                      // For convenience we bind the result to 0 - 1 (theoretical min/max before is [-1, 1])
}




vec3 color_multistop(float x){
    vec3 color = mix(u_Color1, u_Color2, smoothstep(0.0, 0.7, x));
    color = mix(color, u_Color3, smoothstep(0.7, 0.8, x));
    color = mix(color, u_Color4, smoothstep(0.8, 0.9, x));
    color = mix(color, u_Color1, smoothstep(0.9, 1.0, x));
    return color;
}

void main()
{

    // Material base color (before shading)
        vec4 diffuseColor = vec4(u_Color1, 1.0);

        // Calculate the diffuse term for Lambert shading
        float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
        // Avoid negative lighting values
        diffuseTerm = clamp(diffuseTerm, 0.0, 1.0);

        float ambientTerm = 0.2;

        float lightIntensity = diffuseTerm + ambientTerm;   //Add a small float value to the color multiplier
                                                            //to simulate ambient lighting. This ensures that faces that are not
                                                            //lit by our point light are not completely black.



        // Compute final shaded color
        out_Col = vec4(diffuseColor.rgb * lightIntensity, diffuseColor.a);

        //fs_Pos = fs_Pos;
        vec4 fs_Pos2 = fs_Pos * 20.0; // zoom factor

        //float i = floor(sc_v.x);
        //float f = fract(sc_v.x);

        //float rnd = random3d(vec3(fs_Pos.x, fs_Pos.y, fs_Pos.z));
        float rnd = perlin(fs_Pos2.x + u_time, fs_Pos2.y + u_time, fs_Pos2.z + u_time);
        //out_Col = vec4(vec3(rnd),1.0);

        vec3 color = color_multistop(noise_res);
        //vec3 color = vec3(out_Col.x * rnd, out_Col.y * rnd, out_Col.z * rnd);
        color = vec3(color.x * rnd, color.y, color.z);


        //float part = mix(random(vec2(i)), random(vec2(i) + 1.0), f);
        //float part = rnd;
        out_Col = vec4(color.x, color.y, color.z, 1.0);


}
