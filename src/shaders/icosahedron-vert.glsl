
varying vec2 vUv;
varying vec3 vNor;
varying vec3 vPos;
uniform float time;
uniform float frequency;

float hash(vec3 p) 
{
  p = fract( p*0.3183099+.1);
	p *= 17.0;
  return fract( p.x*p.y*p.z*(p.x+p.y+p.z) );
}

float smoothing(float x, float y, float z) {
   
    //left side
    float l1 = hash(vec3(x-1.0,y-1.0,z-1.0));
    float l2 = hash(vec3(x-1.0,y-1.0,z));
    float l3 = hash(vec3(x-1.0,y-1.0,z+1.0));
    float l4 = hash(vec3(x-1.0,y,z-1.0));
    float l5 = hash(vec3(x-1.0,y,z));
    float l6 = hash(vec3(x-1.0,y-1.0,z+1.0));
    float l7 = hash(vec3(x-1.0,y+1.0,z-1.0));
    float l8 = hash(vec3(x-1.0,y+1.0,z));
    float l9 = hash(vec3(x-1.0,y+1.0,z+1.0));

    //middle
    float m1 = hash(vec3(x,y-1.0,z-1.0));
    float m2 = hash(vec3(x,y-1.0,z));
    float m3 = hash(vec3(x,y-1.0,z+1.0));
    float m4 = hash(vec3(x,y,z-1.0));
    float m5 = hash(vec3(x,y,z));
    float m6 = hash(vec3(x,y-1.0,z+1.0));
    float m7 = hash(vec3(x,y+1.0,z-1.0));
    float m8 = hash(vec3(x,y+1.0,z));
    float m9 = hash(vec3(x,y+1.0,z+1.0));
    
    //right
    float r1 = hash(vec3(x+1.0,y-1.0,z-1.0));
    float r2 = hash(vec3(x+1.0,y-1.0,z));
    float r3 = hash(vec3(x+1.0,y-1.0,z+1.0));
    float r4 = hash(vec3(x+1.0,y,z-1.0));
    float r5 = hash(vec3(x+1.0,y,z));
    float r6 = hash(vec3(x+1.0,y-1.0,z+1.0));
    float r7 = hash(vec3(x+1.0,y+1.0,z-1.0));
    float r8 = hash(vec3(x+1.0,y+1.0,z));
    float r9 = hash(vec3(x+1.0,y+1.0,z+1.0));
    
    
    //not including center point
    float total =      (l1) + (l2) + (l3)
                    +  (l4) + (l5) + (l6)
                    +  (l7) + (l8) + (l9)
        
                    +  (m1) + (m2) + (m3)
                    +  (m4) + (m6)
                    +  (m7) + (m8) + (m9)
 
                    +  (r1) + (r2) + (r3)
                    +  (r4) + (r5) + (r6)
                    +  (r7) + (r8) + (r9);
        
    float totalAvg = total / 27.0 * 0.25; //0.25 influence
     
    return totalAvg + m5 * 0.5; //0.5 original point influence
}

float lerp(float a, float b, float t) {
    return a * (1.0 - t) + b * t;
}

float cos_interpolation(float a, float b, float t) {
    float cos_t = (1.0 - cos(t * 3.141592653589793238462643383279)) * 0.5;
    return lerp(a, b, cos_t);
}

float interpolate_noise(float x, float y, float z) {
    
    vec3 v1 = vec3(floor(x), floor(y), floor(z));
    vec3 v2 = vec3(floor(x), floor(y), ceil(z));
    vec3 v3 = vec3(floor(x), ceil(y), floor(z));
    vec3 v4 = vec3(floor(x), ceil(y), ceil(z));
    
    vec3 v5 = vec3(ceil(x), floor(y), floor(z));
    vec3 v6 = vec3(ceil(x), floor(y), ceil(z));
    vec3 v7 = vec3(ceil(x), ceil(y), floor(z));
    vec3 v8 = vec3(ceil(x), ceil(y), ceil(z));
    
    
    float x1, x2, y1, y2;
    
    x1 = cos_interpolation(smoothing(v1.x,v1.y,v1.z),
                smoothing(v2.x,v2.y,v2.z),     
                z - floor(z));                      
    x2 = cos_interpolation(smoothing(v3.x,v3.y,v3.z),
                smoothing(v4.x,v4.y,v4.z),     
                z - floor(z)); 
    
    y1 = cos_interpolation(x1, x2, y - floor(y));

    x1 = cos_interpolation(smoothing(v5.x, v5.y, v5.z),
                smoothing(v6.x, v6.y, v6.z),     
                z - floor(z));                      
    x2 = cos_interpolation(smoothing(v7.x, v7.y, v7.z),
                smoothing(v8.x,v8.y,v8.z),     
                z - floor(z)); 
    
    y2 = cos_interpolation(x1, x2, y - floor(y));
    
    return cos_interpolation(y1, y2, x - floor(x));
}

float perlin_noise(float x, float y, float z) {
    
    float total = 0.0;
    float persistence = 1.5;
      
    float j = 0.0;
    for (int i = 0; i < 5; i++) {
        float frequency = pow(2.0,j);
        float amplitude = pow(persistence, j);
        
        total += interpolate_noise(x * frequency, y * frequency, z  * frequency) * amplitude;
            
        j = j + 1.0;
    }
    
    return total;
}

void main() {
  vUv = uv;
  vNor = normal; 
  
  vec3 offset = position + time/50.0;
  vPos = position + (perlin_noise(offset.x, offset.y, offset.z)) * normal * frequency/500.0;
  gl_Position = projectionMatrix * modelViewMatrix * vec4( vPos, 1.0 );
}