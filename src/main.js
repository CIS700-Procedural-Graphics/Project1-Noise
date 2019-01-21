
const THREE = require('three'); // older modules are imported like this. You shouldn't have to worry about this much
import Framework from './framework'
import Noise from './noise'
import {other} from './noise'

var start = Date.now();

// setup sphere geometry
var sphere = new THREE.IcosahedronGeometry( 80, 6 )

var flameMaterial = new THREE.ShaderMaterial({
  uniforms: {
    time: { // float initialized to 0
    	type: "f",
    	value: 0.0
  	},
    vTurbulence: {
      type: "f",
      value: 1.0
    },
    speed: {
      type: "f",
      value: 1.0
    },
    magnitude: {
      type: "f",
      value: 1.0
    },
    density: {
      type: "f",
      value: 10.0
    }
  },
  vertexShader: require('./shaders/flame-vert.glsl'),
  fragmentShader: require('./shaders/flame-frag.glsl'),
  wireframe: false
});

var flameSphere = new THREE.Mesh(sphere, flameMaterial);
// value params
var graphicsParams = {
  'turbulence': .666,
  'pulse': 0.0,
  'resolution': 6,
  'speed': 1.0,
  'magnitude': 1.0,
  'density': 0.5
};
var dialogPrompted = false;

// called after the scene loads
function onLoad(framework) {
  var scene = framework.scene;
  var camera = framework.camera;
  var renderer = framework.renderer;
  var gui = framework.gui;
  var stats = framework.stats;


  // LOOK: the line below is synyatic sugar for the code above. Optional, but I sort of recommend it.
  var {scene, camera, renderer, gui, stats} = framework; 

  // set camera position
  camera.position.set(1, -150, 2);
  camera.lookAt(new THREE.Vector3(0,0,0));

  // add geom to scene
  scene.add(flameSphere);

  // edit params and listen to changes like this
  // more information here: https://workshop.chromeexperiments.com/examples/gui/#1--Basic-Usage
  gui.add(camera, 'fov', 0, 180).onChange(function(newVal) {
    camera.updateProjectionMatrix();
  });
  gui.add(graphicsParams, 'turbulence' ,0.0,1.0).onFinishChange((newVal) => {
    graphicsParams.vTurbulence = newVal;
  });
  // gui.add(graphicsParams, 'pulse' ,0.0,1.0).onFinishChange((newVal) => {
  //   scene.remove(flameSphere);
  // })
  gui.add(graphicsParams, 'resolution' ,1,10).step(1).onFinishChange((newVal) => {
    if (graphicsParams.resolution > 6 && !dialogPrompted) {
      alert("High resolutions are resource intensive and could cause a browser crash!");
      dialogPrompted = true;
    }
    scene.remove(flameSphere);
    var newSphere = new THREE.IcosahedronGeometry( 80, graphicsParams.resolution )
    flameSphere = new THREE.Mesh(newSphere, flameMaterial);
    scene.add(flameSphere);
  });
  gui.add(graphicsParams, 'speed' ,0.0,3.0).onFinishChange((newVal) => {
    graphicsParams.speed = newVal;
  });
  gui.add(graphicsParams, 'magnitude' ,0.0,10).onFinishChange((newVal) => {
    graphicsParams.magnitude = newVal;
  });
  gui.add(graphicsParams, 'density' ,0.0,2.0).onFinishChange((newVal) => {
    graphicsParams.density = newVal;
  })
}

// called on frame updates
function onUpdate(framework) {
  var now = ((Date.now() - start) / 1000.0);
  flameMaterial.uniforms[ 'time' ].value = 0.25 * now;
  flameMaterial.uniforms[ 'vTurbulence' ].value = graphicsParams.turbulence;
  flameMaterial.uniforms[ 'magnitude' ].value = graphicsParams.magnitude;
  flameMaterial.uniforms[ 'density' ].value = 10*(2.0*graphicsParams.density);
  flameMaterial.uniforms[ 'speed' ].value = (Math.pow(10,graphicsParams.speed));
}

// when the scene is done initializing, it will call onLoad, then on frame updates, call onUpdate
Framework.init(onLoad, onUpdate);