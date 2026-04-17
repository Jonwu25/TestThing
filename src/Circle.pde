import java.util.*;

public class Circle {
    float x, y, radius, mass;
    ArrayList<Circle> collisionCircles;
    Vector vel;
    
    public Circle(float x, float y, float radius, float mass) {
        this.x = x;
        this.y = y;
        this.radius = radius;
        this.mass = mass;
        vel = new Vector(10, 10, 0);
        collisionCircles = new ArrayList<Circle>();
    }
    
    public Circle deepCopy() {
        Circle d = new Circle(x, y, radius, mass);
        d.vel = vel.deepCopy();
        return d;
    }
    
    public void update(ArrayList<Circle> Circles) {
        x+=vel.x;
        y+=vel.y;
        
        if (checkHor()) {
            vel = vel.reflect(new Vector(1, 0, 0));
            if (x + radius > width) {
                x = width - radius;
            } else {
                x = radius;
            }
        }
        if (checkVert()) {
            vel = vel.reflect(new Vector(0, 1, 0));
            if (y + radius > height) {
                y = height - radius;
            } else {
                y = radius;
            }
        }
        
        for (Circle circle : Circles) {
            if (this != circle && checkTouch(circle)) {
                collisionCircles.add(circle.deepCopy());
            }
        }
    }
    
    public void updateVel() {
        for (Circle circle : collisionCircles){
            // Colliding
            Vector v, w;
            
            v = this.vel.multiply(this.mass).add(circle.vel.multiply(circle.mass));
            v = v.multiply(1/(this.mass+circle.mass));
            w = this.vel.subtract(v);
            w = w.reflect(new Vector(circle.x - this.x, circle.y - this.y, 0));
            vel = w.add(v);
            
            Vector dist = new Vector(circle.x - this.x, circle.y - this.y, 0);
            dist = new Vector(radius + circle.radius - dist.size, dist.direction, 1);
            x += -1*dist.multiply(mass/(mass+circle.mass)).x;
            y += -1*dist.multiply(mass/(mass+circle.mass)).y;
        }
        collisionCircles.clear();
    }
    
    public void dr() {
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
