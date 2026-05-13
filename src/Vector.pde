public class Vector{
    float x, y, size, direction;
    public Vector(float x, float y, int mode) {
        if (mode == 0) {
            this.x = x;
            this.y = y;
            this.size = sqrt(pow(x, 2) + pow(y, 2));
            if (x == 0 && y == 0) {
                this.direction = 0;
            } else {
                this.direction = atan2(y, x);
            }
        }
        if (mode == 1) {
            this.size = x;
            this.direction = y;
            this.x = x*cos(y);
            this.y = x*sin(y);
        }
    }

    public Vector(float[] s, float[] e) {
        Vector t = new Vector(e[0]-s[0], e[1]-s[1], 0);
        x = t.x;
        y = t.y;
        size = t.size;
        direction = t.direction;
    }
    
    public Vector deepCopy() {
        return new Vector(x, y, 0);
    }
    
    public float[] standard() {
        return new float[]{this.x, this.y};
    }
    
    public float[] rotation() {
        return new float[]{sqrt(pow(this.x, 2) + pow(this.y, 2)), atan2(this.y, this.x)};
    }
    
    public Vector add(Vector other) {
        return new Vector(this.x + other.x, this.y + other.y, 0);
    }
    
    public Vector subtract(Vector other) {
        return new Vector(this.x - other.x, this.y - other.y, 0);
    }
    
    public Vector multiply(float scalar) {
        return new Vector(scalar*x, scalar*y, 0);
    }
    
    public Vector reflect(Vector other) {
        // reflect by line perpendicular to other
        Vector v = new Vector(this.size, 2*other.direction - this.direction + PI, 1);
        return v.multiply(0.9);
    }
    
    public void display(float x, float y) {
        line(x, y, x+this.x, y+this.y);
    }

    public float angle(Vector v) {
        return (v.direction-direction+2*PI)%(2*PI);
    }

    public float cross(Vector v) {
        return this.x*v.y - this.y*v.x;
    }
    
    public float dot(Vector v) {
        return this.x*v.x + this.y*v.y;
    }
    
    public String toString() {
        return "("+x+", "+y+")"+", ("+size+", "+direction+")";
    }
}
