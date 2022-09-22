#version 300 es

//This is a vertex shader. While it is called a "shader" due to outdated conventions, this file
//is used to apply matrix transformations to the arrays of vertex data passed to it.
//Since this code is run on your GPU, each vertex is transformed simultaneously.
//If it were run on your CPU, each vertex would have to be processed in a FOR loop, one at a time.
//This simultaneous transformation allows your program to run much faster, especially when rendering
//geometry with millions of vertices.

uniform mat4 u_Model;       // The matrix that defines the transformation of the
                            // object we're rendering. In this assignment,
                            // this will be the result of traversing your scene graph.

uniform mat4 u_ModelInvTr;  // The inverse transpose of the model matrix.
                            // This allows us to transform the object's normals properly
                            // if the object has been non-uniformly scaled.

uniform mat4 u_ViewProj;    // The matrix that defines the camera's transformation.
                            // We've written a static matrix for you to use for HW2,
                            // but in HW3 you'll have to generate one yourself

uniform float u_time;
uniform float u_N_octaves;
uniform float u_Persistance;
uniform float u_Lattice_spacing_mod;

in vec4 vs_Pos;             // The array of vertex positions passed to the shader

in vec4 vs_Nor;             // The array of vertex normals passed to the shader

in vec4 vs_Col;             // The array of vertex colors passed to the shader.

out vec4 fs_Nor;            // The array of normals that has been transformed by u_ModelInvTr. This is implicitly passed to the fragment shader.
out vec4 fs_LightVec;       // The direction in which our virtual light lies, relative to each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Col;            // The color of each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Pos;
out float noise_res;

const vec4 lightPos = vec4(5, 5, 3, 1); //The position of our virtual light, which is used to compute the shading of
                                        //the geometry in the fragment shader.



// so called "canonical" pseudoranom
float random_1(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float random1d_1(float x){
    return random_1(vec2(x, 1.337));
}

float random3d_1(vec3 inp){
    return random1d_1(random1d_1(random1d_1(inp.x) * inp.y) * inp.z);
}


float lerp(float a, float b, float x) {
    return a + x * (b - a);
}

float lerp2(float a, float b, float x){
  return a*(1.0-x) + b*x;
}


float bilinear_interp(float a, float b, float c, float d, float x, float y){

    float left = lerp(a, b, x);
    float right = lerp(c, d, x);
    return lerp(left, right, y);
}

float trilinear_interp(float a, float b, float c, float d, float e, float f, float g, float h, float x, float y, float z){
    float bottom = bilinear_interp(a, b, c, d, x, y);
    float top = bilinear_interp(e, f, g, h, x, y);
    return lerp(bottom, top, z);
}

float cos_interp1(float a, float b, float x){
    float cos_t = (1.0 - cos(x*3.41459)) * 0.5;
    return lerp(a, b, cos_t);
}

float trilinear_interp2(float a, float b, float c, float d, float e, float f, float g, float h, float x, float y, float z){
    // adapted from https://en.wikipedia.org/wiki/Trilinear_interpolation

    float xd = (x - floor(x));
    float yd = (y - floor(y));
    float zd = (z - floor(z));

    float c00 = cos_interp1(a, d, xd);
    float c01 = cos_interp1(b, c, xd);
    float c10 = cos_interp1(e, h, xd);
    float c11 = cos_interp1(f, g, xd);

    float c0 = cos_interp1(c00, c10, yd);
    float c1 = cos_interp1(c01, c11, yd);

    float cf = cos_interp1(c0, c1, zd);

    return cf;
}



// trilinear
// const float lattice_spacing = 0.1;

// lattice point before
float l_b(float d, float ls){
    return floor(d / ls) * ls;
}

// lattice point after
float l_a(float d, float ls){
    return ceil(d / ls) * ls;
}

float interp_noise(float x, float y, float z, float ls){
    // interpolating the surrounding lattice values (for 3D, this means the surrounding eight 'corner' points)

    // start by assigning lattice as whole numbers to start
    float a = random3d_1(vec3(l_b(x, ls), l_b(y, ls), l_b(z, ls)));
    float b = random3d_1(vec3(l_b(x, ls), l_a(y, ls), l_b(z, ls)));
    float c = random3d_1(vec3(l_a(x, ls), l_a(y, ls), l_b(z, ls)));
    float d = random3d_1(vec3(l_a(x, ls), l_a(y, ls), l_b(z, ls)));
    float e = random3d_1(vec3(l_b(x, ls), l_b(y, ls), l_a(z, ls)));
    float f = random3d_1(vec3(l_b(x, ls), l_a(y, ls), l_a(z, ls)));
    float g = random3d_1(vec3(l_a(x, ls), l_a(y, ls), l_a(z, ls)));
    float h = random3d_1(vec3(l_a(x, ls), l_b(y, ls), l_a(z, ls)));

    return trilinear_interp2(a, b, c, d, e, f, g, h, x, y, z);
}

//const float N_OCTAVES = 7.0;
//const float PERSISTANCE = 1.0 / 2.0;
//const float lattice_spacing_mod = 0.9;

float fbm3d(float x, float y, float z){
    float total = 0.0;
    for (float i = 0.0; i < u_N_octaves; ++i){
        float frequency = pow(2.0, i);
        //float power = pow(2.0, i);
        float amplitude = pow(u_Persistance, i);

        total += amplitude * interp_noise(x, y, z, (1.0/(frequency * 1000.0)) * u_Lattice_spacing_mod);
    }
    return total / 1.0;
}

void main()
{
    fs_Col = vs_Col;                         // Pass the vertex colors to the fragment shader for interpolation
    fs_Pos = vs_Pos;
    noise_res = fbm3d(vs_Pos.x, vs_Pos.y + (u_time * 0.002), vs_Pos.z);

    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);          // Pass the vertex normals to the fragment shader for interpolation.
                                                            // Transform the geometry's normals by the inverse transpose of the
                                                            // model matrix. This is necessary to ensure the normals remain
                                                            // perpendicular to the surface after the surface is transformed by
                                                            // the model matrix.


    vec4 modelposition = u_Model * vs_Pos;   // Temporarily store the transformed vertex positions for use below

//    if(modelposition.x > 0.5){
//        modelposition = vec4(modelposition.x, sin(u_time) * modelposition.y, modelposition.z, modelposition.w);
//    }else{
//        if(modelposition.z > 0.5){
//            modelposition = vec4(modelposition.x, modelposition.y, modelposition.z, cos(u_time) * modelposition.w);
//        }else{
//            modelposition = vec4(modelposition.x, modelposition.y, tan(u_time / 4.0) * modelposition.z, modelposition.w);
//        }
//    }
    modelposition = (modelposition* 1.0) + (vs_Nor * 1.0 * noise_res); // cos(u_time)

    fs_LightVec = lightPos - modelposition;  // Compute the direction in which the light source lies

    gl_Position = u_ViewProj * modelposition;// gl_Position is a built-in variable of OpenGL which is
                                             // used to render the final positions of the geometry's vertices
}
