
const THREE = require('three'); // older modules are imported like this. You shouldn't have to worry about this much
import Framework from './framework'
import Noise from './noise'
import {other} from './noise'

var myMaterial = new THREE.ShaderMaterial({
  uniforms: {
    time: { // Check the Three.JS documentation for the different allowed types and values
      type: "f", 
      value: Date.now()
    }
  },
  vertexShader: require('./shaders/my-vert.glsl'),
  fragmentShader: require('./shaders/my-frag.glsl')
});

var programStartTime;

// called after the scene loads
function onLoad(framework) {
  programStartTime = Date.now();
  var scene = framework.scene;
  var camera = framework.camera;
  var renderer = framework.renderer;
  var gui = framework.gui;
  var stats = framework.stats;

  // LOOK: the line below is synyatic sugar for the code above. Optional, but I sort of recommend it.
  // var {scene, camera, renderer, gui, stats} = framework; 

  // initialize icosahedron object
  var icosahedron = {
    radius: 1,
    detail: 2
  }
  var icosahedronGeometry = new THREE.IcosahedronGeometry(icosahedron.radius, icosahedron.detail);

  var texturedIcosahedron = new THREE.Mesh(icosahedronGeometry, myMaterial);
  scene.add(texturedIcosahedron);
  
  // set camera position
  camera.position.set(1, 1, 2);
  camera.lookAt(new THREE.Vector3(0,0,0));
  
  // edit params and listen to changes like this
  // more information here: https://workshop.chromeexperiments.com/examples/gui/#1--Basic-Usage
  gui.add(camera, 'fov', 0, 180).onChange(function(newVal) {
    camera.updateProjectionMatrix();
  });

  gui.add(icosahedron, 'detail', 0, 5).step(1).onFinishChange(function(newVal) {
    scene.remove(texturedIcosahedron);
    icosahedronGeometry = new THREE.IcosahedronGeometry(1, newVal);
    texturedIcosahedron = new THREE.Mesh(icosahedronGeometry, myMaterial);
    scene.add(texturedIcosahedron);
  });
}

// called on frame updates
function onUpdate(framework) {
  myMaterial.uniforms.time.value = Date.now() - programStartTime;
  myMaterial.needsUpdate = true;
}

// when the scene is done initializing, it will call onLoad, then on frame updates, call onUpdate
Framework.init(onLoad, onUpdate);
