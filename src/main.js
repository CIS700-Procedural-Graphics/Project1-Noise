
const THREE = require('three'); // older modules are imported like this. You shouldn't have to worry about this much
import Framework from './framework'
import Noise from './noise'
import {other} from './noise'

var clock;
var icosahedronMaterial;

var parameters = {
  speed: 1.0, //animation speed
  volume: 0.5 //music volume
};

var uniforms = { 
  frequency : {
    type: "f", 
    value: 0.0
  },  
  time : {
    type: "f", 
    value: 0.0
  },
  image: {
    type: "t", 
    value: THREE.ImageUtils.loadTexture('./purple.png')
  }
};

window.addEventListener("load", initPlayer, false);
var freqData;
var audio;

function initPlayer() {
  var ctx = new AudioContext();
  audio = document.getElementById('music');
  var audioSource = ctx.createMediaElementSource(audio);
  var analyser = ctx.createAnalyser();
  
  audioSource.connect(analyser);
  audioSource.connect(ctx.destination);
  
  //music frequency data to manipulate mesh vertices
  freqData = new Uint8Array(analyser.frequencyBinCount);
  analyser.getByteFrequencyData(freqData);
  
  for (var i = 0; i < analyser.frequencyBinCount; i++) {
    var value = freqData[i];
    //console.log(value);
  }
  
  function renderFrame() {
    requestAnimationFrame(renderFrame);
    analyser.getByteFrequencyData(freqData);
    //console.log(freqData);
  }
  audio.play();
  renderFrame();
}

// called after the scene loads
function onLoad(framework) {
  var scene = framework.scene;
  var camera = framework.camera;
  var renderer = framework.renderer;
  var gui = framework.gui;
  var stats = framework.stats;

  // LOOK: the line below is synyatic sugar for the code above. Optional, but I sort of recommend it.
  // var {scene, camera, renderer, gui, stats} = framework; 

  var darkMaterial = new THREE.MeshBasicMaterial( { color: 0xffffff } );
  var icosahedron = new THREE.IcosahedronGeometry( 0.2, 5 );

  icosahedronMaterial = new THREE.ShaderMaterial({
    uniforms: uniforms,
    vertexShader: require('./shaders/icosahedron-vert.glsl'),
    fragmentShader: require('./shaders/icosahedron-frag.glsl')
  });
  
  var meshIcosohedron = new THREE.Mesh(icosahedron, icosahedronMaterial);

  // set camera position
  camera.position.set(1, 1, 2);
  camera.lookAt(new THREE.Vector3(0,0,0));

  scene.add(meshIcosohedron);

  gui.add(camera, 'fov', 0, 180).onChange(function(newVal) {
    camera.updateProjectionMatrix();
  });
    
  gui.add(parameters, 'speed', 0, 4).onChange(function(newVal) {
    parameters.speed = newVal;
  });
  
  gui.add(parameters, 'volume', 0, 1).onChange(function(newVal) {
    audio.volume = newVal;
  });
}

var frame = 0; //Used for time

// called on frame updates
function onUpdate(framework) {
  //using the first frequency value to offset all vertices for now
  uniforms.frequency.value = freqData[0];
  uniforms.time.value = frame;
  frame += 0.1 * parameters.speed;
}

// when the scene is done initializing, it will call onLoad, then on frame updates, call onUpdate
Framework.init(onLoad, onUpdate);