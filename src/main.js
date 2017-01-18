
const THREE = require('three'); // older modules are imported like this. You shouldn't have to worry about this much
import Framework from './framework'
import Noise from './noise'
import {other} from './noise'

// called after the scene loads
var noiseMaterial;

function onLoad(framework) {
  var scene = framework.scene;
  var camera = framework.camera;
  var renderer = framework.renderer;
  var gui = framework.gui;
  var stats = framework.stats;

  // LOOK: the line below is synyatic sugar for the code above. Optional, but I sort of recommend it.
  // var {scene, camera, renderer, gui, stats} = framework; 

  // initialize a simple box and material
  var box = new THREE.BoxGeometry(1, 1, 1);

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
  var adamCube = new THREE.Mesh(box, adamMaterial);


  noiseMaterial = new THREE.ShaderMaterial({
    uniforms: {
      uTime: {
        type: "f",
        value: 0.0
      }
    },
    vertexShader: require('./shaders/noise-vert.glsl'),
    fragmentShader: require('./shaders/noise-frag.glsl')
  });
  var geometry = new THREE.IcosahedronGeometry( 1, 0 );
  var mesh = new THREE.Mesh( geometry, noiseMaterial );
  // var mesh = new THREE.Mesh( geometry, adamMaterial );



  // set camera position
  camera.position.set(1, 1, 2);
  camera.lookAt(new THREE.Vector3(0,0,0));

  // scene.add(adamCube);
  scene.add(mesh);

  // edit params and listen to changes like this
  // more information here: https://workshop.chromeexperiments.com/examples/gui/#1--Basic-Usage
  gui.add(camera, 'fov', 0, 180).onChange(function(newVal) {
    camera.updateProjectionMatrix();
  });
}

// called on frame updates
function onUpdate(framework) {
  // console.log(`the time is ${new Date()}`);
  if (noiseMaterial) {
    noiseMaterial.uniforms.uTime.value += 0.1;
  }
  
}

// when the scene is done initializing, it will call onLoad, then on frame updates, call onUpdate
Framework.init(onLoad, onUpdate);

// console.log('hello world');

// console.log(Noise.generateNoise());

// Noise.whatever()

// console.log(other())