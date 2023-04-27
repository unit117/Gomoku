import java.util.ArrayList;

public class Minimax {

    // Static variable to keep count of evaluations made
    public static int evaluationCount = 0;

    // Instance variable for Board
    private Board board;

    // Constant for the winning score
    private static final int WIN_SCORE = 100_000_000;

    // Constructor for Minimax class, takes a Board object as argument
    public Minimax(Board board) {
        this.board = board; // assigning the board instance variable to the passed board object
    }

    // Getter for WIN_SCORE
    public static int getWinningScore() {
        return WIN_SCORE;
    }

    // Method to evaluate board for the white player
    public static double evaluateBoardForWhite(Board board, boolean blacksTurn) {
        evaluationCount++;
        double blackScore = getScore(board, true, blacksTurn); // calculating score for black
        double whiteScore = getScore(board, false, blacksTurn); // calculating score for white
        if (blackScore == 0) {
            blackScore = 1.0; // to avoid division by zero
        }
        // returns the ratio of white score to black score
        return whiteScore / blackScore;
    }

    // Method to calculate the score for the board for a particular player
    public static int getScore(Board board, boolean forBlack, boolean blacksTurn) {
        // Getting board matrix from the board object
        int[][] boardMatrix = board.getBoardMatrix();
        int[] evaluations = new int[3];
        // Evaluating board horizontally, vertically, and diagonally
        evaluateRows(boardMatrix, forBlack, blacksTurn, evaluations);
        evaluateColumns(boardMatrix, forBlack, blacksTurn, evaluations);
        evaluateDiagonals(boardMatrix, forBlack, blacksTurn, evaluations);
        // Returning the final evaluation score
        return evaluations[2];
    }

    // Method to calculate the next move, takes depth of the search tree as argument
    public int[] getNextMove(int depth) {
        board.startAI(); // signaling the board that thinking process has started
        int[] move = new int[2];
        long startTime = System.currentTimeMillis(); // note the start time for calculation
        Object[] bestMove = searchMove(board); // searching for winning move
        // If a winning move is found, assign it to the move array
        if (bestMove != null) {
            move[0] = (Integer) bestMove[1];
            move[1] = (Integer) bestMove[2];
        } else {
            // If no winning move is found, perform Minimax search
            bestMove = minimaxSearchAB(depth, new Board(board), true, -1.0, getWinningScore());
            if (bestMove[1] == null) {
                move = null;
            } else {
                move[0] = (Integer) bestMove[1];
                move[1] = (Integer) bestMove[2];
            }
        }
        // Print number of cases calculated and the calculation time
        System.out.println("Cases calculated: " + evaluationCount + " Calculation time: " + (System.currentTimeMillis() - startTime) + " ms");
        board.stopAI(); // signaling the board that thinking process has finished
        evaluationCount = 0;
        return move;
    }

    // Minimax algorithm with alpha-beta pruning, returns best move
    private static Object[] minimaxSearchAB(int depth, Board dummyBoard, boolean max, double alpha, double beta) {
        // If the depth reaches zero or no possible moves, evaluate the board and return
        ArrayList<int[]> allPossibleMoves = dummyBoard.getAvailableMoves();
        if (depth == 0 || allPossibleMoves.size() == 0) {
            return new Object[]{evaluateBoardForWhite(dummyBoard, !max), null, null};
        }
        Object[] bestMove = new Object[3];
        bestMove[0] = max ? Double.NEGATIVE_INFINITY : Double.POSITIVE_INFINITY;
        for (int[] move : allPossibleMoves) {
            // Apply the move to the board
            dummyBoard.addPieceNoGUI(move[1], move[0], !max);
            // Perform minimax search on the new board state
            Object[] tempMove = minimaxSearchAB(depth - 1, dummyBoard, !max, alpha, beta);
            // Undo the move
            dummyBoard.removePiece(move[1], move[0]);
            // If it's max's turn
            if (max) {
                if ((Double) tempMove[0] > (Double) bestMove[0]) {
                    bestMove = tempMove;
                    bestMove[1] = move[0];
                    bestMove[2] = move[1];
                    alpha = (Double) bestMove[0];
                }
                if (beta <= alpha) {
                    break;
                }
            }
            // If it's min's turn
            else {
                if ((Double) tempMove[0] < (Double) bestMove[0]) {
                    bestMove = tempMove;
                    bestMove[1] = move[0];
                    bestMove[2] = move[1];
                    beta = (Double) bestMove[0];
                }
                if (beta <= alpha) {
                    break;
                }
            }
        }
        return bestMove;
    }

    // Search for a winning move and return it if it exists
    private static Object[] searchMove(Board board) {
        ArrayList<int[]> allPossibleMoves = board.getAvailableMoves(); // Generate all possible moves
        for (int[] move : allPossibleMoves) {
            evaluationCount++; // Count the evaluation
            Board dummyBoard = new Board(board); // Create a dummy board
            dummyBoard.addPieceNoGUI(move[1], move[0], false); // Apply the move to the dummy board
            // If the applied move creates a winning score for the player, return this move
            if (getScore(dummyBoard, false, false) >= WIN_SCORE) {
                Object[] finalMove = new Object[3];
                finalMove[1] = move[0];
                finalMove[2] = move[1];
                return finalMove;
            }
        }
        return null; // If no winning move is found, return null
    }

    // Evaluate the board horizontally
    public static void evaluateRows(int[][] boardMatrix, boolean forBlack, boolean playersTurn, int[] eval) {
        // Loop over the board matrix
        for (int i = 0; i < boardMatrix.length; i++) {
            for (int j = 0; j < boardMatrix[0].length; j++) {
                evaluateDiagonals(boardMatrix, i, j, forBlack, playersTurn, eval);
            }
            evaluateLineAfterPass(eval, forBlack, playersTurn);
        }
    }

    // Evaluate the board vertically
    public static void evaluateColumns(int[][] boardMatrix, boolean forBlack, boolean playersTurn, int[] eval) {
        // Loop over the board matrix
        for (int j = 0; j < boardMatrix[0].length; j++) {
            for (int i = 0; i < boardMatrix.length; i++) {
                evaluateDiagonals(boardMatrix, i, j, forBlack, playersTurn, eval);
            }
            evaluateLineAfterPass(eval, forBlack, playersTurn);
        }
    }

    // Evaluate the board diagonally
    public static void evaluateDiagonals(int[][] boardMatrix, boolean forBlack, boolean playersTurn, int[] eval) {
        // Loop over the board matrix diagonally from top-left to bottom-right
        for (int k = 0; k <= 2 * (boardMatrix.length - 1); k++) {
            int iStart = Math.max(0, k - boardMatrix.length + 1);
            int iEnd = Math.min(boardMatrix.length - 1, k);
            for (int i = iStart; i <= iEnd; ++i) {
                evaluateDiagonals(boardMatrix, i, k - i, forBlack, playersTurn, eval);
            }
            evaluateLineAfterPass(eval, forBlack, playersTurn);
        }
        // Loop over the board matrix diagonally from bottom-left to top-right
        for (int k = 1 - boardMatrix.length; k < boardMatrix.length; k++) {
            int iStart = Math.max(0, k);
            int iEnd = Math.min(boardMatrix.length + k - 1, boardMatrix.length - 1);
            for (int i = iStart; i <= iEnd; ++i) {
                evaluateDiagonals(boardMatrix, i, i - k, forBlack, playersTurn, eval);
            }
            evaluateLineAfterPass(eval, forBlack, playersTurn);
        }
    }

    // Evaluate the score based on the directions of the stones
    // For each position on the board, it checks whether the stone is of the same color as the bot's,
    // an empty spot or the opponent's color, and updates the evaluation variables accordingly.
    public static void evaluateDiagonals(int[][] boardMatrix, int i, int j, boolean isBot, boolean botsTurn, int[] eval) {
        if (boardMatrix[i][j] == (isBot ? 2 : 1)) {
            eval[0]++; // If the stone at (i, j) is of the same color as the bot's, increment the count of consecutive stones
        } else if (boardMatrix[i][j] == 0) {
            if (eval[0] > 0) { // If there was a consecutive streak but we hit an empty spot, update the score and reset the count
                eval[1]--;
                eval[2] += getConsecutiveSetScore(eval[0], eval[1], isBot == botsTurn);
                eval[0] = 0;
            }
            eval[1] = 1; // Reset the block count to 1
        } else if (eval[0] > 0) {
            eval[2] += getConsecutiveSetScore(eval[0], eval[1], isBot == botsTurn); // If there was a consecutive streak but we hit the opponent's stone, update the score and reset the count
            eval[0] = 0;
            eval[1] = 2; // Set the block count to 2
        } else {
            eval[1] = 2; // If the stone at (i, j) is of the opponent's color and there was no consecutive streak, set the block count to 2
        }
    }

    // After one pass of evaluation in a particular direction, this method is called to handle the case where a streak might end at the edge of the board
    private static void evaluateLineAfterPass(int[] eval, boolean isBot, boolean playersTurn) {
        if (eval[0] > 0) {
            eval[2] += getConsecutiveSetScore(eval[0], eval[1], isBot == playersTurn); // If there was a streak at the end, update the score
        }
        eval[0] = 0; // Reset the count and block count for the next pass
        eval[1] = 2;
    }

    // This method calculates the score for a set of consecutive stones, depending on the number of stones, the number of blocks at both ends, and whose turn it is
    public static int getConsecutiveSetScore(int count, int blocks, boolean currentTurn) {
        final int winGuarantee = 1000000; // A large score that guarantees a win
        if (blocks == 2 && count < 5)
            return 0; // If both ends are blocked and the number of consecutive stones is less than 5, then this set is useless
        switch (count) { // Depending on the count of consecutive stones
            case 5: { // 5 stones in a row is a win
                return WIN_SCORE;
            }
            case 4: { // 4 stones in a row
                if (currentTurn) return winGuarantee; // If it's the bot's turn, it's a guaranteed win
                else {
                    if (blocks == 0) return winGuarantee / 4; // If it's not blocked at all, it
                        // could lead to a win, so give it a high score
                    else return 200; // If blocked at one end, it's not a guaranteed win but still a good position
                }
            }
            case 3: { // 3 stones in a row
                if (blocks == 0) { // If it's not blocked at all
                    if (currentTurn)
                        return 50_000; // If it's the bot's turn, this could potentially lead to a win, so give it a high score
                    else return 200; // If it's the opponent's turn, it's not as dangerous but still worth some points
                } else { // If blocked at one end
                    if (currentTurn) return 10; // If it's the bot's turn, this is a slightly advantageous position
                    else return 5; // If it's the opponent's turn, it's not as dangerous
                }
            }
            case 2: { // 2 stones in a row
                if (blocks == 0) { // If it's not blocked at all
                    if (currentTurn) return 7; // If it's the bot's turn, this is a slightly advantageous position
                    else return 5; // If it's the opponent's turn, it's not as dangerous
                } else { // If blocked at one end
                    return 3; // This is not a particularly advantageous position but still worth some points
                }
            }
            case 1: { // 1 stone
                return 1; // This is not a particularly advantageous position but still worth some points
            }
        }
        return WIN_SCORE * 2; // Default return value, should not be reached
    }

}