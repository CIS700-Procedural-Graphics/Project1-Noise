const THREE = require('three'); // older modules are imported like this. You shouldn't have to worry about this much
import Framework from './framework'

// r,g,b to pass to shaders
var r=0.1;
var g=0.3;
var b=0.4;
var r1=0.8;
var g1=0.8;
var b1=0.8;
var s=1.0;
var noisetype=0;
var preset1=false;
var terrain=true;

// function to manipulate stuff from gui
var GUIoptions = function()
{
	this.Red=0.1;
	this.Green=0.3;
	this.Blue=0.4;
	this.Red1=0.8;
	this.Green1=0.8;
	this.Blue1=0.8;
	this.Speed=1.0;
	this.NoiseType=0;
	this.Preset1=false;
	this.Terrain=true;
	// this.Value=true;
	// this.RidgedValue=false;
	// this.Music=false;
	 this.Source=function(){
	 	window.location = "https://github.com/rms13/Project1-Noise";};
}

// for time calculations
var oldt=0.0;
var newt=0.0;
var time=0;

// material for geometry
var icoshMaterial = new THREE.ShaderMaterial({
    uniforms: {
    //   image: { // Check the Three.JS documentation for the different allowed types and values
    //     type: "t",
    //     value: THREE.ImageUtils.loadTexture('./adam.jpg')
    //   },
	  time: {value : 0.0},
	  Red: {value : r},
	  Green: {value : g},
	  Blue: {value : b},
	  Red1: {value : r1},
	  Green1: {value : g1},
	  Blue1: {value : b1},
	  NoiseType: {value : 0},
	  Preset1: {value : false},
	  Terrain: {value : true}
	//   data: {
	// 	  type : 'iv1',
	// 	  value : new Array}
    },
    vertexShader: require('./shaders/adam-vert.glsl'),
    fragmentShader: require('./shaders/adam-frag.glsl')
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
  //var icosh = new THREE.PlaneBufferGeometry( 20, 20, 100, 100 );
  icosh.rotateX(90*3.14/180);
  //var material = new THREE.MeshBasicMaterial( {color: 0xffffff, side: THREE.DoubleSide} );
  var icosh = new THREE.Mesh(icosh, icoshMaterial);

  // var wireframe = new THREE.WireframeGeometry( icosh );
  // var icosh = new THREE.LineSegments( wireframe );
 // icosh.material.depthTest = false;
 // icosh.material.opacity = 0.25;
 // icosh.material.transparent = true;

 //var geometry = new THREE.PlaneBufferGeometry( 20, 20, 100, 100 );
// var material = new THREE.MeshBasicMaterial( {color: 0xffff00, side: THREE.DoubleSide} );
// var plane = new THREE.Mesh( geometry, material );
// scene.add( plane );



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
  gui.add(update,'Red', 0.0, 1.0, 0.05).onChange(function(newVal) {
    r=newVal;
  });
  gui.add(update,'Green', 0.0, 1.0, 0.05).onChange(function(newVal) {
    g=newVal;
  });
  gui.add(update,'Blue', 0.0, 1.0, 0.05).onChange(function(newVal) {
    b=newVal;
  });
  gui.add(update,'Red1', 0.0, 1.0, 0.05).onChange(function(newVal) {
	r1=newVal;
  });
  gui.add(update,'Green1', 0.0, 1.0, 0.05).onChange(function(newVal) {
	g1=newVal;
  });
  gui.add(update,'Blue1', 0.0, 1.0, 0.05).onChange(function(newVal) {
	b1=newVal;
  });
  gui.add(update,'Speed', 0.0, 4.0, 0.05).onChange(function(newVal) {
	s=newVal;
	//newt=0;
  });
  gui.add(update,'NoiseType', 0, 2, 1).onChange(function(newVal)
  {
	  noisetype = newVal;
  });
  gui.add(update,'Preset1').onChange(function(newVal)
  {
	if(newVal==true)
		preset1=true;
	else
		preset1=false;
  });
  gui.add(update,'Terrain').onChange(function(newVal)
  {
	if(newVal==true)
	  terrain=true;
	else
	  terrain=false;
  });
  // gui.add(update,'Music').onChange(function(newVal)
  //
  // if(newVal===false)
  //  		aud.pause();
  // else
  // 	aud.play();
  // 	});
  gui.add(update,'Source').onclick;
}

// called on frame updates
function onUpdate(framework) {
   icoshMaterial.uniforms.Red.value=r;
   icoshMaterial.uniforms.Green.value=g;
   icoshMaterial.uniforms.Blue.value=b;
   icoshMaterial.uniforms.Red1.value=r1;
   icoshMaterial.uniforms.Green1.value=g1;
   icoshMaterial.uniforms.Blue1.value=b1;
   icoshMaterial.uniforms.NoiseType.value=noisetype;
   icoshMaterial.uniforms.Preset1.value=preset1;
   icoshMaterial.uniforms.Terrain.value=terrain;

   oldt=newt;
   newt=performance.now(); // measures time since the beginning of execution
   time+=s*(newt-oldt);

   //icoshMaterial.uniforms.data.value=Int32Array.from(framework.data); // typed arrays casting

   icoshMaterial.uniforms.time.value=(100000.0+time)/25000; // control the speed of cloud movement
}

// when the scene is done initializing, it will call onLoad, then on frame updates, call onUpdate
Framework.init(onLoad, onUpdate);
