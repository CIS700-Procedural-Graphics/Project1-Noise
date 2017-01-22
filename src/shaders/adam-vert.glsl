varying vec2 vUv;
varying float dprod;
varying float noise;
uniform vec2 gradients[8];
uniform vec3 gradients3d[12];
uniform int time;
uniform int table[512];
uniform int seed;

varying vec3 test;

float lerp(in float a, in float b, in float t)
{
	t = clamp(t, 0.0, 1.0);
	float val = t * b + (1.0 - t) * a;
	return val;
}

vec3 vmod(in vec3 v, float m)
{
	return v - floor(v * (1.0 / m)) * m;
}

// the ease curve by Ken Perlin, which gives smoother results for LERP
float ecurve(in float t)
{
	return (t * t * t * (t * (t * 6.0 - 15.0) + 10.0));
}

// randomly select a 3d gradient given a corner's coordinates
vec3 pickGradient(in int x, in int y, in int z)
{
	int hash = table[z + table[y + table[x]]];
	float t = float(hash) / 256.0;
	return gradients3d[int(t * 12.0)];
}

float getnoise3d(in float x, in float y, in float z, in int numSamples)
{
	//vec3 vm = vmod(float(numSamples) * (vec3(x, y, z) + vec3(2, 2, 2)), float(numSamples));

	// position within gradient grid
	float xs = mod(x * float(numSamples) + 289.0, 255.0);
	float ys = mod(y * float(numSamples) + 289.0, 255.0);
	float zs = mod(z * float(numSamples) + 289.0, 255.0);
	// lower bound of grid cube
	int xlb = int(floor(xs));
	int ylb = int(floor(ys));
	int zlb = int(floor(zs));
	// 0 - 1 parameterization of grid cube
	float tx = ecurve(xs - float(xlb));
	float ty = ecurve(ys - float(ylb));
	float tz = ecurve(zs - float(zlb));

	// position in grid cube
	float px = xs - floor(xs);
	float py = ys - floor(ys);
	float pz = zs - floor(zs);

	// sample each corner

	// back left bottom
	float blb = dot(pickGradient(xlb, ylb, zlb), vec3(px, py, pz));
	// back right bottom
	float brb = dot(pickGradient(xlb + 1, ylb, zlb), vec3(px - 1.0, py, pz));
	// front left bottom
	float flb = dot(pickGradient(xlb, ylb, zlb + 1), vec3(px, py, pz - 1.0));
	// front right bottom
	float frb = dot(pickGradient(xlb + 1, ylb, zlb + 1), vec3(px - 1.0, py, pz - 1.0));
	// back left top
	float blt = dot(pickGradient(xlb, ylb + 1, zlb), vec3(px, py - 1.0, pz));
	// back right top
	float brt = dot(pickGradient(xlb + 1, ylb + 1, zlb), vec3(px - 1.0, py - 1.0, pz));
	// front left top
	float flt = dot(pickGradient(xlb, ylb + 1, zlb + 1), vec3(px, py - 1.0, pz - 1.0));
	// front right top
	float frt = dot(pickGradient(xlb + 1, ylb + 1, zlb + 1), vec3(px - 1.0, py - 1.0, pz - 1.0));


	// trilinear sample
	// left to right
	float l1 = lerp(brb, frb, tz);
	float l2 = lerp(blb, flb, tz);
	float l3 = lerp(brt, frt, tz);
	float l4 = lerp(blt, flt, tz);
	// back to front
	float l13 = lerp(l1, l3, ty);
	float l24 = lerp(l2, l4, ty);
	// bottom to top
	return lerp (l24, l13, tx);
}

float getnoise(in float u, in float v, in int numSamples)
{
	//position within gradient grid
	float xs = u * float(numSamples); 
	float ys = v * float(numSamples);

	// lower bound of grid square
	int xlb = int(floor(xs));
	int ylb = int(floor(ys));

	// 0 - 1 parameterization of grid square
	float tx = ecurve(xs - float(xlb));
	float ty = ecurve(ys - float(ylb));
	


	// sample each corner:
	// Lower Left
	int hash3 = table[table[xlb + table[ylb]]];
	float proportion = float(hash3) / 256.0;
	vec2 ll = gradients[int(proportion * 8.0)];

	// Lower Right
	hash3 = table[table[xlb + 1 + table[ylb]]];
	proportion = float(hash3) / 256.0;
	vec2 lr = gradients[int(proportion * 8.0)];

	// Upper Left
	hash3 = table[table[xlb + table[ylb + 1]]];
	proportion = float(hash3) / 256.0;
	vec2 ul = gradients[int(proportion * 8.0)];

	// Upper Right
	hash3 = table[table[xlb + 1 + table[ylb + 1]]];
	proportion = float(hash3) / 256.0;
	vec2 ur = gradients[int(proportion * 8.0)];

	float d1 = dot(ll, (vec2(xs - floor(xs), ys - floor(ys))));
	float d2 = dot(lr, (vec2(xs - floor(xs) - 1.0, ys - floor(ys))));
	float d3 = dot(ul, (vec2(xs - floor(xs), ys - floor(ys) - 1.0)));
	float d4 = dot(ur, (vec2(xs - floor(xs) - 1.0, ys - floor(ys) - 1.0)));

	float d12 = lerp(d1, d2, tx);
	float d34 = lerp(d3, d4, tx);
	return lerp(d12, d34, ty);
}


void main() {
    vUv = uv;
    //noise = getnoise(uv[0], uv[1], 16);
    //float samp = 2.0;
    //for (int i = 0; i < 6; i++) {
    //	samp = 2.0 * samp;
    //	noise = noise + 4.0 / samp * getnoise(uv[0], uv[1], int(samp));
    //}
    //noise = getnoise3d((normal.x + 1.0) / 2.0, (normal.y + 1.0) / 2.0, (normal.z + 1.0) / 2.0, 2);
    float samp = 1.0;
    for (int i = 0; i < 6; i++) {
    	samp = 2.0 * samp;
    	noise = noise + 2.0 / samp * getnoise3d((normal.x + 1.0) / 2.0,
    	 (normal.y + 1.0) / 2.0, 
    	 (normal.z + 1.0) / 2.0, int(samp));
    }
    dprod = dot(normalize(cameraPosition.xyz), normal.xyz);
    clamp(dprod, 0.0, 1.0);
    test = vec3((position.x + 1.0) / 2.0, (position.y + 1.0) / 2.0, (position.z + 1.0) / 2.0);
    gl_Position = projectionMatrix * modelViewMatrix * vec4(noise * 0.2 * normal + position, 1.0 );
}