import java.util.*;

class Polygon extends Shape {
    double[][] vertices, origVertices;
    ArrayList<double[]> positions;
    double x, y, rot, vx, vy, vRot, rotIne, mass;
    boolean st = false, rotSt = false;
    boolean inv = false;
  
    public Polygon(double x, double y, double[][] vertices) {
        this.vertices = vertices;
        this.origVertices = vertices;
        this.x = x;
        this.y = y;
        positions = new ArrayList<double[]>();
    }

    public void update() {
        positions.add(new double[]{x, y});
        if (positions.size() > 100) {
            positions.remove(0);
        }
        for (int i = 0; i < vertices.length; i++) {
            double newX = origVertices[i][0]*Math.cos(rot) - origVertices[i][1]*Math.sin(rot);
            double newY = origVertices[i][0]*Math.sin(rot) + origVertices[i][1]*Math.cos(rot);
            vertices[i][0] = newX + x;
            vertices[i][1] = newY + y;
        }
        x += vx;
        y += vy;
        rot += vRot;
    }

    public void display() {
        noFill();
        stroke(255);
        beginShape();
        for (double[] vertex : vertices) {
            vertex((float)vertex[0], (float)vertex[1]);
        }
        endShape(CLOSE);
        stroke(127);
        for (int i = 0; i < positions.size() - 1; i++) {
            stroke(128 + 127 * i / positions.size());
            line((float)positions.get(i)[0], (float)positions.get(i)[1], (float)positions.get(i+1)[0], (float)positions.get(i+1)[1]);
        }
        stroke(255);
    }
    
    public ArrayList<double[]> intersections(Polygon other) {
        // From O'Rourke
        int startOne = 0;
        int startTwo = 0;
        int[] inside = null; // will be 2 numbers, 0/1 for which polygon, and index of vertex
        ArrayList<double[]> intersections = new ArrayList<>();
        for (int i = 0; i < 2*(vertices.length + other.vertices.length); i++) {
            if (checkIntersect(vertices[startOne], vertices[(startOne-1+vertices.length)%vertices.length],
                               other.vertices[startTwo], other.vertices[(startOne-1+other.vertices.length)%other.vertices.length])) {
                double[] intersectionPoint = intersection(vertices[startOne], vertices[(startOne-1+vertices.length)%vertices.length],
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
            if (!other.inv) {
                intersections.addAll(Arrays.asList(other.vertices));
            }
        } else if (other.inside(vertices[0])) {
            if (!inv) {
                intersections.addAll(Arrays.asList(vertices));
            }
        } else {
            // no intersections
        }
        return intersections;
    }

    public boolean inside(double[] p) {
        double angle = 0;
        for (int i = 0; i < vertices.length; i++) {
            Vector vec = new Vector(p, vertices[i]);
            angle += vec.angle(new Vector(p, vertices[(i+1)%vertices.length]));
        }
        return angle==2*PI;
    }
    
    public boolean checkIntersect(double[] startOne, double[] endOne, double[] startTwo, double[] endTwo) {
        if(onSegment(intersection(startOne, endOne, startTwo, endTwo), startOne, endOne) && onSegment(intersection(startOne, endOne, startTwo, endTwo), startTwo, endTwo)){
            return true;
        }
        return false;
    }

    public double[] intersection(double[] p, double[] q, double[] r, double[] s) {
        // y=(q[1]-p[1])/(q[0]-p[0])(x-p[0])+p[1]
        // y=(s[1]-r[1])/(s[0]-r[0])(x-r[0])+r[1]
        double x = (r[1]-p[1]+(q[1]-p[1])/(q[0]-p[0])*p[0]-(s[1]-r[1])/(s[0]-r[0])*r[0])/((q[1]-p[1])/(q[0]-p[0])-(s[1]-r[1])/(s[0]-r[0]));
        double y = (q[1]-p[1])/(q[0]-p[0])*(x-p[0])+p[1];
        return new double[]{x, y};
    }
    
    public boolean onSegment(double[] p, double[] start, double[] end) {
        return p[0] <= Math.max(start[0], end[0]) && p[0] >= Math.min(start[0], end[0]) &&
               p[1] <= Math.max(start[1], end[1]) && p[1] >= Math.min(start[1], end[1]);
    }
    
    public boolean normal(Polygon other) {
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
            ArrayList<Double> valsOne = new ArrayList<>();
            ArrayList<Double> valsTwo = new ArrayList<>();
            for (double[] p : vertices) {
                valsOne.add(project(v, p));
            }
            for (double[] p : other.vertices) {
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

    public ArrayList<double[]> polygonCircleIntersection(Circle c) {
        ArrayList<double[]> intersections = new ArrayList<>();
        for (int i = 0; i < vertices.length; i++) {
            double[] start = vertices[i];
            double[] end = vertices[(i+1) % vertices.length];
            intersections.addAll(lineCircleIntersection(start, end, c));
            if (c.inside(start)) {
                intersections.add(start);
            }
        }
        if (!inv && intersections.size() == 0 && inside(new double[]{c.x, c.y})) {
            intersections.add(new double[]{c.x, c.y});
        }
        return intersections;
    }

    public ArrayList<double[]> lineCircleIntersection(double[] start, double[] end, Circle c) {
        double dx = end[0] - start[0];
        double dy = end[1] - start[1];
        double A = dx*dx + dy*dy;
        double B = 2*(dx*(start[0]-c.x) + dy*(start[1]-c.y));
        double C = (start[0]-c.x)*(start[0]-c.x) + (start[1]-c.y)*(start[1]-c.y) - c.radius*c.radius;
        double det = B*B - 4*A*C;
        ArrayList<double[]> intersections = new ArrayList<>();
        if (det < 0) {
            return intersections; // no intersection
        } else if (det == 0) {
            if (0 <= -B/(2*A) && -B/(2*A) <= 1) {
                intersections.add(new double[]{start[0] + (-B/(2*A))*dx, start[1] + (-B/(2*A))*dy});
            }
            return intersections;
        } else {
            if (0 <= (-B + Math.sqrt(det))/(2*A) && (-B + Math.sqrt(det))/(2*A) <= 1) {
                intersections.add(new double[]{start[0] + (-B + Math.sqrt(det))/(2*A)*dx, start[1] + (-B + Math.sqrt(det))/(2*A)*dy});
            }
            if (0 <= (-B - Math.sqrt(det))/(2*A) && (-B - Math.sqrt(det))/(2*A) <= 1) {
                intersections.add(new double[]{start[0] + (-B - Math.sqrt(det))/(2*A)*dx, start[1] + (-B - Math.sqrt(det))/(2*A)*dy});
            }
            return intersections;
        }
    }
    
    public double[] intersection(double[] firstInterval, double[] secondInterval) {
        if (firstInterval[1] < secondInterval[0]) {
            return null; // if doesn't intersect
        }
        if (firstInterval[0] > secondInterval[1]) {
            return null; // if doesn't intersect
        }
        if (firstInterval[0] < secondInterval[0]) {
            if (firstInterval[1] < secondInterval[1]) {
                return new double[]{secondInterval[0], firstInterval[1]};
            } else {
                return new double[]{secondInterval[0], secondInterval[0]};
            }
        } else {
            if (firstInterval[1] < secondInterval[1]) {
                return new double[]{firstInterval[0], firstInterval[1]};
            } else {
                return new double[]{firstInterval[0], secondInterval[0]};
            }
        }
    }
    
    public double[] project(Vector v) {
        ArrayList<Double> projs = new ArrayList<>();
        for (double[] vert : vertices) {
            projs.add(project(v.multiply(1/v.size), vert));
        }
        return new double[]{Collections.min(projs), Collections.max(projs)};
    }
    
    public double project(Vector v, double[] point) {
        // v.x*a - v.y*b = point[0]
        // v.y*a + v.x*b = point[1]
        return (point[0] * v.x + point[1] * v.y) / (v.x * v.x + v.y * v.y);
    }
}
