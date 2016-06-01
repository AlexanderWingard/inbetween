import processing.video.*;
import TUIO.*;

TuioObject[] objs = new TuioObject[256];
int[] corners = {2, 0, 1, 3};
int[] calibrators = {77, 75};

void setup() {
  //size(1280, 720/5, P2D);
  //size(640, 360, P2D);
  //frameRate(30);
  fullScreen(P2D, 2);
  setupBackgrounds();
  setupTuio();
}

void draw() {
  clearDebug();
  drawBackgrounds();
  drawTuio();
  removeMissing();
  //  loopSides(corners);
  //printDebug("FPS: " + str(round(frameRate)));
  //calibrateFOV();

  drawDebug();
}
String dbg = "";
void clearDebug() {
  dbg = "";
}

void printDebug(String text) {
  dbg += "\n" + text;
}

void drawDebug() {
  fill(255, 0, 0);
  textSize(30);
  text(dbg, 0, 0);
}

void loopSides(int[] arr) {
  for (int i = 0; i < arr.length; i++) {
    TuioObject from = objs[arr[i]];
    TuioObject to = objs[arr[(i+1) % arr.length]];
    if (from != null && to != null) {
      //printDebug(str(dist(from.getScreenX(width), from.getScreenY(height), to.getScreenX(width), to.getScreenY(height))) + " "  + str(from.getAngleDegrees()));
    }
  }
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

// === Calibrate

void calibrateFOV() {
  background(255);
  rect(width /2 -5, height /2 -5, 10, 10);
  rect(0, 0, 10, 10);
  rect(width - 10, height - 10, 10, 10);
  // objs[calibrators[1]].getScreenX(width) - objs[calibrators[0]].getScreenX(width),
  //objs[calibrators[1]].getScreenY(height) - objs[calibrators[0]].getScreenY(height));
  //scale(objs[calibrators[1]].getX() - objs[calibrators[0]].getX());
  //rotate(-objs[calibrators[0]].getAngle());
}

// === Tuio
TuioProcessing tuioClient;
void setupTuio() {
  tuioClient  = new TuioProcessing(this);
}

PImage maskedBg;
float frameScale  = 1.0;
float size = 430;
float angle = 0;
float x = 0;
float y = 0;
void drawTuio() {
  int[] arr = corners;
  float rotationSum = 0;
  float sizeSum = 0;
  float xSum = 0;
  float ySum = 0;
  int xyCount = 0;
  int sizeCount = 0;
  int rotationCount = 0;
  for (int i = 0; i < arr.length; i++) {
    TuioObject from = objs[arr[i]];
    TuioObject to = objs[arr[(i+1) % arr.length]];
    TuioObject opposite = objs[arr[(i+2) % arr.length]];

    if (from != null && to != null) {
      PVector vec =  new PVector(to.getScreenX(width) - from.getScreenX(width), to.getScreenY(height) - from.getScreenY(height));
      vec.rotate(PI/2);
      sizeSum += dist(from.getScreenX(width), from.getScreenY(height), to.getScreenX(width), to.getScreenY(height));
      sizeCount++;
      xyCount++;
      xSum += from.getScreenX(width) + ((to.getScreenX(width) +vec.x) - from.getScreenX(width))/2;
      ySum += from.getScreenY(height) + ((to.getScreenY(height) + vec.y) - from.getScreenY(height))/2;
    }
    if (from != null) {
      rotationSum = rotationSum + from.getAngle();
      rotationCount++;
    }
    if (i < 2 && from != null && opposite != null) {
      xyCount++;
      xSum += from.getScreenX(width) + (opposite.getScreenX(width) - from.getScreenX(width))/2;
      ySum += from.getScreenY(height) + (opposite.getScreenY(height) - from.getScreenY(height))/2;      
    }
  }

  if (rotationCount > 0) {
    angle = rotationSum / rotationCount;
  }
  if (sizeCount > 0) {
       size = sizeSum / sizeCount; 
  }
    if(xyCount > 0) {
   x = xSum / xyCount;
   y = ySum / xyCount;
  }
  
  printDebug("X: " + x + " Y: " + y);
  printDebug(str(degrees(angle)));
  printDebug(str(round(size)));
  printDebug(str(rotationCount));

  if (onTheMove(corners)) {
    mask.beginDraw();
    mask.background(0);

    //mask.translate(x, y);
    mask.rotate(angle);
    //mask.translate(size/2, size/2);
    mask.fill(255);
    mask.rect(-size/2, -size/2, size, size);
    mask.endDraw();
    maskedBg = bg.copy();
    maskedBg.mask(mask);
  }
  if (maskedBg != null) {
    image(maskedBg, 0, 0);
  }
}

boolean onTheMove(int[] cor) {
  for (int i = 0; i < cor.length; i++) {
    TuioObject obj = objs[cor[i]];
    if (obj != null && (obj.isMoving() || obj.getRotationSpeed() != 0)) {
      return true;
    }
  }
  return false;
}

long secondsSinceUpdate(TuioObject obj) {
  return TuioTime.getSessionTime().subtract(obj.getTuioTime()).getSeconds();
}

void removeMissing() {
  for (int i = 0; i < objs.length; i++) {
    if (objs[i] != null && objs[i].getTuioState() == TuioObject.TUIO_REMOVED && secondsSinceUpdate(objs[i]) > 0) {
      objs[i] = null;
    }
  }
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
  //image(mv, 0, 0, width, height);
  fill(255);
  rect(0, 0, width, height);
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