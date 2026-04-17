import java.util.*;

static ArrayList<Circle> circles;

void setup() {
    surface.setResizable(true);
    //size(1000, 1000);
    //frameRate(4);
    Circle a = new Circle(20, 20, 10, 1);
    Circle b = new Circle(50, 20, 10, 1);
    circles = new ArrayList<Circle>();
    circles.add(a);
    circles.add(b);
}

void draw() {
    background(0);
    for (Circle c : circles) {
        c.dr();
    }
    for (Circle c : circles) {
        c.update(circles);
    }
    for (Circle c : circles) {
        c.updateVel();
    }
    textAlign(LEFT, TOP);
    text(circles.get(0).checkTouch(circles.get(1)) ? "true" : "false", 0, 0);
    text(circles.get(1).checkTouch(circles.get(0)) ? "true" : "false", 0, 10);
}
