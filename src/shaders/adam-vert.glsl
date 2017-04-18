// THIS IS NOT THE TERRAIN WE ARE GOING TO USE FOR THE FINAL SUBMISSION.
// THIS IS JUST FOR TESTING THE TEXTURE.
// RUDRAKSHA IS WORKING ON THE TERRAIN MODELING PART.

varying vec2 vUv;
varying vec3 pos;
uniform bool Terrain;

// NOISE FUNCTIONS FROM:
//      http://www.science-and-fiction.org/rendering/noise.html
float rand2D(in vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}
float rand3D(in vec3 co){
    return fract(sin(dot(co.xyz ,vec3(12.9898,78.233,144.7272))) * 43758.5453);
}

// iq's value noise algorithm:
vec4 noised( in vec3 x )
{
    vec3 p = floor(x);
    vec3 w = fract(x);

    vec3 u = w*w*w*(w*(w*6.0-15.0)+10.0);
    vec3 du = 30.0*w*w*(w*(w-2.0)+1.0);

    float a = rand3D( p+vec3(0,0,0) );
    float b = rand3D( p+vec3(1,0,0) );
    float c = rand3D( p+vec3(0,1,0) );
    float d = rand3D( p+vec3(1,1,0) );
    float e = rand3D( p+vec3(0,0,1) );
    float f = rand3D( p+vec3(1,0,1) );
    float g = rand3D( p+vec3(0,1,1) );
    float h = rand3D( p+vec3(1,1,1) );

    float k0 =   a;
    float k1 =   b - a;
    float k2 =   c - a;
    float k3 =   e - a;
    float k4 =   a - b - c + d;
    float k5 =   a - c - e + g;
    float k6 =   a - b - e + f;
    float k7 = - a + b + c - d + e - f - g + h;

    return vec4( -1.0+2.0*(k0 + k1*u.x + k2*u.y + k3*u.z + k4*u.x*u.y + k5*u.y*u.z + k6*u.z*u.x + k7*u.x*u.y*u.z),
                      2.0* du * vec3( k1 + k4*u.y + k6*u.z + k7*u.y*u.z,
                                      k2 + k5*u.z + k4*u.x + k7*u.z*u.x,
                                      k3 + k6*u.x + k5*u.y + k7*u.x*u.y ) );
}


const mat3 m3  = mat3( 0.00, 0.80, 0.60,
                      -0.80, 0.36,-0.48,
                      -0.60,-0.48, 0.64 );
const mat3 m3i = mat3( 0.00,-0.80,-0.60,
                       0.80, 0.36,-0.48,
                       0.60,-0.48, 0.64 );
// FBM - PROCESSING FOR OCTAVES AND ACCUMULATING DERIVATIVES
vec4 fbm( in vec3 x)
{
    float f = 2.0;  // could be 2.0
    float s = 0.5;  // could be 0.5
    float a = 0.0;
    float b = 0.5;
    vec3  d = vec3(0.0);
    mat3  m  = mat3( 1.00, 0.00, 0.00,
                   0.00, 1.00, 0.00,
                   0.00, 0.00, 1.00);
    //int oct = octaves;
    for( int i=0; i < 8; i++ ) // octaves = 8..
    {
        vec4 n = noised(x);
        //  ADDING RIDGES
        n = 1.0-abs(n);

        a += b*n.x;          // accumulate values
        d += b*m*n.yzw;      // accumulate derivatives
        b *= s;
        x = f*m3*x;
        m = f*m3i*m;
    }
	return vec4( a, d );
}

void main()
{
    vUv = uv;

    if(Terrain)
    {
        vec4 n = fbm(position);
        pos = (n[0]*0.5+0.5) * normal;
    }
    else
    {
        pos=position;
    }

    gl_Position = projectionMatrix * modelViewMatrix * vec4( pos, 1.0 );
}

/* // OLD SHADER : UNCOMMENT THIS AND COMMENT EVERYTHING ELSE TO GET OLD SPHERE SHADER
void main() {
    vUv = uv;
    pos=position;
    gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
}
*/
