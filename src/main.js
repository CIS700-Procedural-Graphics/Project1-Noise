
const THREE = require('three'); // older modules are imported like this. You shouldn't have to worry about this much
import Framework from './framework'
import Noise from './noise'
import {other} from './noise'

// used to animate the icosahedron
var programStartTime;

var myMaterial = new THREE.ShaderMaterial({
  uniforms: {
      time: { // Check the Three.JS documentation for the different allowed types and values
        type: "f", 
        value: Date.now()
      },
      noiseStrength: {
        type: "f",
        value: 2.0
      }, 
      numOctaves: {
        type: "f",
        value: 3
      }
    },
    vertexShader: require('./shaders/my-vert.glsl'),
    fragmentShader: require('./shaders/my-frag.glsl')
  });

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
  var guiFields = {
    icosahedronDetail: 3, 
    noiseStrength: 2.0,
    numOctaves: 3
  }

  var icosahedronGeometry = new THREE.IcosahedronGeometry(1, guiFields.icosahedronDetail);

  var texturedIcosahedron = new THREE.Mesh(icosahedronGeometry, myMaterial);
  scene.add(texturedIcosahedron);
  
  // set camera position
  camera.position.set(1, 1, 5);
  camera.lookAt(new THREE.Vector3(0,0,0));

  // edit params and listen to changes like this
  // more information here: https://workshop.chromeexperiments.com/examples/gui/#1--Basic-Usage
  gui.add(camera, 'fov', 0, 180).onChange(function(newVal) {
    camera.updateProjectionMatrix();
  });

  gui.add(guiFields, 'icosahedronDetail', 0, 5).step(1).onFinishChange(function(newVal) {
    scene.remove(texturedIcosahedron);
    guiFields.icosahedronDetail = newVal;
    icosahedronGeometry = new THREE.IcosahedronGeometry(1, newVal);
    texturedIcosahedron = new THREE.Mesh(icosahedronGeometry, myMaterial);
    scene.add(texturedIcosahedron);
  });

  // changes persistence of noise
  gui.add(guiFields, 'noiseStrength', 1.0, 8.0).onFinishChange(function(newVal) {
    myMaterial.uniforms.noiseStrength.value = newVal;
    myMaterial.needsUpdate = true;
  });

  // determines number of octaves of noise
  gui.add(guiFields, 'numOctaves', 0, 5).step(1).onFinishChange(function(newVal) {
    myMaterial.uniforms.numOctaves.value = newVal;
    myMaterial.needsUpdate = true;
  });
}

// called on frame updates
function onUpdate(framework) {
  // animates icosahedron
  myMaterial.uniforms.time.value = Date.now() - programStartTime;
  myMaterial.needsUpdate = true;
}

// when the scene is done initializing, it will call onLoad, then on frame updates, call onUpdate
Framework.init(onLoad, onUpdate);
