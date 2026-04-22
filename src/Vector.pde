public class Vector{
    float x, y, size, direction;
    public Vector(float x, float y, int mode) {
        if (mode == 0) {
            this.x = x;
            this.y = y;
            this.size = sqrt(pow(x, 2) + pow(y, 2));
            this.direction = atan2(y, x);
        }
        if (mode == 1) {
            this.size = x;
            this.direction = y;
            this.x = x*cos(y);
            this.y = x*sin(y);
        }
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
        return v.multiply(1);
    }
    
    public void display(float x, float y) {
        line(x, y, x+this.x, y+this.y);
    }
}
