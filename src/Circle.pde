import java.util.*;

public class Circle {
    float x, y, radius, mass;
    ArrayList<float[]> positions;
    Vector vel;
    
    public Circle(float x, float y, float radius, float mass, float vx, float vy, int mode) {
        this.x = x;
        this.y = y;
        this.radius = radius;
        this.mass = mass;
        positions = new ArrayList<float[]>();
        vel = new Vector(vx, vy, mode);
    }
    
    public Circle deepCopy() {
        Circle d = new Circle(x, y, radius, mass, vel.x, vel.y, 0);
        return d;
    }
    
    public void update(ArrayList<Circle> circles) {
        positions.add(new float[]{x, y});
        if (positions.size() > 100) {
            positions.remove(0);
        }
        x+=vel.x;
        y+=vel.y;
        for (Circle c : circles) {
            if (!samePos(c)) {
                Vector v = new Vector(c.x - x, c.y - y, 0);
                vel = vel.add(v.multiply(pow(v.size, -3)).multiply(50*c.mass));
            }
        }
    }
    
    public boolean samePos(Circle other) {
        return (x==other.x)&&(y==other.y);
    }
    
    public void display() {
        ellipseMode(RADIUS);
        circle(x, y, radius);
        stroke(127);
        line(x, y, x+10*vel.x, y+10*vel.y);
        for (int i = 0; i < positions.size() - 1; i++) {
            stroke(128 + 127 * i / positions.size());
            line(positions.get(i)[0], positions.get(i)[1], positions.get(i+1)[0], positions.get(i+1)[1]);
        }
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
