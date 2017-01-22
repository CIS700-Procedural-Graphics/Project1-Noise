const THREE = require('three');
import Framework from './framework'

// A container of stuff to play around for the user
// TODO: build a material inspector
var UserInput = {
  timeScale : 2.0,
  displacement : 1.4,
  frequency : .75,
  ratio : .607,
  frequencyRatio: 2.25,
  bias : .82,

  fullscreen : false,
  debugNoise : false
};

var Engine = {
  materials : []
}

function onLoad(framework) 
{
  var scene = framework.scene;
  var camera = framework.camera;
  var renderer = framework.renderer;
  var gui = framework.gui;
  var stats = framework.stats;

  var rendererSize = new THREE.Vector2( renderer.getSize().width, renderer.getSize().height );

  var cloudMaterial = new THREE.ShaderMaterial({
    uniforms: {
      time: { type: "f", value : 0.0 },
      displacement: { type: "f", value : 1.0 },
      bias: { type: "f", value : 0.0 },
      amplitude: { type: "f", value : 1.0 },
      frequency: { type: "f", value : 1.0 },
      ratio: { type: "f", value : 0.707 },
      frequencyRatio: { type: "f", value : 2.0 },
      SCREEN_SIZE: { type: "2fv", value : rendererSize }
    },
    vertexShader: require("./shaders/cloud.vert.glsl"),
    fragmentShader: require("./shaders/cloud.frag.glsl"),
  })

  var debugMaterial = new THREE.ShaderMaterial({
    uniforms: {
      time: { type: "f", value : 0.0 },
      bias: { type: "f", value : 0.0 },
      amplitude: { type: "f", value : 1.0 },
      frequency: { type: "f", value : 1.0 },
      ratio: { type: "f", value : 0.707 },
      frequencyRatio: { type: "f", value : 2.0 },
      SCREEN_SIZE: { type: "2fv", value : rendererSize }
    },
    vertexShader: require("./shaders/debug.vert.glsl"),
    fragmentShader: require("./shaders/debug.frag.glsl"),
    defines : {
      FULLSCREEN: false
    }
  })

  Engine.materials.push(cloudMaterial);
  Engine.materials.push(debugMaterial);

  var sphereGeo = new THREE.IcosahedronBufferGeometry(1, 7);

  var cloudMesh = new THREE.Mesh(sphereGeo, cloudMaterial);

  camera.position.set(1, 1, 4);
  camera.lookAt(new THREE.Vector3(0,0,0));

  scene.add(cloudMesh);

  var planeGeo = new THREE.PlaneGeometry( 1, 1, 1, 1);
  var planeMesh = new THREE.Mesh( planeGeo, debugMaterial);

  scene.add(planeMesh)

  var noiseParameters = gui.addFolder('Noise');

  noiseParameters.add(UserInput, "timeScale", 0.0, 20.0).onChange(function(newVal) {
  });
  noiseParameters.add(UserInput, "displacement", 0.0, 4.0).onChange(function(newVal) {
  });
  noiseParameters.add(UserInput, "frequency", 0.0, 10.0).onChange(function(newVal) {
  });
  noiseParameters.add(UserInput, "ratio", 0.0, 1.0).onChange(function(newVal) {
  });
  noiseParameters.add(UserInput, "frequencyRatio", 0.0, 10.0).onChange(function(newVal) {
  });
  noiseParameters.add(UserInput, "bias", 0.0, 1.0).onChange(function(newVal) {
  });

  noiseParameters.open();

  var debug = gui.addFolder('Debug');

  debug.add(UserInput, "fullscreen").onChange(function(newVal) {
  });

  debug.add(UserInput, "debugNoise").onChange(function(newVal) {
    planeMesh.visible = !planeMesh.visible;
  });

  planeMesh.visible = UserInput.debugNoise;

  Engine.initialized = true;
}

// called on frame updates
function onUpdate(framework) 
{
  if(Engine.initialized)
  {
    var screenSize = new THREE.Vector2( framework.renderer.getSize().width, framework.renderer.getSize().height );

    for (var i = 0; i < Engine.materials.length; i++)
    {
      var material = Engine.materials[i];

      material.uniforms.time.value += .01 * UserInput.timeScale;

      for ( var property in material.uniforms ) 
      {
        if(UserInput[property] != null)
          material.uniforms[property].value = UserInput[property];
      }

      if(material.uniforms["SCREEN_SIZE"] != null)
        material.uniforms.SCREEN_SIZE.value = screenSize;

      if(material.defines["FULLSCREEN"] != null)
      {
        if(material.defines.FULLSCREEN != UserInput.fullscreen)
        {
          material.defines.FULLSCREEN = UserInput.fullscreen;
          material.needsUpdate = true;
        }
      }
    }
  }
}

Framework.init(onLoad, onUpdate);