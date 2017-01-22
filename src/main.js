const THREE = require('three');
import Framework from './framework'

// A container of stuff to play around for the user
var UserInput = { 
  amplitude : 1.0,
  frequency : 1.0,
  ratio : .707,
  frequencyRatio: 2.0,
  bias : .5,
  fullscreen : false
};

var Engine = {
  materials : []
}

function updateMaterials() 
{

}

function onLoad(framework) 
{
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
      time: { type: "f", value : 0.0 },
      bias: { type: "f", value : 0.0 }
    },
    vertexShader: require("./shaders/debug.vert.glsl"),
    fragmentShader: require("./shaders/debug.frag.glsl"),
    defines : {
      FULLSCREEN: false
    }
  })

  Engine.materials.push(cloudMaterial);
  Engine.materials.push(debugMaterial);

  var cloudMesh = new THREE.Mesh(sphereGeo, cloudMaterial);

  camera.position.set(1, 1, 2);
  camera.lookAt(new THREE.Vector3(0,0,0));

  // scene.add(cloudMesh);

  var planeGeo = new THREE.PlaneGeometry( 1, 1, 1, 1);
  var planeMesh = new THREE.Mesh( planeGeo, debugMaterial);

  scene.add(planeMesh)

  var noiseParameters = gui.addFolder('Noise');
  noiseParameters.add(UserInput, "amplitude", 0.0, 1.0).onChange(function(newVal) {
  });

  noiseParameters.add(UserInput, "frequency", 0.0, 10.0).onChange(function(newVal) {
  });

  noiseParameters.add(UserInput, "ratio", 0.0, 1.0).onChange(function(newVal) {
  });

  noiseParameters.add(UserInput, "frequencyRatio", 0.0, 100.0).onChange(function(newVal) {
  });

  noiseParameters.add(UserInput, "bias", 0.0, 1.0).onChange(function(newVal) {
  });


  var debug = gui.addFolder('Debug');

  debug.add(UserInput, "fullscreen").onChange(function(newVal) {
  });


  Engine.initialized = true;
}

// called on frame updates
function onUpdate(framework) 
{
  if(Engine.initialized)
  {
    for (var i = 0; i < Engine.materials.length; i++)
    {
      Engine.materials[i].uniforms.time.value += .01;


    }
  }
}

Framework.init(onLoad, onUpdate);