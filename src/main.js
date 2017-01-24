const THREE = require('three');
import Framework from './framework'

// A container of stuff to play around for the user
// TODO: build a material inspector
var UserInput = {
  timeScale : 3.5,
  displacement : .4,
  frequency : .75,
  ratio : .607,
  frequencyRatio: 1.25,
  bias : .82,

  enableSound : false,
  fullscreen : false,
  debugNoise : false
};

// No time to design something more scalable, 
// so all demo stuff is going to be packed here
var Engine = {
  materials : [],
  music : null,
  audioAnalyser : null,
  initialized : false,
  particles : null,
  particleMaterial: null,
}

function onLoad(framework) 
{
  var scene = framework.scene;
  var camera = framework.camera;
  var renderer = framework.renderer;
  var gui = framework.gui;
  var stats = framework.stats;

  camera.position.set(1, 1, 6);
  camera.lookAt(new THREE.Vector3(0,0,0));
  camera.rotateZ(-.4);
  camera.position.set(0, 1, 6);


  var listener = new THREE.AudioListener();
  camera.add(listener);
  var sound = new THREE.Audio(listener);
  var audioLoader = new THREE.AudioLoader();

  //Load a sound and set it as the Audio object's buffer
  audioLoader.load('./src/misc/music.mp3', function( buffer ) {
    sound.setBuffer( buffer );
    sound.setLoop(true);
    sound.setVolume(1.0);

    if(UserInput.enableSound)
      sound.play();
    // TODO: Start demo here
  });

  Engine.audioAnalyser = new THREE.AudioAnalyser( sound, 256 );

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
      SCREEN_SIZE: { type: "2fv", value : rendererSize },
      soundFrequency: { type: "f", value : 0.0 },
      sphereLit: { type: "t", value: THREE.ImageUtils.loadTexture("./src/misc/MetalMap.png")}
    },
    vertexShader: require("./shaders/cloud.vert.glsl"),
    fragmentShader: require("./shaders/cloud.frag.glsl"),
  })

  var particleMaterial = new THREE.ShaderMaterial({
    uniforms: {
      time: { type: "f", value : 0.0 },
      sphereLit: { type: "t", value: THREE.ImageUtils.loadTexture("./src/misc/CrystalMap.png")},
      frequencyBands: { type: "uIntArray", value: [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32] }
    },
    vertexShader: require("./shaders/particle.vert.glsl"),
    fragmentShader: require("./shaders/particle.frag.glsl"),
  })

  Engine.particleMaterial = particleMaterial;

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

  var sphereGeo = new THREE.IcosahedronBufferGeometry(1, 6);
  var particle = new THREE.TetrahedronBufferGeometry(.01, 1);

  var cloudMesh = new THREE.Mesh(sphereGeo, cloudMaterial);

  scene.add(cloudMesh);

  var planeGeo = new THREE.PlaneGeometry( 1, 1, 1, 1);
  var planeMesh = new THREE.Mesh( planeGeo, debugMaterial);

  var loader = new THREE.OBJLoader( );
  loader.load( './src/misc/particles.obj', function ( object ) {
    object.traverse( function ( child ) {
      if ( child instanceof THREE.Mesh ) {
        child.material = particleMaterial;
        child.position.set(0, -2, 0);
        child.scale.set(.15, .15, .15);
        Engine.particles = child;
      }
    } );    
      scene.add( object );
  } );

  scene.add(planeMesh)

  var noiseParameters = gui.addFolder('Noise');

  noiseParameters.add(UserInput, "timeScale", 0.0, 20.0).onChange(function(newVal) {
  });
  noiseParameters.add(UserInput, "displacement", 0.0, 4.0).onChange(function(newVal) {
  });
  noiseParameters.add(UserInput, "frequency", 0.0, 4.0).onChange(function(newVal) {
  });
  noiseParameters.add(UserInput, "ratio", 0.0, 1.0).onChange(function(newVal) {
  });

  // More than 3 is too much really
  noiseParameters.add(UserInput, "frequencyRatio", 0.0, 4.0).onChange(function(newVal) {
  });
  noiseParameters.add(UserInput, "bias", 0.0, 1.0).onChange(function(newVal) {
  });

  noiseParameters.open();

  var debug = gui.addFolder('Debug');

  debug.add(UserInput, "enableSound").onChange(function(newVal) {
    if(newVal)
      sound.play();
    else
      sound.stop();
  });

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

    var freq = Engine.audioAnalyser.getAverageFrequency();

    var dataArray = Engine.audioAnalyser.getFrequencyData();

    var freqBands = [];

    for(var i = 0; i < 32; i++)
      freqBands[i] = dataArray[i];

    Engine.particleMaterial.uniforms.frequencyBands.value = freqBands;

    if(Engine.particles != null)
    {
      Engine.particles.rotateY(.01);
    }

    for (var i = 0; i < Engine.materials.length; i++)
    {
      var material = Engine.materials[i];

      material.uniforms.time.value += .01 * UserInput.timeScale;

      for ( var property in material.uniforms ) 
      {
        if(UserInput[property] != null)
          material.uniforms[property].value = UserInput[property];
      }

      // 10: Mid freq
      // 12: details of intro
      // 13: No freq found

      if(material.uniforms["soundFrequency"] != null)
        material.uniforms.soundFrequency.value = dataArray[64] / 256;

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