import java.awt.event.MouseListener;
import java.util.ArrayList;
import java.util.List;

public class Board {
    // Instance variables
    private BoardGUI gui; // The graphical user interface for the board
    private int[][] boardMatrix; // A 2D array representing the state of the board
    // 0: Empty, 1: White, 2: Black
    private static final int EMPTY = 0;
    private static final int WHITE = 1;
    private static final int BLACK = 2;

    public Board(int sideLength, int boardSize) {
        gui = new BoardGUI(sideLength, boardSize);
        boardMatrix = new int[boardSize][boardSize];
    }

    public Board(Board board) {
        int[][] matrixToCopy = board.getBoardMatrix();
        boardMatrix = new int[matrixToCopy.length][matrixToCopy.length];
        for (int i = 0; i < matrixToCopy.length; i++) {
            System.arraycopy(matrixToCopy[i], 0, boardMatrix[i], 0, matrixToCopy.length);
        }
    }

    // Returns the size of the board
    public int getBoardSize() {
        return boardMatrix.length;
    }

    // Removes the stone at the given position from the board (without updating the GUI)
    public void removePiece(int posX, int posY) {
        boardMatrix[posY][posX] = EMPTY;
    }

    // Adds a stone of the specified color at the given position to the board (without updating the GUI)
    public void addPieceNoGUI(int posX, int posY, boolean black) {
        boardMatrix[posY][posX] = black ? BLACK : WHITE;
    }

    // Adds a stone of the specified color at the given position to the board (and updates the GUI)
    public boolean addPiece(int posX, int posY, boolean black) {
        // Check whether the cell is empty or not
        if (boardMatrix[posY][posX] != EMPTY) {
            return false;
        }
        gui.drawPiece(posX, posY, black);
        boardMatrix[posY][posX] = black ? BLACK : WHITE;
        return true;
    }

    // Generates a list of all the possible moves for the current state of the board
    public ArrayList<int[]> getAvailableMoves() {
        ArrayList<int[]> moveList = new ArrayList<>();
        int boardSize = boardMatrix.length;

// Look for empty cells that have at least one stone in an adjacent cell
        for (int i = 0; i < boardSize; i++) {
            for (int j = 0; j < boardSize; j++) {
                // If the cell is not empty, continue to the next cell
                if (boardMatrix[i][j] > EMPTY) {
                    continue;
                }
                boolean canAdd = false;
                if (i > 0) {
                    if (j > 0 && (boardMatrix[i - 1][j - 1] > EMPTY || boardMatrix[i][j - 1] > EMPTY)) {
                        canAdd = true;
                    }
                    if (j < boardSize - 1 && (boardMatrix[i - 1][j + 1] > EMPTY || boardMatrix[i][j + 1] > EMPTY)) {
                        canAdd = true;
                    }
                    if (boardMatrix[i - 1][j] > EMPTY) {
                        canAdd = true;
                    }
                }
                if (i < boardSize - 1) {
                    if (j > 0 && (boardMatrix[i + 1][j - 1] > EMPTY || boardMatrix[i][j - 1] > EMPTY)) {
                        canAdd = true;
                    }
                    if (j < boardSize - 1 && (boardMatrix[i + 1][j + 1] > EMPTY || boardMatrix[i][j + 1] > EMPTY)) {
                        canAdd = true;
                    }
                    if (boardMatrix[i + 1][j] > EMPTY) {
                        canAdd = true;
                    }
                }
                // If the cell has at least one adjacent stone, add it to the list of possible moves
                if (canAdd) {
                    int[] move = {i, j};
                    moveList.add(move);
                }
            }
        }
        return moveList;
    }

    /**
     * Returns the current state of the board matrix.
     *
     * @return the current state of the board matrix
     */
    public int[][] getBoardMatrix() {
        return boardMatrix;
    }

    /**
     * Starts listening for mouse events on the board GUI.
     *
     * @param listener the mouse listener to attach to the board GUI
     */
    public void startListening(MouseListener listener) {
        gui.attachListener(listener);
    }

    /**
     * Returns the board GUI associated with this board.
     *
     * @return the board GUI associated with this board
     */
    public BoardGUI getGUI() {
        return gui;
    }

    /**
     * Converts an x-coordinate in pixels to a relative x-coordinate on the board.
     *
     * @param x the x-coordinate in pixels
     * @return the relative x-coordinate on the board
     */
    public int getScreenPosition(int x) {
        return gui.getScreenPosition(x);
    }

    /**
     * Prints the winner of the game to the board GUI.
     *
     * @param winner the winner of the game: 0 for a tie, 1 for white, or 2 for black
     */
    public void printWinner(int winner) {
        gui.printWinner(winner);
    }

    /**
     * Signals to the board GUI that the AI is thinking.
     */
    public void startAI() {
        gui.startAI(true);
    }

    /**
     * Signals to the board GUI that the AI has finished thinking.
     */
    public void stopAI() {
        gui.startAI(false);
    }

    public List<int[]> getPossibleMoves() {
        List<int[]> possibleMoves = new ArrayList<>();
        for (int i = 0; i < boardMatrix.length; i++) {
            for (int j = 0; j < boardMatrix.length; j++) {
                if (boardMatrix[i][j] == EMPTY) {
                    possibleMoves.add(new int[]{i, j});
                }
            }
        }
        return possibleMoves;
    }

    public boolean isTerminal() {
        // This is a simple placeholder. In a real Gomoku game, you would need to check if there are five pieces in a row for either player.
        return getPossibleMoves().isEmpty();
    }

    public int getReward(int player) {
        // This is a simple placeholder. In a real Gomoku game, you would need to check if the player has won and return 1 if yes, 0 if the game is a draw, and -1 if the player has lost.
        return 0;
    }


}