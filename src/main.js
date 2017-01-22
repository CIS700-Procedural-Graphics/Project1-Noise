const THREE = require('three');

//For obj loading
var OBJLoader = require('three-obj-loader');
OBJLoader(THREE);

//Imports
import Framework from './framework'
import {NoiseArrays} from './noise'

//For keeping track of elapsed time during animation
var currentDate = Date.now();

//Audio and Audio Analysis variables

//Create an AudioListener and add it to the camera
var listener = new THREE.AudioListener();

// create a global audio source
var sound = new THREE.PositionalAudio( listener );

//Used for retrieving audio frequency data
var analyser = new THREE.AudioAnalyser( sound, 32 );

//Perlin Noise Material
var noiseMaterial = new THREE.ShaderMaterial({
    uniforms: {
      elapsedTime: { value: 0 },
      audioLevel: { value: 0 },
      noiseLayer1Intensity: { value: 0.5 },
      noiseLayer2Intensity: { value: 0.1 },
      useTexture: { value: 0 },
      useAudio: { value: 0 },
      permArray: {
        type: "fv1",
        value: NoiseArrays.permArray
      },
      gradArray: {
        type: "fv1",
        value: NoiseArrays.gradArray
      },
      image: {
        type: "t", 
        value: THREE.ImageUtils.loadTexture('./res/textures/trippy.jpg')
      }
    },
    vertexShader: require('./shaders/noise-vert.glsl'),
    fragmentShader: require('./shaders/noise-frag.glsl')
  });

// called after the scene loads
function onLoad(framework) {
  var scene = framework.scene;
  var camera = framework.camera;
  var renderer = framework.renderer;
  var gui = framework.gui;
  var stats = framework.stats;
  
  //Display the Noise Cloud to begin with
  var icosahedron = new THREE.IcosahedronBufferGeometry(2, 5);
  var noiseIcosahedron = new THREE.Mesh(icosahedron, noiseMaterial);
  scene.add(noiseIcosahedron);
  
  /* OBJ Loading */
  
  var objToLoad = { name : 'cloud' };
  
  //OBJ Loading function
  var loadOBJ = function()  {
    //Manager from TreeJS to keep track of various loaders
    var manager = new THREE.LoadingManager();
    
    //ThreeJS Obj Loader
    var objLoader = new THREE.OBJLoader(manager);
    
    //Load the OBJ file
    objLoader.load('res/objs/' + objToLoad.name + '.obj', function(object) {
      //Search the children of the object for a Mesh
      object.traverse(function(child) {
        if(child instanceof THREE.Mesh) {
          //child.geometry.computeVertexNormals(); //not perfect...
          child.material = noiseMaterial;
          object.position.set(0, 0, 0);
          object.scale.set(2, 2, 2);
        }
    });
    //Clear the scene before adding a new mesh
    scene.children.forEach(function(object){
        scene.remove(object);
    });
    
    scene.add(object);
  });
  };
  
  /* Audio Loading: https://threejs.org/docs/?q=audio#Reference/Audio/Audio */
  //All variables had to be created globally in order to be updated for animation purposes
  
  camera.add( listener );
  
  var audioLoader = new THREE.AudioLoader();

  //Load a sound and set it as the Audio object's buffer
  audioLoader.load( 'res/audio/Yu-Gi-Oh!FullTheme.mp3', function( buffer ) {
  	sound.setBuffer( buffer );
  	sound.setLoop(true);
  	sound.setVolume(0.5);
  	sound.play();
  });  
  
  // set camera position
  camera.position.set(1, 1, 15);
  camera.lookAt(new THREE.Vector3(0,0,0));

  // edit params and listen to changes like this
  // more information here: https://workshop.chromeexperiments.com/examples/gui/#1--Basic-Usage
  gui.add(camera, 'fov', 0, 180).onChange(function(newVal) {
    camera.updateProjectionMatrix();
  });
  
  /* Additional gui functionality */
  
  //Control Perlin Noise Intensity
  gui.add(noiseMaterial.uniforms["noiseLayer1Intensity"], 'value', 0, 10).name('Inner Noise Layer Intensity');
  gui.add(noiseMaterial.uniforms["noiseLayer2Intensity"], 'value', 0.01, 10).name('Outer Noise Layer Intensity');
  
  //Choose the OBJ file to load
  gui.add(objToLoad, 'name', { Cloud  : 'cloud',
                               Bunny  : 'bunny',
                               Dragon : 'dragon',
                               Teapot : 'teapot' } ).name('Mesh').onChange(function(newVal)
  {
      if(objToLoad.name != 'cloud') {
      loadOBJ(framework);
    } else {
      // initalize the base icosahedron and attach the material to it
      var icosahedron = new THREE.IcosahedronBufferGeometry(2, 5);
      var noiseIcosahedron = new THREE.Mesh(icosahedron, noiseMaterial);
      
      //Clear the scene
      scene.children.forEach(function(object){
          scene.remove(object);
      });
      
      scene.add(noiseIcosahedron);
    }
  });
  
  //Choose whether or not we color using the texture or the Perlin Noise values (black and white)
  gui.add(noiseMaterial.uniforms["useTexture"], 'value', 0, 1).step(1).name('Use Texture?');
  
  //Control whether or not audio plays and affects the noise object                             
  gui.add(noiseMaterial.uniforms["useAudio"], 'value', 0, 1).step(1).name('Use Audio?');
}

// called on frame updates
function onUpdate(framework) {
  //compute the elapsed time
  var elapsedSecs = (Date.now() - currentDate) * 0.001; //last number controls speed of animation
  noiseMaterial.uniforms["elapsedTime"].value = elapsedSecs;
  
  // Audio Analysis: https://threejs.org/docs/?q=audio#Reference/Audio/AudioAnalyser

  //Get the sound frequencies in the form of an array
  var dataArray = analyser.data; // Uint8Array should be the same length as the frequencyBinCount 
  analyser.getFrequencyData(dataArray); // fill the Uint8Array with data returned from getByteFrequencyData()
  noiseMaterial.uniforms["audioLevel"].value = analyser.getAverageFrequency() / 256;
}

// when the scene is done initializing, it will call onLoad, then on frame updates, call onUpdate
Framework.init(onLoad, onUpdate);