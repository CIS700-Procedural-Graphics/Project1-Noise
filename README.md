![Alt text](/src/misc/header.png?raw=true "")
# Playing with Noise

A small and rushed noisy animation that plays along the song Light Cycles by Shock One.

# [SEE IT IN REALTIME](https://mmerchante.github.io/playing-with-noise/)
# [DEMO VIDEO](https://www.youtube.com/watch?v=iShzHAF408I)

# How it works

The animation can be broken down in various pieces:

## The sphere

A 4D perlin noise driven by time and 3D position displaces the sphere along its normal. Its color is defined by a function of its displacement.

## The initial sound disk
![Alt text](/src/misc/disk.png?raw=true "")
The disk's deformation is actually just another perlin noise. It's just a hack to trick the eye thinking it's the actual soundwave.

## Radial lines

![Alt text](/src/misc/stripes.png?raw=true "")
Again, a premade mesh made in Maya is colored by its angle, and synchronized to the song.


## Particle ocean

Using the frequency of the song, a set of particles is displaced. However, because I didn't have any time to batch these particles in threejs, I just merged them in Maya.

## Miscellaneous

There is an overlay and a background shader that add to the overall composition.


# UI

There are some controls to tweak the noise, but most of the choreography code overrides it. If you want to play with the noise, you can enable the debug mode and see the raw perlin noise (which is 3D projected into 2D)


# Notes

The particular Perlin implementation is not the most efficient by any chance. It's done in a way that's easy to read. If I have time I'll try to use the usual methods to optimize it.

# References

Stuff that helped do this!

https://cmaher.github.io/posts/working-with-simplex-noise/

http://weber.itn.liu.se/~stegu/simplexnoise/simplexnoise.pdf

https://www.gamedev.net/topic/285533-2d-perlin-noise-gradient-noise-range--/

https://www.scratchapixel.com/lessons/procedural-generation-virtual-worlds/perlin-noise-part-2

https://www.shadertoy.com/view/llBSWc

http://download.autodesk.com/us/maya/2011help/api/contrast_shader_8cpp-example.html

https://github.com/BrianSharpe/GPU-Noise-Lib/blob/master/gpu_noise_lib.glsl
