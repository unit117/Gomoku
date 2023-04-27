##Gomoku AI

This project involves the design and implementation of a game of Gomoku and its AI. The game logic and board are stored in the class Board, represented as a 2D array of integers with three possible values: 0 (EMPTY), 1 (WHITE), or 2 (BLACK). The SimpleAI class uses a basic approach to game logic, looking for cases of three in a row and making a random move if none are found.

The MainGUI class creates the game's frontend interface with user-friendly components like radio buttons and labels. The Minimax algorithm is implemented in the code, creating a game tree of possible moves with an evaluation function and Alpha-Beta Pruning optimization to determine the best move. The code also includes searching for winning moves before performing a full search, useful when there are obvious winning moves available.

The minimaxSearchAB method is the core of the Minimax algorithm, recursively exploring all possible moves, simulating alternate turns between the AI and player. Alpha and Beta values are used to prune the search tree. The getNextMove method starts this search, and the evaluation function getScore assigns scores to the board state based on the sequence of pieces horizontally, vertically, and diagonally.

The Monte Carlo Tree Search (MCTS) is a heuristic search algorithm that uses randomness and simulation to make decisions. This algorithm constructs a search tree based on statistical analysis of stochastic simulations, consisting of four steps: selection, expansion, simulation, and backpropagation. For Gomoku, MCTS simulates many potential games with randomly chosen moves, using the results to inform the next move.

To play against the AI, run the Minimax class, with difficulty levels set by depth. Higher depth means the AI can see further and explore more potential game states. The project is available on Github at https://github.com/unit117/Gomoku.