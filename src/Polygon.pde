import java.util.*;

class Polygon extends Shape {
    double[][] vertices, origVertices;
    ArrayList<double[]> positions;
    double x, y, ax, ay, rot, vx, vy, vRot, rotIne, mass;
    boolean st = false, rotSt = false;
    boolean inv = false;
  
    public Polygon(double x, double y, double[][] vertices) {
        this.vertices = vertices;
        this.origVertices = new double[vertices.length][2];
        for (int i = 0; i < vertices.length; i++) {
            this.origVertices[i][0] = vertices[i][0];
            this.origVertices[i][1] = vertices[i][1];
        }
        this.x = x;
        this.y = y;
        positions = new ArrayList<double[]>();
        this.ax = 0;
        this.ay = 0;
        for (double[] vert : vertices) {
            ax += vert[0];
            ay += vert[1];
        }
        this.ax /= vertices.length;
        this.ay /= vertices.length;
        ax += x;
        ay += y;
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
        ax = 0;
        ay = 0;
        for (double[] vert : vertices) {
            ax += vert[0];
            ay += vert[1];
        }
        ax /= vertices.length;
        ay /= vertices.length;
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
    
    public ArrayList<double[]> intersections(Polygon other, int cond) {
        // From O'Rourke
        // cond: 0 for normal, 1 for this in other, 2 for other in this
        int startOne = 0;
        int startTwo = 0;
        int inside = -1; // will be 1 number: 0/1 for which polygon
        ArrayList<double[]> intersections = new ArrayList<>();
        double[] lastIntersection = null;
        for (int i = 0; i < 2*(vertices.length + other.vertices.length); i++) {
            if (checkIntersect(vertices[startOne], vertices[(startOne-1+vertices.length)%vertices.length],
                               other.vertices[startTwo], other.vertices[(startTwo-1+other.vertices.length)%other.vertices.length])) {
                double[] intersectionPoint = intersection(vertices[startOne], vertices[(startOne-1+vertices.length)%vertices.length],
                                                         other.vertices[startTwo], other.vertices[(startTwo-1+other.vertices.length)%other.vertices.length]);
                if (lastIntersection != null && !(lastIntersection[0] == intersectionPoint[0] && lastIntersection[1] == intersectionPoint[1])) {
                    if (intersections.size() > 0) {
                        if (intersections.get(0)[0] == intersectionPoint[0] && intersections.get(0)[1] == intersectionPoint[1]) {
                            return intersections;
                        }
                    }
                }
                addPoint(intersections, intersectionPoint);
                lastIntersection = intersectionPoint.clone();
                Vector qDot = new Vector(other.vertices[(startTwo-1+other.vertices.length)%other.vertices.length], other.vertices[startTwo]);
                Vector pHalf = new Vector(other.vertices[(startTwo-1+other.vertices.length)%other.vertices.length], vertices[startOne]);
                if (qDot.cross(pHalf) >= 0) {
                    inside = 0;
                } else {
                    inside = 1;
                }
            }
            Vector qDot = new Vector(other.vertices[(startTwo-1+other.vertices.length)%other.vertices.length], other.vertices[startTwo]);
            Vector pDot = new Vector(vertices[(startOne-1+vertices.length)%vertices.length], vertices[startOne]);
            Vector pHalf = new Vector(other.vertices[(startTwo-1+other.vertices.length)%other.vertices.length], vertices[startOne]);
            Vector qHalf = new Vector(vertices[(startOne-1+vertices.length)%vertices.length], other.vertices[startTwo]);
            if (qDot.cross(pDot) >= 0) {
                if (qDot.cross(pHalf) >= 0) {
                    // advance Q
                    if (inside == 1 && cond != 2) {
                        addPoint(intersections, other.vertices[startTwo]);
                        lastIntersection = other.vertices[startTwo].clone();
                    }
                    startTwo = (startTwo + 1) % other.vertices.length;
                } else {
                    // advance P
                    if (inside == 0 && cond != 1) {
                        addPoint(intersections, vertices[startOne]);
                        lastIntersection = vertices[startOne].clone();
                    }
                    startOne = (startOne + 1) % vertices.length;
                }
            } else {
                if (pDot.cross(qHalf) >= 0) {
                    // advance P
                    if (inside == 0 && cond != 1) {
                        addPoint(intersections, vertices[startOne]);
                        lastIntersection = vertices[startOne].clone();
                    }
                    startOne = (startOne + 1) % vertices.length;
                } else {
                    // advance Q
                    if (inside == 1 && cond != 2) {
                        addPoint(intersections, other.vertices[startTwo]);
                        lastIntersection = other.vertices[startTwo].clone();
                    }
                    startTwo = (startTwo + 1) % other.vertices.length;
                }
            }
        }
        if (inside(other.vertices[0])) {
            if (cond != 1) {
                for (double[] vertex : vertices) {
                    addPoint(intersections, vertex);
                }
            }
        } else if (other.inside(vertices[0])) {
            if (cond != 2) {
                for (double[] vertex : other.vertices) {
                    addPoint(intersections, vertex);
                }
            }
        } else {
            // no intersections
        }
        return intersections;
    }

    private void addPoint(ArrayList<double[]> intersections, double[] point) {
        for (double[] existing : intersections) {
            if (existing[0] == point[0] && existing[1] == point[1]) {
                return;
            }
        }
        intersections.add(point.clone());
    }

    public boolean inside(double[] p) {
        for (int i = 0; i < vertices.length; i++) {
            Vector v1 = new Vector(vertices[i], vertices[(i+1)%vertices.length]);
            Vector v2 = new Vector(p, vertices[(i+1)%vertices.length]);
            if (v1.cross(v2) < 0) {
                return false;
            }
        }
        return true;
    }
    
    public boolean checkIntersect(double[] startOne, double[] endOne, double[] startTwo, double[] endTwo) {
        double[] intersectPoint = intersection(startOne, endOne, startTwo, endTwo);
        if (intersectPoint != null && onSegment(intersectPoint, startOne, endOne) && onSegment(intersectPoint, startTwo, endTwo)) {
            return true;
        }
        return false;
    }

    public double[] intersection(double[] p, double[] q, double[] r, double[] s) {
        // x = dx1*t1 + p[0] = dx2*t2 + r[0]
        // y = dy1*t1 + p[1] = dy2*t2 + r[1]
        double dx1 = q[0] - p[0];
        double dy1 = q[1] - p[1];
        double dx2 = s[0] - r[0];
        double dy2 = s[1] - r[1];
        double denom = dx1 * dy2 - dy1 * dx2; // cancels out t2

        if (denom == 0) {
            return null; // parallel or collinear
        }

        double t = ((r[0] - p[0]) * dy2 - (r[1] - p[1]) * dx2) / denom;
        double x = p[0] + t * dx1;
        double y = p[1] + t * dy1;
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

    public ArrayList<double[]> polygonCircleIntersection(Circle c, int cond) {
        // cond: 0 for normal, 1 for this in other, 2 for other in this
        ArrayList<double[]> intersections = new ArrayList<>();
        for (int i = 0; i < vertices.length; i++) {
            double[] start = vertices[i];
            double[] end = vertices[(i+1) % vertices.length];
            intersections.addAll(lineCircleIntersection(start, end, c));
            if (c.inside(start)) {
                intersections.add(start);
            }
        }
        if (cond != 1 && intersections.size() == 0 && c.inside(new double[]{ax, ay})) {
            intersections.addAll(Arrays.asList(vertices));
        }
        if (cond != 2 && intersections.size() == 0 && inside(new double[]{c.ax, c.ay})) {
            intersections.add(new double[]{c.x, c.y});
        }
        return intersections;
    }

    public ArrayList<double[]> lineCircleIntersection(double[] start, double[] end, Circle c) {
        double dx = end[0] - start[0];
        double dy = end[1] - start[1];
        double A = dx*dx + dy*dy;
        double B = 2*(dx*(start[0]-c.ax) + dy*(start[1]-c.ay));
        double C = (start[0]-c.ax)*(start[0]-c.ax) + (start[1]-c.ay)*(start[1]-c.ay) - c.radius*c.radius;
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
