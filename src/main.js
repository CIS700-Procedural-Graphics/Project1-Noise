
const THREE = require('three');
import Framework from './framework'

var App = {}

function onLoad(framework) {
  var scene = framework.scene;
  var camera = framework.camera;
  var renderer = framework.renderer;
  var gui = framework.gui;
  var stats = framework.stats;

  var sphereGeo = new THREE.IcosahedronBufferGeometry(1, 4);

  var cloudMaterial = new THREE.ShaderMaterial({
    uniforms: {
      time: { type: "f", value : 0.0 }
    },
    vertexShader: require("./shaders/cloud.vert.glsl"),
    fragmentShader: require("./shaders/cloud.frag.glsl"),
  })

  var debugMaterial = new THREE.ShaderMaterial({
    uniforms: {
      time: { type: "f", value : 0.0 }
    },
    vertexShader: require("./shaders/debug.vert.glsl"),
    fragmentShader: require("./shaders/debug.frag.glsl"),
    defines : {
      FULLSCREEN: true
    }
  })

  App.cloudMaterial = cloudMaterial;
  App.debugMaterial = debugMaterial;

  var cloudMesh = new THREE.Mesh(sphereGeo, cloudMaterial);

  camera.position.set(1, 1, 2);
  camera.lookAt(new THREE.Vector3(0,0,0));

  // scene.add(cloudMesh);

  var planeGeo = new THREE.PlaneGeometry( 1, 1, 1, 1);
  var planeMesh = new THREE.Mesh( planeGeo, debugMaterial);

  scene.add(planeMesh)

  // edit params and listen to changes like this
  // more information here: https://workshop.chromeexperiments.com/examples/gui/#1--Basic-Usage
  gui.add(camera, 'fov', 0, 180).onChange(function(newVal) {
    camera.updateProjectionMatrix();
  });


  App.initialized = true;
}

// called on frame updates
function onUpdate(framework) {

  if(App.initialized)
  {
  // console.log(`the time is ${new Date()}`);
    App.cloudMaterial.uniforms.time.value += .01;
    App.debugMaterial.uniforms.time.value += .01;
  }
}

Framework.init(onLoad, onUpdate);