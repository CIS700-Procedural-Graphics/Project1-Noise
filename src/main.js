
const THREE = require('three'); // older modules are imported like this. You shouldn't have to worry about this much
import Framework from './framework'
import Noise from './noise'
import {other} from './noise'

// called after the scene loads
function onLoad(framework) {
  let {scene, camera, renderer, gui, stats} = framework;

  let uniforms = {
    time: {
      type: 'float',
      value: framework.time
    },
    octaves: {
      type: 'int',
      value: 1
    },
    magnitude: {
      type: 'float',
      value: 1.0
    },
    rate: {
      type: 'float',
      value: 1.0
    },
    persistence: {
      type: 'float',
      value: 0.5
    },
    image: {
      type: 't',
      value: THREE.ImageUtils.loadTexture('./img/marble.jpg')
    }
  };

  let material = new THREE.ShaderMaterial({
    uniforms: uniforms,
    vertexShader: require('./shaders/vert.glsl'),
    fragmentShader: require('./shaders/frag.glsl')
  });
  let icosahedron = new THREE.IcosahedronBufferGeometry(1, 6);
  let mesh = new THREE.Mesh(icosahedron, material);

  // set camera position
  camera.position.set(1, 1, 2);
  camera.lookAt(new THREE.Vector3(0,0,0));

  scene.add(mesh);

  gui.add(camera, 'fov', 0, 180).onChange(function(newVal) {
    camera.updateProjectionMatrix();
  });

  let guiVars = {
    'octaves': 1,
    'magnitude': 1.0,
    'rate': 1.0,
    'persistence': 0.5
  };
  gui.add(guiVars, 'octaves', 1, 10).step(1).onFinishChange((newVal) => {
    scene.remove(icosahedron);
    icosahedron = new THREE.IcosahedronGeometry(1, newVal);
    mesh = new THREE.Mesh(icosahedron, material);
    scene.add(mesh);
    guiVars.octaves = newVal;

  });

  gui.add(guiVars, 'magnitude', 1.0, 10.0).onFinishChange((newVal) => {
    guiVars.magnitude = newVal;
  });

  gui.add(guiVars, 'rate', 0.0, 10.0).onFinishChange((newVal) => {
    guiVars.rate = newVal;
  });

  gui.add(guiVars, 'persistence', 0.0, 10.0).onFinishChange((newVal) => {
    guiVars.persistence = newVal;
  });

  framework.guiVars = guiVars;
}

// called on frame updates
function onUpdate(framework) {
  framework.time += 1;
  framework.scene.children.forEach((child) => {
    let uniforms = child.material.uniforms;
    let vars = framework.guiVars;

    uniforms.time.value++;
    uniforms.magnitude.value = vars.magnitude;
    uniforms.rate.value = vars.rate;
    uniforms.persistence.value = vars.persistence
  });
}

Framework.init(onLoad, onUpdate);
