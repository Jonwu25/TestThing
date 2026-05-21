public class Tree { // Technically is a forest 
    ArrayList<Node> roots;
    public Tree() {
        // Children are shapes that are inside of parent
    }
    
    public void addTree(Node x) {
        //    O        O
        //    |   ->  / \
        //    O   -> O   O
        if (roots == null) {
            roots = new ArrayList<>();
            roots.add(x);
            return;
        }
        roots.add(x);
    }
    
    public Node get(ArrayList<Integer> loc) {
        Node cur = roots.get(loc.get(0));
        for (int i = 1; i < loc.size(); i++) {
            cur = cur.children.get(loc.get(i));
        }
        return cur;
    }
    
    public void removeTree(ArrayList<Integer> loc) {
        Node cur = roots.get(loc.get(0));
        for (int i = 1; i < loc.size()-1; i++) {
            cur = cur.children.get(loc.get(i));
        }
        cur.children.remove(loc.get(loc.size()-1));
    }
}
