import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.FontMetrics;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.event.MouseListener;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import javax.imageio.ImageIO;
import javax.swing.JPanel;

public class BoardGUI extends JPanel {

    private Graphics2D g2D;
    private BufferedImage image;
    private boolean isAIThinking = false;

    private static final long serialVersionUID = 1L;

    private int sideLength; // Side length of the square board in pixels
    private int boardSize; // Number of cells in one side (e.g. 19 for a 19x19 board)
    private final int cellLength; // Side length of a single cell in pixels
    private final char[] alphabet = "ABCDEFGHJKLMNOPQRSTUVWXYZ".toCharArray();

    public BoardGUI(int sideLength, int boardSize) {
        this.sideLength = sideLength;
        this.boardSize = boardSize;
        this.cellLength = sideLength / boardSize;

        image = new BufferedImage(sideLength, sideLength, BufferedImage.TYPE_INT_ARGB);

        g2D = (Graphics2D) image.getGraphics();
        g2D.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);

        g2D.setColor(new Color(239, 189, 78)); // brownish color for the board
        g2D.fillRect(0, 0, sideLength, sideLength);

        g2D.setColor(new Color(214, 149, 37)); // dark brownish color for the grid
        for (int i = 1; i <= boardSize; i++) {
            g2D.drawLine(i * cellLength, 0, i * cellLength, sideLength);
        }
        for (int i = 1; i <= boardSize; i++) {
            g2D.drawLine(0, i * cellLength, sideLength, i * cellLength);
        }

        g2D.setColor(Color.BLACK);
        g2D.setFont(new Font("Arial", Font.BOLD, 14)); // font for the labels

        // draw numbers on the left side
        for (int i = 0; i < boardSize; i++) {
            g2D.drawString(Integer.toString(i + 1), 2, (i + 1) * cellLength + cellLength / 2);
        }

        // draw letters on the bottom
        for (int i = 0; i < boardSize; i++) {
            g2D.drawString(Character.toString(alphabet[i]), (i + 1) * cellLength + cellLength / 2, sideLength - 4);
        }

        try {
            // load a background image (optional)
            BufferedImage bgImage = ImageIO.read(new File("board_bg.jpg"));
            g2D.drawImage(bgImage, 0, 0, sideLength, sideLength, null);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public int getScreenPosition(int x) {
        if (x >= sideLength)
            x = sideLength - 1;
        return (int) (x * boardSize / sideLength);
    }

    public Dimension getPreferredSize() {
        return new Dimension(sideLength, sideLength);
    }

    public void printWinner(int winner) {
        FontMetrics metrics = g2D.getFontMetrics(new Font("Arial", Font.BOLD, 48));
        String text = winner == 2 ? "YOU WON!" : (winner == 1 ? "COMPUTER WON!" : "TIED!");

        g2D.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON);

        g2D.setColor(Color.BLACK);
        int x = (sideLength / 2 - metrics.stringWidth(text) / 2);
        int y = sideLength / 2 + metrics.getHeight() / 4;

        // add a drop shadow
        g2D.setColor(new Color(0, 0, 0, 100));
        g2D.drawString(text, x + 3, y + 3);

        // draw the text
        g2D.setColor(winner == 2 ? new Color(55, 200, 113) : (winner == 1 ? new Color(255, 78, 78) : Color.BLUE));
        g2D.drawString(text, x, y);

        repaint();

    }

    public void drawPiece(int posX, int posY, boolean black) {

        if (posX >= boardSize || posY >= boardSize)
            return;

        Color stoneColor = black ? new Color(62, 62, 62) : new Color(230, 230, 230);

        g2D.setColor(stoneColor);
        g2D.fillOval((int) (cellLength * (posX + 0.05)), (int) (cellLength * (posY + 0.05)),
                (int) (cellLength * 0.9), (int) (cellLength * 0.9));
        g2D.setColor(Color.BLACK);
        g2D.setStroke(new BasicStroke(2));
        g2D.drawOval((int) (cellLength * (posX + 0.05)), (int) (cellLength * (posY + 0.05)),
                (int) (cellLength * 0.9), (int) (cellLength * 0.9));

        repaint();
    }

    @Override
    protected void paintComponent(Graphics g) {
        super.paintComponent(g);

        Graphics2D g2D = (Graphics2D) g.create();

        // Draw the board
        g2D.drawImage(image, 0, 0, sideLength, sideLength, null);

        if (isAIThinking) {
            printThinking(g2D);
        }

        // Draw the border
        g2D.setColor(Color.black);
        g2D.drawRect(0, 0, sideLength, sideLength);
    }

    private void printThinking(Graphics2D g2D) {
        FontMetrics metrics = g2D.getFontMetrics(new Font("Arial", Font.BOLD, 48));
        String text = "Thinking...";

        g2D.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON);

        int x = (sideLength / 2 - metrics.stringWidth(text) / 2);
        int y = sideLength / 2 + metrics.getHeight() / 4;

        g2D.setColor(new Color(255, 0, 0, 150));
        // add a drop shadow
        g2D.setColor(new Color(0, 0, 0, 100));
        g2D.drawString(text, x + 3, y + 3);
        // draw the text
        g2D.setColor(new Color(255, 255, 255, 200));
        g2D.drawString(text, x, y);
    }

    public void attachListener(MouseListener listener) {
        addMouseListener(listener);
    }

    public void startAI(boolean flag) {
        isAIThinking = flag;
        repaint();
    }
}


