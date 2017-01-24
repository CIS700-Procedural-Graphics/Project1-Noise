
const THREE = require('three');
import Framework from './framework';

// Initialize Web Audio API stuff
var ctx = new (window.AudioContext || window.webkitAudioContext)();
var src = ctx.createBufferSource();
var analyser = ctx.createAnalyser();

// Connect/disconnect GUI toggle for audio
var isPlaying = true;
var audioGUI = {
  toggle: function () {
    if (isPlaying) {
      src.disconnect();
      isPlaying = false;
      uniforms.isAudioPlaying.value = 0;
    } else {
      src.connect(analyser);
      isPlaying = true;
      uniforms.isAudioPlaying.value = 1;
    }
  }
}

// Make GET request for song
var req = new XMLHttpRequest();
var url = 'http://zelliottm.com/assets/song.mp3';

req.open('GET', url, true)
req.responseType = 'arraybuffer';
req.onload = function() {

    // Decode data and link every node up
    ctx.decodeAudioData(req.response, function(buffer) {
      src = ctx.createBufferSource();
      src.buffer = buffer;
      src.connect(analyser);

      analyser.connect(ctx.destination);

      // Toggle song
      src.start();
    });
};
req.send();

// This array will hold the audio data used
// to animate our blob
var audioData = new Float32Array(analyser.frequencyBinCount);

// Smoothed data generated from the frequency
// array above.
var smoothedAudioData = [];

// Declare uniforms
const perm = [
  151,160,137,91,90,15,131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,
  10,23,190,6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,88,237,149,
  56,87,174,20,125,136,171,168,68,175,74,165,71,134,139,48,27,166,77,146,158,231,83,111,229,
  122,60,211,133,230,220,105,92,41,55,46,245,40,244,102,143,54,65,25,63,161,1,216,80,73,209,
  76,132,187,208,89,18,169,200,196,135,130,116,188,159,86,164,100,109,198,173,186,3,64,52,217,
  226,250,124,123,5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,
  42,223,183,170,213,119,248,152,2,44,154,163,70,221,153,101,155,167,43,172,9,129,22,39,253,
  19,98,108,110,79,113,224,232,178,185,112,104,218,246,97,228,251,34,242,193,238,210,144,
  12,191,179,162,241, 81,51,145,235,249,14,239,107,49,192,214,31,181,199,106,157,184,84,204,
  176,115,121,50,45,127,4,150,254,138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,
  215,61,156,180
];
var start = Date.now();
var uniforms = {
  speed: { value: 2.0 },
  time: { value: 0.0 },
  freq: { value: 0.6 },           // frequency
  pers: { value: 0.20 },           // persistence
  amp: { value: 1.0 },            // amplitude
  octaves: { value: 6 },          // number of octaves
  p: { value: perm },             // perm array,
  smoothedAudioData: { value: smoothedAudioData },
  isAudioPlaying: { value: 1 }
};

// called after the scene loads
function onLoad(framework) {
  var {scene, camera, renderer, gui, stats} = framework;

  // Load geometry & mesh
  var geom = new THREE.IcosahedronBufferGeometry(1, 4);
  var material = new THREE.ShaderMaterial({
    uniforms: uniforms,
    vertexShader: require('./shaders/icos-vert.glsl'),
    fragmentShader: require('./shaders/icos-frag.glsl')
  });
  var mesh = new THREE.Mesh(geom, material);

  // Set camera position
  camera.position.set(1, 1, 2);
  camera.lookAt(new THREE.Vector3(0,0,0));

  scene.add(mesh);

  // More info here: https://workshop.chromeexperiments.com/examples/gui/#1--Basic-Usage
  gui.add(camera, 'fov', 0, 180).onChange(function(newVal) {
    camera.updateProjectionMatrix();
  });

  gui.add(uniforms.speed, 'value', 1, 10).name('speed');
  gui.add(uniforms.freq, 'value', 0, 4).name('frequency');
  gui.add(uniforms.pers, 'value', 0, 2).name('persistence');
  gui.add(uniforms.amp, 'value', 0, 2).name('amplitude');
  gui.add(uniforms.octaves, 'value', 0, 10).name('octaves').step(1.0);
  gui.add(audioGUI, 'toggle').name('toggle song');
}

// Called on frame updates
function onUpdate(framework) {
  analyser.getFloatTimeDomainData(audioData);

  // Smooth audio data via a moving average
  var smoothStep = 16;
  for (var i = 0; i < audioData.length / smoothStep; i++) {
    var total = 0;
    var index = i * smoothStep;
    for (var j = 0; j < smoothStep; j++) {
      total += audioData[index + j];
    }

    smoothedAudioData[i] = total / smoothStep;
  }

  uniforms.smoothedAudioData.value = smoothedAudioData;
  uniforms.time.value = Date.now() - start;
}

Framework.init(onLoad, onUpdate);