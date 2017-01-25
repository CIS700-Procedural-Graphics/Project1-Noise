
const THREE = require('three'); // older modules are imported like this. You shouldn't have to worry about this much
import Framework from './framework'




var parameters = {
    octaves: 2.0,
    persistence: 4.0
}

var noiseMaterial = new THREE.ShaderMaterial({
     uniforms: {
      // image: { // Check the Three.JS documentation for the different allows types and values
      //   type: "t",
      //   value: THREE.ImageUtils.loadTexture('./explosion.png')
      // },
      time: {
        type: "f",
        value: 1.0
      },
      octaves: {
        type: "f",
        value: 3.0
      },
      persistence: {
        type: "f",
        value: 4.0
      }
     },
    vertexShader: require('./shaders/ellen-vert.glsl'),
    fragmentShader: require('./shaders/ellen-frag.glsl')
  });

var startTime = new Date();
var currentTime = new Date();

// called after the scene loads
function onLoad(framework) {
  var scene = framework.scene;
  var camera = framework.camera;
  var renderer = framework.renderer;
  var gui = framework.gui;
  var stats = framework.stats;

  var icosahedron = new THREE.IcosahedronGeometry(1, 6);
  var noiseIcosahedron = new THREE.Mesh(icosahedron, noiseMaterial);

  // set camera position
  camera.position.set(1, 1, 200);
  camera.lookAt(new THREE.Vector3(0,0,0));

  // scene.add(adamCube);
  scene.add(noiseIcosahedron);


  // edit params and listen to changes like this
  // more information here: https://workshop.chromeexperiments.com/examples/gui/#1--Basic-Usage
  gui.add(camera, 'fov', 0, 180).onChange(function(newVal) {
    camera.updateProjectionMatrix();
  });

  gui.add(parameters, 'octaves', 0, 10).onChange(function(newVal) {
    noiseMaterial.uniforms['octaves'].value = newVal;
  });

  gui.add(parameters, 'persistence', 0, 10).onChange(function(newVal) {
    noiseMaterial.uniforms['persistence'].value = newVal;
  });
}

// called on frame updates
function onUpdate(framework) {
  // console.log(`the time is ${new Date()}`);
  currentTime = new Date();
  currentTime = currentTime - startTime;

  if (currentTime > 100000) {
    startTime = new Date();
  }

  noiseMaterial.uniforms['time'].value = currentTime / 2000;
}

// when the scene is done initializing, it will call onLoad, then on frame updates, call onUpdate
Framework.init(onLoad, onUpdate);


// WEBPACK FOOTER //
// ./src/main.js