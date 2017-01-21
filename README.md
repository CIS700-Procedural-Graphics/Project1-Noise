A procedural noise cloud that dances and changes color with music. Returns to default noise based animation on pausing the music.

The color is chosen by interpolating between 1,1,1 and the color from the GUI. This interpolation is done using noise value and audio data (when music is playing). 
The positions of the mesh vertices are also offset using audio data when the music is playing.

Noise used is multi-octave lattice value noise. The noise calculations and vertex manipulations are done in shaders.

References:
1.
dat.GUI:
https://workshop.chromeexperiments.com/examples/gui/#1--Basic-Usage
2.
glsl array passingin three.js:
https://github.com/mrdoob/three.js/issues/389
3.
JS arrays:
http://www.w3schools.com/js/js_arrays.asp
4.
three.js uniform types:
https://github.com/mrdoob/three.js/wiki/Uniforms-types
5.
Audio in JS:
https://www.patrick-wied.at/blog/how-to-create-audio-visualizations-with-javascript-html
https://w-labs.at/experiments/audioviz/
AnalyserNode:
https://webaudio.github.io/web-audio-api/#the-analysernode-interface
6.
JS measure time: performance.now()
http://stackoverflow.com/questions/313893/how-to-measure-time-taken-by-a-function-to-execute
http://stackoverflow.com/questions/1210701/compute-elapsed-time
7.
simplex noise:
https://cmaher.github.io/posts/working-with-simplex-noise/
8.
Plot of noise function:
http://www.wolframalpha.com/input/?i=plot(+mod(+sin(x*12.9898+%2B+y*78.233)+*+43758.5453,1)x%3D0..2,+y%3D0..2)
9.
GLSL: shader functions and stuff:
https://www.khronos.org/opengl/wiki/Core_Language_(GLSL)#Functions
http://relativity.net.au/gaming/glsl/Functions.html
http://www.lighthouse3d.com/tutorials/glsl-tutorial/statements-and-functions/
10.
webgl shader stuff:
http://webglfundamentals.org/webgl/lessons/webgl-shaders-and-glsl.html
11.
webgl basics:
http://webglfundamentals.org/webgl/lessons/webgl-fundamentals.html
https://www.khronos.org/files/webgl/webgl-reference-card-1_0.pdf