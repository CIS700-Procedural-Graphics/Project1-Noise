# [HW1: Noise](https://github.com/CIS700-Procedural-Graphics/Project1-Noise)

## Noise Generation
I created an interactive 3D Multi-octave Perlin noise function. The calculated noise value is used to offset the mesh as well as color the object. The three colors are interpolated with a gradient map of the three input colors. For each octave, the amplitude decreases by the input 'amplitude' and the frequency increases by the input 'frequency'.  

 
## Misc
- I implemented a smoothing function that on my browser runs very slowly because I compute the perlin noise for 7 different values and average them. I commented it out. Since these values are reused, it would be better to implement a data structure to avoid recomputing values. 
- I can import a mesh. However, I commented this code out because I did not like the look of the objects I imported (a banana and a teacup). I thought the floating ameoba looked cooler.