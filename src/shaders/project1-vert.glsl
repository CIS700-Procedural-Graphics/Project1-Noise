uniform float uTimeMsec; //current time in msec

uniform float uN1Scale;
uniform float uN1persistence;
uniform float uN1fundamental;
uniform float uN1overtoneScale;
uniform float uN1numComponents;
uniform float uN1symmetryX, uN1symmetryY, uN1symmetryZ;
uniform float uN1TimeScale; //scaling factor for time

//I think I could just make a uniform vec3 - but how to handle that in gui?
vec3 N1symmetry = vec3( uN1symmetryX, uN1symmetryY, uN1symmetryZ );

uniform float uN2Scale;
uniform float uN2persistence;
uniform float uN2fundamental;
uniform float uN2overtoneScale;
uniform float uN2numComponents;
uniform float uN2symmetryX, uN2symmetryY, uN2symmetryZ;
uniform float uN2TimeScale; //scaling factor for time

vec3 N2symmetry = vec3( uN2symmetryX, uN2symmetryY, uN2symmetryZ );

varying vec2 vUv;
varying float vNoise;

 
////////// Interpolation ///////////

//linear interp
//t must be [0,1]
//
float lerp( float v0, float v1, float t ){
  return v0 + (v1 - v0) * t;
}

//bilinear interp
//Assumes points are 1.0 unit apart
//ll = "lower left" point, etc
//t01 and t02 are fractional [0,1] position between points[0,1] and points[0,2], respectively
//
float blerp( vec4 points, float t01, float t02 ){
  float llerp = lerp( points[0], points[1], t01 );
  float ulerp = lerp( points[2], points[3], t01 );
  return lerp( llerp, ulerp, t02 );
}

//trilinear interp
//Assumes points are 1.0 unit apart
//fll = "front lower left" point, etc
//t01, t02 and tfb are fractional [0,1] position between left/right points, 
// lower/upper points, and front/rear points, respectively
//
float trilerp( vec4 face1, vec4 face2, float t01, float t02, float tfb ){
  float fblerp = blerp( face1, t01, t02 );
  float bblerp = blerp( face2, t01, t02 );
  return lerp( fblerp, bblerp, tfb );
}

/////////// Noise //////////////

//noise example from lecture slides
//Looks like this outputs [0,1] cuz of sin()
//
float noise_gen2(float x, float y) {
  float val = sin( dot( vec2(x,y), vec2( 12.9898, 78.233 )) ) * 43758.5453;
  return val - floor(val);
}
float noise_gen3(float x, float y, float z) {
  float val = sin( dot( vec2(x, y), vec2( z, 78.233 )) ) * 43758.5453;
  return val - floor(val);
}

float noise_gen3b(float x, float y, float z) {
  float val = sin( dot( vec2(x+y, y+z), vec2( z+x, (x+y+z)/3.0 /*78.233*/ )) ) * 43758.5453;
  		//changed to combos of vals to make symmetries around axes less obvious
  		//seems to make them become a little more radial, at least at the pole
  return val - floor(val);

  //Interesting octant symmetries arise:
  //float sign = 1.0 * sign(x) * sign(y) * sign(z);
  //return ( ( (val - floor(val)) * sign ) + 1.0 ) / 2.0;
}

float noise_gen3cSymm(float x, float y, float z) {
  float xN = sin( dot( vec2(x, 23.1406926327792690), vec2( 2.6651441426902251, 78.233 )) ) * 43758.5453;
  float yN = sin( dot( vec2(y, 2.6651441426902251), vec2( 78.233, 23.1406926327792690 )) ) * 43758.5453;
  float zN = sin( dot( vec2(z, 78.233), vec2( 23.1406926327792690, 2.6651441426902251 )) ) * 43758.5453;

  /*
  //Tried doing variable symmetry here, but is very jump as you move through [0,1]. But I don't
  // understand why. For a given x,y,z, xN and xAbs don't change, so the lerp between
  // them is smooth, so the change in valx and final val should be smooth.
  // The per-axis symmetry looks right when symm val is 1.0, but in between it's jumpy.
  float xAbs = sin( dot( vec2(abs(x), 23.1406926327792690), vec2( 2.6651441426902251, 78.233 )) ) * 43758.5453;
  float yAbs = sin( dot( vec2(abs(y), 2.6651441426902251), vec2( 78.233, 23.1406926327792690 )) ) * 43758.5453;
  float zAbs = sin( dot( vec2(abs(z), 78.233), vec2( 23.1406926327792690, 2.6651441426902251 )) ) * 43758.5453;

  float valx = lerp( xN, xAbs, uN1symmetryX );
  float valy = lerp( yN, yAbs, uN1symmetryY );
  float valz = lerp( zN, zAbs, uN1symmetryZ );
  */

  float valx = xN, valy = yN, valz = zN; 
  
  float val = (valx + valy + valz) / 3.0;
  return fract(val);
}

//This samples the generated noise at a particular frequency (relative freq's, really).
//x and y are called 'query' points, to distinguish from sample points
//It always samples the noise func at integer values, and interpolates between those.
//freq - Frequency 1 yields samples of floor(x) and floor(x)+1, and similarly for y.
//Frequency f samples at floor(f*x) and floor(f*x)+1. This will make the query points
// for a given domain get spread out over more sample bins and thus get more peaks (i.e. noisier)
// as f increases. This also 'moves' the sample points along for a given query domain, so
// we don't get output that's aligned over different frequencies.
//freq is a float so we can do non-integer harmonics
//
float noise_query3D(float x, float y, float z, float f /*frequency*/){
  //scale by frequency
  float xs = x * f;
  float ys = y * f;
  float zs = z * f;
  //"lower-left" value
  vec4 face1;
  face1[0] = noise_gen3cSymm( floor(xs),       floor(ys),       floor(zs) );
  face1[1] = noise_gen3cSymm( floor(xs) + 1.0, floor(ys),       floor(zs) );
  face1[2] = noise_gen3cSymm( floor(xs),       floor(ys) + 1.0, floor(zs) );
  face1[3] = noise_gen3cSymm( floor(xs) + 1.0, floor(ys) + 1.0, floor(zs) );

  vec4 face2;
  face2[0] = noise_gen3cSymm( floor(xs),       floor(ys),       floor(zs) + 1.0 );
  face2[1] = noise_gen3cSymm( floor(xs) + 1.0, floor(ys),       floor(zs) + 1.0  );
  face2[2] = noise_gen3cSymm( floor(xs),       floor(ys) + 1.0, floor(zs) + 1.0  );
  face2[3] = noise_gen3cSymm( floor(xs) + 1.0, floor(ys) + 1.0, floor(zs) + 1.0  );
  
  return trilerp( face1, face2, xs - floor(xs), ys - floor(ys), zs - floor(zs) );
}


//Simple time-varying sample.
//If just sample cube in two locations and interp, will have same trouble with symmetry.
//The thing to do is just make a 4D noise generator, to make it easy to keep symmetry
/*
float noise_query4D(float x, float y, float z, float t, float f ){
  float val0 = noise_query3D( x, y, z, f );
  float offset = uTimeMsec / uN1TimeScale;  
  ...
}
*/

//Multi-octave noise
//However, is generalized to non-octave overtones series, based on arbitrary overtone scale factor.
//numComponents - number of frequency components to generate, including fundamental
//
float MON(float x, float y, float z, float fundamental, float overtoneScale, float numComponents, float persistence ) {
  float f = fundamental;
  float amp = 1.0;
  float result = 0.0;
  float scale = 0.0; //Track accumlated maximum scale to keep result in [0,1] 
  //for-loop issue 
  //can't compare against a non-const expression in the loop, cuz (at least
  // on some hardware), loop gets unrolled at compile time so it has to
  // know how many iterations to do
  #define MAX_COMPONENTS 16.0 //Can also do a const var
  for( float component = 1.0; component <= MAX_COMPONENTS; component++ ){
  	float noise = noise_query3D( x, y, z, f );
  	result += noise * amp;  	
  	//update for next overtone
  	f *= overtoneScale; 
  	scale += amp;
  	amp *= persistence;
  	if ( component == numComponents )
  	  break;
  }
  return result / scale;
}

////////////// Main ///////////////////

void main() {
    vUv = uv;
    //float noise = noise_gen2( uv.x, uv.y );
    //vNoise = noise_query( position.x, position.y, 1.0 /*freq*/ );
    float pOffset = 0.0; //offset to lessen symmetry from verts symmetrical around axes

	//////// First Noise ////////
	
	//"time" offset
	//
	vec3 newPos = position;
	//this method spreads out sample points over time until things get really spikey
	//vec3 newPos = position * vec3( uTimeMsec / uN1TimeScale );
	//
	//this ruins symmetry because positions move towards all positive
	//vec3 newPos = position + vec3( uTimeMsec / uN1TimeScale );
	//
	//this keeps symmetry working but creates lines along axes, between octants - why? 
	//because it exagerates the difference betweem points at the axes, i.e. between pos/neg values?
	//vec3 newPos = position + sign(position) * vec3( uTimeMsec / uN1TimeScale );
	//
	//combine the two above methods, using the sign() method for symmetric values
	// and blend. But still get artifact at intermediate values.
	vec3 newPosR = position + vec3( uTimeMsec / uN1TimeScale );
	vec3 newPosAbs = position + sign(position) * vec3( uTimeMsec / uN1TimeScale );
	for( int i=0; i < 3; i++ )
		newPos[i] = lerp( newPosR[i], newPosAbs[i], N1symmetry[i]);

	
    //Doing variable symmetry here by lerping between each vertex component and its abs().
    // This transitions smoothly from [0,1], as opposed to method above in noise_gen3cSymm.
    // However when symm vals are close to 0.5, get artifacts in negative octants - looks like
    // noise is going to 0, but can't understand why. Maybe cuz projections in noise_gen3cSymm
    // get closer to same values since there's less movement in position. I tried using large (500)
    // pOffset to get resultant position vals away from 0, but still seeing artifacts.
    //AND the symmetry is skewed on local level, like order of quads is getting properly reversed but not
    // the contents of each quad
    float noiseN1 = MON(
    			  lerp( newPos.x, abs(newPos.x), uN1symmetryX ) + pOffset,  
    			  lerp( newPos.y, abs(newPos.y), uN1symmetryY ) + pOffset,
    			  lerp( newPos.z, abs(newPos.z), uN1symmetryZ ) + pOffset,
    			  uN1fundamental,
    			  uN1overtoneScale,
    			  uN1numComponents,
    			  uN1persistence);
    
    //////// Second noise ////////
    
    //Should set it up to use a different noise generator, but no time for that now...
    
	newPosR = position + vec3( uTimeMsec / uN2TimeScale );
	newPosAbs = position + sign(position) * vec3( uTimeMsec / uN2TimeScale );
	for( int i=0; i < 3; i++ )
		newPos[i] = lerp( newPosR[i], newPosAbs[i], N2symmetry[i]);
    float noiseN2 = MON(
    			  lerp( newPos.x, abs(newPos.x), uN2symmetryX ),  
    			  lerp( newPos.y, abs(newPos.y), uN2symmetryY ),
    			  lerp( newPos.z, abs(newPos.z), uN2symmetryZ ),
    			  uN2fundamental,
    			  uN2overtoneScale,
    			  uN2numComponents,
    			  uN2persistence);
    
    
    //add them together
    vNoise = ( noiseN1 * uN1Scale + noiseN2 * uN2Scale ) / (uN1Scale + uN2Scale);
    vec3 perturb = normal * vNoise;
    gl_Position = projectionMatrix * modelViewMatrix * vec4( position + perturb, 1.0 );
}