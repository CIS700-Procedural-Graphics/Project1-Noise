
const THREE = require('three'); // older modules are imported like this. You shouldn't have to worry about this much
import Framework from './framework'

var currTime = 0;
var mouse;

var myMaterial = new THREE.ShaderMaterial({
    uniforms: {
      image: { // Check the Three.JS documentation for the different allowed types and values
        type: "t", 
        value: THREE.ImageUtils.loadTexture('./colors.jpg')
      },
      time: {
        type: "float",
        value: currTime
      },
      persistence: {
        type: "float",
        value: 0.59
      },
      amplitude: {
        type: "float",
        value: 40.0
      }
    },
    vertexShader: require('./shaders/my-vert.glsl'),
    fragmentShader: require('./shaders/my-frag.glsl')
  });


var audioLoader = new THREE.AudioLoader();
var listener = new THREE.AudioListener();

var sound = new THREE.Audio( listener );
        audioLoader.load( 'song.mp3', function( buffer ) {
          sound.setBuffer( buffer );
          sound.setLoop(true);
          sound.play();
        });

// called after the scene loads
function onLoad(framework) {
  var {scene, camera, renderer, gui, stats} = framework;

  // create geometry and add it to the scene
  var geom_icosa = new THREE.IcosahedronBufferGeometry(10, 5);
  var myIcosa = new THREE.Mesh(geom_icosa, myMaterial);
  scene.add(myIcosa);

  // set camera position
  camera.position.set(15, 15, 90);
  camera.lookAt(new THREE.Vector3(0,0,0));

  // edit params and listen to changes like this
  // more information here: https://workshop.chromeexperiments.com/examples/gui/#1--Basic-Usage
  gui.add(camera, 'fov', 0, 180).onChange(function(newVal) {
    camera.updateProjectionMatrix();
  });

  // add a slider to let user change *radius* of icosahedron
  gui.add(myIcosa.geometry.parameters, 'radius', 0, 100).onChange(function(newVal) {
    var detail = myIcosa.geometry.parameters.detail;
    scene.remove(myIcosa);
    myIcosa = new THREE.Mesh(new THREE.IcosahedronBufferGeometry(newVal, detail), myMaterial);
    scene.add(myIcosa);
    renderer.render(scene, camera);
  });

  // add a slider to let user change *detail* of icosahedron 
  gui.add(myIcosa.geometry.parameters, 'detail', 0, 8).step(1).onChange(function(newVal) {
    var radius = myIcosa.geometry.parameters.radius;
    scene.remove(myIcosa);
    myIcosa = new THREE.Mesh(new THREE.IcosahedronBufferGeometry(radius, newVal), myMaterial);
    scene.add(myIcosa);
    renderer.render(scene, camera);
  });

  // add a slider to let user change *persistence* of noise 
  gui.add(myMaterial.uniforms.amplitude, 'value', 0, 50).onChange(function(newVal) {
    renderer.render(scene, camera);
  });

  window.addEventListener('click', function(event){
   console.log(event);
   console.log(myIcosa.geometry);
  });

}

function average(array)
{
  var sum = 0;
  for (var i =0; i < array.length; i++)
  {
      sum += array[i];
  }
  return sum / array.length;
}

// called on frame updates
function onUpdate(framework) {
  currTime += 0.2;
  myMaterial.uniforms.time.value = currTime;
  
  var analyser = sound.context.createAnalyser();
  var array = new Uint8Array(analyser.frequencyBinCount);
  analyser.getByteFrequencyData(array);
  console.log(average(array));
}

// when the scene is done initializing, it will call onLoad, then on frame updates, call onUpdate
Framework.init(onLoad, onUpdate);