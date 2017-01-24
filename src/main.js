
const THREE = require('three'); // older modules are imported like this. You shouldn't have to worry about this much
import Framework from './framework'

var currTime = 0;
var mouse;

var input = {
  amplitude: 40.0,
  mouse_interactivity: false
};

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
      },
      inclination: {
        type: "v3",
        value: new THREE.Vector3(0, 0, 0)
      }
    },
    vertexShader: require('./shaders/my-vert.glsl'),
    fragmentShader: require('./shaders/my-frag.glsl')
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
  gui.add(input, 'amplitude', 0, 50).onChange(function(newVal) {
    myMaterial.uniforms.amplitude.value = input.amplitude;
    renderer.render(scene, camera);
  });

  // add a checkbox to toggle mouse interactivity
  gui.add(input, "mouse_interactivity").onChange(function(newVal) {
    if (!newVal)
    {
      myMaterial.uniforms.inclination.value = new THREE.Vector3(0, 0, 0);
    }
  });

  // change inclination based on mouse click position
  window.addEventListener('mousemove', function(event) {

    if (input.mouse_interactivity)
    {
      // from http://stackoverflow.com/questions/13055214/mouse-canvas-x-y-to-three-js-world-x-y-z
      var vector = new THREE.Vector3((event.clientX / window.innerWidth) * 2 - 1, 
        - (event.clientY / window.innerHeight) * 2 + 1, 0.5);
      vector.unproject(camera);
      var dir = vector.sub(camera.position).normalize();
      var distance = - camera.position.z / dir.z;
      var pos = camera.position.clone().add(dir.multiplyScalar(distance));

      myMaterial.uniforms.inclination.value = pos;
      renderer.render(scene, camera);
    }
  });
}

// called on frame updates
function onUpdate(framework) {
  currTime += 0.2;
  myMaterial.uniforms.time.value = currTime;
}

// when the scene is done initializing, it will call onLoad, then on frame updates, call onUpdate
Framework.init(onLoad, onUpdate);