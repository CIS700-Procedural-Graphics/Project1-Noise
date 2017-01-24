const THREE = require('three');

//PROJ 1: NOISE

//Noise Generation
//In the shader, write a 3D multi-octave lattice-value noise function that takes three input parameters and
//generates output in a controlled range, say [0,1] or [-1, 1]. This will require the following steps.

//Write several (for however many octaves of noise you want) basic pseudo-random 3D noise functions
//(the hash-like functions we discussed in class). It's fine to reference one from the slides or elsewhere on the Internet.
//Again, this should just be a set of math operations, often using large prime numbers to random-looking output from three input parameters.

//Write an interpolation function. Lerp is fine, but for better results, we suggest cosine interpolation.

//(Optional) Write a smoothing function that will average the results of the noise value at some (x, y, z) with neighboring values, that is (x+-1, y+-1, z+-1).

//Write an 'interpolate noise' function that takes some (x, y, z) point as input and produces a
//noise value for that point by interpolating the surrounding lattice values (for 3D, this means the surrounding eight 'corner' points).
//Use your interpolation function and pseudo-random noise generator to accomplish this.

//Write a multi-octave noise generation function that sums multiple noise functions together, with each subsequent
//noise function increasing in frequency and decreasing in amplitude. You should use the interpolate noise function you wrote
//previously to accomplish this, as it generates a single octave of noise. The slides contain pseudocode for writing your multi-octave noise function.



function hash1(x) //returns a float
{
  //x = (x << 13) ^ x;
  //return (1.0 - (x * (x * x * 15731 + 789221) + 1376312589) & 7fffffff) / 10737741824.0);
}

function hash2(x, y) //returns a float
{
  //return fract(sin(dot(vec2(x, y), vec2(12.9898, 78.233))) * 43758.5453);
}

/*
float Scene::randomNoise3D(float x, float z, float y)
{
    int int_x = (int)((x + y + z) * 57);
    int_x = (int_x<<13) ^ int_x;
    return ((1.0 - ( (int_x * (int_x * int_x * 15731 + 789221) + 1376312589) & 0x7fffffff) / 1073741824.0f) + 1) / 2.0f;
}

float Scene::randomNoise3D_2(float x, float z, float y)
{
//    int int_x = (int)((x + y + z) * 157);
//    int_x = (int_x>>13) ^ int_x;
//    return ((1.0 - ( (int_x * (int_x * int_x * 15731 + 789221) + 1376312589) & 0x7fffffff) / 1073741824.0f) + 1) / 2.0f;

    glm::vec3 a = glm::vec3(x, y, z);
    glm::vec3 b = glm::vec3(12.9898, 78.233, 140.394);
    float val = std::sin(glm::dot(a, b)) * 43758.5453;
    int int_val = (int)val;
    return (1 + (val - int_val)) / 2.0f;
}
*/

//========================================================================================================================================================

function linear_interp(a, b, t) //returns a float
{
  //return a * (1 - t) + b * t;
}

function cosine_interp(a, b, t) //returns a float
{
  //cos_t = (1 - cos(t * M_PI)) * 0.5f;
  //return linear_interpolate(a, b, cos_t);
}


//========================================================================================================================================================

function perlinNoise2D(x, y) //returns a float
{
  //float total = 0;
  //float persistence = 1 / 2.0f;

  //for(int i = 0; i < numOctaves; i++)
  //{
    //float frequency = pow(2, i);
    //float amplitude = pow(persistence, i);

    //total += sampleNoise(x, y, frequency);
  //}
  //return total;
}


/*
float Scene::perlinWorm(float x, float z, float y)
{
    float output_direction = 0.0f;
    double persistence = .5;
    int numOctaves = 2;
    float frequency = 0;
    float amplitude = 0;

    x = x * .3;
    z = z * .3;
    y = y * .3;

    for (int i = 0; i < numOctaves; i++)
    {
        frequency = std::pow(2, i);
        amplitude = std::pow(persistence, i);
        output_direction = output_direction + randomNoise3D(x * frequency, z * frequency, y * frequency) * amplitude;
    }

    //std::cout<< "OUTPUT LEFT RIGHT VALUE: " << output_direction << std::endl;

    return output_direction;
}
*/







/*


//each sample point has a smoothed value, and then you interpolate between those smoothed values rather than the original ones
float interpolatedNoise(float x, float y, float z)
{
    float floored_x = floor(x);
    float diff_x = x - floored_x;

    float floored_y = floor(y);
    float diff_y = y - floored_y;

    float floored_z = floor(z);
    float diff_z = z - floored_z;

    float v1 = smoothedNoise(floored_x, floored_y, floored_z);
    float v2 = smoothedNoise(floored_x + 1, floored_y, floored_z);
    float v3 = smoothedNoise(floored_x, floored_y + 1, floored_z);
    float v4 = smoothedNoise(floored_x + 1, floored_y + 1, floored_z);

    float v5 = smoothedNoise(floored_x, floored_y, floored_z + 1);
    float v6 = smoothedNoise(floored_x + 1, floored_y, floored_z + 1);
    float v7 = smoothedNoise(floored_x, floored_y + 1, floored_z + 1);
    float v8 = smoothedNoise(floored_x + 1, floored_y + 1, floored_z + 1);


    float interp_1 = cosineInterp(v1, v2, difference_x);
    float interp_2 = cosineInterp(v3, v4, difference_x);

    float interp_3 = cosineInterp(v5, v6, difference_y);
    float interp_4 = cosineInterp(v7, v8, difference_y);

    float interp_5 = cosineInterp(interp_1, interp_2, difference_z);
    float interp_6 = cosineInterp(interp_3, interp_4, difference_z);

    return cosineInterp(interp_5, interp_6, difference_z);
}

float smoothedNoise(float x, float y)
{
    float corners = (randomNoise(x - 1, y - 1, z + 1) + randomNoise(x + 1, y - 1, z + 1) + randomNoise(x - 1, y + 1, z + 1) + randomNoise(x + 1, y + 1, z + 1)) +
                    (randomNoise(x - 1, y - 1, z - 1) + randomNoise(x + 1, y - 1, z - 1) + randomNoise(x - 1, y + 1, z - 1) + randomNoise(x + 1, y + 1, z - 1))
                    / 16.0;

    float sides = (randomNoise(x - 1, y, z + 1) + randomNoise(x + 1, y, z + 1) + randomNoise(x , y - 1, z + 1) + randomNoise(x , y + 1, z + 1))
                  (randomNoise(x - 1, y, z - 1) + randomNoise(x + 1, y, z - 1) + randomNoise(x , y - 1, z - 1) + randomNoise(x , y + 1, z - 1))
                  / 8.0;


    //edge connected (12) / 8
    //(x - 1, y + 1, z), (x, y + 1, z + 1), (x + 1, y + 1, z), (x, y + 1, z - 1)
    //(x - 1, y, z + 1), (x + 1, y, z + 1), (x + 1, y, z - 1), (x - 1, y, z - 1)
    //(x - 1, y - 1, z), (x, y - 1, z + 1), (x + 1, y - 1, z), (x, y - 1, z - 1)

    //point connected (8) / 16
    //(x - 1, y + 1, z + 1), (x + 1, y + 1, z + 1), (x - 1, y - 1, z + 1), (x + 1, y - 1, z + 1)
    //(x - 1, y + 1, z - 1), (x + 1, y + 1, z - 1), (x - 1, y - 1, z - 1), (x + 1, y - 1, z - 1)

    //face connected (6) / 4
    //(x - 1, y , z), (x, y + 1, z), (x , y, z + 1), (x + 1, y, z), (x , y, z - 1), (x , y - 1, z)

    //center (1) / 2
    //(x, y , z)


    float center = randomNoise(x , y, z) / 4.0;

    return corners + sides + center;
}

float cosineInterp(float x, float y, float z)
{
    float t = (1 - std::cos(z * M_PI)) * 0.5;
    return (x * (1 - t)) + (y * t);
}



*/
