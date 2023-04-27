import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public class Node {
    private static final double EPSILON = 1e-6;
    private final Board state;
    private final int player;
    private Node parent;
    private List<Node> children;
    private int[] action;
    private int wins;
    private int visits;

    public Node(Board state, int player) {
        this.state = state;
        this.player = player;
        this.children = new ArrayList<>();
    }

    public Node(Board state, int player, Node parent, int[] action) {
        this(state, player);
        this.parent = parent;
        this.action = action;
    }

    public Board getState() {
        return state;
    }

    public int[] getAction() {
        return action;
    }

    public boolean isFullyExpanded() {
        return state.getPossibleMoves().size() == children.size();
    }

    public Node expand() {
        List<int[]> possibleMoves = state.getPossibleMoves();
        for (Node child : children) {
            possibleMoves.remove(child.getAction());
        }
        int[] action = possibleMoves.get(new Random().nextInt(possibleMoves.size()));
        Node child = new Node(new Board(state), 3 - player, this, action);
        child.getState().getBoardMatrix()[action[0]][action[1]] = player;
        children.add(child);
        return child;
    }

    public void backPropagate(int reward) {
        visits++;
        wins += reward;
        if (parent != null) {
            parent.backPropagate(reward);
        }
    }

    public Node bestChild(double c) {
        Node bestChild = null;
        double bestValue = Double.NEGATIVE_INFINITY;
        for (Node child : children) {
            double uctValue =
                    child.wins / (double) (child.visits + EPSILON) +
                            c * Math.sqrt(Math.log(visits + 1) / (child.visits + EPSILON)) +
                            new Random().nextDouble() * EPSILON;
            if (uctValue > bestValue) {
                bestChild = child;
                bestValue = uctValue;
            }
        }
        return bestChild;
    }
}
