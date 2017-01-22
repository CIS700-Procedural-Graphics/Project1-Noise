// a bunch of 3d pseudo-random noise functions that return floating point numbers between -1.0 and 1.0
function generateNoise1(x, y, z) {
	var n = x + y + z * 57;
    n = (n<<13) ^ n;
    return ( 1.0 -  (n * (n * n * 15731 + 789221) + 1376312589) / 1073741824.0);
}

function linearInterpolate(a, b, t) {
	return a * (1 - t) + b * t;
}

function cosineInterpolate(a, b, t) {
	var cos_t = (1 - cos(t * Math.PI)) * 0.5;
	return linearInterpolate(a, b, cos_t);
}

// given a point in 3d space, produces a noise value by interpolating surrounding points
function interpolateNoise(x, y, z) {
	var integerX = Math.floor(x);
    var weightX = x - integerX;

    var integerY = Math.floor(y);
    var weightY = y - integerY;

    var integerZ = Math.floor(Z);
    var weightZ = z - integerZ;

    var v1 = generateNoise1(integerX, integerY, integerZ);
    var v2 = generateNoise1(integerX, integerY, integerZ + 1);
    var v3 = generateNoise1(integerX, integerY + 1, integerZ + 1);
    var v4 = generateNoise1(integerX, integerY + 1, integerZ);

    var v5 = generateNoise1(integerX + 1, integerY, integerZ);
    var v6 = generateNoise1(integerX + 1, integerY, integerZ + 1);
    var v7 = generateNoise1(integerX + 1, integerY + 1, integerZ + 1);
    var v8 = generateNoise1(integerX + 1, integerY + 1, integerZ);

    var i1 = cosineInterpolate(v1, v5, weightX);
    var i2 = cosineInterpolate(v2, v6, weightX);
    var i3 = cosineInterpolate(v3, v7, weightX);
    var i4 = cosineInterpolate(v4, v8, weightX);

    var ii1 = cosineInterpolate(i1, i4, weightY);
    var ii2 = cosineInterpolate(i2, i3, weightY);

    return cosineInterpolate(ii1, ii2 , weightZ);
}

// a multi-octave noise generation function that sums multiple noise functions together
// with each subsequent noise function increasing in frequency and decreasing in amplitude
function generateMultiOctaveNoise(x, y, z, numOctaves) {
    var total = 0;
    var persistence = 1/2.0;

    //loop for some number of octaves
    for (var i = 0; i < numOctaves; i++) {
        var frequency = Math.pow(2, i);
        var amplitude = Math.pow(persistence, i);

        total += interpolateNoise(x * frequency, y * frequency, z * frequency) * amplitude;
    }

    return total;
}

export default {
  generateNoise1: generateNoise1
}

export function other() {
  return 2
}