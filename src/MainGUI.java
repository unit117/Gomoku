import java.awt.event.ActionListener;

import javax.swing.BoxLayout;
import javax.swing.ButtonGroup;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JRadioButton;

public class MainGUI extends JFrame {
    private static final long serialVersionUID = 1L;
    private int setLevel;
    private boolean computerStarts;

    private JPanel boardPanel;
    private final JPanel setupPanel;
    private final JPanel levelPanel;
    private final JPanel startingPlayerPanel;

    private final JButton startGameButton;
    private final JRadioButton normalDifficultyRadioButton;
    private final JRadioButton hardDifficultyRadioButton;

    private final JRadioButton humanPlayerRadioButton;
    private final JRadioButton computerPlayerRadioButton;

    private final ButtonGroup levelButtonGroup;
    private final ButtonGroup startingPlayerButtonGroup;

    private final JLabel levelLabel;
    private final JLabel startsLabel;

    public MainGUI(int width, int height, String title) {
        setSize(width, height);
        setTitle(title);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        setupPanel = new JPanel();
        setupPanel.setLayout(new BoxLayout(setupPanel, BoxLayout.PAGE_AXIS));
        levelPanel = new JPanel();
        startingPlayerPanel = new JPanel();

        startGameButton = new JButton("Start Game");

        normalDifficultyRadioButton = new JRadioButton("Normal (Faster)");
        hardDifficultyRadioButton = new JRadioButton("Hard (Slower)");

        humanPlayerRadioButton = new JRadioButton("Human");
        computerPlayerRadioButton = new JRadioButton("Computer");

        levelButtonGroup = new ButtonGroup();
        startingPlayerButtonGroup = new ButtonGroup();

        levelButtonGroup.add(normalDifficultyRadioButton);
        levelButtonGroup.add(hardDifficultyRadioButton);

        startingPlayerButtonGroup.add(humanPlayerRadioButton);
        startingPlayerButtonGroup.add(computerPlayerRadioButton);

        levelLabel = new JLabel("Difficulty: ");
        startsLabel = new JLabel("Start first:      ");

        normalDifficultyRadioButton.setSelected(true);
        humanPlayerRadioButton.setSelected(true);

        levelPanel.add(levelLabel);
        levelPanel.add(normalDifficultyRadioButton);
        levelPanel.add(hardDifficultyRadioButton);

        startingPlayerPanel.add(startsLabel);
        startingPlayerPanel.add(humanPlayerRadioButton);
        startingPlayerPanel.add(computerPlayerRadioButton);


        setupPanel.add(levelPanel);
        setupPanel.add(startingPlayerPanel);
        setupPanel.add(startGameButton);

        add(setupPanel);
        pack();
    }

    /*
     * 	Reads components to fetch and return the chosen settings.
     */
    public Object[] fetchSettings() {
        if (hardDifficultyRadioButton.isSelected()) {
            setLevel = 4;
        } else {
            setLevel = 1;
        }

        computerStarts = computerPlayerRadioButton.isSelected();
        Object[] settings = {setLevel, computerStarts};
        return settings;
    }

    public void listenGameStartButton(ActionListener listener) {
        startGameButton.addActionListener(listener);
    }

    public void attachBoard(JPanel board) {
        boardPanel = board;
    }

    public void showBoard() {
        setContentPane(boardPanel);
        invalidate();
        validate();
        pack();
    }
}