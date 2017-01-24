
const THREE = require('three'); // older modules are imported like this. You shouldn't have to worry about this much
import Framework from './framework';

// var declared so in working material can make the object fluctuate depending on the ticked time
//    note: updated in the on Update method
var boolTime = 0;
var stepTime = 0.0;
var usingTime = 0.5;

var renderObj = {
  viewing: 0,
  vShade: './shaders/workingRef-vert.glsl',
  fShade: './shaders/workingRef-frag.glsl',
  onImg: 0,
  myImg: './gradient4.jpg'

};

/*********************/
/* OBJECTS FOR SCENE */
/*********************/

var box = new THREE.BoxGeometry(1, 1, 1);
var icosahedron = new THREE.IcosahedronGeometry(1, 5); //THREE.IcosahedronBufferGeometry(1, 0); //-HB

/*************/
/* MATERIALS */
/*************/

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

var workingMaterial = new THREE.ShaderMaterial({
  uniforms: {
    time: {
      type: "float",
      value: usingTime
    },
    image: { // Check the Three.JS documentation for the different allowed types and values
      type: "t", 
      value: THREE.ImageUtils.loadTexture(renderObj.myImg)
    }
  },
  vertexShader: require(renderObj.vShade),
  fragmentShader: require(renderObj.fShade)
}); //-HB


/***********/
/* ON LOAD */
/***********/
// called after the scene loads
function onLoad(framework) {
  var scene = framework.scene;
  var camera = framework.camera;
  var renderer = framework.renderer;
  var gui = framework.gui;
  var stats = framework.stats;

  // obj to step through for what is being visualized
  framework.currObj = 0;

  var obj = framework.currObj;

  // LOOK: the line below is synyatic sugar for the code above. Optional, but I sort of recommend it.
  // var {scene, camera, renderer, gui, stats} = framework; 

  /*****************************/
  /* PUTTING MATERIALS ON OBJS */
  /*****************************/

  //var adamCube = new THREE.Mesh(box, adamMaterial);
  //adamCube = new THREE.Mesh(box, workingMaterial); // -HB FOR TESTING
  var workingSphere = new THREE.Mesh(icosahedron, workingMaterial);

  /************************************/
  /* SET UP CAMERA AND SCENE TOGETHER */
  /************************************/

  // set camera position
  camera.position.set(1, 1, 2);
  camera.lookAt(new THREE.Vector3(0,0,0));

  // scene.add(adamCube);
  scene.add(workingSphere); //-HB

  gui.add(camera, 'fov', 0, 180).onChange(function(newVal) {
    camera.updateProjectionMatrix();
  });

  gui.add(renderObj, 'viewing', 0, 3).min(0).max(2).step(1).listen().onChange(function(newVal) {
    console.log('VIEWING OBJ CHANGED');
    console.log(renderObj.viewing);

      // setting up which material based on slider
    if (renderObj.viewing == 0) {
      // orig perlin with fire pulse sun
      renderObj.vShade = './shaders/workingRef-vert.glsl';
      renderObj.fShade = './shaders/workingRef-frag.glsl';
      console.log('viewing = 0, loading fire pulse sun');
    } else if (renderObj.viewing == 1) {
      // disco
      renderObj.vShade = './shaders/workingRef-vert_disco.glsl';
      renderObj.fShade = './shaders/workingRef-frag.glsl';
      console.log('viewing = 1, loading disco');
    } else if (renderObj.viewing == 2) {
      // blooping
      renderObj.vShade = './shaders/workingRef-vert_blooping.glsl';
      renderObj.fShade = './shaders/workingRef-frag.glsl';
      console.log('viewing = 3, loading blooping');
    }

    scene.remove(workingSphere);

    workingMaterial = new THREE.ShaderMaterial({
      uniforms: {
          time: {
            type: "float",
            value: usingTime
          },
          image: { // Check the Three.JS documentation for the different allowed types and values
            type: "t", 
            value: THREE.ImageUtils.loadTexture(renderObj.myImg)
          }
        },
        vertexShader: require(renderObj.vShade),
        fragmentShader: require(renderObj.fShade)
      }); //-HB

    // workingMaterial.vertexShader = require(renderObj.vShade);
    // workingMaterial.fragmentShader = require(renderObj.fShade);
    // workingMaterial.uniforms.image.value = THREE.ImageUtils.loadTexture(renderObj.myImg);
    
    workingSphere = new THREE.Mesh(icosahedron, workingMaterial);
    console.log(workingSphere);

    scene.add(workingSphere);
  });

  gui.add(renderObj, 'onImg', 0, 4).min(0).max(4).step(1).listen().onChange(function(newVal) {
    console.log('ON IMG CHANGED');
    console.log(renderObj.onImg);

      // setting up which material based on slider
    if (renderObj.onImg == 0) {
      renderObj.myImg = './gradient1.jpg';
      console.log('img = 0');
    } else if (renderObj.onImg == 1) {
      renderObj.myImg = './gradient2.jpg';
      console.log('img = 1');
    } else if (renderObj.onImg == 2) {
      renderObj.myImg = './gradient3.jpg';
      console.log('img = 2');
    } else if (renderObj.onImg == 3) {
      renderObj.myImg = './gradient4.jpg';
      console.log('img = 3');
    } else {
      renderObj.myImg = './gradient5.jpg';
      console.log('img = 4');
    }

    scene.remove(workingSphere);

    workingMaterial = new THREE.ShaderMaterial({
      uniforms: {
          time: {
            type: "float",
            value: usingTime
          },
          image: { // Check the Three.JS documentation for the different allowed types and values
            type: "t", 
            value: THREE.ImageUtils.loadTexture(renderObj.myImg)
          }
        },
        vertexShader: require(renderObj.vShade),
        fragmentShader: require(renderObj.fShade)
      }); //-HB

    // workingMaterial.vertexShader = require(renderObj.vShade);
    // workingMaterial.fragmentShader = require(renderObj.fShade);
    // workingMaterial.uniforms.image.value = THREE.ImageUtils.loadTexture(renderObj.myImg);
    
    workingSphere = new THREE.Mesh(icosahedron, workingMaterial);
    console.log(workingSphere);

    scene.add(workingSphere);
  });
  
}

/*************/
/* ON UPDATE */
/*************/
// called on frame updates
function onUpdate(framework) {
  var count = 60.0

  if (usingTime < 0.0 || usingTime > count) {
    boolTime = !boolTime;
  }

  stepTime += 1.0;
  if (stepTime % 10.0 == 0) {
    if (boolTime) {
      usingTime ++;
    } else {
      usingTime --;
    }
  }

  workingMaterial.uniforms.time.value = usingTime;

}

// when the scene is done initializing, it will call onLoad, then on frame updates, call onUpdate
Framework.init(onLoad, onUpdate);