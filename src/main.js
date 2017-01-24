
const THREE = require('three'); // older modules are imported like this. You shouldn't have to worry about this much
import Framework from './framework'
import Noise from './noise'


var t = 0;
var planet = {
  mesh:       {},
  material:   {},
  uniforms:   {},
  parameters: {
    music: true,
    radius: 30.0,
    detail: 5.0,
    startTime: 0.0,
    time: -0.0,
    timeStep: 1.0,
    spin: true,
    persistence: 0.5,
    frequency: 2.0,
    displacement: 100.0
  }
};

var shake = 0.0;
var sound = {};
var analyser = {};
var timeState = 1;

function loadPlanet(framework) {
  var scene = framework.scene;

  planet.uniforms = {
    image: {
      type: "t",
      value: THREE.ImageUtils.loadTexture('./resources/fire3.png')
    },
    time: {
      type: "f",
      value: 0.0
    },
    radius: {
      type: "f",
      value: 40.0
    },
    persistence: {
      type: "f",
      value: planet.parameters.persistence
    },
    freqMultiplier: {
      type: "f",
      value: planet.parameters.frequency
    },
    displacement: {
      type: "f",
      value: planet.parameters.displacement
    }
  };
  planet.material = new THREE.ShaderMaterial({
    uniforms: planet.uniforms,
    vertexShader: require('./shaders/custom-vert.glsl'),
    fragmentShader: require('./shaders/custom-frag.glsl')
  });
  var geometry = new THREE.IcosahedronBufferGeometry(
    planet.parameters.radius,
    planet.parameters.detail
  );
  planet.mesh = new THREE.Mesh(geometry, planet.material);
  scene.add(planet.mesh);

  // start time
  planet.parameters.startTime = (new Date()).getTime();
}

function loadSkybox(framework) {
  var scene = framework.scene;

  // skybox: http://stackoverflow.com/questions/16310880/comparing-methods-of-creating-skybox-material-in-three-js
  var imagePrefix = "./resources/";
  var directions  = ["xpos", "xneg", "ypos", "yneg", "zpos", "zneg"];
  var imageSuffix = ".png";
  var skyGeometry = new THREE.CubeGeometry( 2000, 2000, 2000 );
  var materialArray = [];
  for (var i = 0; i < 6; i++)
      materialArray.push( new THREE.MeshBasicMaterial({
          map: THREE.ImageUtils.loadTexture(
                imagePrefix + directions[i] + imageSuffix
               ),
          side: THREE.BackSide
      }));
  var skyMaterial = new THREE.MeshFaceMaterial( materialArray );
  var skyBox = new THREE.Mesh( skyGeometry, skyMaterial );
  scene.add( skyBox );
}

function loadGUI(framework) {
  var gui = framework.gui;
  var camera = framework.camera;

  gui.add(camera, 'fov', 0, 180).onChange(function(newVal) {
    camera.updateProjectionMatrix();
  });

  gui.add(planet.parameters, 'radius', 10.0, 100.0).onChange(function(newVal) {
    planet.mesh.geometry = new THREE.IcosahedronBufferGeometry(
                              planet.parameters.radius, planet.parameters.detail
                            );
    planet.mesh.geometry.verticesNeedUpdate = true;
  });

  gui.add(planet.parameters, 'persistence', 0.0, 5.0).onChange(function(newVal) {
    planet.uniforms.persistence = {
      type: "f",
      value: planet.parameters.persistence
    };
  });

  gui.add(planet.parameters, 'frequency', 0.0, 5.0).onChange(function(newVal) {
    planet.uniforms.freqMultiplier = {
      type: "f",
      value: planet.parameters.frequency
    };
  });

  gui.add(planet.parameters, 'displacement', 0.0, 500.0).onChange(function(newVal) {
    planet.uniforms.displacement = {
      type: "f",
      value: planet.parameters.displacement
    };
  });

  gui.add(planet.parameters, 'time', 0.0, 800.0);

  gui.add(planet.parameters, 'timeStep', 0.0, 2.0);

  gui.add(planet.parameters, 'spin');

  gui.add(planet.parameters, 'music').onChange(function(newVal) {
    var oldVolume = sound.getVolume();
    sound.setVolume(0.5 - oldVolume);
  });
}

function loadCamera(framework) {
  var camera = framework.camera;

  // set camera position
  camera.position.set(300,300,90);
  camera.lookAt(new THREE.Vector3(0,0,0));
}

// called after the scene loads
function onLoad(framework) {
  var camera = framework.camera;

  loadCamera(framework);
  loadGUI(framework);
  loadSkybox(framework);
  loadPlanet(framework);

  var listener = new THREE.AudioListener();
  camera.add( listener );

  // create a global audio source
  sound = new THREE.Audio( listener );

  var audioLoader = new THREE.AudioLoader();

  //Load a sound and set it as the Audio object's buffer
  audioLoader.load( './resources/overwerk_canon.mp3', function( buffer ) {
  	sound.setBuffer( buffer );
  	sound.setLoop(true);
  	sound.setVolume(0.5);
  	sound.play();
  });

  //Create an AudioAnalyser, passing in the sound and desired fftSize
  analyser = new THREE.AudioAnalyser( sound, 32 );
}

function mean(arr) {
  var sum = arr.reduce((a, b) => a + b, 0);
  return sum / arr.length;
}

function median(arr) {
  return arr.slice().sort()[arr.length / 2]; // slice to not modify original array
}

// called on frame updates
function onUpdate(framework) {

  var camera = framework.camera;

  if (planet.parameters.spin) {
    camera.position.set(
      300 * Math.sin((new Date()).getTime() * 0.0005),
      0.0,
      300 * Math.cos((new Date()).getTime() * 0.0005)
    );
    camera.lookAt(new THREE.Vector3(0,0,0));
  }

  if (analyser.analyser) {
    analyser.fftSize = 32;
    var bufferLength = analyser.fftSize;
    var dataArray = new Uint8Array(bufferLength);
    analyser.analyser.getByteFrequencyData(dataArray);

    // console.log(dataArray);
    if (dataArray[12] > 120.0) {
      var amount = (dataArray[12] - 100.0) / 2.0;
      camera.lookAt(new THREE.Vector3(amount * Math.random(), amount * Math.random(), amount * Math.random()));
      // console.log("shake");
    }
  }

  // planet.parameters.time = (new Date()).getTime();
  var elapsedTime = (planet.parameters.startTime - (new Date()).getTime());
  if (planet.parameters.time >= 800.0 && timeState > 0) {
    timeState = -2;
  } else if (planet.parameters.time <= 0.0 && timeState < 0) {
    timeState = 1;
  }
  planet.parameters.time += planet.parameters.timeStep * timeState;

  planet.uniforms.time = {
    type: "f",
    value: planet.parameters.time + planet.parameters.timeStep
  };

  planet.parameters.startTime = (new Date()).getTime();
}

// when the scene is done initializing, it will call onLoad, then on frame updates, call onUpdate
Framework.init(onLoad, onUpdate);
