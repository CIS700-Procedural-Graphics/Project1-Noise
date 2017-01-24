varying vec2 new_uv;
varying vec3 vnor;
uniform sampler2D image1;
uniform sampler2D image2;
uniform sampler2D image3;
uniform float flag_color;

void main()
{
  if(flag_color <= 1.0)
  {
    vec4 texColor = texture2D( image1, new_uv );
    gl_FragColor = vec4( texColor.rgb, 1.0 );
  }
  else if(flag_color <= 2.0)
  {
    vec4 texColor = texture2D( image2, new_uv );
    gl_FragColor = vec4( texColor.rgb, 1.0 );
  }
  else if(flag_color <= 3.0)
  {
    gl_FragColor = vec4(vnor, 1.0);
  }
  else
  {
    vec4 texColor = texture2D( image3, new_uv );
    gl_FragColor = vec4( texColor.rgb, 1.0 );
  }
}
