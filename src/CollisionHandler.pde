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
                Vector normal;
                float[] intersection = new float[2];
                for (int k = 0; k < intersections.size(); k++) {
                    intersection[0] += intersections.get(k)[0]/intersections.size();
                    intersection[1] += intersections.get(k)[1]/intersections.size();
                }
                // float impulse = -(1+elasticity)
            }
        }
    }
    
    public Vector nor(Polygon p, Polygon q) {
        // Returns normal vector of collision

        // Should probably change
        ArrayList<Vector> possibleAxis = new ArrayList<>();
        
        for (int i = 0; i < p.vertices.length; i++) {
            possibleAxis.add(new Vector(p.vertices[i], p.vertices[(i+1)%p.vertices.length]));
        }
        for (int i = 0; i < q.vertices.length; i++) {
            possibleAxis.add(new Vector(q.vertices[i], q.vertices[(i+1)%q.vertices.length]));
        }
        for (int i = 0; i < possibleAxis.size(); i++) {
            Vector v = possibleAxis.get(i);
            possibleAxis.set(i, new Vector(1, v.direction + PI/2, 1));
        }
        
        float minIntersect = MAX_FLOAT;
        Vector minInter = new Vector(0, 0, 0);
        
        for (Vector v : possibleAxis) {
            float[] intersect = p.intersection(p.project(v), q.project(v));
            float s = intersect[1] - intersect[0];
            if (s < minIntersect) {
                minInter = v;
                minIntersect = s;
            }
        }
        return new Vector(1, minInter.direction+PI/2, 1);
    }
    
    public Vector nor(Polygon p, Circle c) {
        float edgeMin = MAX_VALUE;
        float edgeI = -1;
        float vertMin = MAX_VALUE;
        float vertI = -1;

        for (int i = 0; i < p.vertices.length; i++) {
            // (x-a[0])/(b[0]-a[0])+(y-a[1])/(b[1]-a[1])=0
            float[] a = p.vertices[i];
            float[] b = p.vertices[(i+1)%p.vertices.length];
            float d = p.project(new Vector(a, b), new float[]{c.x-a.x, c.y-a.y});
            float dist;
            if (0 <= d && d <= 1) {
                dist = abs((c.x-a[0])/(b[0]-a[0])+(c.y-a[1])/(b[1]-a[1]))/sqrt(pow(1/(b[0]-a[0]), 2)+pow(1/(b[1]-a[1]), 2));
            } else if (d < 0) {
                dist = sqrt(pow(c.x-a.x, 2)+pow(c.y-a.y, 2));
            } else {
                dist = sqrt(pow(c.x-b.x, 2)+pow(c.y-b.y, 2));
            }
            if (dist < edgeMin) {
                edgeMin = dist;
                edgeI = i;
            }
        }

        for (int i = 0; i < p.vertices.length; i++) {
            float[] a = p.vertices[i];
            float dist = sqrt(pow(c.x-a.x, 2)+pow(c.y-a.y, 2));
            if (dist < vertMin) {
                vertMin = dist;
                vertI = i;
            }
        }

        if (vertMin <= edgeMin) {
            Vector v = new Vector(new float[]{v.x, v.y}, p.vertices[vertI]);
            return v.multiply(1/v.size);
        } else {
            return new Vector(p.vertices[edgeI], p.vertices[(edgeI+1)%p.vertices.length]);
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
