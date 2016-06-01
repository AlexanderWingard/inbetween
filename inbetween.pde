import processing.video.*;
import TUIO.*;


TuioObject[] objs = new TuioObject[256];
int[] corners = {8, 9, 10, 11};
int[] calibrators = {0, 1};

void setup() {
  //size(1280, 720/5, P2D);
  size(640, 360, P2D);
  //frameRate(30);
  //fullScreen(P2D);
  setupBackgrounds();
  setupTuio();
}

void draw() {
  clearDebug();
  calibrateFOV();
  drawBackgrounds();
  drawTuio();
  removeMissing();
  loopSides(corners);
  printDebug("FPS: " + str(round(frameRate)));
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
  textSize(height/10);
  text(dbg, 0, 0);
}

void loopSides(int[] arr) {
  for (int i = 0; i < arr.length; i++) {
    TuioObject from = objs[arr[i]];
    TuioObject to = objs[arr[(i+1) % arr.length]];
    if (from != null && to != null) {
      printDebug(str(dist(from.getScreenX(width), from.getScreenY(height), to.getScreenX(width), to.getScreenY(height))) + " "  + str(from.getAngleDegrees()));
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
  if (objs[calibrators[0]] == null || objs[calibrators[1]] == null) {
    return;
  }
  background(255);
  translate(objs[calibrators[0]].getScreenX(width), objs[calibrators[0]].getScreenY(height));
  scale(objs[calibrators[1]].getX() - objs[calibrators[0]].getX());
  rotate(-objs[calibrators[0]].getAngle());
}

// === Tuio
TuioProcessing tuioClient;
void setupTuio() {
  tuioClient  = new TuioProcessing(this);
}

PImage maskedBg;
float frameScale  = 1.0;
void drawTuio() {
  int[] arr = corners;
  float size = 430;
  float angle = 0;
  float x = 0;
  float y = 0;
  for (int i = 0; i < arr.length; i++) {
    TuioObject from = objs[arr[i]];
    TuioObject to = objs[arr[(i+1) % arr.length]];
    if (from != null && to != null) {
      size = dist(from.getScreenX(width), from.getScreenY(height), to.getScreenX(width), to.getScreenY(height));
      angle = from.getAngle();
    }
    if (from != null) {
      x = from.getScreenX(width);
      y = from.getScreenY(height);
      if (arr[i] == arr[1] || arr[i] == arr[2]) {
        x = x - size;
      }
      if (arr[i] == arr[2] || arr[i] == arr[3]) {
        y = y - size;
      }
    }
  }

  if (onTheMove(corners)) {
    mask.beginDraw();
    mask.background(0);
    mask.translate(x, y);
    mask.rotate(angle);
    mask.fill(255);
    mask.rect(0, 0, size, size);
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