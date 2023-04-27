import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class Main {
    public static void main(String[] args) {

        // Create the main GUI instance.
        final int width = 760;
        final MainGUI gui = new MainGUI(width,width, "Gomoku");

        // Create a 19x19 game board.
        Board board = new Board(width, 19);

        // Create the game manager instance and pass the game board to it.
        final Game game = new Game(board);

        // Attach the game board's GUI component to the main frame.
        gui.attachBoard(board.getGUI());

        // Pack and display the GUI.
        gui.pack();
        gui.setVisible(true);

        // Listen for the Game Start button click and set the game settings.
        gui.listenGameStartButton(new ActionListener() {

            public void actionPerformed(ActionEvent arg0) {

                // Get the settings from the main GUI manager.
                Object[] settings = gui.fetchSettings();
                int depth = (Integer)(settings[0]);
                boolean computerStarts = (Boolean)(settings[1]);

                System.out.println("Depth: " + depth + " Computer starts: " + computerStarts );

                // Show the game board to the user.
                gui.showBoard();

                // Set the game settings and start the game.
                game.setAIDepth(depth);
                game.setAIStarts(computerStarts);
                game.start();
            }
        });
    }

}