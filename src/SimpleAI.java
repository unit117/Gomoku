import java.util.Random;

public class SimpleAI {

    private final Board board;
    private static final int EMPTY = 0;
    private static final int WHITE = 1;
    private static final int BLACK = 2;
    private final int myColor;

    public SimpleAI(Board board, int myColor) {
        this.board = board;
        this.myColor = myColor;
    }

    public void makeMove() {
        for (int i = 0; i < board.getBoardMatrix().length; i++) {
            for (int j = 0; j < board.getBoardMatrix().length; j++) {
                if (checkThreeInRow(i, j, 3, myColor == WHITE ? BLACK : WHITE)) {
                    board.getBoardMatrix()[i][j] = myColor;
                    return;
                }
            }
        }
        makeRandomMove();
    }

    private boolean checkThreeInRow(int x, int y, int length, int color) {
        int[][] directions = {{0, 1}, {1, 0}, {1, 1}, {1, -1}};
        for (int[] dir : directions) {
            int count = 0;
            for (int i = 0; i < length; i++) {
                int dx = x + dir[0] * i;
                int dy = y + dir[1] * i;
                if (dx < 0 || dx >= board.getBoardMatrix().length || dy < 0 || dy >= board.getBoardMatrix().length) {
                    break;
                }
                if (board.getBoardMatrix()[dx][dy] == color) {
                    count++;
                } else {
                    break;
                }
            }
            if (count == length) {
                return true;
            }
        }
        return false;
    }

    private void makeRandomMove() {
        Random random = new Random();
        while (true) {
            int x = random.nextInt(board.getBoardMatrix().length);
            int y = random.nextInt(board.getBoardMatrix().length);
            if (board.getBoardMatrix()[x][y] == EMPTY) {
                board.getBoardMatrix()[x][y] = myColor;
                break;
            }
        }
    }
}
