
const THREE = require('three'); // older modules are imported like this. You shouldn't have to worry about this much
import Framework from './framework'
import Noise from './noise'
import {other} from './noise'
import DAT from 'dat-gui'

var adamMaterial = new THREE.ShaderMaterial({
    uniforms: {
      image: { // Check the Three.JS documentation for the different allowed types and values
        type: "t", 
        value: THREE.ImageUtils.loadTexture('./explosion.png')
      },
        time: {
        type: "f",
        value: 1.0
    },
        persistance_p: {
            type: "f",
            value: 0.5
        },
        audData: {
            type: "iv1",
            value: new Array
        }
        
    },
    vertexShader: require('./shaders/adam-vert.glsl'),
    fragmentShader: require('./shaders/adam-frag.glsl')
  });

var timer ={ 
    speed: 0.03
    }

var persist = {
    persistance: 1.13
}

var audToggle = {
    AudioToggle: false
}

// called after the scene loads
function onLoad(framework) {
  var scene = framework.scene;
  var camera = framework.camera;
  var renderer = framework.renderer;
  var gui = framework.gui;
  var stats = framework.stats;
    var audio = framework.audio;
    //var data = framework.frequencyData;
    
  // LOOK: the line below is synyatic sugar for the code above. Optional, but I sort of recommend it.
  // var {scene, camera, renderer, gui, stat} = framework; 

  // initialize a simple box and material
  //var box = new THREE.BoxGeometry(1, 1, 1);
  var box = new THREE.IcosahedronGeometry(1,5);
    
  var adamCube = new THREE.Mesh(box, adamMaterial);

  // set camera position
  camera.position.set(1, 1, 2);
  camera.lookAt(new THREE.Vector3(0,0,0));

  scene.add(adamCube);

  // edit params and listen to changes like this
  // more information here: https://workshop.chromeexperiments.com/examples/gui/#1--Basic-Usage
  gui.add(camera, 'fov', 0, 180).onChange(function(newVal) {
    camera.updateProjectionMatrix();
  });
   
  gui.add(timer, 'speed', 0,0.05, 0.001).onChange(function(newVal1){
     timer.speed = newVal1; 
  });
    
  gui.add(persist, 'persistance', 0,2).onChange(function(newVal2){
     persist.persistance = newVal2; 
  }); 

    gui.add(audToggle, 'AudioToggle').onChange(function(newVal3){
     //audToggle.AudioToggle = newVal3; 
        if(newVal3 === true) audio.play();
        else audio.pause();
  }); 
    
}

  

  //var gui1 = new DAT.GUI();
  

// called on frame updates
function onUpdate(framework) {
  // console.log(`the time is ${new Date()}`);
    
    adamMaterial.uniforms.time.value += timer.speed;
    adamMaterial.uniforms.persistance_p.value = persist.persistance;  
    adamMaterial.uniforms.audData.value = Int32Array.from(framework.frequencyData);
    //console.log(framework.frequencyData);
    
}

// when the scene is done initializing, it will call onLoad, then on frame updates, call onUpdate
Framework.init(onLoad, onUpdate);

// console.log('hello world');

// console.log(Noise.generateNoise());

// Noise.whatever()

// console.log(other())