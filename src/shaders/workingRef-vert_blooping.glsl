//THIS IS THE BLOOPING

varying vec2 vUv;

varying vec3 nor; //-HB
uniform float time; //-HB

/******************************************************************************/
/* DEFINING OVERALL AND INDIVIDUAL NOISE FUNCTIONS ETC FOR THE WORKING SHADER */
/******************************************************************************/
    
// NOISE COS BASED
float noiseFunc_1(float in1, float in2, float in3) {
//	in1 = in1 * 13.0;
//	in2 = in2 * 0.17;
//	in3 = in3 * 0.19;

    return (cos( dot( vec3(in1, in2, in3), vec3(12.9898, 78.233, 45.3535))) );
}
    
// NOISE SIN BASED
float noiseFunc_2(float in1, float in2, float in3) {
//	in1 = in1 * 0.13;
//	in2 = in2 * 17.0;
//	in3 = in3 * 1.9;

    return (sin( dot( vec3(in1, in2, in3), vec3(80.233, .9898, 50.3535))) );
}
    
// NOISE COMBO OF BOTH
float noiseFunc_3(float in1, float in2, float in3) {
    float f1 = noiseFunc_1(in1, in2, in3); 
    float f2 = noiseFunc_2(in1, in2, in3); 
    return ( cos( (f1 * 3.0 + f2 / 13.0) ) );
}
    
// CURR NOISE FUNCTION OF THE ABOVE THREE THAT IS ACTUALLY USED bc interp func and smoothing both need to get noise
// of surrounding locations so it's a way to keep consistent which noise function is being used as 'the' noise 
// function outisde of the 3D multi-octave lattice-value noise function
float currNoiseFunc(float in1, float in2, float in3) {
    return noiseFunc_3(in1, in2, in3);
}

// LINEAR INTERP FUNCTION for interpolating between two different values with a given t linearly defined % to get 
// destination location between
float linearInterp(float in1, float in2, float t) {
	return (in1 * (1.0 - t + in2 * t));
}
    
// COS INTERP FUNCTION for interpolating between two different values with a given t linearly defined % to get 
// destination location between
// uses the linear interp as part of it
float cosInterpFunc(float in1, float in2, float t) {
	float PI = 3.14159265;
    float cos_t = (1.0 - cos(t * PI)) * 0.5;
    return linearInterp(in1, in2, cos_t);
}

    
// AVERAGES NOISE RESULTS BASED ON SURROUNDINGS at an x,y,z location with neighboring values (x +/-1, y +/-1, z +/-1)
// calculates overall noise at given location in func so don't have to input as param
float smooth(float x, float y, float z) {
    float ave = 0.0;
    float count = 0.0;

    float i = x - 1.0;
    float j = y - 1.0;
    float k = z - 1.0;
    
    for (int q = 0; q < 2; q++) {
        for (int r = 0; r < 2; r++) {
            for (int s = 0; s < 2; s++) {
                ave += currNoiseFunc(i, j, k);
                count += 1.0;

                k++;
            }
            j++;
        }
        i++;
    }
    
    return (ave / count);
}
    
// PRODUCES NOISE VALUE FOR POINT by interpolating surrounding lattice values (8 corner points)
float interpNoiseByCorners(float x, float y, float z) {
    
    //upper cube check loc
    float tl_up = currNoiseFunc(x-1.0, y+1.0, z+1.0);
    float tr_up = currNoiseFunc(x+1.0, y+1.0, z+1.0);
    float bl_up = currNoiseFunc(x-1.0, y-1.0, z+1.0);
    float br_up = currNoiseFunc(x+1.0, y-1.0, z+1.0);
    //lower cube check loc
    float tl_bot = currNoiseFunc(x-1.0, y+1.0, z-1.0);
    float tr_bot = currNoiseFunc(x+1.0, y+1.0, z-1.0);
    float bl_bot = currNoiseFunc(x-1.0, y-1.0, z-1.0);
    float br_bot = currNoiseFunc(x+1.0, y-1.0, z-1.0);
    
    // cant just divide all 
    // interp1: need to interpolate between two of opp x with same y and same z loc (8 locations yield 4 locations)
    // interp2: need to interpolate between two of x with opp y and same z loc (4 locations yield 2 locations)
    // interp3: need to interpolate between two of x and y with opp z loc (2 locations yield 1 value)
    
    // interp value t set as .5 bc always directly halfway between the two locations
    float t = 0.5;
    
    // interp1 //
    float top_up = cosInterpFunc(tl_up, tr_up, t);
    float back_up = cosInterpFunc(bl_up, br_up, t);
    float top_bot = cosInterpFunc(tl_bot, tr_bot, t);
    float back_bot = cosInterpFunc(bl_bot, br_bot, t);
    
    // interp2 //
    float up = cosInterpFunc(top_up, back_up, t);
    float bot = cosInterpFunc(top_bot, back_bot, t);
    
    // interp3 //
    float val = cosInterpFunc(up, bot, t);
    
    return val;
}

// 3D MULTI-OCTAVE LATTICE-VALUE NOISE FUNCTION generates output in controlled range [0,1] or [-1,1]
float overallNoiseFunc(float in1, float in2, float in3) {
	// EDITS HERE BETWEEN ORIG FIRE AND MOVING BLOOPS
	in1 = in1*.005;
	in2 = in2*.04;
	in3 = in3*.006;

    float total = 0.0;
    float persistence = .5;
    
    const int numOctaves = 5;

    // orig oct = 5, persist is .5

    float i = 0.0;
    
    // looping through the octaves
    for (int j = 0; j < numOctaves; j++) {
        float frequency = pow(2.0, i);
        float amplitude = pow(persistence, i);

        i++; // doing this here to avoid float / int issues with WebGL
        
        // accumulating overall noise over the octaves
        total += currNoiseFunc(in1, in2, in3) * frequency;
    }
    
    return total;
}

/********/
/* MAIN */
/********/

void main() {
	nor = normal;

	/************/
	/* POSITION */
	/************/

    // TO MAKE BREATHE
    /*
     * float noise = overallNoiseFunc(position[0], position[1], position[2]);
     * noise = noise / (300.0 * ((time / 6.0 + 3.0) * 10.0)); // scaling down so easier to see in fov
     */

    // TO MAKE MOVE WITH UNDULATION

     float timeOffset = (time / 90.0 * 13.0 + 50.0);
     float noise = overallNoiseFunc(position[0] + timeOffset, position[1] + timeOffset, position[2] + timeOffset);
     noise = noise / 50.0;
     

    gl_Position = projectionMatrix
    				* modelViewMatrix
    				* ( 
    					vec4(position, 1.0)
    					+ vec4(noise * nor[0], noise * nor[1], noise * nor[2], 1.0)
    				);

	/*********/
	/* COLOR */
	/*********/

	// FOR PURE PHOTO
	// vUv = uv;

    // FOR FIRE
    /*
     * float timeOffsetForColor = (timeOffset * 13.0 + 3.0);
     * float noiseForColor = noiseFunc_1(position[0] + timeOffsetForColor, position[1] + timeOffsetForColor, position[2] + timeOffsetForColor);
     * float pixelImageHeight = 664.0;
     * float noiseOrig = overallNoiseFunc(position[0], position[1], position[2]);
     * float height = cosInterpFunc(1.0, 664.0 - pixelImageHeight, noiseForColor);
     */

    // FOR BLOOPING
    float timeOffsetForColor = (timeOffset * 13.0 + 3.0);
    float noiseForColor = noiseFunc_1(position[0] + timeOffsetForColor, position[1] + timeOffsetForColor, position[2] + timeOffsetForColor);
    float pixelImageHeight = 664.0;
    float noiseOrig = overallNoiseFunc(position[0], position[1], position[2]);
    float height = cosInterpFunc(1.0, 664.0 - pixelImageHeight, 3.0 * noise);
    
     vUv = vec2 (20.0, height);

}