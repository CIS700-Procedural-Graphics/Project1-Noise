# Texture Generation for Final Project


### Milestone-2

Finally we have the server thanks to Austin!! We haven't merged our code, so it is not yet deployed. The texture does not become more defined as you go closer as I have hardcoded the number of octaves. I will be changing them based on the viewer distance to change the levels of detail.

![](images/shadercesium.gif)

- `shaders/sinenoise-frag.glsl` fragment shader is an accidental marble texture that I did not intend to make.

    I found articles on warping noise functions with other noise functions while looking up Voronoi diagrams. I thought I could use the Ridged noise with just sine functions to get cool streams and rivers. [cegaton](https://blender.stackexchange.com/questions/45892/is-it-possible-to-distort-a-voronoi-texture-like-the-wave-textures-distortion-sl) does it using voronoise.

    So I tried it, and It looks more like marble than rivers. I don't think it will work for this project.

    I am still understanding voronoise and how to integrate it to the texture I already have.

![](images/sinenoise.gif)

- Demo (of marble texture): https://rms13.github.io/Project1-Noise

### Milestone-1

`mountain-frag.glsl` fragment shader contains the shader that textures the mountain. Value Noise algorithm is used as the noise generator. It is a slightly modified version (the noise function and the matrices are different) of what IQ shows [here](http://www.iquilezles.org/www/articles/morenoise/morenoise.htm). The derivatives of noise are used to simulate erosion effects. It still needs some work.

`mountain-vert.glsl` vertex shader uses Ridged Value Noise to model mountains. This is *not* the terrain we will be using for the final version. It's used only for testing the texture. The terrain part (using Diamond Square algorithm) is being done by [Rudraksha](https://github.com/rudraksha20).


#### GUI Controls
- Colors (Red, Green, Blue), and (Red1, Green1, Blue1), can be used to set the colors of layers based on height, which is useful for visualizing the noise output.
- NoiseType demos 3 variations of value noise I experimented with. This can only be used with Preset1 off.
    1. Value Noise.
    2. Absolute Value Noise.
    3. Ridged Value Noise.  
- Increasing the Speed will animate the noise (and erosion effects with Preset1). Although increasing it too much will increase the frequency too much, which is not what the static texture looks like.
- Preset1 will show the mountain texture that I think looks good. The erosion effect needs some fine-tuning. Uses Value Noise no matter what is selected
- Terrain will toggle the geometry between Terrain and Sphere.

### [Demo](https://rms13.github.io/Project1-Noise/)

### [Final Project original repository](https://github.com/rms13/Final-Project)
