
const THREE = require('three'); // older modules are imported like this. You shouldn't have to worry about this much
import Framework from './framework'

//Make this a global so can see it in onUpdate to
// get at uniforms.
//Must be a better way!?
//
var adamMaterial = new THREE.ShaderMaterial({
uniforms: {
  image: { // Check the Three.JS documentation for the different allowed types and values
	type: "t", 
	value: THREE.ImageUtils.loadTexture('./adam.jpg')
	},
  //Maybe better to do this by creating a second shader?
  uTimeMsec: { value: 0.0 },
  uN1TimeScale: { value: 15000.0 },
  uN1Scale: { value: 0.8 },
  uN1fundamental: { value: 2.71828 },
  uN1overtoneScale: { value: 2.71828 },
  uN1numComponents: { value: 3.0 },
  uN1persistence: { value: 2 },
  uN1symmetryX: {value: 1.0 },
  uN1symmetryY: {value: 0.0 },
  uN1symmetryZ: {value: 0.0 },

  uN2TimeScale: { value: 1500.0 },
  uN2Scale: { value: 1.0 },
  uN2fundamental: { value: 0.1 },
  uN2overtoneScale: { value: 2.71828 },
  uN2numComponents: { value: 4.0 },
  uN2persistence: { value: 1.5 },
  uN2symmetryX: {value: 0.0 },
  uN2symmetryY: {value: 1.0 },
  uN2symmetryZ: {value: 0.0 }

  },
vertexShader: require('./shaders/project1-vert.glsl'),
fragmentShader: require('./shaders/project1-frag.glsl')
});
  
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
  var sphere = new THREE.SphereGeometry(1, 120, 120);
  
  //var adamCube = new THREE.Mesh(box, adamMaterial);
  var adamCube = new THREE.Mesh(sphere, adamMaterial);
  
  // set camera position
  camera.position.set(0, 0, 3);
  camera.lookAt(new THREE.Vector3(0,0,0));

  scene.add(adamCube);

  // edit params and listen to changes like this
  // more information here: https://workshop.chromeexperiments.com/examples/gui/#1--Basic-Usage
  gui.add(camera, 'fov', 0, 180).onChange(function(newVal) {
    camera.updateProjectionMatrix();
  });
  //console.log(adamMaterial.uniforms.uTime.value);
  gui.add(adamMaterial.uniforms.uN1TimeScale, 'value', 0.01, 25000).name('N1 Time Scale');
  gui.add(adamMaterial.uniforms.uN1Scale, 'value', 0.01, 10).name('N1 Size Scale');
  gui.add(adamMaterial.uniforms.uN1fundamental, 'value', 0.01, 10).name('N1 fundamental');
  gui.add(adamMaterial.uniforms.uN1overtoneScale, 'value', 0.1, 10).name('N1 harmScale');
  gui.add(adamMaterial.uniforms.uN1numComponents, 'value', 1, 16).name('N1 components');
  gui.add(adamMaterial.uniforms.uN1persistence, 'value', 0.1, 4).name('N1 persistence');
  gui.add(adamMaterial.uniforms.uN1symmetryX, 'value', 0.0, 1.0).name('N1 symmetryX');
  gui.add(adamMaterial.uniforms.uN1symmetryY, 'value', 0.0, 1.0).name('N1 symmetryY');
  gui.add(adamMaterial.uniforms.uN1symmetryZ, 'value', 0.0, 1.0).name('N1 symmetryZ');

  gui.add(adamMaterial.uniforms.uN2TimeScale, 'value', 0.01, 25000).name('N2 Time Scale');
  gui.add(adamMaterial.uniforms.uN2Scale, 'value', 0, 10).name('N2 Size Scale');
  gui.add(adamMaterial.uniforms.uN2fundamental, 'value', 0.01, 10).name('N2 fundamental');
  gui.add(adamMaterial.uniforms.uN2overtoneScale, 'value', 0.1, 10).name('N2 harmScale');
  gui.add(adamMaterial.uniforms.uN2numComponents, 'value', 1, 16).name('N2 components');
  gui.add(adamMaterial.uniforms.uN2persistence, 'value', 0.1, 4).name('N2 persistence');
  gui.add(adamMaterial.uniforms.uN2symmetryX, 'value', 0.0, 1.0).name('N2 symmetryX');
  gui.add(adamMaterial.uniforms.uN2symmetryY, 'value', 0.0, 1.0).name('N2 symmetryY');
  gui.add(adamMaterial.uniforms.uN2symmetryZ, 'value', 0.0, 1.0).name('N2 symmetryZ');

  //start the time
  framework.startTime = Date.now();
}

// called on frame updates
function onUpdate(framework) {
  //console.log(`the time is ${new Date()}`);
  adamMaterial.uniforms.uTimeMsec.value = Date.now() - framework.startTime;
  //console.log(adamMaterial.uniforms.uTimeMsec.value);
}

// when the scene is done initializing, it will call onLoad, then on frame updates, call onUpdate
Framework.init(onLoad, onUpdate);