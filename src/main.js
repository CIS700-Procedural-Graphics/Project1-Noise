
const THREE = require('three'); // older modules are imported like this. You shouldn't have to worry about this much
import Framework from './framework'

// Colors
var additionalControls = {
	'Color' : [255, 255, 255],
	'scale' : 1.,
	'music' : true,
	'inv persistence' : 2.,
	'radius' : 0.7,
	'detail' : 6.
};

// Local global to allow for modifying variables
var noiseCloud = {
	mesh : {},
};

// called after the scene loads
function onLoad(framework) {
	var scene = framework.scene;
	var camera = framework.camera;
	var renderer = framework.renderer;
	var gui = framework.gui;
	var stats = framework.stats;

	// LOOK: the line below is synyatic sugar for the code above. Optional, but I sort of recommend it.
	// var {scene, camera, renderer, gui, stats} = framework; 
 	var adamMaterial = new THREE.ShaderMaterial({
	  	uniforms: {
	      image: { // Check the Three.JS documentation for the different allowed types and values
	      	type: "t", 
	      	value: THREE.ImageUtils.loadTexture('./adam.jpg')
	      },
	      inv_persistence: {
	      	type: "f",
	      	value: 2.0
	      },
	      time: {
	      	type: "f",
	      	value: 0.
	      },
	      music: {
	      	type: "f",
	      	value: 1.
	      },
	      music2: {
	      	type: "f",
	      	value: 1.
	      },
	      colorMult: {
	      	value: new THREE.Vector3(additionalControls['Color'][0]/255, additionalControls['Color'][1]/255, additionalControls['Color'][2]/255,)
	      }
	  },
	  vertexShader: require('./shaders/adam-vert.glsl'),
	  fragmentShader: require('./shaders/adam-frag.glsl')
	});

	var iso = new THREE.IcosahedronBufferGeometry(0.7, 6);
	noiseCloud.mesh = new THREE.Mesh(iso, adamMaterial);
	noiseCloud.mesh.name = "adamCube";

	// set camera position
	camera.position.set(1, 1, 6);
	camera.lookAt(new THREE.Vector3(0,0,0));

	scene.add(noiseCloud.mesh);

	// edit params and listen to changes like this
	// more information here: https://workshop.chromeexperiments.com/examples/gui/#1--Basic-Usage
	gui.add(camera, 'fov', 0, 180).onChange(function(newVal) {
		camera.updateProjectionMatrix();
	});

	gui.add(additionalControls, 'inv persistence', 1., 10.).onChange(function(newVal) {
		noiseCloud.mesh.material.uniforms.inv_persistence.value = newVal;
	});

	gui.add(additionalControls, 'music').onChange(function(newVal) {
		additionalControls.music = newVal;
	});

	// Color menu
	gui.addColor(additionalControls, 'Color').onChange(function(newVal) {
		noiseCloud.mesh.material.uniforms.colorMult.value = new THREE.Vector3(newVal[0]/255, newVal[1]/255, newVal[2]/255,);
	});


	// Audio stuff below
	// http://raathigesh.com/Audio-Visualization-with-Web-Audio-and-ThreeJS/
	// http://stackoverflow.com/questions/27589179/basic-web-audio-api-not-playing-a-mp3-file
	// http://stackoverflow.com/questions/3273552/html5-audio-looping
	var context = new AudioContext();
	var jsNode = context.createScriptProcessor(2048,1,1);
	jsNode.connect(context.destination);

	// Load file and set to repeat
	var audio = new Audio();
	audio.src = "./sounds/music2.mp3"; //https://www.jamendo.com/track/1350213/jumper
	audio.controls = true;
	audio.autoplay = true;
	audio.addEventListener('ended', function(){
		this.currentTime = 0;
		this.play();
	}, false);
	audio.loop = true;

	// Play file
	var source = context.createMediaElementSource(audio);
	source.connect(context.destination);
	source.mediaElement.play();

	// Analyze waveform data
	var analyser = context.createAnalyser();
	analyser.fftSize = 128;
	analyser.smoothingTimeConstat = 0.8;
	source.connect(analyser);

	// Action to take with processed data
	jsNode.onaudioprocess = function () {

		// If music sync box is checked
		if (additionalControls.music) {
			var array = new Uint8Array(analyser.frequencyBinCount);
			analyser.getByteFrequencyData(array);
			// console.log(analyser.maxDecibels)

		 	var Z = [array.slice(0, 9).reduce((a, b) => a + b, 0) / 10 /256, 
		 	array.slice(10, 19).reduce((a, b) => a + b, 0) / 10 /256,
		 	array.slice(20, 29).reduce((a, b) => a + b, 0) / 10 /256,
		 	array.slice(30, 39).reduce((a, b) => a + b, 0) / 10 /256,
		 	array.slice(40, 49).reduce((a, b) => a + b, 0) / 10 /256,
		 	array.slice(50, 59).reduce((a, b) => a + b, 0) / 10 /256];
			// console.log(Z);

			noiseCloud.mesh.material.uniforms.music.value = Z[4];
			noiseCloud.mesh.material.uniforms.music2.value = Z[1];
		} else {
			noiseCloud.mesh.material.uniforms.music.value = 1.;
			noiseCloud.mesh.material.uniforms.music2.value = 0.;
		}


	}


}

// called on frame updates
function onUpdate(framework) {


	framework.scene.traverse(function (object)
	{
		if (object instanceof THREE.Mesh)
		{
			if (object.name === 'adamCube') {
	        	// var d = new Date();
	         	// console.log(`the time is ${(object.material.uniforms.time.value)}`);
	         	object.material.uniforms.time.value += .01;

	         }
	     }
	 });
}

// when the scene is done initializing, it will call onLoad, then on frame updates, call onUpdate
Framework.init(onLoad, onUpdate);