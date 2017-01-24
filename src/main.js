
const THREE = require('three'); // older modules are imported like this. You shouldn't have to worry about this much
import Framework from './framework'

// create new noise material 
    var noiseMaterial = new THREE.ShaderMaterial({
    uniforms: {
      time: { value: 0.0 },
      u_persistance: { value : 0.7 },
      u_color: {value : 0.0 }
    },
    vertexShader: require('./shaders/noise-vert.glsl'),
    fragmentShader: require('./shaders/noise-frag.glsl')
  });

// add to the GUI 
var persistObj = function() {
  this.message = 'persistance';
  this.persistance = 0.7; 
  this.colors = 0.0;
};

// Uniform time to be sent to shader
var totalTime = 0.0; 


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

  // set camera position
  camera.position.set(1, 1, 3);
  camera.lookAt(new THREE.Vector3(0,0,0));

  // commenting out the adamCube
  // scene.add(adamCube);

// Create an Isodecahedron, and assign it a new material
  var isodec = new THREE.IcosahedronBufferGeometry(1, 5);
  var isoShape = new THREE.Mesh(isodec, noiseMaterial);
  scene.add(isoShape);

  // edit params and listen to changes like this
  // more information here: https://workshop.chromeexperiments.com/examples/gui/#1--Basic-Usage
  gui.add(camera, 'fov', 0, 180).onChange(function(newVal) {
    camera.updateProjectionMatrix();
  });

  // Add functionality to change the persistance of noise function
  var perturb = new persistObj(); 
  gui.add(perturb, 'persistance', 0.0, 1.0).onChange(function(newVal) {
      noiseMaterial.uniforms.u_persistance.value = newVal;
    });
  gui.add(perturb, 'colors', 0.0, 1.0).onChange(function(newVal) {
      noiseMaterial.uniforms.u_color.value = newVal;
  }); 
}

// called on frame updates
function onUpdate(framework) {

  // send time to shader
  var date = new Date()
  totalTime += 1; 
  noiseMaterial.uniforms.time.value = totalTime;
}

// when the scene is done initializing, it will call onLoad, then on frame updates, call onUpdate
Framework.init(onLoad, onUpdate);