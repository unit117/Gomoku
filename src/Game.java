import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;

public class Game {
    private Board board;
    private boolean isPlayersTurn = true;
    private boolean gameFinished = false;
    private int minimaxDepth = 3;
    private boolean aiStarts = true; // AI makes the first move
    private Minimax ai;
    public static final String cacheFile = "score_cache.ser";
    private int winner; // 0: There is no winner yet, 1: AI Wins, 2: Human Wins

    public Game(Board board) {
        this.board = board;
        ai = new Minimax(board);
        winner = 0;
    }

    /*
     * Loads the cache and starts the game, enabling human player interactions.
     */
    public void start() {
        // If the AI is making the first move, place a white stone in the middle of the board.
        if (aiStarts) {
            playMove(board.getBoardSize() / 2, board.getBoardSize() / 2, false);
        }
        // Now it's human player's turn.
        // Make the board start listening for mouse clicks.
        board.startListening(new MouseListener() {
            public void mouseClicked(MouseEvent arg0) {
                if (isPlayersTurn) {
                    isPlayersTurn = false;
                    // Handle the mouse click in another thread, so that we do not held the event dispatch thread busy.
                    new Thread(new MouseClickHandler(arg0)).start();
                }
            }

            public void mouseEntered(MouseEvent arg0) {
            }

            public void mouseExited(MouseEvent arg0) {
            }

            public void mousePressed(MouseEvent arg0) {
            }

            public void mouseReleased(MouseEvent arg0) {
            }
        });
    }

    /*
     * Sets the depth of the minimax tree. (i.e. how many moves ahead should the AI calculate.)
     */
    public void setAIDepth(int depth) {
        minimaxDepth = depth;
    }

    public void setAIStarts(boolean aiStarts) {
        this.aiStarts = aiStarts;
    }

    public class MouseClickHandler implements Runnable {
        private MouseEvent e;

        public MouseClickHandler(MouseEvent e) {
            this.e = e;
        }

        public void run() {
            if (gameFinished) {
                return;
            }

            // Find out which cell of the board do the clicked coordinates belong to.
            int posX = board.getScreenPosition(e.getX());
            int posY = board.getScreenPosition(e.getY());

            // Place a black stone to that cell.
            if (!playMove(posX, posY, true)) {
                // If the cell is already populated, do nothing.
                isPlayersTurn = true;
                return;
            }

            // Check if the last move ends the game.
            winner = checkWinner();
            if (winner == 2) {
                System.out.println("Player Won!");
                board.printWinner(winner);
                gameFinished = true;
                return;
            }

            // Make the AI instance calculate a move.
            int[] aiMove = ai.getNextMove(minimaxDepth);
            if (aiMove == null) {
                System.out.println("No possible moves left. Game Over.");
                board.printWinner(0); // Prints "TIED!"
                gameFinished = true;
                return;
            }

            // Place a black stone to the found cell.
            playMove(aiMove[1], aiMove[0], false);

            System.out.println("Black: " + Minimax.getScore(board, true, true) + " White: " + Minimax.getScore(board, false, true));

            winner = checkWinner();
            if (winner == 1) {
                System.out.println("AI won!");
                board.printWinner(winner);
                gameFinished = true;
                return;
            }

            if (board.getAvailableMoves().isEmpty()) {
                System.out.println("No possible moves left. Game Over.");
                board.printWinner(0); // Prints "TIED!"
                gameFinished = true;
                return;
            }

            isPlayersTurn = true;
        }
    }

    private int checkWinner() {
        if (Minimax.getScore(board, true, false) >= Minimax.getWinningScore()) {
            return 2;
        }
        if (Minimax.getScore(board, false, true) >= Minimax.getWinningScore()) {
            return 1;
        }
        return 0;
    }

    private boolean playMove(int posX, int posY, boolean black) {
        return board.addPiece(posX, posY, black);
    }
}