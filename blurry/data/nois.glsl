


float rand(vec2 co){
  return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

uniform sampler2D textureSampler;
uniform float ammount;

void main(){

  gl_FragColor = rand(vertTexcoord.st);
}
