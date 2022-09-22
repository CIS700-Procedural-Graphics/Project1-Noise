import {vec3, vec4} from 'gl-matrix';
const Stats = require('stats-js');
import * as DAT from 'dat.gui';
import Icosphere from './geometry/Icosphere';
import Square from './geometry/Square';
import OpenGLRenderer from './rendering/gl/OpenGLRenderer';
import Camera from './Camera';
import {setGL} from './globals';
import ShaderProgram, {Shader} from './rendering/gl/ShaderProgram';
import Cube from "./geometry/Cube";

// Define an object with application parameters and button callbacks
// This will be referred to by dat.GUI's functions that add GUI elements.
const defaultColor1: Array<number> = [180, 150, 150, 1];
const defaultColor2: Array<number> = [255, 0, 0, 1];
const defaultColor3: Array<number> = [0, 0, 255, 1];
const defaultColor4: Array<number> = [0, 255, 0, 1];
const defaultN_octaves: number = 7.0;
const defaultPersistance: number = 4.0;
const defaultLattice_spacing_mod: number = 9.0;


const controls = {
  tesselations: 5,
  'Load Scene': loadScene, // A function pointer, essentially,
  color1: defaultColor1,
  color2: defaultColor2,
  color3: defaultColor3,
  color4: defaultColor4,
  n_octaves: defaultN_octaves,
  persistance: defaultPersistance,
  lattice_spacing_mod: defaultLattice_spacing_mod
};


let icosphere: Icosphere;
let square: Square;
let cube: Cube;
let prevTesselations: number = 5;
let prevColor1: Array<number> = defaultColor1;
let prevColor2: Array<number> = defaultColor2;
let prevColor3: Array<number> = defaultColor3;
let prevColor4: Array<number> = defaultColor4;
let prevN_octaves: number = defaultN_octaves;
let prevPersistance: number = defaultPersistance;
let prevLattice_spacing_mod: number = defaultLattice_spacing_mod;

let time: number = 0.0;

function loadScene() {
  icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, controls.tesselations);
  icosphere.create();
  // square = new Square(vec3.fromValues(0, 0, 0));
  // square.create();
  // cube = new Cube(vec3.fromValues(0, 0, 0));
  // cube.create();
}

function main() {
  // Initial display for framerate
  const stats = Stats();
  stats.setMode(0);
  stats.domElement.style.position = 'absolute';
  stats.domElement.style.left = '0px';
  stats.domElement.style.top = '0px';
  document.body.appendChild(stats.domElement);

  // Add controls to the gui
  const gui = new DAT.GUI();
  gui.add(controls, 'tesselations', 0, 8).step(1);
  gui.add(controls, 'Load Scene');
  gui.addColor(controls, 'color1');
  gui.addColor(controls, 'color2');
  gui.addColor(controls, 'color3');
  gui.addColor(controls, 'color4');
  gui.add(controls, 'n_octaves', 1, 14).step(1);
  gui.add(controls, 'persistance', 1, 10,0).step(0.1);
  gui.add(controls, 'lattice_spacing_mod', 1, 10,0).step(0.1);

  // get canvas and webgl context
  const canvas = <HTMLCanvasElement> document.getElementById('canvas');
  const gl = <WebGL2RenderingContext> canvas.getContext('webgl2');
  if (!gl) {
    alert('WebGL 2 not supported!');
  }
  // `setGL` is a function imported above which sets the value of `gl` in the `globals.ts` module.
  // Later, we can import `gl` from `globals.ts` to access it
  setGL(gl);

  // Initial call to load scene
  loadScene();

  const camera = new Camera(vec3.fromValues(0, 0, 5), vec3.fromValues(0, 0, 0));

  const renderer = new OpenGLRenderer(canvas);
  renderer.setClearColor(0.2, 0.2, 0.2, 1);
  gl.enable(gl.DEPTH_TEST);

  const lambert = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/lambert-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/lambert-frag.glsl')),
  ]);
  lambert.setUnifVec3(vec3.fromValues(defaultColor1[0]/255.0, defaultColor1[1]/255.0, defaultColor1[2]/255.0), 'unifColor1');
  lambert.setUnifVec3(vec3.fromValues(defaultColor2[0]/255.0, defaultColor2[1]/255.0, defaultColor2[2]/255.0), 'unifColor2');
  lambert.setUnifVec3(vec3.fromValues(defaultColor3[0]/255.0, defaultColor3[1]/255.0, defaultColor3[2]/255.0), 'unifColor3');
  lambert.setUnifVec3(vec3.fromValues(defaultColor4[0]/255.0, defaultColor4[1]/255.0, defaultColor4[2]/255.0), 'unifColor4');
  lambert.setFloat(defaultN_octaves, 'unifN_octaves');
  lambert.setFloat(defaultPersistance * 0.1, 'unifPersistance');
  lambert.setFloat(defaultLattice_spacing_mod * 0.1, 'unifLattice_spacing_mod');

  // This function will be called every frame
  function tick() {


    camera.update();
    stats.begin();
    gl.viewport(0, 0, window.innerWidth, window.innerHeight);
    renderer.clear();
    if(controls.color1 != prevColor1){
      prevColor1 = controls.color1;
      lambert.setUnifVec3(vec3.fromValues(prevColor1[0]/255.0, prevColor1[1]/255.0, prevColor1[2]/255.0), 'unifColor1');
    }
    if(controls.color2 != prevColor2){
      prevColor2 = controls.color2;
      lambert.setUnifVec3(vec3.fromValues(prevColor2[0]/255.0, prevColor2[1]/255.0, prevColor2[2]/255.0), 'unifColor2');
    }
    if(controls.color3 != prevColor3){
      prevColor3 = controls.color3;
      lambert.setUnifVec3(vec3.fromValues(prevColor3[0]/255.0, prevColor3[1]/255.0, prevColor3[2]/255.0), 'unifColor3');
    }
    if(controls.color4 != prevColor4){
      prevColor4 = controls.color4;
      lambert.setUnifVec3(vec3.fromValues(prevColor4[0]/255.0, prevColor4[1]/255.0, prevColor4[2]/255.0), 'unifColor4');
    }

    if(controls.n_octaves != prevN_octaves){
      prevN_octaves = controls.n_octaves;
      lambert.setFloat(prevN_octaves, 'unifN_octaves');
    }
    if(controls.persistance != prevPersistance){
      prevPersistance = controls.persistance;
      lambert.setFloat(prevPersistance * 0.1, 'unifPersistance');
    }
    if(controls.lattice_spacing_mod != prevLattice_spacing_mod){
      prevLattice_spacing_mod = controls.lattice_spacing_mod;
      lambert.setFloat(prevLattice_spacing_mod * 0.1, 'unifLattice_spacing_mod');
    }

    if(controls.tesselations != prevTesselations)
    {
      prevTesselations = controls.tesselations;
      icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, prevTesselations);
      icosphere.create();
    }

    time += 0.01;
    lambert.setTime(time);
    renderer.render(camera, lambert, [
      icosphere,
      // square,
      // cube
    ]);
    stats.end();

    // Tell the browser to call `tick` again whenever it renders a new frame
    requestAnimationFrame(tick);
  }

  window.addEventListener('resize', function() {
    renderer.setSize(window.innerWidth, window.innerHeight);
    camera.setAspectRatio(window.innerWidth / window.innerHeight);
    camera.updateProjectionMatrix();
  }, false);

  renderer.setSize(window.innerWidth, window.innerHeight);
  camera.setAspectRatio(window.innerWidth / window.innerHeight);
  camera.updateProjectionMatrix();

  // Start the render loop
  tick();
}

main();
