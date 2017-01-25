													MULTI OCTAVE NOISE

Implemented Multi Octave Pseudo-Random noise and applied it to each vertex point on the mesh.

Implemented cosine interpolation and smoothing function to obtain the average noise at each lattice point surround the given vertex of the mesh and to find an interpolated noise value for the vertex point.

The vertex positions are offset by a factor of the noise along the normal direction and the height is interpolated along all the intermediate points of the mesh.

The texture applied on the mesh is manipulated with the noise value for randomising the output.

Music is sampled and analised to mnipulate the position and offset of the vertices of the mesh when the music is playing.



Reference Website List:

1.) For loading and using audio on the website using Java script I used the code and explanation on this site:
https://www.patrick-wied.at/blog/how-to-create-audio-visualizations-with-javascript-html

2.) WebGL 1.0 API referenece Card a quick and extensive list of all functions and libraries available for you while using WebGL 1.0.:
https://www.khronos.org/files/webgl/webgl-reference-card-1_0.pdf

3.) Counting Uniforms in WebGL, each OS and machine has its own requirments and limitations on how many uniforms are available at a time in a shader I used this website to referece it for my machine:
https://bocoup.com/weblog/counting-uniforms-in-webgl

4.) Three.js documentation of its Libraries and Syntax of functions:
https://threejs.org/docs/index.html#Reference/Extras.Core/CurvePath

5.)A Good giude to understand and implement Perlin noise:
https://web.archive.org/web/20160510013854/http://freespace.virgin.net/hugo.elias/models/m_perlin.htm
