# [Project 1: Noise](https://github.com/CIS700-Procedural-Graphics/Project1-Noise)

## Description

Using three.js and its shader support to generate an interesting 3D, continuous surface using a multi-octave noise algorithm.

## Implementation Details

  - Breakdown of value noise:
      - `perlinNoise()` is an octave function that changes frequency and amplitude with each octave. The value of each octave is determined by a call to interpolatedNoise() and is summed together to achieve a final result

      - `interpolatedNoise()` is a function that does trilinear interpolation, upon running smoothedNoise() on the 8 vertices it interpolates between first to achieve a smoother curve.

      - `randomNoise3D()` is a hash function used to obtain pseudo-random results between 0 and 1.

      - `cosineInterp()` does cosine interpolate

      -  `smoothedNoise()` is a function that smoothens vertices based on its 8 neighbors on each axis (for a total of 27 vertices), a configuration similar to that of a rubiks cube.


  - Time:
      - Time is passed in from main.js as a uniform variable. It is incorporated as an input in the noise function to animate the change in the icosahedron mesh's structure

  - num_octaves:
      - A uniform variable passed in to the vertex shader from main.js that allows users to change its value in the gui

  - perlin_persistence:
      - A uniform variable passed in to the vertex shader from main.js that allows users to change its value in the gui


## Results

1. Control Panel: ![alt text](https://github.com/MegSesh/Project1-Noise/blob/proj1noise_branch1/images/controls.png "Image 1")


2. Jagged Flower:
![alt text](https://github.com/MegSesh/Project1-Noise/blob/proj1noise_branch1/images/cleanjaggedflower_controls.png "Image 2")


3. Ripples:
![alt text](https://github.com/MegSesh/Project1-Noise/blob/proj1noise_branch1/images/ripple_controls.png "Image 3")

More Ripples:
![alt text](https://github.com/MegSesh/Project1-Noise/blob/proj1noise_branch1/images/globe_ripples.png "Image 4")


4. Embryo:
![alt text](https://github.com/MegSesh/Project1-Noise/blob/proj1noise_branch1/images/smootherembryo_controls.png "Image 5")


## Lessons

Despite programming a noise function before and using it to build a terrain, I learned more about how interpolation works with this assignment. I also learned more on how much persistence, frequency, and amplitude can really affect the output of your noise function. I had a lot of fun creating the shapes above, and I hope to do more with this soon!
