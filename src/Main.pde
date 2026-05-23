//import processing.javafx.*;

import java.util.*;

CollisionHandler c;
float G;
ArrayList<Circle> circles;
ArrayList<Polygon> polygons;

void setup() {
    size(500, 500);
    surface.setResizable(true);
    float x = 2;
    G = 10000;
    Circle a = new Circle(250f, 250f, 10f, 1f, 1f, x, 0);
    Circle b = new Circle(30f, 40f, 10f, 1f, 0f, -1f, 0);
    Circle d = new Circle(400f, 500f, 20f, 0.5f, 0f, -0.5f*x, 0);
    Circle e = new Circle(110f, 20f, 10*sqrt(10), 10f, 0.1f, -0f, 0);
    Circle f = new Circle(140f, 20f, 20f, 4f, -0.5f, 0f, 0);
    Circle g = new Circle(170f, 20f, 10*sqrt(10), 10f, 0.5f, -0f, 0);
    Polygon p = new Polygon(0, 0, new double[][]{{0, 0}, {width, 0}, {width, height}, {0, height}});
    Polygon q = new Polygon(451, 451, new double[][]{{-49, -49}, {49, -49}, {49, 49}, {-49, 49}});
    p.st = true;
    p.rotSt = true;
    p.inv = true;
    q.vx = 1f;
    q.vy = 1f;
    q.mass = 1;
    q.rotIne = 10;
    circles = new ArrayList<Circle>();
    polygons = new ArrayList<Polygon>();
    Node n = new Node(p);
    n.children.add(new Node(a));
    n.children.add(new Node(b));
    n.children.add(new Node(d));
    n.children.add(new Node(q));
    Tree t = new Tree();
    t.addTree(n);
    c = new CollisionHandler(t);
}

void draw() {
    background(0);
    c.display();
    c.update();
    c.handleCollisions();
    ArrayList<Integer> loc1 = new ArrayList<>();
    ArrayList<Integer> loc2 = new ArrayList<>();
    loc1.add(0);
    loc1.add(1);
    loc2.add(0);
}
