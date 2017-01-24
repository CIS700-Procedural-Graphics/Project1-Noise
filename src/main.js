const THREE = require('three');
import Framework from './framework'

var CameraShot = {
  INTRO : 0,
  MAIN : 1,
  CEILING : 2,
  OVERVIEW : 3
}

var State = {
  NONE : 0,
  INTRO : 1,
  DROP : 2,
  MAIN : 3
};

var SubState = {
  NONE : 0,
  D1 : 1,
  D2 : 2,
}

// A container of stuff to play around for the user
// TODO: build a material inspector
var UserInput = {
  timeScale : 3.5,
  displacement : .25,
  frequency : 1.5,
  ratio : .607,
  frequencyRatio: 1.25,
  bias : .62,

  enableSound : true,
  fullscreen : false,
  debugNoise : false
};

// No time to design something more scalable, 
// so all demo stuff is going to be packed here
var Engine = {
  camera : null,
  cameraTime : 0,
  time : 0.0,
  clock : null,
  materials : [],
  music : null,
  audioAnalyser : null,
  initialized : false,
  particles : null,
  particleMaterial: null,
  currentState : State.NONE,
  currentSubState : SubState.NONE,
  currentCameraShot : CameraShot.INTRO,

  mainSphere : null,
  perlinDisk : null,
}

function startMain(time)
{
  Engine.mainSphere.scale.set(1.25, 1.25, 1.25);
  Engine.mainSphere.visible = true;
  Engine.particles.visible = true;

  Engine.perlinDisk.visible = true;
  Engine.perlinDisk.position.set(0,-2,0);
  Engine.perlinDisk.scale.set(4, 4, 4);
  
  Engine.currentCameraShot = CameraShot.MAIN;
  Engine.cameraTime = 0;
}

function updateMain(time)
{
  if( Engine.cameraTime > 11.0)
  {
    Engine.cameraTime = 0;

    if(Engine.currentCameraShot == CameraShot.MAIN)
      Engine.currentCameraShot = CameraShot.CEILING;
    else if(Engine.currentCameraShot == CameraShot.CEILING)
      Engine.currentCameraShot = CameraShot.OVERVIEW;
    else
      Engine.currentCameraShot = CameraShot.MAIN;
  }
}

function startDrop(time)
{
  Engine.mainSphere.visible = false;
  Engine.perlinDisk.visible = true;
  Engine.perlinDisk.rotateX(3.1415 * -.5);
}

function updateDrop(time)
{
  var d1 = 2.5;

  if(Engine.currentSubState == SubState.NONE)
  {
    var diskScale = Math.pow(time * 30.0, .15) * 30.0;
    Engine.perlinDisk.scale.set(diskScale, diskScale, diskScale);

    if(time > d1)
    {
      Engine.mainSphere.true = false;
      Engine.perlinDisk.visible = false;
      Engine.currentSubState = SubState.D1;
      console.log("D1");
    }
  }
  else if(Engine.currentSubState == SubState.D1)
  {
    var v = Math.sin(time * 32.0) > 0 ? true : false;
    var t = THREE.Math.clamp((time - d1) * .45, 0, 1.0);
    var sphereScale = Math.sqrt(1.0 - t * t) * 2.5 + .0001;
    
    Engine.mainSphere.scale.set(sphereScale, sphereScale, sphereScale);
    Engine.mainSphere.visible = v;
  }
}

function startIntro(time)
{
  Engine.mainSphere.visible = true;
}

function updateIntro(time)
{
  var sphereScale = THREE.Math.smoothstep(THREE.Math.clamp(time / 5.15, 0, 1.0), 0, 1) * 1.5;
  Engine.mainSphere.scale.set(sphereScale, sphereScale, sphereScale);

  if(Engine.currentSubState == SubState.NONE)
  {
    if(time > 23)
    {
      Engine.currentSubState = SubState.D1;
      console.log("D1");
    }
  }
  else if(Engine.currentSubState == SubState.D1)
  {
    if(time > 44)
    {
      Engine.currentSubState = SubState.D2;
      console.log("D2");
    }
  }
}

function onLoad(framework) 
{
  Engine.clock = new THREE.Clock();

  var scene = framework.scene;
  var camera = framework.camera;
  var renderer = framework.renderer;
  var gui = framework.gui;
  var stats = framework.stats;

  camera.position.set(0, 0, 6);
  camera.lookAt(new THREE.Vector3(0,0,0));

  Engine.camera = camera;

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

    // Initialize the Engine ONLY when the sound is loaded
    Engine.initialized = true;
  });

  Engine.audioAnalyser = new THREE.AudioAnalyser( sound, 64 );

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

  var sphereParticleMaterial = new THREE.ShaderMaterial({
    uniforms: {
      time: { type: "f", value : 0.0 },
      sphereLit: { type: "t", value: THREE.ImageUtils.loadTexture("./src/misc/CrystalMap.png")},
      frequencyBands: { type: "uIntArray", value: [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32] }
    },
    vertexShader: require("./shaders/sphere_particle.vert.glsl"),
    fragmentShader: require("./shaders/sphere_particle.frag.glsl"),
  })


  var perlinRingMaterial = new THREE.ShaderMaterial({
    uniforms: {
      time: { type: "f", value : 0.0 },
      sphereLit: { type: "t", value: THREE.ImageUtils.loadTexture("./src/misc/CrystalMap.png")}
    },
    vertexShader: require("./shaders/perlin_ring.vert.glsl"),
    fragmentShader: require("./shaders/perlin_ring.frag.glsl"),
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
  Engine.materials.push(particleMaterial);
  Engine.materials.push(sphereParticleMaterial);
  Engine.materials.push(perlinRingMaterial);  

  var sphereGeo = new THREE.IcosahedronBufferGeometry(1, 6);
  var particle = new THREE.TetrahedronBufferGeometry(.01, 1);

  var cloudMesh = new THREE.Mesh(sphereGeo, cloudMaterial);

  cloudMesh.visible = false;
  scene.add(cloudMesh);
  Engine.mainSphere = cloudMesh;


  var loader = new THREE.OBJLoader( );
  loader.load( './src/misc/particles.obj', function ( object ) {
    object.traverse( function ( child ) {
      if ( child instanceof THREE.Mesh ) {
        child.material = particleMaterial;
        child.position.set(0, -2, 0);
        child.scale.set(.15, .15, .15);
        child.visible = false;
        Engine.particles = child;
      }
    } );    
      scene.add( object );
  } );

  loader.load( './src/misc/ring.obj', function ( object ) {
    object.traverse( function ( child ) {
      if ( child instanceof THREE.Mesh ) {
        child.material = perlinRingMaterial;
        child.scale.set(6,6,6);
        Engine.perlinDisk = child;
        child.lookAt(camera.position);
        child.rotateX(3.1415*.5);
        // child.visible = false;
      }
    } );    
    scene.add( object );
  } );

  loader.load( './src/misc/sphere_particles.obj', function ( object ) {
    object.traverse( function ( child ) {
      if ( child instanceof THREE.Mesh ) {
        child.material = sphereParticleMaterial;
        child.scale.set(2.15, 2.15, 2.15);
        Engine.particles = child;
        child.visible = false;
      }
    } );    
      scene.add( object );
  } );


  var planeGeo = new THREE.PlaneGeometry( 1, 1, 1, 1);
  var planeMesh = new THREE.Mesh( planeGeo, debugMaterial);
  scene.add(planeMesh);

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

  // noiseParameters.open();

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
}

function updateCamera()
{
    if(Engine.currentCameraShot == CameraShot.INTRO)
    {      
      Engine.camera.position.set(0, 0, 6);
      Engine.camera.lookAt(new THREE.Vector3(0,0,0));
    }
    else if(Engine.currentCameraShot == CameraShot.MAIN)
    {
      Engine.camera.position.set(0, 0, 6);
      Engine.camera.lookAt(new THREE.Vector3(0,0,0));
      Engine.camera.rotateZ(-.4);
      Engine.camera.position.set(0, 1, 6);
    }
    else if(Engine.currentCameraShot == CameraShot.CEILING)
    {
      Engine.camera.position.set(.5, 5, .5);
      Engine.camera.lookAt(new THREE.Vector3(0,0,0));
    } 
    else if(Engine.currentCameraShot == CameraShot.OVERVIEW)
    {
      var p = new THREE.Vector3( Math.cos(Engine.time), 0.0, Math.sin(Engine.time) );
      Engine.camera.position.set(p.x * 5.0, 2, p.z * 5.0);
      Engine.camera.lookAt(new THREE.Vector3(0,0,0));
    }
}

function onUpdate(framework) 
{
  if(Engine.initialized)
  {
    var deltaTime = Engine.clock.getDelta();
    Engine.time += deltaTime;
    Engine.cameraTime += deltaTime;

    // CHOREOGRAPHY
    // INTRO STARTS AT: 0:03
    //  D1: 0:26 // 23
    //  D2: 0:46 // 43
    // DROP STARTS AT: 1:08
    //  D1: 1:10.5 // 2.5
    // MAIN STARTS AT: 1:14
    //  D1: 1:57
    if(Engine.currentState == State.NONE)
    {
      if(Engine.time > 3.0)
      {
        Engine.currentState = State.INTRO;
        Engine.currentSubState = SubState.NONE;
        startIntro();
      }
    }
    else if(Engine.currentState == State.INTRO)
    {
      var t = Engine.time - 3.0;
      updateIntro(t);

      if(Engine.time > 68.65)
      {
        Engine.currentState = State.DROP;
        Engine.currentSubState = SubState.NONE;
        startDrop(t);
      }
    }
    else if(Engine.currentState == State.DROP)
    {
      var t = Engine.time - 68.65;
      updateDrop(t);

      if(Engine.time > 74.25)
      {
        Engine.currentState = State.MAIN;
        Engine.currentSubState = SubState.NONE;
        startMain(t);
      }
    }
    else if(Engine.currentState == State.MAIN)
    {
      var t = Engine.time - 74.25;
      updateMain(t);
    }

    // After main logic
    updateCamera();


    var screenSize = new THREE.Vector2( framework.renderer.getSize().width, framework.renderer.getSize().height );

    var freq = Engine.audioAnalyser.getAverageFrequency();

    var dataArray = Engine.audioAnalyser.getFrequencyData();

    var freqBands = [];

    for(var i = 0; i < 64; i++)
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