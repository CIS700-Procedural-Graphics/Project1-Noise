import {vec3, vec4} from 'gl-matrix';
import Drawable from '../rendering/gl/Drawable';
import {gl} from '../globals';

class Cube extends Drawable {
  indices: Uint32Array;
  positions: Float32Array;
  normals: Float32Array;
  center: vec4;

  constructor(center: vec3) {
    super(); // Call the constructor of the super class. This is required.
    this.center = vec4.fromValues(center[0], center[1], center[2], 1);

  }

  create() {

      let indices: Array<number>;
      indices = [];

      for(let i of [0, 1, 2, 3, 4, 5]){
          let si = i*4
          indices = indices.concat([si, si+1, si+2]);
          indices = indices.concat([si, si+2, si+3]);
      }

      console.log(indices)

  this.indices = new Uint32Array(indices);
  this.normals = new Float32Array([
    0, 0, 1, 0,
    0, 0, 1, 0,
    0, 0, 1, 0,
    0, 0, 1, 0,
      0, 0, -1, 0,
      0, 0, -1, 0,
      0, 0, -1, 0,
      0, 0, -1, 0,
      -1, 0, 0, 0,
      -1, 0, 0, 0,
      -1, 0, 0, 0,
      -1, 0, 0, 0,
      1, 0, 0, 0,
      1, 0, 0, 0,
      1, 0, 0, 0,
      1, 0, 0, 0,
      0, 1, 0, 0,
      0, 1, 0, 0,
      0, 1, 0, 0,
      0, 1, 0, 0,
      0, -1, 0, 0,
      0, -1, 0, 0,
      0, -1, 0, 0,
      0, -1, 0, 0
  ]);
  this.positions = new Float32Array([
      -1, -1, 1, 1,
      1, -1, 1, 1,
      1, 1, 1, 1,
      -1, 1, 1, 1,

      -1, -1, -1, 1,
      1, -1, -1, 1,
      1, 1, -1, 1,
      -1, 1, -1, 1,
      //
      -1, -1, -1, 1,
      -1, -1, 1, 1,
      -1, 1, 1, 1,
      -1, 1, -1, 1,
      //
      1, -1, 1, 1,
      1, -1, -1, 1,
      1, 1, -1, 1,
      1, 1, 1, 1,
      //
      -1, 1, -1, 1,
      -1, 1, 1, 1,
      1, 1, 1, 1,
      1, 1, -1, 1,
      //
      1, -1, -1, 1,
      1, -1, 1, 1,
      -1, -1, 1, 1,
      -1, -1, -1, 1,

      // 0, 0, 0, 0,
      // 0, 0, 0, 0,
      // 0, 0, 0, 0,
      // 0, 0, 0, 0,

      // 0, 0, 0, 0,
      // 0, 0, 0, 0,
      // 0, 0, 0, 0,
      // 0, 0, 0, 0,

      // 0, 0, 0, 0,
      // 0, 0, 0, 0,
      // 0, 0, 0, 0,
      // 0, 0, 0, 0,

      // 0, 0, 0, 0,
      // 0, 0, 0, 0,
      // 0, 0, 0, 0,
      // 0, 0, 0, 0,

      // 0, 0, 0, 0,
      // 0, 0, 0, 0,
      // 0, 0, 0, 0,
      // 0, 0, 0, 0,
  ]);


    this.generateIdx();
    this.generatePos();
    this.generateNor();

    this.count = this.indices.length;
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.bufIdx);
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, this.indices, gl.STATIC_DRAW);

    gl.bindBuffer(gl.ARRAY_BUFFER, this.bufNor);
    gl.bufferData(gl.ARRAY_BUFFER, this.normals, gl.STATIC_DRAW);

    gl.bindBuffer(gl.ARRAY_BUFFER, this.bufPos);
    gl.bufferData(gl.ARRAY_BUFFER, this.positions, gl.STATIC_DRAW);

    console.log(`Created cube`);
  }
};

export default Cube;
