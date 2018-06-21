
// runs at start of sketch
void setup ()  {
  size(600,600);
  frameRate(30);
}

// runs every frame
void draw ()  {
  background(180,180,0);
  
  noStroke();
  fill(255,0,0);
  ellipse(200+100*sin(frameCount*.05), 46, 55, 55);
}
