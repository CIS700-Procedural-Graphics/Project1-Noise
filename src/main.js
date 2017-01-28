
const THREE = require('three'); // older modules are imported like this. You shouldn't have to worry about this much
import Framework from './framework'
import Noise from './noise'
import {other} from './noise'

var scene,
camera,
renderer,
gui,
stats;

// create start time
var start = Date.now();

var AmplitudeText = function() {
  this.amplitude = 10.0;
};
var amplitudeText = new AmplitudeText();

// Audio initialization
var context = new AudioContext(),
source = context.createBufferSource(),
analyser = context.createAnalyser();
analyser.smoothingTimeConstant = 0.3;
analyser.fftSize = 1024; //there are (fftSize/2) bins when getByteFrequencyData(array) is called
var xhr = new XMLHttpRequest();
xhr.responseType = 'arraybuffer';
xhr.open('GET', 'https://echiu1997.github.io/musicvisualizer/testing.mp3', true);
xhr.onload = function() {
  context.decodeAudioData(this.response, function(buffer) {
    source.connect(analyser);
    analyser.connect(context.destination);
    source.buffer = buffer;
    source.start(0);
  });
}
xhr.send();

// create the shader material      
var material = new THREE.ShaderMaterial( {
    uniforms: THREE.UniformsUtils.merge([ 
        THREE.UniformsLib['lights'], {
            // float initialized to 0
            time: { type: "f", value: 0.0 },
            // float initialized to 0
            freq: { type: "f", value: 0.0 },
            //float initialized to 25
            amp: { type: "f", value: 10.0 }
        }
    ]),
    vertexShader: require('./shaders/adam-vert.glsl'),
    fragmentShader: require('./shaders/adam-frag.glsl'),
    lights: true
} );

// create a sphere and assign the material
var mesh = new THREE.Mesh( 
    new THREE.IcosahedronGeometry( 15, 5 ), 
    material 
);

//decides if your domain has permission to use the image and if you do have permission it sends certain headers back to the browser. 
//The browser, if it sees those headers will then let you use the image.
THREE.ImageUtils.crossOrigin = '';
//for more info: http://blog.mastermaps.com/2013/09/creating-webgl-earth-with-threejs.html
var sky = new THREE.Mesh(
  new THREE.SphereGeometry(90, 64, 64), 
  new THREE.MeshBasicMaterial({
    map: THREE.ImageUtils.loadTexture('https://echiu1997.github.io/musicvisualizer/mars7.png'), 
    side: THREE.BackSide
  })
);

// create light
var light = new THREE.PointLight(0xffffff, 1.0);
light.position.set(-10.0, 20.0, 30.0);

// called after the scene loads
function onLoad(framework) {
  scene = framework.scene;
  camera = framework.camera;
  renderer = framework.renderer;
  gui = framework.gui;
  stats = framework.stats;

  // LOOK: the line below is synyatic sugar for the code above. Optional, but I sort of recommend it.
  // var {scene, camera, renderer, gui, stats} = framework; 

  scene.add( mesh );
  scene.add( sky );
  scene.add( light );

  /*
  // initialize a simple box and material
  var adamMaterial = new THREE.ShaderMaterial({
    uniforms: {
      image: { // Check the Three.JS documentation for the different allowed types and values
        type: "t", 
        value: THREE.ImageUtils.loadTexture('./adam.jpg')
      }
    },
    vertexShader: require('./shaders/adam-vert.glsl'),
    fragmentShader: require('./shaders/adam-frag.glsl')
  });
  var box = new THREE.BoxGeometry(1, 1, 1);
  var adamCube = new THREE.Mesh(box, adamMaterial);
  */

  // set camera position
  camera.position.set(1, 1, 40);
  camera.lookAt(new THREE.Vector3(0,0,0));

  // edit params and listen to changes like this
  // more information here: https://workshop.chromeexperiments.com/examples/gui/#1--Basic-Usage
  gui.add(camera, 'fov', 0, 180).onChange(function(newVal) {
    camera.updateProjectionMatrix();
  });

  //add amplitude slider for user to adjust
  gui.add(amplitudeText, 'amplitude', 5.0, 40.0);
}

// called on frame updates
function onUpdate(framework) {

  //rotates the mesh and sky around
  mesh.rotation.y += 0.005;
  sky.rotation.y -= 0.005;

  //passing time into shader
  material.uniforms[ 'time' ].value = 0.00025 * ( Date.now() - start );

  //pass music data into shader
  var array =  new Uint8Array(analyser.frequencyBinCount);
  analyser.getByteFrequencyData(array);
  
  //Audio Analysis
  //the array contains frequency elements with values ranging from [0,255]
  //in total there are 512 bins because analyser.fftSize is 1024
  var sum = 0.0;
  for(var j = 0.0; j < analyser.frequencyBinCount; j++) {
    sum += array[j];
  }
  //average is normalized to [0, 1]
  var avg = sum / analyser.frequencyBinCount / 255.0;
  material.uniforms[ 'freq' ].value = avg;

  //pass the slider amplitude the user modified
  material.uniforms[ 'amp' ].value = amplitudeText.amplitude;
}

// when the scene is done initializing, it will call onLoad, then on frame updates, call onUpdate
Framework.init(onLoad, onUpdate);

// console.log('hello world');

// console.log(Noise.generateNoise());

// Noise.whatever()

// console.log(other())