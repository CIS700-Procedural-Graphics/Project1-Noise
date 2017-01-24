varying vec2 vUv;

varying vec3 nor; //-HB
uniform float time; //-HB

/******************************************************************************/
/* DEFINING OVERALL AND INDIVIDUAL NOISE FUNCTIONS ETC FOR THE WORKING SHADER */
/******************************************************************************/
    
// NOISE COS BASED
float noiseFunc_1(float in1, float in2, float in3) {
    return ( cos( dot( vec3(in2, in3, in1), vec3(2.9898, 8.233, 5.3535))) );
}
    
// NOISE SIN BASED
float noiseFunc_2(float in1, float in2, float in3) {
    return ( sin( dot( vec3(in1, in2, in3), vec3(80.233, 13.9898, 50.3535))) );
}

// NOISE BASED ON MOD
float noiseFunc_4(float in1, float in2, float in3) {
    return pow(-1.0, in1 - 1.79284291400159 - 0.85373472095314 * floor(in2 * (1.0 / 289.0))) * in3 / 289.0;
}
    
// NOISE COMBO OF BOTH
float noiseFunc_3(float in1, float in2, float in3) {
    float f1 = noiseFunc_1(in1, in2, in3); 
    float f2 = noiseFunc_4(in1, in2, in3); 
    return ( f1 * (f2 + 5627783.0) / (f1 + 1849102.0) )  / (f2+ .05);
}

float noiseFunc_5(float in1, float in2, float in3) {
  return in1;
}

float noiseFunc_6(float in1, float in2, float in3) {
    return sin(0.2 + (in1 * 0.08) * cos(0.4 + in2*0.3)) * in3;
}

float noiseFunc_7(float in1, float in2, float in3) {
    return (15.0 * (1.0 - (in1*(in2*in3*1.57310 + 7.892210)+1.3763125890) ) + (in1*in2*in3)) / 1.234567890987654321;
    // return in1;
}

    
// CURR NOISE FUNCTION OF THE ABOVE THREE THAT IS ACTUALLY USED bc interp func and smoothing both need to get noise
// of surrounding locations so it's a way to keep consistent which noise function is being used as 'the' noise 
// function outisde of the 3D multi-octave lattice-value noise function
float currNoiseFunc(float in1, float in2, float in3) {
    return noiseFunc_1(in1, in2, in3);
}

// LINEAR INTERP FUNCTION for interpolating between two different values with a given t linearly defined % to get 
// destination location between
float linearInterp(float in1, float in2, float t) {
	return (in1 * (1.0 - t) + in2 * t);
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


// 3D MULTI-OCTAVE LATTICE-VALUE NOISE FUNCTION generates output in controlled range [0,1] or [-1,1]
float overallNoiseFunc(float in1, float in2, float in3) {

    float total = 0.0;
    float persistence = 15.0;
    const int numOctaves = 8;

    float i = 0.0;
    
    // looping through the octaves
    for (int j = 0; j < numOctaves; j++) {
        float frequency = pow(2.0, i);
        float amplitude = pow(persistence, i);

        i++; // doing this here to avoid float / int issues with WebGL
        
        // accumulating overall noise over the octaves
        total +=  amplitude * smooth(in1, in2, in3) * frequency;
    }
    
    return total;
}

// PRODUCES NOISE VALUE FOR POINT by interpolating surrounding lattice values (8 corner points)
float interpNoiseByCorners(float x, float y, float z) {

    // interval at 1.0 ( can't change interval with this floor, ceil set up);
    float interval = 1.0;

    // l: low, h: high

    float x_l = floor(x);
    float x_h = ceil(x);
    float xDiff = (1.0 - abs(x_l -interval) / interval);

    float y_l = floor(y);
    float y_h = ceil(y);
    float yDiff = (1.0 - abs(y_l - interval) / interval);
    
    float z_l = floor(z);
    float z_h = ceil(z);
    float zDiff = (1.0 - abs(z_l - interval) / interval);

    //l = left, r = right
    //t = top, b = bottom
    //f = front (farther from viewer), b = back (closer to viewer)

    // always in order of left/right (x), top/bottom (y), front/back (z)

    // interping x values of top area
    float ltf = overallNoiseFunc(x_l, y_h, z_h);
    float rtf = overallNoiseFunc(x_h, y_h, z_h);
    float ltb = overallNoiseFunc(x_l, y_h, z_l);
    float rtb = overallNoiseFunc(x_h, y_h, z_l);
    // interp between them
    float tf = cosInterpFunc(ltf, rtf, xDiff);
    float tb = cosInterpFunc(ltb, rtb, xDiff);

    // interping x values of bot area
    float lbf = overallNoiseFunc(x_l, y_l, z_h);
    float rbf = overallNoiseFunc(x_h, y_l, z_h);
    float lbb = overallNoiseFunc(x_l, y_l, z_l);
    float rbb = overallNoiseFunc(x_h, y_l, z_l);
    // interp between them
    float bf = cosInterpFunc(lbf, rbf, xDiff);
    float bb = cosInterpFunc(lbb, rbb, xDiff);

    // interping between y values top and bot
    float f = cosInterpFunc(bf, tf, yDiff);
    float b = cosInterpFunc(bb, tb, yDiff);

    // interping between z values of front and back
    float val = cosInterpFunc(b, f, zDiff);

    return val;
}

/********/
/* MAIN */
/********/

void main() {
	nor = normal;

	/************/
	/* POSITION */
	/************/

    
    float noise = interpNoiseByCorners( position[0] * time * .03,
                                        position[1] * time * .03,
                                        position[2] * time * .03
                                       );
    float height = mod(time, 5.0) / 5.0 * 50.0;
    gl_Position = projectionMatrix
    				* modelViewMatrix
    				* ( vec4(position, 1.0) + 500.0 * vec4(nor[0], nor[1], nor[2], 1.0) );

	/*********/
	/* COLOR */
	/*********/

	 // FOR PURE PHOTO
	 // vUv = uv;

     // FOR TESTING
     
     float noise_color = noise;
     float pixelImageHeight = 664.0;
     float height_color = noise_color;
     vUv = vec2 (.5, noise_color);
}