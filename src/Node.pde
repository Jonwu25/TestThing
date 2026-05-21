private class Node {
    Shape data;
    ArrayList<Node> children;
    
    Node(Shape d) {
        data = d;
        children = new ArrayList<Node>();
    }
}
