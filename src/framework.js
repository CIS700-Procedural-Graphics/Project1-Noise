
const THREE = require('three');
const OrbitControls = require('three-orbit-controls')(THREE)
import Stats from 'stats-js'
import DAT from 'dat-gui'

//////////////
// Sound:
var analyser;
var data;
window.onload = function() {
  var audcon = new AudioContext();
  var aud = document.getElementById('myAudio');
  var audsrc = audcon.createMediaElementSource(aud);
  analyser = audcon.createAnalyser();
  
  audsrc.connect(analyser);
  audsrc.connect(audcon.destination);
  data = new Uint8Array(analyser.frequencyBinCount);
/*   function audplay() {
     requestAnimationFrame(audplay);
     // update data in frequencyData
     analyser.getByteFrequencyData(data);
     // render frame based on values in frequencyData
     // console.log(data);
  } */
  // aud.start();
   aud.play();
};
//////////////

// when the scene is done initializing, the function passed as `callback` will be executed
// then, every frame, the function passed as `update` will be executed
function init(callback, update) {
  var stats = new Stats();
  stats.setMode(1);
  stats.domElement.style.position = 'absolute';
  stats.domElement.style.left = '0px';
  stats.domElement.style.top = '0px';
  document.body.appendChild(stats.domElement);

  var gui = new DAT.GUI();

  var framework = {
    gui: gui,
    stats: stats
  };

  // run this function after the window loads
  window.addEventListener('load', function() {

    var scene = new THREE.Scene();
    var camera = new THREE.PerspectiveCamera( 75, window.innerWidth/window.innerHeight, 0.1, 1000 );
    var renderer = new THREE.WebGLRenderer( { antialias: true } );
    renderer.setPixelRatio(window.devicePixelRatio);
    renderer.setSize(window.innerWidth, window.innerHeight);
    renderer.setClearColor(0x020202, 0);

    var controls = new OrbitControls(camera, renderer.domElement);
    controls.enableDamping = true;
    controls.enableZoom = true;
    controls.target.set(0, 0, 0);
    controls.rotateSpeed = 0.3;
    controls.zoomSpeed = 1.0;
    controls.panSpeed = 2.0;

    document.body.appendChild(renderer.domElement);

    // resize the canvas when the window changes
    window.addEventListener('resize', function() {
      camera.aspect = window.innerWidth / window.innerHeight;
      camera.updateProjectionMatrix();
      renderer.setSize(window.innerWidth, window.innerHeight);
    });

    // assign THREE.js objects to the object we will return
    framework.scene = scene;
    framework.camera = camera;
    framework.renderer = renderer;
	


    // begin the animation loop
    (function tick() {
      stats.begin();
	  analyser.getByteFrequencyData(data);
	  framework.data=data;
	  //console.log(data);
      update(framework); // perform any requested updates
      renderer.render(scene, camera); // render the scene
      stats.end();
      requestAnimationFrame(tick); // register to call this again when the browser renders a new frame
    })();

    // we will pass the scene, gui, renderer, camera, etc... to the callback function
    return callback(framework);
  });
}

export default {
  init: init
}

export const PI = 3.14159265
export const e = 2.7181718