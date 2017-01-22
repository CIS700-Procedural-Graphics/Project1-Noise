//For animation
uniform float elapsedTime;

//Used with GUI interaction to make the noise layers more/less intense
uniform float noiseLayer1Intensity;
uniform float noiseLayer2Intensity;

//Equal to 0 or 1, used with the loaded audio file
uniform int useAudio;

//Scale the noise on the range (0, 1)
uniform float audioLevel;

//Necessary for Perlin Noise computations
uniform int permArray[512];
uniform vec3 gradArray[12];

varying vec2 vUv;
varying vec3 color;

/****************************************************
**** Improved Perlin Noise Computation Functions ****
****************************************************/

/*** Helper Functions: ***/

//Apply the fade curve (6t^5 - 15t^4 + 10t^3) to some input
float fade(float t) {
    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

// Linear Interpolation function
float lerp(float a, float b, float w) {
    return (1.0 - w) * a + w * b;
}

//Perlin Noise Functions

// Given an x, y, and z coordinate, produce a 3D noise value
float PerlinNoiseValue(float x, float y, float z) {
	
	//First find the unit lattice cell containing the coordinate
	float xFloor = floor(x);
	float yFloor = floor(y);
	float zFloor = floor(z);
	
	//The the x, y, and z values local to this lattice cell
	float xLocal = x - floor(x);//sign(x) * floor(abs(x));
    //float xLocal = x - sign(x) * floor(abs(x));
	float yLocal = y - floor(y);//sign(y) * floor(abs(y));
    //float yLocal = y - sign(y) * floor(abs(y));
	float zLocal = z - floor(z);//sign(z) * floor(abs(z));
    //float zLocal = z - sign(z) * floor(abs(z));
	
	//Wrap the lattice integer cells to 255
	xFloor = mod(xFloor, 255.0);
	yFloor = mod(yFloor, 255.0);
	zFloor = mod(zFloor, 255.0);
	
	//Because this version of GLSL is old, in order to index permArray in the first place, we need to "cast" to an int:
	int xFloori = int(xFloor);
	int yFloori = int(yFloor);
	int zFloori = int(zFloor);
	
	//Get indices which we will use to fetch the gradient vectors from the uniform grad array
	int gIndexAAA = int(mod(float(permArray[permArray[permArray[xFloori ] +    yFloori ]+     zFloori ]), 12.0));
	int gIndexAAB = int(mod(float(permArray[permArray[permArray[xFloori ] +    yFloori ] +    zFloori + 1]), 12.0));
    int gIndexABA = int(mod(float(permArray[permArray[permArray[xFloori ] +    yFloori + 1] + zFloori ]), 12.0));
    int gIndexABB = int(mod(float(permArray[permArray[permArray[xFloori ] +    yFloori + 1] + zFloori + 1]), 12.0));
    int gIndexBAA = int(mod(float(permArray[permArray[permArray[xFloori + 1] + yFloori ]+     zFloori ]), 12.0));
    int gIndexBAB = int(mod(float(permArray[permArray[permArray[xFloori + 1] + yFloori ]+     zFloori + 1]), 12.0));
    int gIndexBBA = int(mod(float(permArray[permArray[permArray[xFloori + 1] + yFloori + 1] + zFloori ]), 12.0));
    int gIndexBBB = int(mod(float(permArray[permArray[permArray[xFloori + 1] + yFloori + 1] + zFloori + 1]), 12.0));
    
    //Index the uniform grad array and compute the dot product with the local x, y, and z values to get the
    //noise contributions from each of the eight corners
    float noiseAAA = dot(gradArray[gIndexAAA], vec3(xLocal, yLocal, zLocal));
    float noiseBAA = dot(gradArray[gIndexBAA], vec3(xLocal - 1.0, yLocal, zLocal));
    float noiseABA = dot(gradArray[gIndexABA], vec3(xLocal, yLocal - 1.0, zLocal));
    float noiseBBA = dot(gradArray[gIndexBBA], vec3(xLocal - 1.0, yLocal - 1.0, zLocal));
    float noiseAAB = dot(gradArray[gIndexAAB], vec3(xLocal, yLocal, zLocal - 1.0));
    float noiseBAB = dot(gradArray[gIndexBAB], vec3(xLocal - 1.0, yLocal, zLocal - 1.0));
    float noiseABB = dot(gradArray[gIndexABB], vec3(xLocal, yLocal - 1.0, zLocal - 1.0));
    float noiseBBB = dot(gradArray[gIndexBBB], vec3(xLocal - 1.0, yLocal - 1.0, zLocal - 1.0));
    
    //using the fade curve, compute smoother weights for the trilinear interpolation
    float u = fade(xLocal);
    float v = fade(yLocal);
    float w = fade(zLocal);
    
    //Trilinearly Interpolate the eight noise contributions
    
    //Along x-axis
    float noiseInterpXAA = lerp(noiseAAA, noiseBAA, u);//Lower-back-left to lower-back-right
    float noiseInterpXAB = lerp(noiseAAB, noiseBAB, u);
    float noiseInterpXBA = lerp(noiseABA, noiseBBA, u);
    float noiseInterpXBB = lerp(noiseABB, noiseBBB, u);
    
    //Along y-axis
    float noiseInterpXYA = lerp(noiseInterpXAA, noiseInterpXBA, v);
    float noiseInterpXYB = lerp(noiseInterpXAB, noiseInterpXBB, v);
    
    //Along z-axis
    float noiseInterpXYZ = lerp(noiseInterpXYA, noiseInterpXYB, w);
	
    //on the range (-1, 1)
    return noiseInterpXYZ;
}

float PerlinNoiseMultiOctave(float x, float y, float z) {
    float totalNoise = 0.0; //running sum of noise values over all octaves
    float frequency = 1.0; //sampling rate
    float persistence = 0.5; //how much each successive octave contributes to the sum
    float amplitude = 1.0; //how much a particular octave contributes to the sum
    float maxValue = 0.0; //for normalizing the noise back to (-1, 1)
    
    //number of octaves is the upper limit in the conditional statement
    //GLSL can only use constant expressions in for loops
    for(int i = 0; i < 2; i++) {
        //Retrieve Perlin Noise value at this frequency
        totalNoise += PerlinNoiseValue(x * frequency, y * frequency, z * frequency);
        
        //Keep track of max value
        maxValue += amplitude;
        
        //Update parameters for the next octave
        amplitude *= persistence;
        frequency *= 2.0;
    }
    
    return totalNoise / maxValue; //remap back to (-1, 1)
}

//For convenience
float PerlinNoiseMultiOctave(vec3 noiseInput) {
    return PerlinNoiseMultiOctave(noiseInput.x, noiseInput.y, noiseInput.z);
}

void main() {
    
    //All noise-based displacement is along the surface normal
    vec3 offset = normal;
    
    //Apply the amount of elapsed time as an offset for the animation
    vec3 posTimeOffset = position + vec3(300.0) + vec3(mod(elapsedTime, 256.0));
    
    /*
      Scale the noise to achieve different effects:
       > 1 means sharper, bumpier noise
       < 1 means more gradual, smoother noise
    */
    float noiseLayer1Scale = 0.5;
    float noiseLayer2Scale = 2.0;
    
    /*
      Retrieve the Perlin Noise values
      Note: there are two noise samples, one more gradual than the other
    */
    float noiseLayer1 = PerlinNoiseMultiOctave(posTimeOffset * noiseLayer1Scale);
    float noiseLayer2 = PerlinNoiseMultiOctave(posTimeOffset * noiseLayer2Scale);
    float finalNoise = noiseLayer1 * noiseLayer1Intensity +
                       noiseLayer2 * noiseLayer2Intensity;
    
    //Incorporate Audio contribution to the noise
    float audioScaledNoise = 2.0 * pow(audioLevel * float(useAudio) * finalNoise, 2.0);
    finalNoise = finalNoise * float(1 - useAudio);
    finalNoise += audioScaledNoise;
    
    offset *= finalNoise;
    
    //Set the UVs, which sample the texture according to the noise value
    
    //keep all UVs to the left side of the image
    vUv.x = 0.0;
    
    //remap to (0, 1) for proper uv values
    vUv.y = ((finalNoise / (noiseLayer1Intensity + noiseLayer2Intensity))) + 1.0 / 2.0;
    
    color = vec3(((finalNoise / (noiseLayer1Intensity + noiseLayer2Intensity))) + 1.0 / 2.0);
    
    //Include the offset along the surface normal when computing gl_Position
    gl_Position = projectionMatrix * modelViewMatrix * vec4( position + offset, 1.0 );
}