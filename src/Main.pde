static Circle c;

void setup() {
    surface.setResizable(true);
    c = new Circle(20, 20, 10);
}

void draw() {
    background(0);
    circle(mouseX, mouseY, 10);
    c.update();
    c.dr();
}
