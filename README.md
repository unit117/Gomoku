Here is a revised README for the Gomoku AI project:

# Gomoku AI

This project implements an artificial intelligence to play the game of Gomoku (also known as Five in a Row) against a human player. 

## Overview

The game logic and board are represented in the `Board` class as a 2D array of integers, with 0 for empty spots, 1 for white pieces, and 2 for black pieces. The `BoardGUI` class handles displaying the graphical game board and pieces in a Swing GUI.

The AI opponent uses the Minimax algorithm with alpha-beta pruning to calculate the best move by searching possible future game states. The `Minimax` class contains the implementation, evaluating board positions with a score and searching the game tree to a configurable depth. 

The `Game` class brings everything together to control game flow and alternate moves between the AI and human player. It detects winners, handles user mouse clicks for moves, and requests the next AI move from `Minimax`.

The `MainGUI` class provides a simple Swing interface to configure game options like the AI difficulty level and whether the human or AI plays first.

## Usage

To play against the AI:

1. Run the `Main` class 
2. Configure the options in the setup panel:
   - Select the AI difficulty (search depth)
   - Choose whether human or AI plays first
3. Click "Start Game" to begin
4. Click on the game board to place your pieces
5. The AI will automatically calculate and make a move after each human turn

The higher the difficulty, the deeper the AI will search, allowing it to play better but slowing it down.

## Customizing the AI

The evaluation function in `Minimax` that scores board positions can be adjusted to tweak the AI logic. Additional optimizations like move ordering and caching can also be added. 

An alternative algorithm like Monte Carlo Tree Search could be implemented for different AI behavior. The modular structure makes it easy to experiment with new approaches.

Overall this project provides a nice foundation for developing a game-playing AI bot!
