public abstract class Shape {
    float x, y, rot, radius, mass, rotIne, vRot, vx, vy;
    ArrayList<float[]> positions;
    boolean st = false, rotSt = false;
    boolean inv; // inverted
    
    public void update() {
        positions.add(new float[]{x, y});
        if (positions.size() > 100) {
            positions.remove(0);
        }
        x+=vx;
        y+=vy;
    }
}
