
const THREE = require('three'); // older modules are imported like this. You shouldn't have to worry about this much
import Framework from './framework'
import Noise from './noise'
import {other} from './noise'

var start = Date.now();

// geometry

// setup sphere geometry
var sphere = new THREE.IcosahedronGeometry( 20, 4 )

var adamMaterial = new THREE.ShaderMaterial({
  uniforms: {
    time: { // float initialized to 0
    	type: "f",
    	value: 0.0
  	}
  },
  vertexShader: require('./shaders/adam-vert.glsl'),
  fragmentShader: require('./shaders/adam-frag.glsl'),
  wireframe: true
});

var adamCube = new THREE.Mesh(sphere, adamMaterial);

// called after the scene loads
function onLoad(framework) {
  var scene = framework.scene;
  var camera = framework.camera;
  var renderer = framework.renderer;
  var gui = framework.gui;
  var stats = framework.stats;


  // LOOK: the line below is synyatic sugar for the code above. Optional, but I sort of recommend it.
  var {scene, camera, renderer, gui, stats} = framework; 

  // set camera position
  camera.position.set(1, 1, 2);
  camera.lookAt(new THREE.Vector3(0,0,0));

  scene.add(adamCube);

  // edit params and listen to changes like this
  // more information here: https://workshop.chromeexperiments.com/examples/gui/#1--Basic-Usage
  gui.add(camera, 'fov', 0, 180).onChange(function(newVal) {
    camera.updateProjectionMatrix();
  });
}

// called on frame updates
function onUpdate(framework) {
  // console.log(`the time is ${new Date()}`);
  	var now = ((Date.now() - start) / 1000.0);
  	adamMaterial.uniforms[ 'time' ].value = 0.25 * now;
  }

// when the scene is done initializing, it will call onLoad, then on frame updates, call onUpdate
Framework.init(onLoad, onUpdate);

// console.log('hello world');

// console.log(Noise.generateNoise());

// Noise.whatever()

// console.log(other())