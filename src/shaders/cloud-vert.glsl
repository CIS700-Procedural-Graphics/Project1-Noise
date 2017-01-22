uniform float time;
uniform float perst;
varying float noise;

//basic pseudo-noise function, will calculate noise values for the lattice points
float findNoise(float x, float y, float z)
{
	vec3 v1 = vec3(x, y, z);
	vec3 v2 = vec3(12.9898, 78.233, 46.379);
	float bigNum = sin(dot(v1, v2))*43758.5453;
	if(bigNum < 0.0){ return bigNum - ceil(bigNum); }
	else { return bigNum - floor(bigNum); }
}

//smooths the noise values of a given lattice point by averaging its noise with the 6 surrounding lattice points 
float findSmoothNoise(float x, float y, float z)
{
	float posX = findNoise(x + 1.0, y, z);
	float negX = findNoise(x - 1.0, y, z);
	float posY = findNoise(x, y + 1.0, z);
	float negY = findNoise(x, y - 1.0, z);
	float posZ = findNoise(x, y, z + 1.0);
	float negZ = findNoise(x, y, z - 1.0);
	float point = findNoise(x, y, z);

	//i weighted the noise value of the point itself much higher than the surrounding points so that I didn't lose too much amplitude
	return (posX + negX + posY + negY + posZ + negZ + 30.0*point)/36.0;
}

#define M_PI 3.1415926535897932384626433832795

//cosine interpolates from a to b, where the point is t away from point a
float cosInterpolate(float a, float b, float t)
{
	float newT = (1.0 - cos(t*M_PI))/2.0;
	return (a * (1.0 - newT) + b * newT);
}

//for a given vertex, finds the noise on that vertex by trilinear interpolation of the 8 surrounding lattice points
float findInterpNoise(float x, float y, float z)
{

	float lowX = floor(x);
	float highX = lowX + 1.0;
	float tx = (x-lowX)/(highX-lowX);

	float lowY = floor(y);
	float highY = lowY + 1.0;
	float ty = (y-lowY)/(highY-lowY);

	float lowZ = floor(z);
	float highZ = lowZ + 1.0;
	float tz = (z-lowZ)/(highZ-lowZ);

	float calc1 = cosInterpolate(findSmoothNoise(lowX, highY, highZ), findSmoothNoise(highX, highY, highZ), tx);
	float calc2 = cosInterpolate(findSmoothNoise(lowX, lowY, highZ), findSmoothNoise(highX, lowY, highZ), tx);
	float calc3 = cosInterpolate(calc2, calc1, ty);
	float calc4 = cosInterpolate(findSmoothNoise(lowX, highY, lowZ), findSmoothNoise(highX, highY, lowZ), tx);
	float calc5 = cosInterpolate(findSmoothNoise(lowX, lowY, lowZ), findSmoothNoise(highX, lowY, lowZ), tx);
	float calc6 = cosInterpolate(calc5, calc4, ty);
	float calc7 = cosInterpolate(calc6, calc3, tz);

	return calc7;
}

//takes the noise value at multiple different octaves to get an attractive looking noise
float sampleOctaves(float x, float y, float z)
{
	float displacement = 0.0;
	float persistence = perst;

	for (float i = 0.0; i < 4.0; i++)
	{
		float freq = pow(2.0, i);
		float ampl = pow(persistence, i);

		//x, y, and z multiplied by frequency so that they sample from a wider range of values for this octave, creating a bumpier result
		displacement += findInterpNoise(freq*x, freq*y, freq*z) * ampl;
	}

	return displacement;
}


void main() {
	//samples noise for vertex based on ever changing position
	vec3 samplePos = position + vec3(time * 0.0025);

	//finds offset for vertex based on noise value
	float offset = sampleOctaves(samplePos[0], samplePos[1], samplePos[2]);

	//every 2 seconds, the offset goes from 1/7 of its full potential to its full potential and back down to 1/7 of its full potential
	float t  = mod(time, 120.0);
	if(t < 60.0){ offset *= (t+10.0)/70.0; }
	else { offset *= (1.0 - (t-60.0)/70.0); }
	
	//so that the offset can affect color in the fragment shader
	noise = offset;
	
	//moves the position by the offset along the vertex's surface normal
	vec3 pos = position + offset*normal;

    gl_Position = projectionMatrix * modelViewMatrix * vec4( pos, 1.0 );
}