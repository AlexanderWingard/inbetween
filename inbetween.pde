import processing.video.*;
import TUIO.*;
Movie myMovie;
TuioProcessing tuioClient;
PImage bg;
TuioObject[] objs = new TuioObject[3];

void setup() {
  size(1024, 683, P2D);
  tuioClient  = new TuioProcessing(this);
  myMovie = new Movie(this, "example.mp4");
  bg = loadImage("bg.jpg");
  myMovie.loop();
  myMovie.volume(0);
}

void draw() {
  background(0);
  TuioObject upperLeft = objs[0];
  TuioObject lowerRight = objs[1];
  TuioObject imgPos = objs[2];
  if(upperLeft != null && lowerRight != null) {
    translate(upperLeft.getScreenX(width), upperLeft.getScreenY(height));
    scale(lowerRight.getX()-upperLeft.getX());
    image(bg, 0, 0);
    if(imgPos != null) {
        translate(imgPos.getScreenX(width), imgPos.getScreenY(height));
        rotate(imgPos.getAngle());
        image(myMovie, 0, 0);
    }
  }
}

void updateTuioObject(TuioObject tobj) {
  int id = tobj.getSymbolID();
  if(id < objs.length) {
    objs[id] = tobj;
  }
}

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
}