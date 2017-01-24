varying vec2 new_uv;
varying vec3 vnor;
uniform float time;
uniform float strength;
uniform vec2 uv_offset;
uniform float persistence;
uniform float num_octaves;

float Noisehash(vec3 p)
{
  p  = fract( p*0.3183099+0.1 );
  p *= 17.0;
  return fract( p.x*p.y*p.z*(p.x+p.y+p.z) );
}

float smoothed_noise(vec3 p)
{
  vec3 p1 = vec3(p.x - 1.0, p.y + 1.0,p.z + 1.0);
  vec3 p2 = vec3(p.x,       p.y + 1.0,p.z + 1.0);
  vec3 p3 = vec3(p.x + 1.0, p.y + 1.0,p.z + 1.0);
  vec3 p4 = vec3(p.x - 1.0, p.y,      p.z + 1.0);
  vec3 p5 = vec3(p.x,       p.y,      p.z + 1.0);
  vec3 p6 = vec3(p.x + 1.0, p.y,      p.z + 1.0);
  vec3 p7 = vec3(p.x - 1.0, p.y - 1.0,p.z + 1.0);
  vec3 p8 = vec3(p.x,       p.y - 1.0,p.z + 1.0);
  vec3 p9 = vec3(p.x + 1.0, p.y - 1.0,p.z + 1.0);

  vec3 p10 = vec3(p.x - 1.0,p.y + 1.0,p.z);
  vec3 p11 = vec3(p.x,      p.y + 1.0,p.z);
  vec3 p12 = vec3(p.x + 1.0,p.y + 1.0,p.z);
  vec3 p13 = vec3(p.x - 1.0,p.y,      p.z);
  vec3 p14 = vec3(p.x + 1.0,p.y,      p.z);
  vec3 p15 = vec3(p.x - 1.0,p.y - 1.0,p.z);
  vec3 p16 = vec3(p.x,      p.y - 1.0,p.z);
  vec3 p17 = vec3(p.x + 1.0,p.y - 1.0,p.z);

  vec3 p18 = vec3(p.x - 1.0,p.y + 1.0,p.z - 1.0);
  vec3 p19 = vec3(p.x,p.y + 1.0,p.z - 1.0);
  vec3 p20 = vec3(p.x + 1.0,p.y + 1.0,p.z - 1.0);
  vec3 p21 = vec3(p.x - 1.0,p.y,      p.z - 1.0);
  vec3 p22 = vec3(p.x,p.y,      p.z - 1.0);
  vec3 p23 = vec3(p.x + 1.0,p.y,      p.z - 1.0);
  vec3 p24 = vec3(p.x - 1.0,p.y - 1.0,p.z - 1.0);
  vec3 p25 = vec3(p.x,p.y - 1.0,p.z - 1.0);
  vec3 p26 = vec3(p.x + 1.0,p.y - 1.0,p.z - 1.0);

  float influence1 = 4.0/100.0;
  float influence2 = 1.8/100.0;
  float influence3 = 40.0/100.0;
  //make sure 6*influnce1 + 20*influence2=1

  float n1 =  influence2 * Noisehash(p1);
  float n2 =  influence2 * Noisehash(p2);
  float n3 =  influence2 * Noisehash(p3);
  float n4 =  influence2 * Noisehash(p4);
  float n5 =  influence1 * Noisehash(p5);
  float n6 =  influence2 * Noisehash(p6);
  float n7 =  influence2 * Noisehash(p7);
  float n8 =  influence2 * Noisehash(p8);
  float n9 =  influence2 * Noisehash(p9);

  float n10 = influence2 * Noisehash(p10);
  float n11 = influence1 * Noisehash(p11);
  float n12 = influence2 * Noisehash(p12);
  float n13 = influence1 * Noisehash(p13);
  float n14 = influence3 * Noisehash(p13);
  float n15 = influence1 * Noisehash(p14);
  float n16 = influence2 * Noisehash(p15);
  float n17 = influence1 * Noisehash(p16);
  float n18 = influence2 * Noisehash(p17);

  float n19 = influence2 * Noisehash(p18);
  float n20 = influence2 * Noisehash(p19);
  float n21 = influence2 * Noisehash(p20);
  float n22 = influence2 * Noisehash(p21);
  float n23 = influence1 * Noisehash(p22);
  float n24 = influence2 * Noisehash(p23);
  float n25 = influence2 * Noisehash(p24);
  float n26 = influence2 * Noisehash(p25);
  float n27 = influence2 * Noisehash(p26);

  float average = n1 + n2 +n3 + n4 + n5 + n6 +n7 + n8 + n9 + n10 +n11 + n12 + n13 +
                  n14 + n15 + n16 + n17 + n18 +n19 + n20 + n21 + n22 +n23 + n24 + n25 + n26 +n27;

  return average;
}

float noise3D_linear(vec3 x)
{
    //uses linear blending through the mix function
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f*f*(3.0-2.0*f);

    return mix(mix(mix( Noisehash(p+vec3(0,0,0)),
                        Noisehash(p+vec3(1,0,0)),f.x),
                   mix( Noisehash(p+vec3(0,1,0)),
                        Noisehash(p+vec3(1,1,0)),f.x),f.y),
               mix(mix( Noisehash(p+vec3(0,0,1)),
                        Noisehash(p+vec3(1,0,1)),f.x),
                   mix( Noisehash(p+vec3(0,1,1)),
                        Noisehash(p+vec3(1,1,1)),f.x),f.y),f.z);
}

float Cosine_Interpolate(float a, float b, float t)
{
  // a --- the lower bound value of interpolation
  // b --- the upper bound value of interpolation

	float ft = t * 3.1415927;
	float f = (1.0 - cos(ft)) * 0.5;

	return  a*(1.0-f) + b*f;
}

float Noise3D_cosine(vec3 p)
{
  float x = p.x;
  float y = p.y;
  float z = p.z;

  vec3 p1 = vec3(floor(x), floor(y), floor(z));
  vec3 p2 = vec3(floor(x), floor(y), ceil(z));
  vec3 p3 = vec3(floor(x), ceil(y),  floor(z));
  vec3 p4 = vec3(floor(x), ceil(y),  ceil(z));
  vec3 p5 = vec3(ceil(x),  floor(y), floor(z));
  vec3 p6 = vec3(ceil(x),  floor(y), ceil(z));
  vec3 p7 = vec3(ceil(x),  ceil(y),  floor(z));
  vec3 p8 = vec3(ceil(x),  ceil(y),  ceil(z));

  // float v1 = Noisehash (p1);
  // float v2 = Noisehash (p2);
  // float v3 = Noisehash (p3);
  // float v4 = Noisehash (p4);
  // float v5 = Noisehash (p5);
  // float v6 = Noisehash (p6);
  // float v7 = Noisehash (p7);
  // float v8 = Noisehash (p8);

  float v1 = smoothed_noise(p1);
  float v2 = smoothed_noise(p2);
  float v3 = smoothed_noise(p3);
  float v4 = smoothed_noise(p4);
  float v5 = smoothed_noise(p5);
  float v6 = smoothed_noise(p6);
  float v7 = smoothed_noise(p7);
  float v8 = smoothed_noise(p8);

  float i1 = Cosine_Interpolate(v1 , v2 , z-floor(z));
  float i2 = Cosine_Interpolate(v3 , v4 , z-floor(z));
  float i3 = Cosine_Interpolate(v5 , v6 , z-floor(z));
  float i4 = Cosine_Interpolate(v7 , v8 , z-floor(z));

  float i5 = Cosine_Interpolate(i1 , i2 , y-floor(y));
  float i6 = Cosine_Interpolate(i3 , i4 , y-floor(y));

  float noise_interpolated = Cosine_Interpolate(i5 , i6 , x-floor(x));

  return noise_interpolated;
}

float Noise3D(vec3 p)
{
  float total = 0.0;
  //float persistence = 0.8;

  //Loop over n =4 octaves
  float i=0.0;
  for(int j=0; j< 20; j++)
  {
    if(j < int(num_octaves))
    {
      float frequency = pow(2.0, i);
      float amplitude = pow(persistence, i);
      i= i+1.0;
      //sum up all the octaves
      total += Noise3D_cosine(p * frequency) * (1.0/amplitude);
    }
  }
  return total;
}

void main()
{
    new_uv = uv + uv_offset;

    if(new_uv.x > 1.0)
    {
      new_uv.x -= 1.0;
    }
    if(new_uv.y > 1.0)
    {
      new_uv.y -= 1.0;
    }

    if(new_uv.x > 0.95)
    {
      new_uv.x = 0.95;
    }
    if(new_uv.y > 0.95)
    {
      new_uv.y = 0.95;
    }

    vnor = normal;
    vec3 p = vec3(uv[0],uv[1],time);
    vec3 vposition = position + normal * strength * Noise3D(position + time/250.0);
    gl_Position = projectionMatrix * modelViewMatrix * vec4( vposition, 1.0 );
}
