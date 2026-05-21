import java.util.*;

class Circle extends Shape {
    double x, y, rot, radius, mass, rotIne, vRot, vx, vy;
    ArrayList<double[]> positions;
    boolean st = false, rotSt = false;
    boolean inv; // inverted
    
    public Circle(double x, double y, double radius, double mass, double vx, double vy, int mode) {
        this.x = x;
        this.y = y;
        this.radius = radius;
        this.mass = mass;
        this.rotIne = mass;
        positions = new ArrayList<double[]>();
        this.vx = vx;
        this.vy = vy;
    }
    
    public Circle deepCopy() {
        Circle d = new Circle(x, y, radius, mass, vx, vy, 0);
        return d;
    }
    
    public void update() {
        positions.add(new double[]{x, y});
        if (positions.size() > 100) {
            positions.remove(0);
        }
        x+=vx;
        y+=vy;
    }
    
    public boolean samePos(Circle other) {
        return (x==other.x)&&(y==other.y);
    }

    public ArrayList<double[]> circleIntersection(Circle other) {
        ArrayList<double[]> intersections = new ArrayList<>();
        if (checkTouch(other)) {
            double d = Math.sqrt(Math.pow(x - other.x, 2) + Math.pow(y - other.y, 2));
            double a = (Math.pow(radius, 2) - Math.pow(other.radius, 2) + Math.pow(d, 2)) / (2*d);
            double h = Math.sqrt(Math.pow(radius, 2) - Math.pow(a, 2));
            double x2 = x + a*(other.x - x)/d;
            double y2 = y + a*(other.y - y)/d;
            double rx = -(other.y - y) * (h/d);
            double ry = -(other.x - x) * (h/d);
            intersections.add(new double[]{x2 + rx, y2 - ry});
            if (h != 0) {
                intersections.add(new double[]{x2 - rx, y2 + ry});
            }
        }
        return intersections;
    }
    
    public void display() {
        ellipseMode(RADIUS);
        circle((float)x, (float)y, (float)radius);
        stroke(127);
        line((float)x, (float)y, (float)(x+radius*Math.cos(rot)), (float)(y+radius*Math.sin(rot)));
        //line(x, y, x+10*vel.x, y+10*vel.y);
        for (int i = 0; i < positions.size() - 1; i++) {
            stroke(128 + 127 * i / positions.size());
            line((float)positions.get(i)[0], (float)positions.get(i)[1], (float)positions.get(i+1)[0], (float)positions.get(i+1)[1]);
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
        return (Math.sqrt(Math.pow(this.x - other.x, 2) + Math.pow(this.y - other.y, 2)) < this.radius + other.radius);
    }
    
    public double[] project(Vector v) {
        double center = project(v.multiply(1/v.size), new double[]{x, y});
        return new double[]{center - radius, center + radius};
    }
    
    public double project(Vector v, double[] point) {
        // v.x*a - v.y*b = point[0]
        // v.y*a + v.x*b = point[1]
        return (point[0] * v.x + point[1] * v.y) / (v.x * v.x + v.y * v.y);
    }
    
    public boolean inside(double[] point) {
        return (Math.sqrt(Math.pow(point[0] - x, 2)+Math.pow(point[1] - y, 2)) < radius);
    }
}
