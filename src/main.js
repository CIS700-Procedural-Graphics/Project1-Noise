
const THREE = require('three'); // older modules are imported like this. You shouldn't have to worry about this much
import Framework from './framework'
import Noise from './noise'


var t = 0;
var planet = {
  mesh:       {},
  material:   {},
  uniforms:   {},
  parameters: {
    radius: 40.0,
    detail: 5.0,
    startTime: 0.0,
    time: 0.0,
    timeMultiplier: 0.01,
    spin: false
  }
};

var shake = 0.0;
var sound = {};
var analyser = {};

var last10 = [200, 200, 200, 200, 200, 200, 200, 200, 200, 200];

function loadPlanet(framework) {
  var scene = framework.scene;

  planet.uniforms = {
    image: {
      type: "t",
      value: THREE.ImageUtils.loadTexture('./resources/fire.png')
    },
    time: {
      type: "f",
      value: 0.0
    },
    radius: {
      type: "f",
      value: 40.0
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
  var skyGeometry = new THREE.CubeGeometry( 1000, 1000, 1000 );
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

  gui.add(planet.parameters, 'timeMultiplier', 0.0, 0.1);

  gui.add(planet.parameters, 'spin');
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
  analyser = new THREE.AudioAnalyser( sound, 2048 );
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
      300 * Math.sin(planet.parameters.time * 0.0005),
      0.0,
      300 * Math.cos(planet.parameters.time * 0.0005)
    );
    camera.lookAt(new THREE.Vector3(0,0,0));
  }

  if (analyser.analyser) {
    analyser.fftSize = 32;
    var bufferLength = analyser.fftSize;
    var dataArray = new Uint8Array(bufferLength);
    analyser.analyser.getByteTimeDomainData(dataArray);

    if (mean(dataArray.slice(0,4)) < 100.0 || shake > 1.5) {
      shake += 1.0;
      camera.lookAt(new THREE.Vector3(10.0 * Math.random(), 10.0 * Math.random(), 10.0 * Math.random()));
      console.log("shake");
    }
  }

  shake -= 0.2;
  shake = Math.max(shake, 0.0);

  planet.parameters.time = (new Date()).getTime();
  planet.uniforms.time = {
    type: "f",
    value: (planet.parameters.time - planet.parameters.startTime) * planet.parameters.timeMultiplier
  };
}

// when the scene is done initializing, it will call onLoad, then on frame updates, call onUpdate
Framework.init(onLoad, onUpdate);
