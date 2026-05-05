import java.util.*;

public class Polygon {
    float[][] vertices, origVertices;
    float x, y, rot, vx, vy, vrot, rotIne;
    boolean st = false;
    boolean inv = false;
  
    public Polygon(float x, float y, float[][] vertices) {
        this.vertices = vertices;
        this.origVertices = vertices;
        this.x = x;
        this.y = y;
    }

    public void update() {
        for (int i = 0; i < vertices.length; i++) {
            float newX = origVertices[i][0]*cos(rot) - origVertices[i][1]*sin(rot);
            float newY = origVertices[i][0]*sin(rot) + origVertices[i][1]*cos(rot);
            vertices[i][0] = newX + x;
            vertices[i][1] = newY + y;
        }
    }
    
    public ArrayList<float[]> intersections(Polygon other) {
        // From O'Rourke
        int startOne = 0;
        int startTwo = 0;
        int[] inside = null; // will be 2 numbers, 0/1 for which polygon, and index of vertex
        ArrayList<float[]> intersections = new ArrayList<>();
        for (int i = 0; i < 2*(vertices.length + other.vertices.length); i++) {
            if (checkIntersect(vertices[startOne], vertices[(startOne-1+vertices.length)%vertices.length],
                               other.vertices[startTwo], other.vertices[(startOne-1+other.vertices.length)%other.vertices.length])) {
                float[] intersectionPoint = intersection(vertices[startOne], vertices[(startOne-1+vertices.length)%vertices.length],
                                                         other.vertices[startTwo], other.vertices[(startOne-1+other.vertices.length)%other.vertices.length]);
                if (intersections.size() > 0) {
                    if (intersections.get(0)[0] == intersectionPoint[0] && intersections.get(0)[1] == intersectionPoint[1]) {
                        return intersections;
                    }
                }
                intersections.add(intersectionPoint);
                Vector first = new Vector(other.vertices[(startTwo-1+other.vertices.length)%other.vertices.length], other.vertices[startTwo]);
                Vector second = new Vector(other.vertices[(startTwo-1+other.vertices.length)%other.vertices.length], vertices[startOne]);
                if (first.cross(second) >= 0) {
                    inside = new int[]{0, startOne}; // P
                } else {
                    inside = new int[]{1, startTwo}; // Q
                }
            }
            Vector qDot = new Vector(other.vertices[(startTwo-1+other.vertices.length)%other.vertices.length], other.vertices[startTwo]);
            Vector pDot = new Vector(vertices[(startOne-1+vertices.length)%vertices.length], vertices[startOne]);
            Vector pHalf = new Vector(other.vertices[(startTwo-1+other.vertices.length)%other.vertices.length], vertices[startOne]);
            Vector qHalf = new Vector(vertices[(startOne-1+vertices.length)%vertices.length], other.vertices[startTwo]);
            if (qDot.cross(pDot) >= 0) {
                if (qDot.cross(pHalf) >= 0) {
                    // advance Q
                    if (inside != null && inside[0] == 1 && inside[1] == startTwo) {
                        intersections.add(other.vertices[startTwo]);
                        startTwo = (startTwo + 1) % other.vertices.length;
                    }
                } else {
                    // advance P
                    if (inside != null && inside[0] == 0 && inside[1] == startOne) {
                        intersections.add(vertices[startOne]);
                        startOne = (startOne + 1) % vertices.length;
                    }
                }
            } else {
                if (pDot.cross(qHalf) >= 0) {
                    // advance P
                    if (inside != null && inside[0] == 0 && inside[1] == startOne) {
                        intersections.add(vertices[startOne]);
                        startOne = (startOne + 1) % vertices.length;
                    }
                } else {
                    // advance Q
                    if (inside != null && inside[0] == 1 && inside[1] == startTwo) {
                        intersections.add(other.vertices[startTwo]);
                        startTwo = (startTwo + 1) % other.vertices.length;
                    }
                }
            }
        }
        if (inside(other.vertices[0])) {
            intersections.add(other.vertices[0]);
        } else if (other.inside(vertices[0])) {
            intersections.add(vertices[0]);
        } else {
            // no intersections
        }
        return intersections;
    }

    public boolean inside(float[] p) {
        float angle = 0;
        for (int i = 0; i < vertices.length; i++) {
            Vector vec = new Vector(p, vertices[i]);
            angle += vec.angle(new Vector(p, vertices[(i+1)%vertices.length]));
        }
        return angle==2*PI;
    }
    
    public boolean checkIntersect(float[] startOne, float[] endOne, float[] startTwo, float[] endTwo) {
        if(onSegment(intersection(startOne, endOne, startTwo, endTwo), startOne, endOne) && onSegment(intersection(startOne, endOne, startTwo, endTwo), startTwo, endTwo)){
            return true;
        }
        return false;
    }

    public float[] intersection(float[] p, float[] q, float[] r, float[] s) {
        // y=(q[1]-p[1])/(q[0]-p[0])(x-p[0])+p[1]
        // y=(s[1]-r[1])/(s[0]-r[0])(x-r[0])+r[1]
        float x = (r[1]-p[1]+(q[1]-p[1])/(q[0]-p[0])*p[0]-(s[1]-r[1])/(s[0]-r[0])*r[0])/((q[1]-p[1])/(q[0]-p[0])-(s[1]-r[1])/(s[0]-r[0]));
        float y = (q[1]-p[1])/(q[0]-p[0])*(x-p[0])+p[1];
        return new float[]{x, y};
    }
    
    public boolean onSegment(float[] p, float[] start, float[] end) {
        return p[0] <= max(start[0], end[0]) && p[0] >= min(start[0], end[0]) &&
               p[1] <= max(start[1], end[1]) && p[1] >= min(start[1], end[1]);
    }
    
    public boolean intersects(Polygon other) {
        ArrayList<Vector> possibleAxis = new ArrayList<>();
        for (int i = 0; i < vertices.length; i++) {
            possibleAxis.add(new Vector(vertices[(i+1) % vertices.length][0] - vertices[i][0],
                                        vertices[(i+1) % vertices.length][1] - vertices[i][1], 0));
        }
        for (int i = 0; i < other.vertices.length; i++) {
            possibleAxis.add(new Vector(other.vertices[(i+1) % other.vertices.length][0] - other.vertices[i][0],
                                        other.vertices[(i+1) % other.vertices.length][1] - other.vertices[i][1], 0));
        }
        for (int i = 0; i < possibleAxis.size(); i++) {
            possibleAxis.set(i, new Vector(possibleAxis.get(i).size, possibleAxis.get(i).direction + PI/2, 1));
        }
        for (Vector v : possibleAxis) {
            ArrayList<Float> valsOne = new ArrayList<>();
            ArrayList<Float> valsTwo = new ArrayList<>();
            for (float[] p : vertices) {
                valsOne.add(project(v, p));
            }
            for (float[] p : other.vertices) {
                valsTwo.add(project(v, p));
            }
            if (Collections.max(valsOne) < Collections.min(valsTwo)) {
                return false;
            }
            if (Collections.min(valsOne) > Collections.max(valsTwo)) {
                return false;
            }
        }
        return true;
    }

    public ArrayList<float[]> polygonCircleIntersection(Circle c) {
        ArrayList<float[]> intersections = new ArrayList<>();
        for (int i = 0; i < vertices.length; i++) {
            float[] start = vertices[i];
            float[] end = vertices[(i+1) % vertices.length];
            intersections.addAll(lineCircleIntersection(start, end, c));
        }
        return intersections;
    }

    public ArrayList<float[]> lineCircleIntersection(float[] start, float[] end, Circle c) {
        float dx = end[0] - start[0];
        float dy = end[1] - start[1];
        float A = dx*dx + dy*dy;
        float B = 2*(dx*(start[0]-c.x) + dy*(start[1]-c.y));
        float C = (start[0]-c.x)*(start[0]-c.x) + (start[1]-c.y)*(start[1]-c.y) - c.radius*c.radius;
        float det = B*B - 4*A*C;
        ArrayList<float[]> intersections = new ArrayList<>();
        if (det < 0) {
            return intersections; // no intersection
        } else if (det == 0) {
            if (0 <= -B/(2*A) && -B/(2*A) <= 1) {
                intersections.add(new float[]{start[0] + (-B/(2*A))*dx, start[1] + (-B/(2*A))*dy});
            }
            return intersections;
        } else {
            if (0 <= (-B + sqrt(det))/(2*A) && (-B + sqrt(det))/(2*A) <= 1) {
                intersections.add(new float[]{start[0] + (-B + sqrt(det))/(2*A)*dx, start[1] + (-B + sqrt(det))/(2*A)*dy});
            }
            if (0 <= (-B - sqrt(det))/(2*A) && (-B - sqrt(det))/(2*A) <= 1) {
                intersections.add(new float[]{start[0] + (-B - sqrt(det))/(2*A)*dx, start[1] + (-B - sqrt(det))/(2*A)*dy});
            }
            return intersections;
        }
    }
    
    public float project(Vector v, float[] point) {
        // v.x*a - v.y*b = point[0]
        // v.y*a + v.x*b = point[1]
        return (point[0] * v.x + point[1] * v.y) / (v.x * v.x + v.y * v.y);
    }
}
