import java.util.*;

static CollisionHandler c;

void setup() {
    surface.setResizable(true);
    //size(1000, 1000);
    //frameRate(4);
    Circle a = new Circle(20f, 20f, 10f, 1f, 1f, 1f, 0);
    Circle b = new Circle(50f, 20f, 10f, 1f, 0f, 0.5f, 0);
    Circle d = new Circle(80f, 20f, 20f, 2f, 0.5f, 0f, 0);
    ArrayList<Circle> circles = new ArrayList<Circle>();
    circles.add(a);
    circles.add(b);
    circles.add(d);
    c = new CollisionHandler(circles);
}

void draw() {
    background(0);
    c.display();
    c.update();
    c.handleCollisions();

    /*if (circles.get(0).checkTouch(circles.get(1)) != circles.get(1).checkTouch(circles.get(0))) {
        System.out.println(":(");
    }

    textAlign(LEFT, TOP);
    text(circles.get(0).checkTouch(circles.get(1)) ? "true" : "false", 0, 0);
    text(circles.get(1).checkTouch(circles.get(0)) ? "true" : "false", 0, 10);*/
}
