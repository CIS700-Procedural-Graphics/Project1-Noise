
const THREE = require('three'); // older modules are imported like this. You shouldn't have to worry about this much
import Framework from './framework'
import MainStuff from './mainStuff.js'

//variable keeping track of time
var tim = 0.0;

//initialize the material for my noise which corresponds to the cloud vertex and fragment shaders
var cloudMaterial = new THREE.ShaderMaterial({
    uniforms: {
      time: { 
        value: tim
      },
      bright: {
        value: MainStuff.brightness //will control how bright the colors of the cloud are
      },
      perst: {
        value: MainStuff.persistence //will control persistence, which will control amplitude
      }
    },
    vertexShader: require('./shaders/cloud-vert.glsl'),
    fragmentShader: require('./shaders/cloud-frag.glsl')
  });

// called after the scene loads
function onLoad(framework) {
  var scene = framework.scene;
  var camera = framework.camera;
  var renderer = framework.renderer;
  var gui = framework.gui;
  var stats = framework.stats;

  // initialize an icosahedron
  var cloud = new THREE.IcosahedronBufferGeometry(1, 6);

  //initialize the mesh with icosahedron shape and the material initialized earlier
  var noiseCloud = new THREE.Mesh(cloud, cloudMaterial);

  // set camera position
  camera.position.set(1, 1, 2);
  camera.lookAt(new THREE.Vector3(0,0,0));

  scene.add(noiseCloud);

  // edit params and listen to changes like this
  // more information here: https://workshop.chromeexperiments.com/examples/gui/#1--Basic-Usage
  gui.add(camera, 'fov', 0, 180).onChange(function(newVal) {
    camera.updateProjectionMatrix();
  });

  //makes a slider for brightness of the colors, which is changed in the fragment shader
  gui.add(MainStuff, 'brightness', 0, 1.5).onChange(function(newVal) {
    MainStuff.updateBrightness(newVal);
    cloudMaterial.uniforms["bright"].value = MainStuff.brightness;
  });

  //makes a slider for persistence, which is changed in the vertex shader
  gui.add(MainStuff, 'persistence', 0, 1).onChange(function(newVal) {
    MainStuff.updatePers(newVal);
    cloudMaterial.uniforms["perst"].value = MainStuff.persistence;
  });
}

// called on frame updates
function onUpdate(framework) {
  tim++;
  cloudMaterial.uniforms["time"].value = tim;
  //console.log(`the time is ${new Date()}`);
}

// when the scene is done initializing, it will call onLoad, then on frame updates, call onUpdate
Framework.init(onLoad, onUpdate);