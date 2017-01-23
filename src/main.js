const THREE = require('three'); // older modules are imported like this. You shouldn't have to worry about this much
import Framework from './framework'

// r,g,b to pass to shaders
var r=0.6;
var g=0.0; 
var b=0.0;

// function to manipulate stuff from gui
var GUIoptions = function()
{
	this.Red=0.6;
	this.Green=0.0;
	this.Blue=0.0;
	this.Music=false;	
	this.MusicSource=function(){
		window.location = "http://freemusicarchive.org/music/The_Kyoto_Connection/Wake_Up_1957/09_Hachiko_The_Faithtful_Dog";};
}

// for time calculations
var oldt=0.0;
var newt=0.0;
var time=0.0;

// material for geometry
var icoshMaterial = new THREE.ShaderMaterial({
    uniforms: {
      image: { // Check the Three.JS documentation for the different allowed types and values
        type: "t", 
        value: THREE.ImageUtils.loadTexture('./adam.jpg') 
      },
	  time: {value : 0.0},
	  Red: {value : 0.6},
	  Green: {value : 0.0},
	  Blue: {value : 0.0},
	  data: {
		  type : 'iv1',
		  value : new Array}
    },
    vertexShader: require('./shaders/icosh-vert.glsl'),
    fragmentShader: require('./shaders/icosh-frag.glsl')
  });

// called after the scene loads
function onLoad(framework) {
  var scene = framework.scene;
  var camera = framework.camera;
  var renderer = framework.renderer;
  var gui = framework.gui;
  var stats = framework.stats;
  var data= framework.data; // per frame audio data
  var aud= framework.aud; // audio object to control play/pause
  
  var {scene, camera, renderer, gui, stats, data, aud} = framework; 

  // initialize an icosahedron and material
  var icosh = new THREE.IcosahedronBufferGeometry(1, 5);
  var icosh = new THREE.Mesh(icosh, icoshMaterial);
  
  // set camera position
  camera.position.set(1, 4, 2);
  camera.lookAt(new THREE.Vector3(0,0,0));

  // add icosh to the scene
  scene.add(icosh);

  // Elements for the GUI:
  gui.add(camera, 'fov', 0, 180).onChange(function(newVal) {
    camera.updateProjectionMatrix();
  });
  var update= new GUIoptions();
  gui.add(update,'Red', 0.0, 1.0,0.05).onChange(function(newVal) {
    r=newVal;
  });
  gui.add(update,'Green', 0.0, 1.0,0.05).onChange(function(newVal) {
    g=newVal;
  });
  gui.add(update,'Blue', 0.0, 1.0,0.05).onChange(function(newVal) {
    b=newVal;
  });
  gui.add(update,'Music').onChange(function(newVal) {
    if(newVal===false) aud.pause();
	else aud.play();
  });
  gui.add(update,'MusicSource').onclick;  
}

// called on frame updates
function onUpdate(framework) {
   icoshMaterial.uniforms.Red.value=r;
   icoshMaterial.uniforms.Green.value=g;
   icoshMaterial.uniforms.Blue.value=b;
   
   oldt=newt;
   newt=performance.now(); // measures time since the beginning of execution
   time+=(newt-oldt);
   
   icoshMaterial.uniforms.data.value=Int32Array.from(framework.data); // typed arrays casting
   
   icoshMaterial.uniforms.time.value=time/4000; // control the speed of cloud movement
}

// when the scene is done initializing, it will call onLoad, then on frame updates, call onUpdate
Framework.init(onLoad, onUpdate);