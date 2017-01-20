
const THREE = require('three'); // older modules are imported like this. You shouldn't have to worry about this much
import Framework from './framework'
import Noise from './noise'
import {other} from './noise'



var oldt=0.0;
var newt=0.0;
var time=0.0;
var icoshMaterial = new THREE.ShaderMaterial({
    uniforms: {
      image: { // Check the Three.JS documentation for the different allowed types and values
        type: "t", 
        value: THREE.ImageUtils.loadTexture('./adam.jpg') 
      },
	  time: {value : 0.0},
	  data: {
		  type : 'iv1',
		  value : new Array}
    },
    vertexShader: require('./shaders/icosh-vert.glsl'),
    fragmentShader: require('./shaders/icosh-frag.glsl')
  });

// called after the scene loads
function onLoad(framework) {
  var scene = framework.scene;
  var camera = framework.camera;
  var renderer = framework.renderer;
  var gui = framework.gui;
  var stats = framework.stats;
  var data= framework.data;
  
  // LOOK: the line below is synyatic sugar for the code above. Optional, but I sort of recommend it.
   var {scene, camera, renderer, gui, stats, data} = framework; 

  // initialize an icosahedron and material
	var icosh = new THREE.IcosahedronBufferGeometry(1, 5);
    
  var icosh = new THREE.Mesh(icosh, icoshMaterial);
  
  // set camera position
  camera.position.set(1, 1, 2);
  camera.lookAt(new THREE.Vector3(0,0,0));

  scene.add(icosh);

  // edit params and listen to changes like this
  // more information here: https://workshop.chromeexperiments.com/examples/gui/#1--Basic-Usage
  gui.add(camera, 'fov', 0, 180).onChange(function(newVal) {
    camera.updateProjectionMatrix();
  });
}

// called on frame updates
function onUpdate(framework) {
   //console.log(`the time is ${new Date()}`);
   oldt=newt;
   newt=performance.now();
   time+=(newt-oldt);
   icoshMaterial.uniforms.data.value=Int32Array.from(framework.data);
   icoshMaterial.uniforms.time.value=time/2000;//Math.sin((time%360)*3.14159265/180.0/100.0);
}

// when the scene is done initializing, it will call onLoad, then on frame updates, call onUpdate
Framework.init(onLoad, onUpdate);

// console.log('hello world');

// console.log(Noise.generateNoise());

// Noise.whatever()

// console.log(other())