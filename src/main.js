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
  timeScale : 1.0,
  displacement : .25,
  frequency : .65,
  ratio : .675,
  frequencyRatio: 1.25,
  bias : .7,

  enableSound : true,
  fullscreen : false,
  debugNoise : false
};

// No time to design something more scalable, 
// so all demo stuff is going to be packed here
var Engine = {
  initialized : false,
  camera : null,
  cameraTime : 0,
  time : 0.0,
  clock : null,
  
  music : null,
  audioAnalyser : null,
  
  currentState : State.NONE,
  currentSubState : SubState.NONE,
  currentCameraShot : CameraShot.INTRO,

  particles : null,
  mainSphere : null,
  perlinDisk : null,
  radialLines : null,
  overlay : null,
  background : null,

  materials : [],
  sphereMaterial : null,
  particleMaterial: null,
  radialLinesMaterial : null,
  overlayMaterial : null,
  backgroundMaterial : null,
}

function startMain(time)
{
  Engine.mainSphere.scale.set(1.25, 1.25, 1.25);
  Engine.mainSphere.visible = true;
  Engine.particles.visible = true;
  
  Engine.radialLines.visible = false; // Maybe enable it on some beats?

  Engine.perlinDisk.visible = true;
  Engine.perlinDisk.position.set(0,-2,0);
  Engine.perlinDisk.scale.set(4, 4, 4);
  
  Engine.currentCameraShot = CameraShot.MAIN;
  Engine.cameraTime = 0;

  Engine.overlayMaterial.uniforms.intensityMultiplier.value = .1;
  Engine.overlayMaterial.uniforms.size.value = .1;
  Engine.overlayMaterial.uniforms.fullscreenFlash.value = 0.0;

  UserInput.frequency = 1.0;
  UserInput.bias = .7;
  UserInput.frequencyRatio = 1.95;
  UserInput.ratio = .65;
  UserInput.displacement = .25;

  Engine.background.visible = true;
}

function updateMain(time)
{
  if( Engine.cameraTime > 10.65)
  {
    Engine.cameraTime = 0;

    if(Engine.currentCameraShot == CameraShot.MAIN)
      Engine.currentCameraShot = CameraShot.CEILING;
    else if(Engine.currentCameraShot == CameraShot.CEILING)
      Engine.currentCameraShot = CameraShot.OVERVIEW;
    else
      Engine.currentCameraShot = CameraShot.MAIN;
  }

  if(Engine.particles != null)
    Engine.particles.rotateY(.01);

    Engine.sphereMaterial.uniforms.excentricity.value = 0.001;
}

function startDrop(time)
{
  Engine.mainSphere.visible = false;
  Engine.perlinDisk.visible = true;
  Engine.radialLines.visible = false;
  Engine.perlinDisk.rotateX(3.1415 * -.5);
}

function updateDrop(time)
{
  var d1 = 2.95;

  Engine.overlayMaterial.uniforms.intensityMultiplier.value = THREE.Math.clamp(1.0 - time * 3.0, 0, 1.0) * .8;

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
  else if(Engine.currentSubState == SubState.D1 && time - d1)
  {
    var v = Math.sin(time * 64.0) > 0 ? true : false;
    var t = THREE.Math.clamp((time - d1) * .4, 0, 1.0);
    var sphereScale = Math.sqrt(1.0 - t * t * t) * 1.5 + .0001;
    
    Engine.mainSphere.scale.set(sphereScale, sphereScale, sphereScale);
    Engine.mainSphere.visible = v;
    Engine.radialLines.visible = v;
    Engine.radialLinesMaterial.uniforms.doubleSided.value = 0.0;

    Engine.sphereMaterial.uniforms.excentricity.value = 1.0;

    var flash = Math.cos(time * 64.0 + .05) > .75 ? t * t * t * t : 0.0;
    Engine.overlayMaterial.uniforms.fullscreenFlash.value = flash;

    UserInput.frequency = 1.1;
    UserInput.bias = .7;
    UserInput.frequencyRatio = 1.95;
    UserInput.ratio = .65;
    UserInput.displacement = .5;
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
    if(time > 21.8)
    {
      Engine.currentSubState = SubState.D1;
      console.log("D1");
    }
  }
  else if(Engine.currentSubState == SubState.D1)
  {
    if(time > 43.5)
    {
      Engine.currentSubState = SubState.D2;
      Engine.radialLines.visible = true;
    }
  }
  else
  {
    var t = time - 43.5;
    var v = Math.sin(t * .56) > 0 ? 0.0 : 1.0;
    Engine.radialLinesMaterial.uniforms.doubleSided.value = v;
    Engine.sphereMaterial.uniforms.excentricity.value = .25;
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
      overallFrequency: { type: "f", value : 0.0 },
      displacement: { type: "f", value : 1.0 },
      excentricity: { type: "f", value : 1.0 },
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

  var radialLinesMaterial = new THREE.ShaderMaterial({
    uniforms: {
      time: { type: "f", value : 0.0 },
      doubleSided: { type: "f", value : 0.0 },
      sphereLit: { type: "t", value: THREE.ImageUtils.loadTexture("./src/misc/CrystalMap.png")}
    },
    vertexShader: require("./shaders/radial_lines.vert.glsl"),
    fragmentShader: require("./shaders/radial_lines.frag.glsl"),
  })

  Engine.sphereMaterial = cloudMaterial;
  Engine.particleMaterial = particleMaterial;
  Engine.radialLinesMaterial = radialLinesMaterial;

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

  var backgroundMaterial = new THREE.ShaderMaterial({
    uniforms: {
      time: { type: "f", value : 0.0 },
      SCREEN_SIZE: { type: "2fv", value : rendererSize },
      overallFrequency: { type: "f", value : 0.0 },
      fullscreenFlash: { type: "f", value : 0.0 },
      size: { type: "f", value : 1.0 },
      gradientTexture: { type: "t", value: THREE.ImageUtils.loadTexture("./src/misc/gradient_1.png")}
    },
    vertexShader: require("./shaders/background.vert.glsl"),
    fragmentShader: require("./shaders/background.frag.glsl")
  })

  backgroundMaterial.depthWrite = false;
  backgroundMaterial.depthTest = false;

  Engine.backgroundMaterial = backgroundMaterial;

  var overlayMaterial = new THREE.ShaderMaterial({
    uniforms: {
      time: { type: "f", value : 0.0 },
      SCREEN_SIZE: { type: "2fv", value : rendererSize },
      intensityMultiplier: { type: "f", value : .8 },
      overallFrequency: { type: "f", value : 0.0 },
      fullscreenFlash: { type: "f", value : 0.0 },
      size: { type: "f", value : 1.0 },
      gradientTexture: { type: "t", value: THREE.ImageUtils.loadTexture("./src/misc/gradient_1.png")}
    },
    vertexShader: require("./shaders/overlay.vert.glsl"),
    fragmentShader: require("./shaders/overlay.frag.glsl")
  })

  overlayMaterial.blending = THREE.CustomBlending;
  overlayMaterial.blendEquation = THREE.AddEquation;
  overlayMaterial.blendSrc = THREE.OneFactor;
  overlayMaterial.blendDst = THREE.OneFactor;
  overlayMaterial.depthWrite = false;
  overlayMaterial.depthTest = false;
  overlayMaterial.transparent = true;

  Engine.materials.push(cloudMaterial);
  Engine.materials.push(debugMaterial);
  Engine.materials.push(particleMaterial);
  Engine.materials.push(sphereParticleMaterial);
  Engine.materials.push(perlinRingMaterial);
  Engine.materials.push(radialLinesMaterial);
  Engine.materials.push(overlayMaterial);
  Engine.materials.push(backgroundMaterial);

  var sphereGeo = new THREE.IcosahedronBufferGeometry(1, 7);
  var particle = new THREE.TetrahedronBufferGeometry(.01, 1);

  var cloudMesh = new THREE.Mesh(sphereGeo, cloudMaterial);

  cloudMesh.scale.set(0,0,0);
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

  loader.load( './src/misc/radial_lines.obj', function ( object ) {
    object.traverse( function ( child ) {
      if ( child instanceof THREE.Mesh ) {
        child.material = radialLinesMaterial;
        child.scale.set(6,6,6);
        child.lookAt(camera.position);
        child.rotateX(3.1415*.5);
        child.position.set(0,0,-.01);
        Engine.radialLines = child;
        child.visible = false;
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

  var overlayMesh = new THREE.Mesh( planeGeo, overlayMaterial);
  overlayMesh.frustumCulled = false;
  overlayMesh.renderOrder = 1;
  scene.add(overlayMesh);
  
  Engine.overlay = overlayMesh;
  Engine.overlayMaterial = overlayMaterial;

  var backgroundMesh = new THREE.Mesh( planeGeo, backgroundMaterial);
  backgroundMesh.frustumCulled = false;
  backgroundMesh.renderOrder = -1;
  backgroundMesh.visible = false;
  scene.add(backgroundMesh);

  Engine.background = backgroundMesh;

  var noiseParameters = gui.addFolder('Noise');

  // noiseParameters.add(UserInput, "timeScale", 0.0, 20.0).onChange(function(newVal) {
  // });
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
      Engine.mainSphere.visible = false;

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
    var avgFrequency = Engine.audioAnalyser.getAverageFrequency() / 256.0;
    var dataArray = Engine.audioAnalyser.getFrequencyData();
    var freqBands = [];

    for(var i = 0; i < 64; i++)
      freqBands[i] = dataArray[i];

    Engine.particleMaterial.uniforms.frequencyBands.value = freqBands;

    for (var i = 0; i < Engine.materials.length; i++)
    {
      var material = Engine.materials[i];

      material.uniforms.time.value = Engine.time;

      for ( var property in material.uniforms ) 
      {
        if(UserInput[property] != null)
          material.uniforms[property].value = UserInput[property];
      }

      if(material.uniforms["overallFrequency"] != null)
        material.uniforms.overallFrequency.value = avgFrequency;

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