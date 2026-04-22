import java.util.*;

public class Circle {
    float x, y, radius, mass;
    Vector vel;
    
    public Circle(float x, float y, float radius, float mass, float vx, float vy, int mode) {
        this.x = x;
        this.y = y;
        this.radius = radius;
        this.mass = mass;
        vel = new Vector(vx, vy, mode);
    }
    
    public Circle deepCopy() {
        Circle d = new Circle(x, y, radius, mass, vel.x, vel.y, 0);
        return d;
    }
    
    public void update() {
        x+=vel.x;
        y+=vel.y;
        vel.y += 0.1;
    }
    
    public void display() {
        ellipseMode(RADIUS);
        circle(x, y, radius);
        stroke(127);
        line(x, y, x+10*vel.x, y+10*vel.y);
        stroke(255);
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
