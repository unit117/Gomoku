import java.util.*;

public class MCTS {
    private static final int SIMULATIONS = 1000;
    private final Board board;
    private final int player;
    private final Random random = new Random();

    public MCTS(Board board, int player) {
        this.board = board;
        this.player = player;
    }

    public void makeMove() {
        Node root = new Node(board, player);
        for (int i = 0; i < SIMULATIONS; i++) {
            Node v = treePolicy(root);
            int reward = defaultPolicy(v.getState());
            v.backPropagate(reward);
        }
        Node bestChild = root.bestChild(0);
        board.getBoardMatrix()[bestChild.getAction()[0]][bestChild.getAction()[1]] = player;
    }

    private Node treePolicy(Node v) {
        while (!v.getState().isTerminal()) {
            if (!v.isFullyExpanded()) {
                return v.expand();
            } else {
                v = v.bestChild(1.0 / Math.sqrt(2));
            }
        }
        return v;
    }

    private int defaultPolicy(Board state) {
        Board tempState = new Board(state);
        int player = this.player;
        while (!tempState.isTerminal()) {
            List<int[]> possibleMoves = tempState.getPossibleMoves();
            int[] action = possibleMoves.get(random.nextInt(possibleMoves.size()));
            tempState.getBoardMatrix()[action[0]][action[1]] = player;
            player = 3 - player; // switch player
        }
        return state.getReward(this.player);
    }
}
