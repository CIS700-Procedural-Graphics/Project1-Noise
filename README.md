## Joseph Klinger - CIS 700 Procedural Graphics - Project 1 - Noise

(Make sure to use the good values I describe later on when testing out my project! They matter!)

This project uses ThreeJS to displace and color the veritces of a sphere (subdivided icosahedron) using Ken Perlin's Improved Noise Algorithm in 3D.

All computations occur from within the shaders - noise-vert.glsl and noise-frag.glsl. The position of each vertex, offset by the amount of elapsed time, is used as input to the noise generation functions. The UVs are also set according to this noise value in order to change the color according to a color pallet in a loaded texture file.

Ken Perlin's defined permutation and gradient vector arrays are imported from 'noise.js' and passed as uniforms to the shaders.

Textures and OBJs are included in the folder called 'res' that I created.

Good values to use:
If you want to view just the raw Perlin Noise values, set Inner Noise = 0 and then Outer Noise = 0.01.

If you're using the audio, I suggest Inner Noise = 8 or 9, Outer Noise = 1, and use the texture for enhanced visual effect (looks weird without the texture).

If you're viewing an of the OBJs (regardless of audio), I suggest Inner Noise = 0 and Outer Noise = 0.1. The bunny looks best, I think.

## Extra Credit:
The extra credit that I implemented was:
- Additional controllable variables in the GUI
- OBJ Loading
- Music incorporation

## Sources:
I did implement this form of noise for my Mini-Minecraft, but I felt at the time that I did not understand it fully, but I think I understand it much more clearly now. I did also use the following sources as reference for this:

http://weber.itn.liu.se/~stegu/simplexnoise/simplexnoise.pdf (primary)

http://flafla2.github.io/2014/08/09/perlinnoise.html (secondary)

https://web.archive.org/web/20160510013854/http://freespace.virgin.net/hugo.elias/models/m_perlin.htm (mostly for high-level details, even though this article isn't *really* on Perlin Noise)

OBJ Files:

http://www.prinmath.com/csci5229/OBJ/index.html

The Teapot was included in a CIS 277 Project from Spring '15.


OBJ Loading Sources:

https://www.npmjs.com/package/three-obj-loader

http://stackoverflow.com/questions/40574474/three-fileloader-is-not-a-constructor

http://stackoverflow.com/questions/30359830/how-do-i-clear-three-js-scene

Audio Sources:

https://threejs.org/docs/?q=audio#Reference/Audio/Audio

https://developer.mozilla.org/en-US/docs/Web/API/AnalyserNode/getByteFrequencyData

http://ianreah.com/2013/02/28/Real-time-analysis-of-streaming-audio-data-with-Web-Audio-API.html