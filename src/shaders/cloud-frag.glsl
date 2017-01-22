varying float noise;
uniform float bright;

void main() {

  vec3 color;

  //all the colors that will be used in the gradient, multiplied by bright, which will darken or brighten the colors when less than and greater than 1	
  vec3 white = vec3(1.0, 1.0, 1.0) * bright;
  vec3 yellow = vec3(1.0, 1.0, 0.0) * bright; 
  vec3 lightBlue = vec3((100.0/255.0), (149.0/255.0), (237.0/255.0)) * bright; 
  vec3 lavendar = vec3((230.0/255.0), (230.0/255.0), (250.0/255.0)) * bright;
  vec3 purple = vec3((123.0/255.0), (104.0/255.0), (238.0/255.0)) * bright;

  //roughly every difference in the offset of 0.28 within the range of -0.6 to 0.8, the color changes and blends between eahc color through linear interpolation
  if(noise < -0.6)
  {
  		color = yellow;
  }
  else if(noise <= -0.32)
  {
  		float t = (-0.32 - noise)/0.28;
  		color = (1.0-t)*(white) + t*(yellow);
  }
  else if(noise <= -0.04)
  {
  		float t = (-0.04 - noise)/0.28;
  		color = (1.0-t)*(lightBlue) + t*(white);
  }
  else if(noise <= 0.24)
  {
  		float t = (0.24 - noise)/0.28;
  		color = (1.0-t)*(purple) + t*(lightBlue);
  }
  else if(noise <= 0.52)
  {
  		float t = (0.52 - noise)/0.28;
  		color = (1.0-t)*(lavendar) + t*(purple);
  }
  else if(noise <= 0.8)
  {
  		float t = (0.8 - noise)/0.28;
  		color = (1.0-t)*(white) + t*(lavendar);
  }
  else 
  {
  		color = white;
  }

  gl_FragColor = vec4( color.rgb, 1.0 );

}