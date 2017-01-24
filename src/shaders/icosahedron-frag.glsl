varying vec3 vNormal;
varying vec3 perlin_color;

void main() {
  //PROJ1 : NOISE
  //Test your shader setup by applying the material to the icosahedron and color the mesh in the fragment shader using the normals' XYZ components as RGB.

  gl_FragColor = vec4(vNormal, 1.0);
  //gl_FragColor = vec4(1.0 * perlin_color, 1.0);
}
