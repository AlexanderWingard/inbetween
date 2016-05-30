import processing.video.*;
import TUIO.*;

TuioObject[] objs = new TuioObject[256];

void setup() {
  size(1024, 768, P2D);
  //frameRate(30);
  //fullScreen(P2D);
  setupBackgrounds();
  setupTuio();
}

void draw() {
  drawBackgrounds();
  drawTuio();
  printDebug(str(round(frameRate)));
}

void printDebug(String text) {
  fill(255, 0, 0);
  textSize(30);
  text(text, 20, 30);
}

void updateTuioObject(TuioObject tobj) {
  int id = tobj.getSymbolID();
  if (id < objs.length) {
    objs[id] = tobj;
  }
}

void movieEvent(Movie m) {
  m.read();
}

TuioProcessing tuioClient;
// === Tuio
void setupTuio() {
  tuioClient  = new TuioProcessing(this);
}
PImage maskedBg;
void drawTuio() {
  int size = 430;
  TuioObject imgUL = objs[3];
  if (imgUL == null) {
    return;
  }
  if (imgUL.isMoving() || imgUL.getRotationSpeed() != 0) {
    //float target = dist(imgUL.getScreenX(width), imgUL.getScreenY(height), imgUR.getScreenX(width), imgUR.getScreenY(height));
    //    float a = atan2(diffX, diffY);
    //        float diffX = imgUR.getX() - imgUL.getX();
    //float diffY = imgUR.getY() - imgUL.getY();
    mask.beginDraw();
    mask.background(0);
    mask.translate(imgUL.getScreenX(width), imgUL.getScreenY(height));
    mask.rotate(imgUL.getAngle());
    mask.fill(255);
    mask.rect(0, 0, size, size);
    mask.endDraw();
    maskedBg = bg.copy();
    maskedBg.mask(mask);
    //PImage newImg = new PImage(size, size);
    //newImg.copy(bg, imgUL.getScreenX(width), imgUL.getScreenY(height), size, size, 0, 0, size, size);
    //image(mv,0,0);
  }
  image(maskedBg, 0, 0);
}

// === Backgrounds
Movie mv;
PImage bg;
PGraphics mask;
float scale = 1.0;
void setupBackgrounds() {
  mv = new Movie(this, "example.mp4");
  mv.loop();
  mv.volume(0);
  bg = loadImage("bg.jpeg");
  bg.resize(width, height);
  mask = createGraphics(width, height);
}

void drawBackgrounds() {
  image(mv, 0, 0, width, height);
}

// === Corners
PImage fid1, fid2;
void setupCorners() {
  fid1 = loadImage("1.png");
  fid2 = loadImage("2.png");
  fid1.resize(30, 30);
  fid2.resize(30, 30);
}

void drawCorners() {
  image(fid1, 0, 0);
  image(fid2, width - fid2.width, height - fid2.height);
}