import java.util.*;

public class Circle {
    float x, y, radius, mass;
    Vector vel;
    
    public Circle(float x, float y, float radius, float mass) {
        this.x = x;
        this.y = y;
        this.radius = radius;
        this.mass = mass;
        vel = new Vector(1, 1, 0);
    }
    
    public void update(ArrayList<Circle> Circles) {
        x+=vel.x;
        y+=vel.y;
        
        if (checkHor()) {
            vel = vel.reflect(new Vector(1, 0, 0));
        }
        if (checkVert()) {
            vel = vel.reflect(new Vector(0, 1, 0));
        }
        
        for (Circle circle : Circles) {
            if (this != circle && checkTouch(circle)) {
                // Colliding
                Vector v, w;
                
                v = this.vel.multiply(this.mass).add(circle.vel.multiply(circle.mass));
                v = v.multiply(1/(this.mass+circle.mass));
                w = this.vel.subtract(v);
                w = w.reflect(new Vector(circle.x - this.x, circle.y - this.y, 0));
                vel = w.add(v);
            }
        }
    }
    
    public void dr() {
        ellipseMode(RADIUS);
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
