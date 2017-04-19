// THIS IS THE SHADER WHICH WILL PROVIDE THE TEXTURE TO THE TERRAIN.
// VALUE NOISE IS THE NOISE GENERATOR USED HERE (THE TERRAIN USES RIDGED VERSION). IT IS A MODIFICATION OF IQ'S VALUE NOISE GENERATOR.
// DERIVATIVES OF THE NOISE ARE USED TO SIMULATE EROSION EFFECTS.
// CHANGING THE SPEED IN THE GUI WILL ANIMATE THE NOISE AND EROSION [FOR VISUALIZATION].

varying vec2 vUv;
varying vec3 pos;

uniform float Red;
uniform float Green;
uniform float Blue;
uniform float Red1;
uniform float Green1;
uniform float Blue1;

uniform float time;
uniform int NoiseType;
uniform bool Preset1;
//uniform sampler2D image;

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
        if(NoiseType==1 && !Preset1) // ABS NOISE
            n = abs(n);
        else if(NoiseType==2 && !Preset1) // RIDGED NOISE
            n = 1.0-abs(n);

        a += b*n.x;          // accumulate values
        d += b*m*n.yzw;      // accumulate derivatives
        b *= s;
        x = f*m3*x;
        m = f*m3i*m;
    }
	return vec4( a, d );
}

void main() {
    //gl_FragColor = vec4( noise3(pos), 1.0 );

    vec4 n = fbm(time*pos);
    //float random = rand3D(pos);
    vec3 col;
    vec3 colBase;
    vec3 colSnow;

    if(Preset1) // MOUNTAINS SHADER
    {
        // EARTH TONES: http://www.varian.net/dreamview/dreamcolor/earth.html
        //    col = clamp(n[0]+1.0,0.5,1.0) * vec3(0.37,0.27,0.18);

        colBase = mix(vec3(115.,69.,35.)/4.0,vec3(95.,71.,47.)/4.0,n[0]*length(pos)) / 255.; // BLENDING LAYERS: Grayish base + Brownish soil + fine-tuning using noise (height and n)..
        colSnow = vec3(1.,0.98,0.98); // SNOW: 255,250,250

        // COL : 1. Snow at higher altitudes (length(pos)) blended with some randomness (n[0]) to avoid hard edges at a fixed height.
        //       2. Simulate erosion using derivatives (n[1],n[2]).
        //          - High altitude and snow accumulation (colSnow) -> low alt (colBase)
        //          - equivalent to (I guess) Higher noise value to lower noise value
        //          - equivalent to (I guess) subtracting the derivatives. Seems to work.
        col = mix(colBase,colSnow,(length(pos)-3.0*n[0]-2.0*n[1]-n[2])/5.0);

        col = max(colBase,col); // CLAMPING LOWEST VALUES TO BASE COLOR
    }
    else // ADJUSTABLE COLORS FOR DEBUGGING
    {
        float no = n[0];
        float r = mix(Red,Red1,no);
        float g = mix(Green,Green1,no);
        float b = mix(Blue,Blue1,no);

        col = vec3(r,g,b);

        //col = vec3(n[0],n[0],n[0])*vec3(1.0,0.5,0.1)+vec3(0.2,0.2,0.2);
    }

    col = sqrt(col); // gamma correction
    gl_FragColor = vec4( col.rgb, 1.0 );
}


/* // OLD SHADER - DOES NOTHING.. GETS THE COLOR FROM VERTEX SHADER AND PLOTS IT
void main()
{
  vec2 uv = vec2(1,1) - vUv;
  vec4 color = texture2D( image, uv );
  gl_FragColor = vec4( color.rgb, 1.0 );
}
*/
