
const THREE = require('three'); // older modules are imported like this. You shouldn't have to worry about this much
import Framework from './framework'
import Noise from './noise'
import {other} from './noise'
//import { rotateY } from 'gl-matrix/src/gl-matrix/vec3';

var cloud = {
  myMaterial: {},
  parameters: {
    time: 0.0,
    cloudNoise_strength: 0.3,
    cloudNoise_frequency: 2.0,
    cloud_speed: 1.0,
  },
  uniforms: {},
}

var planet = {
  myMaterial: {},
  parameters: {
    time: 0.0,
    planetNoise_strength: 0.3,
    planetNoise_frequency: 2.0,
    cloud_speed: 1.0,
  },
  uniforms: {},
}

var basePlanet;

// called after the scene loads
function onLoad(framework) {
  var scene = framework.scene;
  var camera = framework.camera;
  var renderer = framework.renderer;
  var gui = framework.gui;
  var stats = framework.stats;


  // LOOK: the line below is synyatic sugar for the code above. Optional, but I sort of recommend it.
  // var {scene, camera, renderer, gui, stats} = framework; 

  //initialize icosahedron and material
  var icosahedron = new THREE.IcosahedronGeometry(1, 5);

  cloud.uniforms= {
    u_time: {
      type: "f",
      value : cloud.parameters.time, 
    },
    u_strength: {
      type: "f",
      value : cloud.parameters.cloudNoise_strength,
    },
    u_frequency: {
      type: "f",
      value : cloud.parameters.cloudNoise_frequency,
    },
    u_speed: {
      type: "f",
      value: cloud.parameters.cloud_speed,
    },
    image: { // Check the Three.JS documentation for the different allowed types and values
      type: "t", 
      value: THREE.ImageUtils.loadTexture('./resource/cloud.jpg'),
    },
    alpha: { // Check the Three.JS documentation for the different allowed types and values
      type: "t", 
      value: THREE.ImageUtils.loadTexture('./resource/alpha2.jpg'),
    },
  },

  cloud.myMaterial = new THREE.ShaderMaterial({
    uniforms: cloud.uniforms,
    vertexShader: require('./shaders/cloud-vert.glsl'),
    fragmentShader: require('./shaders/cloud-frag.glsl')
  });
  cloud.myMaterial.transparent = true;
  var myIcosahedronn = new THREE.Mesh(icosahedron, cloud.myMaterial);


  //initialize icosahedron and material
  var baseSphere = new THREE.IcosahedronGeometry(0.95, 5);

  planet.uniforms= {
    u_time: {
      type: "f",
      value : planet.parameters.time, 
    },
    u_strength: {
      type: "f",
      value : planet.parameters.planetNoise_strength,
    },
    u_frequency: {
      type: "f",
      value : planet.parameters.planetNoise_frequency,
    },
    u_speed: {
      type: "f",
      value: planet.parameters.speed,
    },
    image: { // Check the Three.JS documentation for the different allowed types and values
      type: "t", 
      value: THREE.ImageUtils.loadTexture('./resource/earth.jpg'),
    },
    alpha: { // Check the Three.JS documentation for the different allowed types and values
      type: "t", 
      value: THREE.ImageUtils.loadTexture('./resource/alpha2.jpg'),
    },
  },

  planet.myMaterial = new THREE.ShaderMaterial({
    uniforms: planet.uniforms,
    vertexShader: require('./shaders/basePlanet-vert.glsl'),
    fragmentShader: require('./shaders/basePlanet-frag.glsl')
  });
  basePlanet = new THREE.Mesh(baseSphere, planet.myMaterial);


  
  // set camera position
  camera.position.set(1, 1, 2);
  camera.lookAt(new THREE.Vector3(0,0,0));

  scene.add(myIcosahedronn);
  scene.add(basePlanet);

  // edit params and listen to changes like this
  // more information here: https://workshop.chromeexperiments.com/examples/gui/#1--Basic-Usage
  gui.add(camera, 'fov', 0, 180).onChange(function(newVal) {
    camera.updateProjectionMatrix();
  });
  gui.add(cloud.parameters, 'cloudNoise_frequency').onChange(function(newVal) {
    cloud.uniforms.u_frequency= {
      type: "f",
      value: cloud.parameters.cloudNoise_frequency,
    }
  });
  gui.add(cloud.parameters, 'cloudNoise_strength').onChange(function(newVal) {
    cloud.uniforms.u_strength= {
      type: "f",
      value: cloud.parameters.cloudNoise_strength,
    }
  });
  
  gui.add(planet.parameters, 'planetNoise_frequency').onChange(function(newVal) {
    planet.uniforms.u_frequency= {
      type: "f",
      value: planet.parameters.planetNoise_frequency,
    }
  });
  gui.add(planet.parameters, 'planetNoise_strength').onChange(function(newVal) {
    planet.uniforms.u_strength= {
      type: "f",
      value: planet.parameters.planetNoise_strength,
    }
  });

  gui.add(cloud.parameters, 'cloud_speed').onChange(function(newVal) {
    cloud.uniforms.u_speed= {
      type: "f",
      value: cloud.parameters.cloud_speed,
    }
  });
}

// called on frame updates
function onUpdate(framework) {

  cloud.parameters.time++;

  cloud.uniforms.u_time= {
      type: "f",
      value : cloud.parameters.time, 
  }

}

// when the scene is done initializing, it will call onLoad, then on frame updates, call onUpdate
Framework.init(onLoad, onUpdate);


// console.log('hello world');

// console.log(Noise.generateNoise());

// Noise.whatever()

// console.log(other())