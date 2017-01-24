
const THREE = require('three'); // older modules are imported like this. You shouldn't have to worry about this much
import Framework from './framework'
import Noise from './noise'
import {other} from './noise'

// uniform variables for noisy shader
var noisyUniforms = {
    time: { 
          type: "float", 
          value: 0
        },
    octaves: {
          type: "int",
          value: 1
    },
    magnitude: {
          type: "float",
          value: 1.0
    },
    image: { // Check the Three.JS documentation for the different allowed types and values
          type: "t", 
          value: THREE.ImageUtils.loadTexture('./gradient.jpg')
    }
  };

// gui variables
var shaderVariables = function() {
   this.octaves = 1;
   this.magnitude = 1;
}

var noisyMaterial = new THREE.ShaderMaterial({
      uniforms: noisyUniforms,
      vertexShader: require('./shaders/noisy-vert.glsl'),
      fragmentShader: require('./shaders/noisy-frag.glsl')
  });

var clock = new THREE.Clock();

// called after the scene loads
function onLoad(framework) {
  var scene = framework.scene;
  var camera = framework.camera;
  var renderer = framework.renderer;
  var gui = framework.gui;
  var stats = framework.stats;
 
  // LOOK: the line below is synyatic sugar for the code above. Optional, but I sort of recommend it.
  // var {scene, camera, renderer, gui, stats} = framework; 
  var icosahedron = new THREE.IcosahedronBufferGeometry(1, 6);
  var noisyMesh = new THREE.Mesh(icosahedron, noisyMaterial);

  // set camera position
  camera.position.set(1, 1, 2);
  camera.lookAt(new THREE.Vector3(0,0,0));
  
  scene.add(noisyMesh);

  var shadV = new shaderVariables();

  // edit params and listen to changes like this
  // more information here: https://workshop.chromeexperiments.com/examples/gui/#1--Basic-Usage
  gui.add(camera, 'fov', 0, 180).onChange(function(newVal) {
    camera.updateProjectionMatrix();
  });

  gui.add(shadV, 'octaves', 1, 16).onChange(function(newVal) {
    noisyUniforms.octaves.value = newVal;
  });
  gui.add(shadV, 'magnitude', 1.0, 20.0).onChange(function(newVal) {
    noisyUniforms.magnitude.value = newVal;
  });
}

// called on frame updates
function onUpdate(framework) {
  var delta = clock.getDelta();
  noisyUniforms.time.value += delta;
  //console.log(uniforms.time.value);
}

// when the scene is done initializing, it will call onLoad, then on frame updates, call onUpdate
Framework.init(onLoad, onUpdate);