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
        int startOne = 0;
        int startTwo = 0;
        ArrayList<float[]> intersections;
        for (int i = 0; i < vertices.length + other.vertices.length; i++) {
            if (checkIntersect(vertices[startOne], vertices[(startOne+1)%vertices.length],
                               other.vertices[startTwo], other.vertices[(startOne+1)%other.vertices.length])) {
                
            }
        }
        return null;
    }
    
    public boolean checkIntersect(float[] startOne, float[] endOne, float[] startTwo, float[] endTwo) {
        int o1 = orientation(startOne, endOne, startTwo);
        int o2 = orientation(startOne, endOne, endTwo);
        int o3 = orientation(startTwo, endTwo, startOne);
        int o4 = orientation(startTwo, endTwo, startTwo);

        if (o1 != o2 && o3 != o4)
            return true;

        if (o1 == 0 &&
        onSegment(startOne, startTwo, endOne)) return true;

        if (o2 == 0 &&
        onSegment(startOne, endTwo, endOne)) return true;

        if (o3 == 0 &&
        onSegment(startTwo, startOne, endTwo)) return true;

        if (o4 == 0 &&
        onSegment(startTwo, endOne, endTwo)) return true;

        return false;
    }
    
    public int orientation(float[] p, float[] q, float[] r) {
        float val = (q[1] - p[1]) * (r[0] - q[0]) -
                  (q[0] - p[0]) * (r[1] - q[1]);
        if(val == 0) return 0;
        return (val > 0) ? 1 : -1;
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
