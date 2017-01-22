
const THREE = require('three'); // older modules are imported like this. You shouldn't have to worry about this much
import Framework from './framework'
import Noise from './noise'
import {other} from './noise'

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
  var icosahedron = new THREE.IcosahedronGeometry(1, 0);
  icosahedron.computeFaceNormals();
  icosahedron.computeVertexNormals();

  var vertexOffsets = {};
  var vertexNormals = {};
  for (var i = 0; i < icosahedron.faces.length; i++) {
    var vertices = icosahedron.vertices;
    var face = icosahedron.faces[i];
    console.log(face);
    var v1 = vertices[face.a];
    var v2 = vertices[face.b];
    var v3 = vertices[face.c];

    var vertexNormal1 = face.vertexNormals[0];
    var vertexNormal2 = face.vertexNormals[1];
    var vertexNormal3 = face.vertexNormals[2];

    vertexNormals[face.a] = vertexNormal1;
    vertexNormals[face.b] = vertexNormal2;
    vertexNormals[face.c] = vertexNormal3;

    var offset1 = Noise.generateMultiOctaveNoise(v1.x, v1.y, v1.z, 1); 
    var offset2 = Noise.generateMultiOctaveNoise(v2.x, v2.y, v2.z, 1); 
    var offset3 = Noise.generateMultiOctaveNoise(v3.x, v3.y, v3.z, 1); 

    vertexOffsets[face.a] = offset1;
    vertexOffsets[face.b] = offset2;
    vertexOffsets[face.c] = offset3;
  }

  console.log(vertexOffsets);
  console.log(vertexNormals);
  for (var j = 0; j < icosahedron.vertices.length; j++) {
    console.log(vertexOffsets[j]);
    var offset = vertexOffsets[j];
    var normal = vertexNormals[j];
    //normal = normal.multiplyScalar(-1.0);

    var offsetAlongNormal = normal.multiplyScalar(offset);

    icosahedron.vertices[j] = icosahedron.vertices[j].add(offsetAlongNormal);
  }
  icosahedron.verticesNeedUpdate = true;


  var myMaterial = new THREE.ShaderMaterial({
    vertexShader: require('./shaders/my-vert.glsl'),
    fragmentShader: require('./shaders/my-frag.glsl')
  });

  var meshMaterial = new THREE.MeshNormalMaterial();

  var texturedIcosahedron = new THREE.Mesh(icosahedron, meshMaterial);
  var helper = new THREE.VertexNormalsHelper(texturedIcosahedron);

  // set camera position
  camera.position.set(1, 1, 2);
  camera.lookAt(new THREE.Vector3(0,0,0));

  scene.add(texturedIcosahedron);
  scene.add(helper);

  // edit params and listen to changes like this
  // more information here: https://workshop.chromeexperiments.com/examples/gui/#1--Basic-Usage
  gui.add(camera, 'fov', 0, 180).onChange(function(newVal) {
    camera.updateProjectionMatrix();
  });
}

// called on frame updates
function onUpdate(framework) {
  // console.log(`the time is ${new Date()}`);
}

// when the scene is done initializing, it will call onLoad, then on frame updates, call onUpdate
Framework.init(onLoad, onUpdate);
