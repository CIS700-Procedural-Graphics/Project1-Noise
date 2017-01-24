
const THREE = require('three'); // older modules are imported like this. You shouldn't have to worry about this much
require('three-obj-loader')(THREE);
import Framework from './framework'

var time;
var mat = {
  uniforms: {
    time: {value: new Date().getMilliseconds()},
    amplitude: {value: 0.8},
    frequency: {value: 2.0},
    num_octaves: {value: 5},
    bcolor: {value: [16/255,17/255, 134/255]},
    rcolor: {value: [0, 0.4,0.2]},
    tcolor: {value: [1,1,1]},
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

  var loader = new THREE.OBJLoader();
  loader.load('koffie.obj', function(object) {
    for (var i = 0; i < object.children.length; ++i) {
      var geo = object.children[i].geometry;
      var mat = new THREE.MeshLambertMaterial({color: 0xffffff});
      var mesh = new THREE.Mesh(geo, mat);
      //scene.add(mesh);

      geo.computeBoundingSphere();
      var center = geo.boundingSphere.center;
      geo.translate(-center.x, -center.y, -center.z);
      geo.scale(0.1, 0.1, 0.1);
      geo.computeVertexNormals();
    }
  });

  var ico = new THREE.IcosahedronBufferGeometry(4, 6);

  var material = new THREE.ShaderMaterial(mat);

  ico.base_color = [1.0,0.0,0.0];
  ico.root_color = [0.0,1.0,0.0];
  ico.tip_color = [0.0,0.0,1.0];
  ico.amplitude = 0.8;
  ico.frequency = 2.0;
  ico.num_octaves = 5;

  var ball = new THREE.Mesh(ico, material);

  // set camera position
  camera.position.set(1, 1, 20);
  camera.lookAt(new THREE.Vector3(0,0,0));

   scene.add(ball);

  var directionalLight = new THREE.DirectionalLight(0xffffff, 0.5);
  scene.add(directionalLight);

  // edit params and listen to changes like this
  // more information here: https://workshop.chromeexperiments.com/examples/gui/#1--Basic-Usage
  gui.addColor(ico, 'base_color').onChange(function(newVal) {
    mat.uniforms['bcolor'].value = [newVal[0]/255, newVal[1]/255, newVal[2]/255];
  });
  gui.addColor(ico, 'root_color').onChange(function(newVal) {
    mat.uniforms['rcolor'].value = [newVal[0]/255, newVal[1]/255, newVal[2]/255];
  });
  gui.addColor(ico, 'tip_color').onChange(function(newVal) {
    mat.uniforms['tcolor'].value = [newVal[0]/255, newVal[1]/255, newVal[2]/255];
  });
  gui.add(ico, 'num_octaves',0,10).onChange(function(newVal) {
    mat.uniforms['num_octaves'].value = newVal;
  });
  gui.add(ico, 'amplitude',0.0,1.0).onChange(function(newVal) {
    mat.uniforms['amplitude'].value = newVal;
  });
  gui.add(ico, 'frequency',0,5.0).onChange(function(newVal) {
    mat.uniforms['frequency'].value = newVal;
  });
}

// called on frame updates
function onUpdate(framework) {
  time = (time + 1);
  mat.uniforms.time.value = time;
}

// when the scene is done initializing, it will call onLoad, then on frame updates, call onUpdate
Framework.init(onLoad, onUpdate);