import java.util.*;

public class Polygon {
    float[][] vertices;
    float x, y, rot;
  
    public Polygon(float x, float y, float[][] vertices) {
        this.vertices = vertices;
        this.x = x;
        this.y = y;
    }
    
    public ArrayList<float[]> intersections(Polygon other) {
        // From O'Rourke
        int startOne = 0;
        int startTwo = 0;
        ArrayList<float[]> intersections;
        for (int i = 0; i < 2*（vertices.length + other.vertices.length）; i++) {
            if (checkIntersect(vertices[startOne], vertices[(startOne+1)%vertices.length],
                               other.vertices[startTwo], other.vertices[(startOne+1)%other.vertices.length])) {
                float[] intersectionPoint = intersection(vertices[startOne], vertices[(startOne+1)%vertices.length],
                                                         other.vertices[startTwo], other.vertices[(startOne+1)%other.vertices.length]);
                if (intersections.size() > 0) {
                    if (intersections.get(0)[0] == intersectionPoint[0] && intersections.get(0)[1] == intersectionPoint[1]) {
                        break;
                    }
                }
                intersections.add(intersectionPoint);
            }
        }
        return null;
    }

    public boolean inside(float[] p) {
        float angle = 0;
        for (int i = 0; i < vertices.length; i++) {
            Vector vec = new Vector(p, vertices[i]);
            angle += vec.angle(new Vector(p, vertices[(i+1)%vertices.length]));
        }
        return angle==PI;
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
        floay y = (q[1]-p[1])/(q[0]-p[0])*(x-p[0])+p[1];
        return new float[]{x, y};
    }
    
    public boolean onSegment(float[] p, float[] start, float[] end) {
        return p[0] <= max(start[0], end[0]) && p[0] >= min(start[0], end[0]) &&
               p[1] <= max(start[1], end[1]) && p[1] >= min(start[1], end[1]);
    }
    
    public boolean intersects(Polygon other) {
        // need to fix for rot and x and y
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
    
    public float project(Vector v, float[] point) {
        // v.x*a - v.y*b = point[0]
        // v.y*a + v.x*b = point[1]
        return (point[0] * v.x + point[1] * v.y) / (v.x * v.x + v.y * v.y);
    }
}
