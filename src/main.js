
const THREE = require('three'); // older modules are imported like this. You shouldn't have to worry about this much
import Framework from './framework'
import Noise from './noise'
import {other} from './noise'

var time = 0.0;
var params = {
  speed: 1.0,
  frequency: 1.0
};
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
  sphereMaterial = new THREE.ShaderMaterial({
    uniforms: {
      image: {
        type: "t", 
        value: THREE.ImageUtils.loadTexture('./explosion.png')
      },
      uTime: {value: time},
      uSpeed: {value: params.speed},
      uFreq: {value: params.frequency}
    },
    vertexShader: require('./shaders/sphere-vert.glsl'),
    fragmentShader: require('./shaders/sphere-frag.glsl')
  });

  var sphere = new THREE.IcosahedronBufferGeometry(1, 5);
  var mySphere =new THREE.Mesh(sphere, sphereMaterial);

  // set camera position
  camera.position.set(1, 5, 2);
  camera.lookAt(new THREE.Vector3(0,0,0));

  //scene.add(adamCube);
  scene.add(mySphere);

  // edit params and listen to changes like this
  // more information here: https://workshop.chromeexperiments.com/examples/gui/#1--Basic-Usage
  gui.add(camera, 'fov', 0, 180).onChange(function(newVal) {
    camera.updateProjectionMatrix();
  });

  gui.add(params, 'speed', 0, 3 ).onChange(function(newVal) {
  });


  gui.add(params, 'frequency', 0.1, 5 ).onChange(function(newVal) {
  });

}


// called on frame updates
function onUpdate(framework) {
  time += 0.025;
  if (sphereMaterial){
      sphereMaterial.uniforms.uTime.value = time;
      sphereMaterial.uniforms.uSpeed.value = params.speed;
      sphereMaterial.uniforms.uFreq.value = params.frequency;

  }

}

// when the scene is done initializing, it will call onLoad, then on frame updates, call onUpdate
Framework.init(onLoad, onUpdate);

// console.log('hello world');

// console.log(Noise.generateNoise());

// Noise.whatever()

// console.log(other())