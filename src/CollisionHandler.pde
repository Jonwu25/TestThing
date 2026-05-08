import java.util.*;

public class CollisionHandler {
    ArrayList<Circle> circles;
    ArrayList<Polygon> polygons;
    float elasticity = 1f;

    public CollisionHandler(ArrayList<Circle> circles, ArrayList<Polygon> polygons) {
        this.circles = circles;
        this.polygons = polygons;
    }

    /*public void handleCollisions() {
        ArrayList<Vector> newVel = new ArrayList<Vector>();
        ArrayList<Vector> displacement = new ArrayList<Vector>();

        for (Circle circle : circles) {  
            if (circle.checkHor()) {
                circle.vel = circle.vel.reflect(new Vector(1, 0, 0));
                if (circle.x + circle.radius > width) {
                    circle.x = width - circle.radius;
                } else {
                    circle.x = circle.radius;
                }
            }
            if (circle.checkVert()) {
                circle.vel = circle.vel.reflect(new Vector(0, 1, 0));
                if (circle.y + circle.radius > height) {
                    circle.y = height - circle.radius;
                } else {
                    circle.y = circle.radius;
                }
            }
        }

        for (int i = 0; i < circles.size(); i++) {
            float dx = 0f;
            float dy = 0f;
            Vector finalVel = circles.get(i).vel.deepCopy();
            for (int j = 0; j < circles.size(); j++) {
                if (j!=i && circles.get(i).checkTouch(circles.get(j))) {
                    // Colliding
                    Vector v, w;

                    Circle first = circles.get(i);
                    Circle second = circles.get(j);
                    
                    if (!first.samePos(second)) {
                        v = finalVel.multiply(first.mass);
                        v = v.add(second.vel.multiply(second.mass));
                        v = v.multiply(1/(first.mass+second.mass));
                        w = finalVel.subtract(v);
                        w = w.reflect(new Vector(second.x - first.x, second.y - first.y, 0));
                        w = w.add(v);
                        finalVel = w;
                        
                        Vector dist = new Vector(second.x - first.x, second.y - first.y, 0);
                        dist = new Vector(first.radius + second.radius - dist.size, dist.direction, 1);
                        dx += -1*dist.multiply(first.mass/(first.mass+second.mass)).x;
                        dy += -1*dist.multiply(first.mass/(first.mass+second.mass)).y;
                    } else {
                        Vector dist = new Vector(first.radius + second.radius, 0, 1);
                        dx += -1*dist.multiply(first.mass/(first.mass+second.mass)).x;
                        dy += -1*dist.multiply(first.mass/(first.mass+second.mass)).y;
                    }
                }
            }
            newVel.add(finalVel);
            displacement.add(new Vector(dx, dy, 0));
        }

        for (int i = 0; i < circles.size(); i++) {
            circles.get(i).vel = newVel.get(i);
            circles.get(i).x += displacement.get(i).x;
            circles.get(i).y += displacement.get(i).y;
        }
    }*/
    
    public void handleCollisions() {
        ArrayList<Vector> newVel = new ArrayList<>();
        ArrayList<Float> newAngRot = new ArrayList<>();
        
        // Between circles
        
        for (int i = 0; i < circles.size(); i++) {
            for (int j = 0; j < circles.size(); j++) {
                if (i == j) {
                    continue;
                }
                ArrayList<float[]> intersections = circles.get(i).circleIntersection(circles.get(j));
                if (intersections.size() == 0) {
                    continue;
                }
                float[] intersection = new float[2];
                for (int k = 0; k < intersections.size(); k++) {
                    intersection[0] += intersections.get(k)[0]/intersections.size();
                    intersection[1] += intersections.get(k)[1]/intersections.size();
                }
                // float impulse = -(1+
            }
        }
    }

    public void update() {
        for (Circle c : circles) {
            c.update(circles);
        }
    }

    public void display() {
        for (Circle c : circles) {
            c.display();
        }
    }
}
