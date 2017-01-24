
const THREE = require('three'); // older modules are imported like this. You shouldn't have to worry about this much
import Framework from './framework'

var myIco;
var noiseBlob = {
  'Base Color': [200, 50, 50],
  'Outer Color': [0, 0, 0],
  'Inner Color': [255, 255, 100],
  'Stripes': false,
  'Stripe Density': 0.3,
  'Pattern': false,
  'Pattern Color': [0, 0, 0],
  'Stripe Color': [255, 255, 255],
  'Pattern Density': 0.5
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

  // initialize a simple box and material
  var box = new THREE.BoxGeometry(1, 1, 1);

  var adamMaterial = new THREE.ShaderMaterial({
    uniforms: {
      image: { // Check the Three.JS documentation for the different allowed types and values
        type: "t", 
        value: THREE.ImageUtils.loadTexture('./adam.jpg')
      }
    },
    vertexShader: require('./shaders/adam-vert.glsl'),
    fragmentShader: require('./shaders/adam-frag.glsl')
  });
  var adamCube = new THREE.Mesh(box, adamMaterial);
 
  // Create a new material 
  var velvetMaterial = new THREE.ShaderMaterial({
    uniforms: {
      image: {
       type: 't',
        value: THREE.ImageUtils.loadTexture('./bh_velvet.jpg')
      },
      time: {
        type: 'f',
        value: 0.0
      },
      baseColor: {
        type: 'v3',
        value: new THREE.Vector3(
            noiseBlob['Base Color'][0] / 255, 
            noiseBlob['Base Color'][1] / 255, 
            noiseBlob['Base Color'][2] / 255)
      },
      outerColor: {
        type: 'v3',
        value: new THREE.Vector3(
            noiseBlob['Outer Color'][0] / 255, 
            noiseBlob['Outer Color'][1] / 255, 
            noiseBlob['Outer Color'][2] / 255)
      },
      innerColor: {
        type: 'v3',
        value: new THREE.Vector3(
            noiseBlob['Inner Color'][0] / 255, 
            noiseBlob['Inner Color'][1] / 255, 
            noiseBlob['Inner Color'][2] / 255)
      },
      stripes: {
        type: 'uInt',
        value: noiseBlob['Stripes']
      },
      pattern: {
        type: 'uInt',
        value: noiseBlob['Pattern']
      },
      stripeDensity: {
        type: 'f',
        value: noiseBlob['Stripe Density']
      },
      patternColor: {
        type: 'v3',
        value: new THREE.Vector3(
            noiseBlob['Pattern Color'][0] / 255, 
            noiseBlob['Pattern Color'][1] / 255, 
            noiseBlob['Pattern Color'][2] / 255)
      },
      stripeColor: {
        type: 'v3',
        value: new THREE.Vector3(
            noiseBlob['Stripe Color'][0] / 255, 
            noiseBlob['Stripe Color'][1] / 255, 
            noiseBlob['Stripe Color'][2] / 255)
      },
      patternDensity: {
        type: 'f',
        value: noiseBlob['Pattern Density']
      }
    },
    vertexShader: require('./shaders/ico-vert.glsl'),
    fragmentShader: require('./shaders/ico-frag.glsl')
  });

  // Create icosahedron
  var icosahedron = new THREE.IcosahedronBufferGeometry(0.8, 5);
  myIco = new THREE.Mesh(icosahedron, velvetMaterial);


// set camera position
  camera.position.set(1, 1, -100);
  camera.lookAt(new THREE.Vector3(0,0,0));

  // scene.add(adamCube);
  scene.add(myIco);

  // edit params and listen to changes like this
  // more information here: https://workshop.chromeexperiments.com/examples/gui/#1--Basic-Usage
  gui.add(camera, 'fov', 0, 180).onChange(function(newVal) {
    camera.updateProjectionMatrix();
  });

  gui.addColor(noiseBlob, 'Base Color').onChange(function (value) {
    myIco.material.uniforms.baseColor.value = new THREE.Vector3(value[0] / 255, value[1] / 255, value[2] / 255);
  });
  gui.addColor(noiseBlob, 'Outer Color').onChange(function (value) {
    myIco.material.uniforms.outerColor.value = new THREE.Vector3(value[0] / 255, value[1] / 255, value[2] / 255);
  });
  gui.addColor(noiseBlob, 'Inner Color').onChange(function (value) {
    myIco.material.uniforms.innerColor.value = new THREE.Vector3(value[0] / 255, value[1] / 255, value[2] / 255);
  });

  gui.add(noiseBlob, 'Stripes').onChange(function (value) {
    myIco.material.uniforms.stripes.value = value;
  });

  gui.add(noiseBlob, 'Stripe Density', 0, 1).onChange(function (value) {
    myIco.material.uniforms.stripeDensity.value = value;
  });
  gui.addColor(noiseBlob, 'Stripe Color').onChange(function (value) {
    myIco.material.uniforms.stripeColor.value = new THREE.Vector3(value[0] / 255, value[1] / 255, value[2] / 255);
  });

  gui.add(noiseBlob, 'Pattern').onChange(function (value) {
    myIco.material.uniforms.pattern.value = value;
  });

  gui.addColor(noiseBlob, 'Pattern Color').onChange(function (value) {
    myIco.material.uniforms.patternColor.value = new THREE.Vector3(value[0] / 255, value[1] / 255, value[2] / 255);
  });

  gui.add(noiseBlob, 'Pattern Density', 0, 1).onChange(function (value) {
    myIco.material.uniforms.patternDensity.value = value;
  }); 
}

var incr = 0.011721523423;
// called on frame updates
function onUpdate(framework) {
  if (myIco) {
    myIco.material.uniforms.time.value += incr;
    // console.log(myIco.material.uniforms.time.value);

  }
}

// when the scene is done initializing, it will call onLoad, then on frame updates, call onUpdate
Framework.init(onLoad, onUpdate);