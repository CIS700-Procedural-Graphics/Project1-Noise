#[Project 1: Noise](http://www.emilyhvo.com/Project1-Noise/)
This project is a demonstration in procedural mesh and textures using noise. 


![alt tag](https://raw.githubusercontent.com/emily-vo/Project1-Noise/master/noise.png)


# Documentation

The first thing I did was write a good hash function to use for psuedo-randomness. 
Then, I wrote a function that sampled the noise at grids and interpolated between the grid values for intermediate points. I used trilinear interpolation to interpolate between 8 points of a voxel. The t-values for interpolation are based on distance from the point whose value is being calculated to the voxel points. This is similar to perlin noise. 
Finally, I wrote a multioctave function that combines multiple noise functions for a more interesting result.
All of these computations were done in a vertex shader. I used the noise function I created by passing in the vertex positions with an offset of time for each dimension. I then displaced each vertex by the generated noise value along the normal. I did the colors by passing the noise value to the fragment shader, and the noise value determined where the UVs were in a gradient texture.

You can use the sliders to change the number of octaves used in the multi-octave noise function. You will see that it makes for a more noisey result if you slide it to the right, and a smoother result for the slider to the left. You can also use the sliders to change the magnitude of the noise to increase the displacement created by the noise.

![alt tag](https://raw.githubusercontent.com/emily-vo/Project1-Noise/master/noise2.png)

# Technical Difficulties

One problem that I saw for a lot of people is that there were grid artifacts in the mesh. It wasn't smoothly interpolating between the voxels. One thing to be careful of is to make sure that the point arguments to the linear interpolation function is in the right order. If they are reversed, the interpolation will not perform correctly. 
