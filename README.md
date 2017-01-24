Hannah Bollar
CIS 700: Procedural Graphics Hw1


![alt text](https://github.com/hanbollar/Project1-Noise/blob/a03262b73d3c30cfa6915e465cd7e778c1cfe086/still1.png "Image 1")


Using WebGL and Javascript created spheres with procedurally rendered animation based on 
noise functions.

Outcome image 1 (that the project was looking for)
![alt text](https://github.com/hanbollar/Project1-Noise/blob/a03262b73d3c30cfa6915e465cd7e778c1cfe086/still1.png "Image 1")

Outcome image 2 (noise for shape splatterings of color)
![alt text](https://github.com/hanbollar/Project1-Noise/blob/a03262b73d3c30cfa6915e465cd7e778c1cfe086/still2.png "Image 2")

Outcome image 3 (symmetrical position based noise)
![alt text](https://github.com/hanbollar/Project1-Noise/blob/a03262b73d3c30cfa6915e465cd7e778c1cfe086/still3.png "Image 3")

I came up with one main noise animation that worked as expected; however, it broke when i was
testing different features. While I was fixing it I came across two additional configurations that
I found to be quite interesting. Picture 1 is the main view of my actual perlin noise generated
animation in which there is time-based and position-based noise that fluctuates not only around
each position but also across the sphere as a whole. Picture 2 is where I focused mainly on using
my noise to generate color attributes and landed on a hexagonal spattering configuration. Picture 3
illustrates a symmetrical noise configuration that I found less based on time as in the first creation
and instead more position based as the animation cycles through.

I ultimately ended up with about five different main perlin functions that I used as a combination
between one another to create the different outcomes. 

This will be updated later with more detailed walk throughs of the steps to how I built this project
along with gifs depicting the features.

Regarding the features of this work, along with the pre-implemented fov slider to allow the user to 
pan around the page, I implemented two additional sliders. One that was a homework feature that allows
the user to switch between the three different noise configurations depicted in the images above and the 
other (extra credit) loading up different materials into the shader in real time. The different materials
are depicted below (on different figures to further illustrate the effect of noise on the surfaces).


![alt text](https://github.com/hanbollar/Project1-Noise/blob/a03262b73d3c30cfa6915e465cd7e778c1cfe086/still4.png "Image 4")

![alt text](https://github.com/hanbollar/Project1-Noise/blob/a03262b73d3c30cfa6915e465cd7e778c1cfe086/still5.png "Image 5")

![alt text](https://github.com/hanbollar/Project1-Noise/blob/a03262b73d3c30cfa6915e465cd7e778c1cfe086/still6.png "Image 6"))
	