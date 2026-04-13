public class Circle {
    float x, y, radius;
    float velx, vely;
    
    public Circle(float x, float y, float radius) {
        this.x = x;
        this.y = y;
        this.radius = radius;
        this.velx = 10;
        this.vely = 10;
    }
    
    public void update() {
        x+=velx;
        y+=vely;
        velx = checkHor() ? -velx : velx;
        vely = checkVert() ? -vely : vely;
    }
    
    public void dr() {
        circle(x, y, radius);
    }
    
    public boolean checkHor() {
        return ((x - radius < 0) || (x + radius > width));
    }
    
    public boolean checkVert() {
        return ((y - radius < 0) || (y + radius > height));
    }
    
    public boolean checkTouch(Circle other) {
        return (sqrt());
    }
}
