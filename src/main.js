
const THREE = require('three'); // older modules are imported like this. You shouldn't have to worry about this much
import Framework from './framework'

var time;
var mat = {
  uniforms: {
    time: {value: new Date().getMilliseconds()},
    cell: {value: false},
    bcolor: {value: [16/255,17/255, 134/255]},
    rcolor: {value: [0,0,0.1]},
    tcolor: {value: [12/255,84/255, 49/255]},
    grads: {type: 'vec3', value: [new THREE.Vector3(1,1,0), new THREE.Vector3(-1,1,0), new THREE.Vector3(1,-1,0),        new THREE.Vector3(-1,-1,0), new THREE.Vector3(1,0,1), new THREE.Vector3(-1,0,1), new THREE.Vector3(1,0,-1), 
      new THREE.Vector3(-1,0,-1), new THREE.Vector3(0,1,1), new THREE.Vector3(0,-1,1), new THREE.Vector3(0,1,-1), 
      new THREE.Vector3(0,-1,-1)]}
    },
  vertexShader: require('./shaders/noise-vert.glsl'),
  fragmentShader: require('./shaders/noise-frag.glsl')
};

// called after the scene loads
function onLoad(framework) {
  time = 0;
  var scene = framework.scene;
  var camera = framework.camera;
  var renderer = framework.renderer;
  var gui = framework.gui;
  var stats = framework.stats;

  // LOOK: the line below is synyatic sugar for the code above. Optional, but I sort of recommend it.
  // var {scene, camera, renderer, gui, stats} = framework; 

  // initialize a simple box and material

  //var loader = new THREE.OBJLoader();

  loader.load('koffie.obj', function(object) {
    console.log(object);
  });

  var ico = new THREE.IcosahedronBufferGeometry(4, 6);

  var material = new THREE.ShaderMaterial(mat);

  ico.base_color = [1.0,0.0,0.0];
  ico.root_color = [0.0,1.0,0.0];
  ico.tip_color = [0.0,0.0,1.0];
  ico.cellular = false;

  var ball = new THREE.Mesh(ico, material);

  // set camera position
  camera.position.set(1, 1, 20);
  camera.lookAt(new THREE.Vector3(0,0,0));

  scene.add(ball);

  // edit params and listen to changes like this
  // more information here: https://workshop.chromeexperiments.com/examples/gui/#1--Basic-Usage
  //gui.add(camera, 'fov', 0, 180).onChange(function(newVal) {
    //camera.updateProjectionMatrix();
  //});
  gui.addColor(ico, 'base_color').onChange(function(newVal) {
    mat.uniforms['bcolor'].value = [newVal[0]/255, newVal[1]/255, newVal[2]/255];
  });
  gui.addColor(ico, 'root_color').onChange(function(newVal) {
    mat.uniforms['rcolor'].value = [newVal[0]/255, newVal[1]/255, newVal[2]/255];
  });
  gui.addColor(ico, 'tip_color').onChange(function(newVal) {
    mat.uniforms['tcolor'].value = [newVal[0]/255, newVal[1]/255, newVal[2]/255];
  });
  gui.add(ico, 'cellular').onChange(function(newVal) {
    mat.uniforms['cell'].value = newVal;
  });
}

// called on frame updates
function onUpdate(framework) {
  time = (time + 1);
  mat.uniforms.time.value = time;
}

// when the scene is done initializing, it will call onLoad, then on frame updates, call onUpdate
Framework.init(onLoad, onUpdate);