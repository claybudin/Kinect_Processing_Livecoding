#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D sprite;

varying vec4 vertColor;
varying vec2 texCoord;

void main() {  
  vec4 color = texture2D(sprite, texCoord) * vertColor;
  gl_FragColor = color;
}


