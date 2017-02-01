
const THREE = require('three'); // older modules are imported like this. You shouldn't have to worry about this much
import Framework from './framework'
import Noise from './noise'
import {other} from './noise'

var global_time = 1.0;
var start_time = Date.now();

var noise_scale = function() {
    this.scale = 50.0;
};
var my_scale = new noise_scale();

var icosa = new THREE.IcosahedronBufferGeometry(1, 6);
var icosaMaterial = new THREE.ShaderMaterial({
  uniforms: {
      time: { value: global_time },
      noise_scale: { value: my_scale.scale },
      image: {
          type: "t",
          value: THREE.ImageUtils.loadTexture('./.jpg')
      }
      //resolution: { value: new THREE.Vector2() }
  },
  vertexShader: require('./shaders/icosahedron-vert.glsl'),
  fragmentShader: require('./shaders/icosahedron-frag.glsl')
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
  //var box = new THREE.BoxGeometry(1, 1, 1);

  var myIcosa = new THREE.Mesh(icosa, icosaMaterial);

  //var adamMaterial = new THREE.ShaderMaterial({
    //uniforms: {
      //image: { // Check the Three.JS documentation for the different allowed types and values
        //type: "t", 
        //value: THREE.ImageUtils.loadTexture('./adam.jpg')
      //}
    //},
    //vertexShader: require('./shaders/adam-vert.glsl'),
    //fragmentShader: require('./shaders/adam-frag.glsl')
  //});

  //var adamCube = new THREE.Mesh(box, adamMaterial);

  // set camera position
  camera.position.set(1, 1, 2);
  camera.lookAt(new THREE.Vector3(0,0,0));

  //scene.add(adamCube);
  scene.add(myIcosa);

  // edit params and listen to changes like this
  // more information here: https://workshop.chromeexperiments.com/examples/gui/#1--Basic-Usage
  gui.add(camera, 'fov', 0, 180).onChange(function(newVal) {
    camera.updateProjectionMatrix();
  });

  gui.add(my_scale, 'scale', 0, 100).onChange(function(newVal) {
    my_scale.scale = newVal;
  });

}

// called on frame updates
function onUpdate(framework) {
  global_time += 1;
  icosaMaterial.uniforms.time.value = 0.001 * (Date.now() - start_time);//global_time;
  icosaMaterial.uniforms.noise_scale.value = my_scale.scale;
}

// when the scene is done initializing, it will call onLoad, then on frame updates, call onUpdate
Framework.init(onLoad, onUpdate);

// console.log('hello world');

// console.log(Noise.generateNoise());

// Noise.whatever()

// console.log(other())
