
const THREE = require('three'); // older modules are imported like this. You shouldn't have to worry about this much
import Framework from './framework'
import Noise from './noise'
import {other} from './noise'

var time = 0.0;
var sphereMaterial;

// called after the scene loads
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

  sphereMaterial = new THREE.ShaderMaterial({
    uniforms: {
      image: {
        type: "t", 
        value: THREE.ImageUtils.loadTexture('./explosion.png')
      },
      uTime: {value: time}
    },
    vertexShader: require('./shaders/sphere-vert.glsl'),
    fragmentShader: require('./shaders/sphere-frag.glsl')
  });

  var sphere = new THREE.IcosahedronBufferGeometry(1, 5);
  var mySphere =new THREE.Mesh(sphere, sphereMaterial);

  // set camera position
  camera.position.set(1, 1, 2);
  camera.lookAt(new THREE.Vector3(0,0,0));

  //scene.add(adamCube);
  scene.add(mySphere);

  // edit params and listen to changes like this
  // more information here: https://workshop.chromeexperiments.com/examples/gui/#1--Basic-Usage
  gui.add(camera, 'fov', 0, 180).onChange(function(newVal) {
    camera.updateProjectionMatrix();
  });
}


// called on frame updates
function onUpdate(framework) {
  time += 0.025;
  if (sphereMaterial){
      sphereMaterial.uniforms.uTime.value = time;
  }

}

// when the scene is done initializing, it will call onLoad, then on frame updates, call onUpdate
Framework.init(onLoad, onUpdate);

// console.log('hello world');

// console.log(Noise.generateNoise());

// Noise.whatever()

// console.log(other())