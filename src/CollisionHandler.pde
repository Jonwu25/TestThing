import java.util.*;

class CollisionHandler {
    Tree shapes;
    double elasticity = 1f;

    public CollisionHandler(Tree shapes) {
        this.shapes = shapes;
    }
    
    public HashMap<ArrayList<Integer>, Vector>[] merge(HashMap<ArrayList<Integer>, Vector>[] x,  HashMap<ArrayList<Integer>, Vector>[] y) {
          HashMap<ArrayList<Integer>, Vector>[] res = (HashMap<ArrayList<Integer>, Vector>[]) new HashMap[2];
          res[0] = x[0];
          res[1] = x[1];
          for (ArrayList<Integer> k : y[0].keySet()) {
              res[0].merge(k, y[0].get(k), (Vector v, Vector w) -> {return v.add(w);});
              res[1].merge(k, y[1].get(k), (Vector v, Vector w) -> {return v.add(w);});
          }
          return res;
    }
    
    public HashMap<ArrayList<Integer>, Vector>[] handleCircles(Circle s, Circle t, ArrayList<Integer> locS, ArrayList<Integer> locT, int cond) {
        // cond is 0 for s and t apart, 1 for s inside t, 2 for t inside s
        HashMap<ArrayList<Integer>, Vector>[] res = (HashMap<ArrayList<Integer>, Vector>[]) new HashMap[2];
        res[0] = new HashMap<ArrayList<Integer>, Vector>();
        res[1] = new HashMap<ArrayList<Integer>, Vector>();
        ArrayList<double[]> intersections = s.circleIntersection(t);
        if (intersections.size() == 0) {
            return res;
        }
        Vector normal = nor(s, t, cond);
        double[] intersection = new double[2];
        for (int k = 0; k < intersections.size(); k++) {
            intersection[0] += intersections.get(k)[0] / intersections.size();
            intersection[1] += intersections.get(k)[1] / intersections.size();
        }
        Vector sv = new Vector(new double[]{s.x, s.y}, intersection);
        sv = new Vector(sv.size * s.vRot, sv.direction + PI/2, 1);
        sv = sv.add(new Vector(s.vx, s.vy, 0));
        Vector tv = new Vector(new double[]{t.x, t.y}, intersection);
        tv = new Vector(tv.size * t.vRot, tv.direction + PI/2, 1);
        tv = tv.add(new Vector(t.vx, t.vy, 0));
        double relDot = sv.subtract(tv).dot(normal);
        if (relDot >= 0) {
            return res;
        }
        double impulse = -(1 + elasticity) * relDot;
        double denom = 0;
        if (!s.st) {
            denom += 1 / s.mass;
        }
        if (!t.st) {
            denom += 1 / t.mass;
        }
        if (!s.rotSt) {
            Vector r = new Vector(new double[]{s.x, s.y}, intersection);
            denom += Math.pow(r.cross(normal), 2) / s.rotIne;
        }
        if (!t.rotSt) {
            Vector r = new Vector(new double[]{t.x, t.y}, intersection);
            denom += Math.pow(r.cross(normal), 2) / t.rotIne;
        }
        if (denom == 0) {
            return res;
        }
        impulse /= denom;
        Vector impu = normal.multiply(impulse);
        Vector dVelS = new Vector(0, 0, 0);
        double dRotS = 0;
        Vector dVelT = new Vector(0, 0, 0);
        double dRotT = 0;
        if (!s.st) {
            dVelS = dVelS.add(impu.multiply(1 / s.mass));
        }
        if (!s.rotSt) {
            Vector r = new Vector(new double[]{s.x, s.y}, intersection);
            dRotS += r.cross(impu) / s.rotIne;
        }
        if (!t.st) {
            dVelT = dVelT.add(impu.multiply(-1 / t.mass));
        }
        if (!t.rotSt) {
            Vector r = new Vector(new double[]{t.x, t.y}, intersection);
            dRotT += r.cross(impu.multiply(-1)) / t.rotIne;
        }
        res[0].put(new ArrayList<Integer>(locS), dVelS);
        res[1].put(new ArrayList<Integer>(locS), new Vector(dRotS, 0, 0));
        res[0].put(new ArrayList<Integer>(locT), dVelT);
        res[1].put(new ArrayList<Integer>(locT), new Vector(dRotT, 0, 0));
        return res;
    }

    public HashMap<ArrayList<Integer>, Vector>[] handlePolygons(Polygon s, Polygon t, ArrayList<Integer> locS, ArrayList<Integer> locT, int cond) {
        // cond is 0 for s and t apart, 1 for s inside t, 2 for t inside s
        HashMap<ArrayList<Integer>, Vector>[] res = (HashMap<ArrayList<Integer>, Vector>[]) new HashMap[2];
        res[0] = new HashMap<ArrayList<Integer>, Vector>();
        res[1] = new HashMap<ArrayList<Integer>, Vector>();
        ArrayList<double[]> intersections = s.intersections(t, cond);
        if (intersections.size() == 0) {
            return res;
        }
        double[] center = new double[2];
        for (int k = 0; k < intersections.size(); k++) {
            center[0] += intersections.get(k)[0] / intersections.size();
            center[1] += intersections.get(k)[1] / intersections.size();
        }
        Vector normal = nor(s, t, cond);
        double[] intersection = new double[2];
        for (int k = 0; k < intersections.size(); k++) {
            intersection[0] += intersections.get(k)[0] / intersections.size();
            intersection[1] += intersections.get(k)[1] / intersections.size();
        }
        Vector sv = new Vector(new double[]{s.x, s.y}, intersection);
        sv = new Vector(sv.size * s.vRot, sv.direction + PI/2, 1);
        sv = sv.add(new Vector(s.vx, s.vy, 0));
        Vector tv = new Vector(new double[]{t.x, t.y}, intersection);
        tv = new Vector(tv.size * t.vRot, tv.direction + PI/2, 1);
        tv = tv.add(new Vector(t.vx, t.vy, 0));
        double relDot = sv.subtract(tv).dot(normal);
        if (relDot >= 0) {
            return res;
        }
        double impulse = -(1 + elasticity) * relDot;
        textSize(12);
        textAlign(LEFT, TOP);
        text((float) impulse, 0, 0);
        double denom = 0;
        if (!s.st) {
            denom += 1 / s.mass;
        }
        if (!t.st) {
            denom += 1 / t.mass;
        }
        if (!s.rotSt) {
            Vector r = new Vector(new double[]{s.x, s.y}, intersection);
            denom += Math.pow(r.cross(normal), 2) / s.rotIne;
        }
        if (!t.rotSt) {
            Vector r = new Vector(new double[]{t.x, t.y}, intersection);
            denom += Math.pow(r.cross(normal), 2) / t.rotIne;
        }
        if (denom == 0) {
            return res;
        }
        impulse /= denom;
        Vector impu = normal.multiply(impulse);
        Vector dVelS = new Vector(0, 0, 0);
        double dRotS = 0;
        Vector dVelT = new Vector(0, 0, 0);
        double dRotT = 0;
        if (!s.st) {
            dVelS = dVelS.add(impu.multiply(1 / s.mass));
        }
        if (!s.rotSt) {
            Vector r = new Vector(new double[]{s.x, s.y}, intersection);
            dRotS += r.cross(impu) / s.rotIne;
        }
        if (!t.st) {
            dVelT = dVelT.add(impu.multiply(-1 / t.mass));
        }
        if (!t.rotSt) {
            Vector r = new Vector(new double[]{t.x, t.y}, intersection);
            dRotT += r.cross(impu.multiply(-1)) / t.rotIne;
        }
        res[0].put(new ArrayList<Integer>(locS), dVelS);
        res[1].put(new ArrayList<Integer>(locS), new Vector(dRotS, 0, 0));
        res[0].put(new ArrayList<Integer>(locT), dVelT);
        res[1].put(new ArrayList<Integer>(locT), new Vector(dRotT, 0, 0));
        return res;
    }

    public HashMap<ArrayList<Integer>, Vector>[] handleCirclePolygon(Circle s, Polygon t, ArrayList<Integer> locS, ArrayList<Integer> locT, int cond) {
        // cond is 0 for s and t apart, 1 for s inside t, 2 for t inside s
        HashMap<ArrayList<Integer>, Vector>[] res = (HashMap<ArrayList<Integer>, Vector>[]) new HashMap[2];
        res[0] = new HashMap<ArrayList<Integer>, Vector>();
        res[1] = new HashMap<ArrayList<Integer>, Vector>();
        ArrayList<double[]> intersections = t.polygonCircleIntersection(s, cond);
        if (intersections.size() == 0) {
            return res;
        }
        double[] intersection = new double[2];
        for (int k = 0; k < intersections.size(); k++) {
            intersection[0] += intersections.get(k)[0] / intersections.size();
            intersection[1] += intersections.get(k)[1] / intersections.size();
        }
        Vector normal = nor(t, s, cond);
        Vector pv = new Vector(new double[]{t.x, t.y}, intersection);
        pv = new Vector(pv.size * t.vRot, pv.direction + PI/2, 1);
        pv = pv.add(new Vector(t.vx, t.vy, 0));
        Vector cv = new Vector(new double[]{s.x, s.y}, intersection);
        cv = new Vector(cv.size * s.vRot, cv.direction + PI/2, 1);
        cv = cv.add(new Vector(s.vx, s.vy, 0));
        double relDot = cv.subtract(pv).dot(normal);
        if (relDot >= 0) {
            return res;
        }
        double impulse = -(1 + elasticity) * relDot;
        double denom = 0;
        if (!t.st) {
            denom += 1 / t.mass;
        }
        if (!s.st) {
            denom += 1 / s.mass;
        }
        if (!t.rotSt) {
            Vector r = new Vector(new double[]{t.x, t.y}, intersection);
            denom += Math.pow(r.cross(normal), 2) / t.rotIne;
        }
        if (!s.rotSt) {
            Vector r = new Vector(new double[]{s.x, s.y}, intersection);
            denom += Math.pow(r.cross(normal), 2) / s.rotIne;
        }
        if (denom == 0) {
            return res;
        }
        impulse /= denom;
        Vector impu = normal.multiply(impulse);
        Vector dVelC = new Vector(0, 0, 0);
        double dRotC = 0;
        Vector dVelP = new Vector(0, 0, 0);
        double dRotP = 0;
        if (!s.st) {
            dVelC = dVelC.add(impu.multiply(1 / s.mass));
        }
        if (!s.rotSt) {
            Vector r = new Vector(new double[]{s.x, s.y}, intersection);
            dRotC += r.cross(impu) / s.rotIne;
        }
        if (!t.st) {
            dVelP = dVelP.add(impu.multiply(-1 / t.mass));
        }
        if (!t.rotSt) {
            Vector r = new Vector(new double[]{t.x, t.y}, intersection);
            dRotP += r.cross(impu.multiply(-1)) / t.rotIne;
        }
        res[0].put(new ArrayList<Integer>(locS), dVelC);
        res[1].put(new ArrayList<Integer>(locS), new Vector(dRotC, 0, 0));
        res[0].put(new ArrayList<Integer>(locT), dVelP);
        res[1].put(new ArrayList<Integer>(locT), new Vector(dRotP, 0, 0));
        return res;
    }
    
    public HashMap<ArrayList<Integer>, Vector>[] handleCollisions(ArrayList<Integer> loc) {
        Node cur = shapes.get(loc);
        HashMap<ArrayList<Integer>, Vector>[] res = (HashMap<ArrayList<Integer>, Vector>[]) new HashMap[2];
        res[0] = new HashMap<ArrayList<Integer>, Vector>();
        res[1] = new HashMap<ArrayList<Integer>, Vector>();
        if (cur.children == null) {
            return res;
        }
        for(int i = 0; i < cur.children.size(); i++) {
            Shape c = cur.data;
            Shape c1 = cur.children.get(i).data;
            ArrayList<Integer> childLoc = new ArrayList<>(loc);
            childLoc.add(i);
            if (Circle.class.isInstance(c)) {
                if (Circle.class.isInstance(c1)) {
                    res = merge(res, handleCircles((Circle)c, (Circle)c1, loc, childLoc, 2));
                }
                if (Polygon.class.isInstance(c1)) {
                    res = merge(res, handleCirclePolygon((Circle)c, (Polygon)c1, loc, childLoc, 2));
                }
            }
            if (Polygon.class.isInstance(c)) {
                if (Circle.class.isInstance(c1)) {
                    res = merge(res, handleCirclePolygon((Circle)c1, (Polygon)c, childLoc, loc, 1));
                }
                if (Polygon.class.isInstance(c1)) {
                    res = merge(res, handlePolygons((Polygon)c, (Polygon)c1, loc, childLoc, 2));
                }
            }
            for (int j = i+1; j < cur.children.size(); j++) {
                Shape c2 = cur.children.get(j).data;
                ArrayList<Integer> loc1 = new ArrayList<>(loc);
                loc1.add(i);
                ArrayList<Integer> loc2 = new ArrayList<>(loc);
                loc2.add(j);
                if (Circle.class.isInstance(c1)) {
                    if (Circle.class.isInstance(c2)) {
                        res = merge(res, handleCircles((Circle)c1, (Circle)c2, loc1, loc2, 0));
                    }
                    if (Polygon.class.isInstance(c2)) {
                        res = merge(res, handleCirclePolygon((Circle)c1, (Polygon)c2, loc1, loc2, 0));
                    }
                }
                if (Polygon.class.isInstance(c1)) {
                    if (Circle.class.isInstance(c2)) {
                        res = merge(res, handleCirclePolygon((Circle)c2, (Polygon)c1, loc2, loc1, 0));
                    }
                    if (Polygon.class.isInstance(c2)) {
                        res = merge(res, handlePolygons((Polygon)c1, (Polygon)c2, loc1, loc2, 0));
                    }
                }
            }
        }
        for (int i = 0; i < cur.children.size(); i++) {
            ArrayList<Integer> newLoc = new ArrayList<>(loc);
            newLoc.add(i);
            HashMap<ArrayList<Integer>, Vector>[] childRes = handleCollisions(newLoc);
            res = merge(res, childRes);
        }
        return res;
    }
    
    public void handleCollisions() {
        HashMap<ArrayList<Integer>, Vector> newVel = new HashMap<>();
        HashMap<ArrayList<Integer>, Vector> newAngRot = new HashMap<>(); // x value is the actual thing, y value is 0
        
        for (int i = 0; i < shapes.roots.size(); i++) {
            ArrayList<Integer> loc = new ArrayList<>(Arrays.asList(i));
            HashMap<ArrayList<Integer>, Vector>[] res = handleCollisions(loc);
            for (ArrayList<Integer> k : res[0].keySet()) {
                newVel.merge(k, res[0].get(k), (Vector v, Vector w) -> {return v.add(w);});
                newAngRot.merge(k, res[1].get(k), (Vector v, Vector w) -> {return v.add(w);});
            }
        }
        
        setNewVels(newVel, newAngRot);
    }

    public void setNewVels(HashMap<ArrayList<Integer>, Vector> newVel, HashMap<ArrayList<Integer>, Vector> newAngRot) {
        for (ArrayList<Integer> k : newVel.keySet()) {
            Node cur = shapes.get(k);
            if (Circle.class.isInstance(cur.data)) {
                Circle c = (Circle)cur.data;
                c.vx += newVel.get(k).x;
                c.vy += newVel.get(k).y;
                c.vRot += newAngRot.get(k).x;
            }
            if (Polygon.class.isInstance(cur.data)) {
                Polygon p = (Polygon)cur.data;
                p.vx += newVel.get(k).x;
                p.vy += newVel.get(k).y;
                p.vRot += newAngRot.get(k).x;
            }
        }
    }
    
    public Vector nor(Polygon p, Polygon q, int cond) {
        // Returns normal vector of collision
        
        // p is polygon normal vector is acting on
        // q is polygon of collision
        
        // Should probably change
        ArrayList<Vector> possibleAxis = new ArrayList<>();

        // Add edge normals from both polygons as potential separating axes
        for (int i = 0; i < p.vertices.length; i++) {
            double[] a = p.vertices[i];
            double[] b = p.vertices[(i+1) % p.vertices.length];
            possibleAxis.add(new Vector(a, b));
        }
        for (int i = 0; i < q.vertices.length; i++) {
            double[] a = q.vertices[i];
            double[] b = q.vertices[(i+1) % q.vertices.length];
            possibleAxis.add(new Vector(a, b));
        }

        double minIntersect = Double.MAX_VALUE;
        Vector minInter = new Vector(0, 0, 0);

        for (Vector edge : possibleAxis) {
            Vector axis = new Vector(1, edge.direction + PI/2, 1);
            double[] intP = p.project(axis);
            double[] intQ = q.project(axis);
            double overlap = Math.min(intP[1], intQ[1]) - Math.max(intP[0], intQ[0]);
            if (overlap < minIntersect) {
                minInter = axis;
                minIntersect = overlap;
            }
        }

        Vector v = new Vector(1, minInter.direction, 1);
        Vector w = new Vector(new double[]{p.ax, p.ay}, new double[]{q.ax, q.ay});
        if (v.dot(w) > 0) {
            v = v.multiply(-1);
        }
        if (cond == 1 || cond == 2) {
            v = v.multiply(-1);
        }
        return v;
    }
    
    public Vector nor(Polygon p, Circle c, int cond) {
        double edgeMin = Double.MAX_VALUE;
        int edgeI = -1;
        double vertMin = Double.MAX_VALUE;
        int vertI = -1;
        // Act on c

        for (int i = 0; i < p.vertices.length; i++) {
            // (x-a[0])/(b[0]-a[0])+(y-a[1])/(b[1]-a[1])=0
            double[] a = p.vertices[i];
            double[] b = p.vertices[(i+1)%p.vertices.length];
            double d = p.project(new Vector(a, b), new double[]{c.x-a[0], c.y-a[1]});
            double dist;
            if (0 <= d && d <= 1) {
                dist = Math.abs((a[0]-b[0])*c.ay+(b[1]-a[1])*c.ax+b[0]*a[1]-a[0]*b[1])/Math.sqrt(Math.pow((b[0]-a[0]), 2)+Math.pow((b[1]-a[1]), 2));
            } else if (d < 0) {
                dist = Math.sqrt(Math.pow(c.ax-a[0], 2)+Math.pow(c.ay-a[1], 2));
            } else {
                dist = Math.sqrt(Math.pow(c.ax-b[0], 2)+Math.pow(c.ay-b[1], 2));
            }
            if (dist < edgeMin) {
                edgeMin = dist;
                edgeI = i;
            }
        }

        for (int i = 0; i < p.vertices.length; i++) {
            double[] a = p.vertices[i];
            double dist = Math.sqrt(Math.pow(c.ax-a[0], 2)+Math.pow(c.ay-a[1], 2));
            if (dist < vertMin) {
                vertMin = dist;
                vertI = i;
            }
        }

        if (vertMin <= edgeMin) {
            Vector v = new Vector(new double[]{c.ax, c.ay}, p.vertices[vertI]);
            if (v.dot(new Vector(new double[]{c.ax, c.ay}, new double[]{p.ax, p.ay})) > 0) {
                v = v.multiply(-1);
            }
            if (cond == 1 || cond == 2) {
                v = v.multiply(-1);
            }
            return new Vector(1, v.direction, 1);
        } else {
            Vector v = new Vector(p.vertices[edgeI], p.vertices[(edgeI+1)%p.vertices.length]);
            v = new Vector(1, v.direction + PI/2, 1);
            if (v.dot(new Vector(new double[]{c.ax, c.ay}, new double[]{p.ax, p.ay})) > 0) {
                v = v.multiply(-1);
            }
            if (cond == 1 || cond == 2) {
                v = v.multiply(-1);
            }
            return v;
        }
    }
    
    public Vector nor(Circle c, Circle d, int cond) {
        // Act on c
        Vector v = new Vector(c.ax-d.ax, c.ay-d.ay, 0);
        if (cond == 1 || cond == 2) {
            v = v.multiply(-1);
        }
        return new Vector(1, v.direction, 1);
    }

    public void update() {
        for (int i = 0; i < shapes.roots.size(); i++) {
            ArrayList<Integer> loc = new ArrayList<>(Arrays.asList(i));
            update(loc);
        }
    }

    public void update(ArrayList<Integer> loc) {
        Node cur = shapes.get(loc);
        if (cur.children == null) {
            return;
        }
        if (Circle.class.isInstance(cur.data)) {
            Circle c = (Circle)cur.data;
            c.update();
        }
        if (Polygon.class.isInstance(cur.data)) {
            Polygon p = (Polygon)cur.data;
            p.update();
        }
        for (int i = 0; i < cur.children.size(); i++) {
            ArrayList<Integer> newLoc = new ArrayList<>(loc);
            newLoc.add(i);
            update(newLoc);
        }
    }

    public void display(ArrayList<Integer> loc) {
        Node cur = shapes.get(loc);
        if (cur.children == null) {
            return;
        }
        if (Circle.class.isInstance(cur.data)) {
            Circle c = (Circle)cur.data;
            c.display();
        }
        if (Polygon.class.isInstance(cur.data)) {
            Polygon p = (Polygon)cur.data;
            p.display();
        }
        for (int i = 0; i < cur.children.size(); i++) {
            ArrayList<Integer> newLoc = new ArrayList<>(loc);
            newLoc.add(i);
            display(newLoc);
        }
    }

    public void display() {
        for (int i = 0; i < shapes.roots.size(); i++) {
            ArrayList<Integer> loc = new ArrayList<>(Arrays.asList(i));
            display(loc);
        }
    }
}

