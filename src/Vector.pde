public class Vector{
    double x, y, size, direction;
    public Vector(double x, double y, int mode) {
        if (mode == 0) {
            this.x = x;
            this.y = y;
            this.size = Math.sqrt(Math.pow(x, 2) + Math.pow(y, 2));
            if (x == 0 && y == 0) {
                this.direction = 0;
            } else {
                this.direction = Math.atan2(y, x);
            }
        }
        if (mode == 1) {
            this.size = x;
            this.direction = y;
            this.x = x*Math.cos(y);
            this.y = x*Math.sin(y);
        }
    }

    public Vector(double[] s, double[] e) {
        Vector t = new Vector(e[0]-s[0], e[1]-s[1], 0);
        x = t.x;
        y = t.y;
        size = t.size;
        direction = t.direction;
    }
    
    public Vector deepCopy() {
        return new Vector(x, y, 0);
    }
    
    public double[] standard() {
        return new double[]{this.x, this.y};
    }
    
    public double[] rotation() {
        return new double[]{Math.sqrt(Math.pow(this.x, 2) + Math.pow(this.y, 2)), Math.atan2(this.y, this.x)};
    }
    
    public Vector add(Vector other) {
        return new Vector(this.x + other.x, this.y + other.y, 0);
    }
    
    public Vector subtract(Vector other) {
        return new Vector(this.x - other.x, this.y - other.y, 0);
    }
    
    public Vector multiply(double scalar) {
        return new Vector(scalar*x, scalar*y, 0);
    }
    
    public Vector reflect(Vector other) {
        // reflect by line perpendicular to other
        Vector v = new Vector(this.size, 2*other.direction - this.direction + PI, 1);
        return v.multiply(0.9);
    }
    
    public void display(double x, double y) {
        line((float)x, (float)y, (float)(x+this.x), (float)(y+this.y));
    }

    public double angle(Vector v) {
        return (v.direction-direction+2*PI)%(2*PI);
    }

    public double cross(Vector v) {
        return this.x*v.y - this.y*v.x;
    }
    
    public double dot(Vector v) {
        return this.x*v.x + this.y*v.y;
    }
    
    public String toString() {
        return "("+x+", "+y+")"+", ("+size+", "+direction+")";
    }
}
