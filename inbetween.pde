import processing.video.*;
import TUIO.*;
Movie myMovie;
TuioProcessing tuioClient;
PImage bg;

void setup() {
    size(1024, 683);
    tuioClient  = new TuioProcessing(this);
    myMovie = new Movie(this, "example.mp4");
    bg = loadImage("bg.jpg");
    myMovie.loop();
}

void draw() {
    background(bg);
    ArrayList<TuioObject> tuioObjectList = tuioClient.getTuioObjectList();
    if(tuioObjectList.size() > 0) {
        TuioObject tobj = tuioObjectList.get(0);
        translate(tobj.getScreenX(width),tobj.getScreenY(height));
        rotate(tobj.getAngle());
    }
    image(myMovie, 0, 0);
}

void movieEvent(Movie m) {
    m.read();
}
