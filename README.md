# [Project 1: Noise](https://github.com/CIS700-Procedural-Graphics/Project1-Noise)

## Objective

Get comfortable with using three.js and its shader support and generate an interesting 3D, continuous surface using a multi-octave noise algorithm.

## Getting Started

1. Install [Node.js](https://nodejs.org/en/download/). [three.js](https://threejs.org/), [dat.GUI](https://workshop.chromeexperiments.com/examples/gui/#1--Basic-Usage), and [glMatrix](http://glmatrix.net/). 

2. Fork and clone [this repository](https://github.com/CIS700-Procedural-Graphics/Project1-Noise).

3. In the root directory of your project, run `npm install`. This will download all of those dependencies.

4. Do either of the following (but I highly recommend the first one for reasons I will explain later).

    a. Run `npm start` and then go to `localhost:7000` in your web browser

    b. Run `npm run build` and then go open `index.html` in your web browser

    You should hopefully see the framework code with a 3D cube at the center of the screen!

4. Publish your project to gh-pages. `npm run deploy`. It should now be visible at http://username.github.io/repo-name

## Features Implemented
Demo: https://iambrian.github.io/Project1-Noise/

![Fireball](http://i.imgur.com/9CknAiT.png)

![Earth](http://i.imgur.com/jygVhZZ.png)

1.  Multioctave Noise (3D and 4D) -- demo uses 3D
2.  Background Music
3.  Skybox
4.  Camera Shake -- used a threshold on fft data
5.  Adjustable Parameters: time, timeStep, frequency, persistence, displacement, spin, music

## Resources
Gradient: http://www.colorzilla.com/gradient-editor/

Skybox images: Spacescape (http://alexcpeterson.com/spacescape/)

Music: OVERWERK Canon (http://www.overwerk.com)
