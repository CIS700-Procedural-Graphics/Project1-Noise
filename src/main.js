
const THREE = require('three'); // older modules are imported like this. You shouldn't have to worry about this much
import Framework from './framework'


//PROJ 1: NOISE
//Using the provided framework code, create a new three.js material which references a vertex and fragment shader.
//Look at the adamMaterial for reference. It should reference at least one uniform variable (you'll need a time variable to animate your mesh later on).

//Create an icosahedron, instead of the default cube geometry provided in the scene.
//Test your shader setup by applying the material to the icosahedron and color the mesh in the fragment shader using the normals' XYZ components as RGB.

//Note that three.js automatically injects several uniform and attribute variables into your shaders by default;
//they are listed in the documentation for three.js's WebGLProgram class.


var time_update = 0;

//adding new slider variables
var total_octaves = 8;
var max_persistence = 1.0;

var start = Date.now();

//adding new slider variables
var p = {
  explode : 20.0,
  octaves : 1.0,
  persistence : 0.25
}

var icosahedron_geo = new THREE.IcosahedronGeometry(0.25, 5);//5); //making the second var 1 adds more verts and makes it more spherical
icosahedron_geo.translate(2, 0, -1);

var icosahedronMaterial = new THREE.ShaderMaterial({
  uniforms: {
    time: {
      type: "float",
      value : time_update
    },
    num_octaves: {
      type: "float",
      value : total_octaves
    },
    perlin_persistence: {
      type: "float",
      value : max_persistence
    }

    //to add a slider that'll change the mesh's texture
    //add multiple images with their respective file names as uniform variables
    //have a flag variable
  },

  vertexShader: require('./shaders/icosahedron-vert.glsl'),
  fragmentShader: require('./shaders/icosahedron-frag.glsl')
});
var icosahedronMesh = new THREE.Mesh(icosahedron_geo, icosahedronMaterial);




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
  }); //end adam material

  var adamCube = new THREE.Mesh(box, adamMaterial);


  // set camera position
  camera.position.set(1, 1, 2);
  camera.lookAt(new THREE.Vector3(0,0,0));

  scene.add(adamCube);

  //PROJ 1: NOISE
  scene.add(icosahedronMesh);


//SLIDERS ON GUI

  // edit params and listen to changes like this
  // more information here: https://workshop.chromeexperiments.com/examples/gui/#1--Basic-Usage
  gui.add(camera, 'fov', 0, 180).onChange(function(newVal) {
    camera.updateProjectionMatrix();
  });

  gui.add(p, 'explode', 0, 100).onChange(function(newVal) {
    p.explode = newVal;
  });

  gui.add(p, 'octaves', 1, total_octaves).onChange(function(newVal) {
    p.octaves = newVal;
  });

  gui.add(p, 'persistence', 0.25, max_persistence).onChange(function(newVal) {
    p.octaves = newVal;
  });

  //CLASS NOTES: get the camera object and bind to its fov attribute

  //CLASS NOTES: for homework, we'd want to update shader uniform variables
}

//

// called on frame updates
function onUpdate(framework) {
  console.log(`the time is ${new Date()}`);

  time_update = (Date.now() - start) * 0.00025;

  //adding the changing vars for the icosahedron material 
  icosahedronMaterial.uniforms.time.value = time_update;
  icosahedronMaterial.uniforms.num_octaves.value = p.octaves;
  icosahedronMaterial.uniforms.perlin_persistence.value = p.persistence;
}

// when the scene is done initializing, it will call onLoad, then on frame updates, call onUpdate
Framework.init(onLoad, onUpdate);
