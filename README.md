# [Project 1: Noise](https://github.com/CIS700-Procedural-Graphics/Project1-Noise)

#LINK TO THE DEMO: #[HERE](https://mccannd.github.io/Project1-Noise/)

Usage:
The checkbox labelled 'time' turns animation on and off
Light direction is controlled by "pitch" and "yaw"

Description and features:
Generates a shifting planetoid using improved Perlin Noise.
Height is determined by multi-octave noise, but clamped to not fall below a certain height.
Color is read from a 2D texture. V is height, U is an additional noise sample.
Blinn-Phong shading on the material, with a multiplier read from a 2D texture. This should only apply on the water / spherical portion
Simple lighting of the sphere. The mountains are not bump mapped.
Aerial perspective / atmosphere: geographic features farther away from the view will be colored by the atmosphere.

Notes on the code:
The hash table and ease function are from Ken Perlin's implementation.
There are a few vestigial uniforms, such as seed and max octave. My plan was to use min and max octave with UI integration. Alas, the for loop must be constant.
