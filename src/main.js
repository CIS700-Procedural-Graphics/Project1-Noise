
const THREE = require('three'); // older modules are imported like this. You shouldn't have to worry about this much
import Framework from './framework'

var d_orig = new Date();
var d2 = d_orig.getSeconds();
var d3 = d_orig.getSeconds();
var count = 0.0;
var flag = false;

var settings = {
    strength: 3.0,
    colors: 1.0,
    uv_x: 0.0,
    uv_y: 0.0,
    persistence: 0.8,
    num_octaves: 4.0
}

var color_Material = new THREE.ShaderMaterial({
  uniforms: {
    image1: { // Check the Three.JS documentation for the different allowed types and values
      type: "t",
      value: THREE.ImageUtils.loadTexture('./red_r.png')
      //value: THREE.ImageUtils.loadTexture('./blue gradient.png')
    },
    image2: { // Check the Three.JS documentation for the different allowed types and values
      type: "t",
      value: THREE.ImageUtils.loadTexture('./blue_gradient.jpg')
      //value: THREE.ImageUtils.loadTexture('./blue gradient.png')
    },
    image3: { // Check the Three.JS documentation for the different allowed types and values
      type: "t",
      value: THREE.ImageUtils.loadTexture('./adam.jpg')
      //value: THREE.ImageUtils.loadTexture('./blue gradient.png')
    },
    time: {
      type: "f",
      value: 0.0
    },
    uv_offset: {
      type: "v2",
      value: new THREE.Vector2( 0, 0 ),
    },
    persistence: {
      type: "f",
      value: 0.8,
    },
    num_octaves: {
      type: "f",
      value: 4.0,
    },
    strength: {
      type: "f",
      value: 1.0
    },
    flag_color: {
      type: "f",
      value: 1.0
    }
  },
  vertexShader: require('./shaders/Noise-vert.glsl'),
  fragmentShader: require('./shaders/Noise-frag.glsl')
});

// called after the scene loads
function onLoad(framework)
{
  var scene = framework.scene;
  var camera = framework.camera;
  var renderer = framework.renderer;
  var gui = framework.gui;
  var stats = framework.stats;

  // LOOK: the line below is synyatic sugar for the code above. Optional, but I sort of recommend it.
  // var {scene, camera, renderer, gui, stats} = framework;

  // // initialize a simple box and material
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

  // // instantiate a loader
  // var loader = new THREE.JSONLoader();
  //
  // // load a resource
  // loader.load(
  // 	// resource URL
  // 	'./cow.json',
  // 	// Function when resource is loaded
  // 	function ( geometry, materials ) {
  // 		//var material = new THREE.MultiMaterial( color_Material );
  // 		var cow_object = new THREE.Mesh( geometry, color_Material );
  // 		scene.add( cow_object );
  // 	}
  // );

  var sphereGeom = new THREE.IcosahedronGeometry(0.2, 5);
  var sphere = new THREE.Mesh( sphereGeom, color_Material );

  // set camera position
  camera.position.set(1, 1, 20);
  camera.lookAt(new THREE.Vector3(0,0,0));

  //scene.add(adamCube);
  scene.add( sphere );

  // edit params and listen to changes like this
  // more information here: https://workshop.chromeexperiments.com/examples/gui/#1--Basic-Usage
  gui.add(camera, 'fov', 0, 180).onChange(function(newVal)
  {
    camera.updateProjectionMatrix();
  });
  gui.add(camera, 'aspect', 1, 10).onChange(function(newVal)
  {
    camera.updateProjectionMatrix();
  });
  gui.add(settings, 'strength', 0, 10).onChange(function(newVal)
  {
    settings.strength = newVal;
  });
  gui.add(settings, 'colors', 1, 4).onChange(function(newVal)
  {
    settings.colors = newVal;
  });
  gui.add(settings, 'persistence', 0.0, 1.0).onChange(function(newVal)
  {
    settings.persistence = newVal;
  });
  gui.add(settings, 'num_octaves', 1.0, 15.0).onChange(function(newVal)
  {
    settings.num_octaves = newVal;
  });
}

// called on frame updates
function onUpdate(framework)
{
  settings.uv_x += 0.01;
  settings.uv_y += 0.01;

  if(settings.uv_x > 1.0)
  {
    settings.uv_x = settings.uv_x - 1.0;
  }
  if(settings.uv_y > 1.0)
  {
    settings.uv_y = settings.uv_y - 1.0;
  }

  count++;
  color_Material.uniforms.uv_offset.value = new THREE.Vector2(settings.uv_x, settings.uv_y);
  //console.log(color_Material.uniforms.uv_offset.value);
  color_Material.uniforms.persistence.value = settings.persistence;
  color_Material.uniforms.num_octaves.value = settings.num_octaves;
  color_Material.uniforms.flag_color.value = settings.colors;
  color_Material.uniforms.time.value = count;
  color_Material.uniforms.strength.value = settings.strength;
}

// when the scene is done initializing, it will call onLoad, then on frame updates, call onUpdate
Framework.init(onLoad, onUpdate);
