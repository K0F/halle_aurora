/**
 *   Halle interactive exhibition
 *   by kof 2013 
 */

import ddf.minim.*;

Minim minim;
AudioInput in;


float FADEOUT = 200.0;

float BSIZE,SIGMA,ALPHA;
float maxval,lmaxval;

float TRESHOLD = 0.02;
float SENSITIVITY = 4.0;

boolean peaks = false;

PShader blur;
PShader nois;
PGraphics src;
PGraphics pass1, pass2;

PImage img[];
int slide = 0;

void setup() {

  size(1280,720, P2D);

  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, 256);

  in.mute();

  frameRate(50);
  noCursor();

  img = new PImage[27];
  for(int i = 0 ; i < img.length;i++){
    img[i] = loadImage(nf(i,2)+".jpg");
  }

  blur = loadShader("frag.glsl");
  blur.set("blurSize", 10);
  blur.set("sigma", 5.0f);  

  nois = loadShader("nois.glsl");

  src = createGraphics(width, height, P2D); 

  pass1 = createGraphics(width, height, P2D);
  pass1.noSmooth();  

  pass2 = createGraphics(width, height, P2D);
  pass2.noSmooth();


  src.beginDraw();
  //  src.background(255);
  src.endDraw();
  refresh();

  BSIZE = SIGMA = ALPHA = 0;
}

void refresh(){

  src.beginDraw();
  //src.imageMode(CENTER);
  src.image(img[slide],0,0,width,height);
  src.noTint();
  src.endDraw();
}

void draw() {

  if(frameCount%500==0)
    forward();

  background(255);



  maxval = maxval;
  maxval = 0;
  for(int i = 0; i < in.bufferSize() - 1; i++)
  {
    maxval = max(maxval,(in.left.get(i)+in.right.get(i))*SENSITIVITY);
  }

  if((maxval*50.0)>BSIZE){
    BSIZE += (constrain(maxval*50.0,0,50)-BSIZE)/1.5;
    SIGMA += (constrain(maxval*25.0,0,25)-SIGMA)/1.5;
    ALPHA += (constrain(maxval/2.0,0,1)-ALPHA)/1.5;
  }else{
    BSIZE += ((maxval*50.0)-BSIZE)/FADEOUT;
    SIGMA += ((maxval*25.0)-SIGMA)/(FADEOUT*1.1);
    ALPHA += (constrain(maxval/2.0,0,1)-ALPHA)/(FADEOUT*1.3);
  }




  ///////
  int am = (int)BSIZE;//(int)(noise(frameCount/30.0)*10);
  float sigma = SIGMA;//(noise(frameCount/30.0)*5);
  float time = frameCount;
  float alpha = ALPHA;//(noise(frameCount/30.0))/4.0; 
  ////

  blur.set("blurSize", am);
  blur.set("sigma", sigma);  
  nois.set("time",frameCount);
  nois.set("alpha",alpha);



  // Applying the blur shader along the vertical direction   
  blur.set("horizontalPass", 0);
  pass1.beginDraw();            
  pass1.noTint();
  pass1.shader(blur);  
  pass1.image(src, 0, 0);
  pass1.endDraw();

  // Applying the blur shader along the horizontal direction      
  blur.set("horizontalPass", 1);
  pass2.beginDraw();            
  pass2.shader(blur);  
  pass2.tint(255,10);
  pass2.image(pass1, 0, 0);
  pass2.endDraw();    

  noTint();
  image(pass2, ((noise(frameCount/9.0,0)-0.5)*3.0), ((noise(0,frameCount/9.0)-0.5)*3.0));

  if(peaks){
    println(maxval);
    resetShader();
    stroke(#ffcc00);
    for(int i = 0; i < in.bufferSize() - 1; i++)
    {
      line(i, 50 + in.left.get(i)*50, i+1, 50 + in.left.get(i+1)*50);
      line(i, 150 + in.right.get(i)*50, i+1, 150 + in.right.get(i+1)*50);
    }   
  }

  if(ALPHA>0.01){
    shader(nois);
    rect(0,0,width,height);
  }

  resetShader();
  pushStyle();
  strokeWeight(5);
  noFill();
  stroke(0);
  rect(0,0,width,height);
  popStyle();
}

void forward() {
  slide++;
  slide=slide%img.length;
  refresh();
}

void stop()
{

  in.close();
  minim.stop();

  super.stop();
}
