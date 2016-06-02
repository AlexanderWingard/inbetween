import processing.video.*;
import TUIO.*;

TuioObject[] objs = new TuioObject[256];
int[] corners = {2, 0, 1, 3};
final boolean DEBUG = true;
final boolean BACKGROUND = true;
final int REMOVE_TIME_MS = 200;

void setup() {
  fullScreen(P2D, 2);
  //size(640, 360, P2D);
  setupBackgrounds();
  setupTuio();
}

void draw() {
  clearDebug();
  drawBackgrounds();
  drawTuio();
  removeMissing();
  printDebug("FPS: " + str(round(frameRate)));
  drawDebug();
}
String dbg = "";
void clearDebug() {
  if (DEBUG) {
    dbg = "";
  }
}

void printDebug(String text) {
  if (DEBUG) {
    dbg += "\n" + text;
  }
}

void drawDebug() {
  if (DEBUG) {
    fill(255, 0, 0);
    textSize(30);
    text(dbg, 0, 0);
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
int fade = 255;
void drawTuio() {
  int[] arr = corners;
  float rotationSum = 0;
  float sizeSum = 0;
  float xSum = 0;
  float ySum = 0;
  int xyCount = 0;
  int sizeCount = 0;
  int rotationCount = 0;
  fade = max(0, fade-32);
  for (int i = 0; i < arr.length; i++) {
    TuioObject from = objs[arr[i]];
    TuioObject to = objs[arr[(i+1) % arr.length]];
    TuioObject opposite = objs[arr[(i+2) % arr.length]];

    if (from != null && to != null) {
      PVector vec =  new PVector(to.getScreenX(width) - from.getScreenX(width), to.getScreenY(height) - from.getScreenY(height));
      vec.rotate(PI/2);
      sizeSum += dist(from.getScreenX(width), from.getScreenY(height), to.getScreenX(width), to.getScreenY(height));
      xSum += from.getScreenX(width) + ((to.getScreenX(width) +vec.x) - from.getScreenX(width))/2;
      ySum += from.getScreenY(height) + ((to.getScreenY(height) + vec.y) - from.getScreenY(height))/2;
      sizeCount++;
      xyCount++;
    }
    if (from != null) {
      rotationSum = rotationSum + from.getAngle();
      rotationCount++;
    }
    if (i < 2 && from != null && opposite != null) {
      xSum += from.getScreenX(width) + (opposite.getScreenX(width) - from.getScreenX(width))/2;
      ySum += from.getScreenY(height) + (opposite.getScreenY(height) - from.getScreenY(height))/2;
      xyCount++;
    }
  }

  if (rotationCount > 0) {
    angle = rotationSum / rotationCount;
  }
  if (sizeCount > 0) {
    size = sizeSum / sizeCount + 40;
  }
  if (xyCount > 0) {
    fade = 255;
    x = xSum / xyCount;
    y = ySum / xyCount;
  }

  if (onTheMove(corners) || (fade > 0  && fade < 255)) {
    mask.beginDraw();
    mask.background(0);
    mask.translate(x, y);        
    mask.rotate(angle);
    mask.fill(fade);
    mask.rect(-size/2, -size/2, size, size);
    mask.endDraw();
    maskedBg = bg.copy();
    maskedBg.mask(mask);
  }
  if (maskedBg != null) {
    image(maskedBg, 0, 0);
  }

  if (DEBUG) {
    printDebug("X: " + x + " Y: " + y + ' ' + str(xyCount));
    printDebug(str(degrees(angle)) + ' ' + str(rotationCount));
    printDebug(str(round(size)) + ' ' + str(sizeCount));
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

long millisSinceUpdate(TuioObject obj) {
  return TuioTime.getSessionTime().subtract(obj.getTuioTime()).getTotalMilliseconds();
}

void removeMissing() {
  for (int i = 0; i < objs.length; i++) {
    if (objs[i] != null && objs[i].getTuioState() == TuioObject.TUIO_REMOVED && millisSinceUpdate(objs[i]) > REMOVE_TIME_MS) {
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
  if (BACKGROUND) {
    mv = new Movie(this, "example.mp4");
    mv.loop();
    mv.volume(0);
  }
  bg = loadImage("bg.jpeg");
  bg.resize(width, height);
  mask = createGraphics(width, height);
}

void drawBackgrounds() {
  if (BACKGROUND) {
    image(mv, 0, 0, width, height);
  } else {
    fill(255);
    rect(0, 0, width, height);
  }
}