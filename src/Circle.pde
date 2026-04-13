public class Circle {
    float x, y, radius, mass;
    float velx, vely;
    
    public Circle(float x, float y, float radius, float mass) {
        this.x = x;
        this.y = y;
        this.radius = radius;
        this.mass = mass;
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
        return (sqrt(pow(this.x - other.x, 2) + pow(this.y - other.y, 2)) < this.radius + other.radius);
    }
}
