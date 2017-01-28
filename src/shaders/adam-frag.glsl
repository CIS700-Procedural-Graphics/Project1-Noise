//varying vec2 vUv;
varying float noise;
varying vec3 normColor;
varying vec3 vecPos;
varying vec3 vecNormal;

uniform vec3 pointLightColor[NUM_POINT_LIGHTS];
uniform vec3 pointLightPosition[NUM_POINT_LIGHTS];
uniform float pointLightDistance[NUM_POINT_LIGHTS];

void main() {

    //Color using UV coordinate, modulate with the noise like ambient occlusion
    //vec3 color = vec3( vUv * ( 1. - 2. * noise ), 0.0 );
    //gl_FragColor = vec4( color.rgb, 1.0 );

    //Color using normals, modulate with noise like ambient occlusion
    vec3 color = vec3( normColor * ( 1.0 - 1.5 * noise ));
    //gl_FragColor = vec4( color, 1.0 );

    //Lambertian lighting
    vec4 addedLights = vec4(0.0, 0.0, 0.0, 1.0);
    for(int i = 0; i < NUM_POINT_LIGHTS; i++) {
        vec3 lightDirection = normalize(vecPos - pointLightPosition[i]);
        addedLights.rgb += clamp( dot(-lightDirection, vecNormal), 0.0, 1.0) * pointLightColor[i];
    }

    //Ambient Lighting
    //this ensures faces that are not lit by point light are not compeltely black
    addedLights.rgb += 0.25 * vec3(1.0, 1.0, 1.0);

    //vec3 color = vec3( vec3(0.7, 0.025, 0.1) * ( 1.0 - 2.0 * noise ));
    gl_FragColor = vec4(addedLights.x * color.x, addedLights.y * color.y, addedLights.z * color.z, 1.0);
}




/*
varying vec2 vUv;
varying float noise;
uniform sampler2D image;

void main() {

  vec2 uv = vec2(1,1) - vUv;
  vec4 color = texture2D( image, uv );

  gl_FragColor = vec4( color.rgb, 1.0 );

}
*/