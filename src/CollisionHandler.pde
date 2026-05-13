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
        ArrayList<Vector> newPolyVel = new ArrayList<>();
        ArrayList<Float> newPolyAngRot = new ArrayList<>();
        ArrayList<Vector> newCircVel = new ArrayList<>();
        ArrayList<Float> newCircAngRot = new ArrayList<>();

        for (int i = 0; i < polygons.size(); i++) {
            Polygon p = polygons.get(i);
            newPolyVel.add(new Vector(p.vx, p.vy, 0));
            newPolyAngRot.add(p.vRot);
        }

        for (int i = 0; i < circles.size(); i++) {
            Circle c = circles.get(i);
            newCircVel.add(new Vector(c.vx, c.vy, 0));
            newCircAngRot.add(c.vRot);
        }
        
        // Between Polygons
        
        for (int i = 0; i < polygons.size(); i++) {
            Vector dVel = new Vector(0, 0, 0);
            float dRot = 0;
            for (int j = 0; j < polygons.size(); j++) {
                if (i == j) {
                    continue;
                }
                ArrayList<float[]> intersections = polygons.get(i).intersections(polygons.get(j));
                if (intersections.size() == 0) {
                    continue;
                }
                Polygon p = polygons.get(i);
                Polygon q = polygons.get(j);
                // Update p
                float[][] intersectionsArray = new float[intersections.size()][2];
                for (int k = 0; k < intersections.size(); k++) {
                    intersectionsArray[k] = intersections.get(k);
                }
                Polygon intersectionPoly = new Polygon(0, 0, intersectionsArray);
                Vector normal = nor(intersectionPoly);
                float[] intersection = new float[2];
                for (int k = 0; k < intersections.size(); k++) {
                    intersection[0] += intersections.get(k)[0]/intersections.size();
                    intersection[1] += intersections.get(k)[1]/intersections.size();
                }
                Vector pv = new Vector(new float[]{p.x, p.y}, intersection);
                pv = new Vector(pv.size*p.vRot, pv.direction + PI/2, 1);
                pv = pv.add(new Vector(p.vx, p.vy, 0));
                Vector qv = new Vector(new float[]{q.x, q.y}, intersection);
                qv = new Vector(qv.size*q.vRot, qv.direction + PI/2, 1);
                qv = qv.add(new Vector(q.vx, q.vy, 0));
                float impulse = -(1+elasticity)*pv.subtract(qv).dot(normal);
                float denom = 0;
                if (!p.st) {
                    denom += 1/p.mass;
                }
                if (!q.st) {
                    denom += 1/q.mass;
                }
                if (!p.rotSt) {
                    Vector r = new Vector(new float[]{p.x, p.y}, intersection);
                    denom += pow(r.cross(normal), 2)/p.rotIne;
                }
                if (!q.rotSt) {
                    Vector r = new Vector(new float[]{q.x, q.y}, intersection);
                    denom += pow(r.cross(normal), 2)/q.rotIne;
                }
                if (denom == 0) {
                    continue;
                }
                impulse /= denom;
                Vector impu = normal.multiply(impulse);
                if (!p.st) {
                    dVel.add(impu.multiply(1/p.mass));
                }
                if (!p.rotSt) {
                    Vector r = new Vector(new float[]{p.x, p.y}, intersection);
                    dRot+=r.cross(impu)/p.rotIne;
                }
            }
            newPolyVel.set(i, newPolyVel.get(i).add(dVel));
            newPolyAngRot.set(i, newPolyAngRot.get(i)+dRot);
        }

        // Between circles

        for (int i = 0; i < circles.size(); i++) {
            Vector dVel = new Vector(0, 0, 0);
            float dRot = 0;
            for (int j = 0; j < circles.size(); j++) {
                if (i == j) {
                    continue;
                }
                ArrayList<float[]> intersections = circles.get(i).circleIntersection(circles.get(j));
                if (intersections.size() == 0) {
                    continue;
                }
                Circle c = circles.get(i);
                Circle d = circles.get(j);
                // Update c
                Vector normal = nor(c, d);
                float[] intersection = new float[2];
                for (int k = 0; k < intersections.size(); k++) {
                    intersection[0] += intersections.get(k)[0]/intersections.size();
                    intersection[1] += intersections.get(k)[1]/intersections.size();
                }
                Vector cv = new Vector(new float[]{c.x, c.y}, intersection);
                cv = new Vector(cv.size*c.vRot, cv.direction + PI/2, 1);
                cv = cv.add(new Vector(c.vx, c.vy, 0));
                Vector dv = new Vector(new float[]{d.x, d.y}, intersection);
                dv = new Vector(dv.size*d.vRot, dv.direction + PI/2, 1);
                dv = dv.add(new Vector(d.vx, d.vy, 0));
                float impulse = -(1+elasticity)*(cv.subtract(dv)).dot(normal);
                float denom = 0;
                if (!c.st) {
                    denom += 1/c.mass;
                }
                if (!d.st) {
                    denom += 1/d.mass;
                }
                if (!c.rotSt) {
                    Vector r = new Vector(new float[]{c.x, c.y}, intersection);
                    denom += pow(r.cross(normal), 2)/c.rotIne;
                }
                if (!d.rotSt) {
                    Vector r = new Vector(new float[]{d.x, d.y}, intersection);
                    denom += pow(r.cross(normal), 2)/d.rotIne;
                }
                if (denom == 0) {
                    continue;
                }
                impulse /= denom;
                Vector impu = normal.multiply(impulse);
                if (!c.st) {
                    dVel.add(impu.multiply(1/c.mass));
                }
                if (!c.rotSt) {
                    Vector r = new Vector(new float[]{c.x, c.y}, intersection);
                    dRot+=r.cross(impu)/c.rotIne;
                }
            }
            newCircVel.set(i, newCircVel.get(i).add(dVel));
            newCircAngRot.set(i, newCircAngRot.get(i)+dRot);
        }

        // Circle and Polygon

        for (int i = 0; i < polygons.size(); i++) {
            for (int j = 0; j < circles.size(); j++) {
                Polygon p = polygons.get(i);
                Circle c = circles.get(j);
                ArrayList<float[]> intersections = p.polygonCircleIntersection(c);
                if (intersections.size() == 0) {
                    continue;
                }
                // Update both
                Vector normal = nor(p, c);
                float[] intersection = new float[2];
                for (int k = 0; k < intersections.size(); k++) {
                    intersection[0] += intersections.get(k)[0]/intersections.size();
                    intersection[1] += intersections.get(k)[1]/intersections.size();
                }
                Vector pv = new Vector(new float[]{p.x, p.y}, intersection);
                pv = new Vector(pv.size*p.vRot, pv.direction + PI/2, 1);
                pv = pv.add(new Vector(p.vx, p.vy, 0));
                Vector cv = new Vector(new float[]{c.x, c.y}, intersection);
                cv = new Vector(cv.size*c.vRot, cv.direction + PI/2, 1);
                cv = cv.add(new Vector(c.vx, c.vy, 0));
                float impulse = -(1+elasticity)*pv.subtract(cv).dot(normal);
                float denom = 0;
                if (!p.st) {
                    denom += 1/p.mass;
                }
                if (!c.st) {
                    denom += 1/c.mass;
                }
                if (!p.rotSt) {
                    Vector r = new Vector(new float[]{p.x, p.y}, intersection);
                    denom += pow(r.cross(normal), 2)/c.rotIne;
                }
                if (!c.rotSt) {
                    Vector r = new Vector(new float[]{c.x, c.y}, intersection);
                    denom += pow(r.cross(normal), 2)/c.rotIne;
                }
                if (denom == 0) {
                    continue;
                }
                println(denom);
                impulse /= denom;
                Vector impu = normal.multiply(impulse);
                //println(impulse);
                Vector dVelP = new Vector(0, 0, 0);
                float dRotP = 0;
                Vector dVelC = new Vector(0, 0, 0);
                float dRotC = 0;
                if (!p.st) {
                    dVelP.add(impu.multiply(1/p.mass));
                }
                if (!p.rotSt) {
                    Vector r = new Vector(new float[]{p.x, p.y}, intersection);
                    dRotP+=r.cross(impu)/p.rotIne;
                }
                if (!c.st) {
                    dVelC.add(impu.multiply(-1/c.mass));
                }
                if (!c.rotSt) {
                    Vector r = new Vector(new float[]{c.x, c.y}, intersection);
                    dRotC+=r.cross(impu.multiply(-1))/c.rotIne;
                }
                newPolyVel.set(i, newPolyVel.get(i).add(dVelP));
                newPolyAngRot.set(i, newPolyAngRot.get(i)+dRotP);
                newCircVel.set(j, newPolyVel.get(j).add(dVelC));
                newCircAngRot.set(j, newPolyAngRot.get(j)+dRotC);
            }
        }
        
        for (int i = 0; i < polygons.size(); i++) {
            polygons.get(i).vx = newPolyVel.get(i).x;
            polygons.get(i).vy = newPolyVel.get(i).y;
            polygons.get(i).vRot = newPolyAngRot.get(i);
        }
        
        for (int i = 0; i < circles.size(); i++) {
            circles.get(i).vx = newCircVel.get(i).x;
            circles.get(i).vy = newCircVel.get(i).y;
            circles.get(i).vRot = newCircAngRot.get(i);
        }
    }
    
    public Vector nor(Polygon p) {
        // Returns normal vector of collision
        
        // r is polygon of collision
        
        // Should probably change
        ArrayList<Vector> possibleAxis = new ArrayList<>();
        
        for (int i = 0; i < p.vertices.length; i++) {
            float[] a = p.vertices[i];
            float[] b = p.vertices[(i+1)%p.vertices.length];
        }
        for (int i = 0; i < possibleAxis.size(); i++) {
            Vector v = possibleAxis.get(i);
            possibleAxis.set(i, new Vector(1, v.direction + PI/2, 1));
        }
        
        float minIntersect = MAX_FLOAT;
        Vector minInter = new Vector(0, 0, 0);
        
        for (Vector v : possibleAxis) {
            float[] intersect = p.project(v);
            float s = intersect[1] - intersect[0];
            if (s < minIntersect) {
                minInter = v;
                minIntersect = s;
            }
        }
        return new Vector(1, minInter.direction+PI/2, 1);
    }
    
    public Vector nor(Polygon p, Circle c) {
        float edgeMin = MAX_FLOAT;
        int edgeI = -1;
        float vertMin = MAX_FLOAT;
        int vertI = -1;

        for (int i = 0; i < p.vertices.length; i++) {
            // (x-a[0])/(b[0]-a[0])+(y-a[1])/(b[1]-a[1])=0
            float[] a = p.vertices[i];
            float[] b = p.vertices[(i+1)%p.vertices.length];
            float d = p.project(new Vector(a, b), new float[]{c.x-a[0], c.y-a[1]});
            float dist;
            if (0 <= d && d <= 1) {
                dist = abs((c.x-a[0])/(b[0]-a[0])+(c.y-a[1])/(b[1]-a[1]))/sqrt(pow(1/(b[0]-a[0]), 2)+pow(1/(b[1]-a[1]), 2));
            } else if (d < 0) {
                dist = sqrt(pow(c.x-a[0], 2)+pow(c.y-a[1], 2));
            } else {
                dist = sqrt(pow(c.x-b[0], 2)+pow(c.y-b[1], 2));
            }
            if (dist < edgeMin) {
                edgeMin = dist;
                edgeI = i;
            }
        }

        for (int i = 0; i < p.vertices.length; i++) {
            float[] a = p.vertices[i];
            float dist = sqrt(pow(c.x-a[0], 2)+pow(c.y-a[1], 2));
            if (dist < vertMin) {
                vertMin = dist;
                vertI = i;
            }
        }

        if (vertMin <= edgeMin) {
            Vector v = new Vector(new float[]{c.x, c.y}, p.vertices[vertI]);
            return new Vector(1, v.direction+PI/2, 1);
        } else {
            Vector v = new Vector(p.vertices[edgeI], p.vertices[(edgeI+1)%p.vertices.length]);
            return new Vector(1, v.direction+PI/2, 1);
        }
    }
    
    public Vector nor(Circle c, Circle d) {
        Vector v = new Vector(c.x-d.x, c.y-d.y, 0);
        return new Vector(1, v.direction, 1);
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
