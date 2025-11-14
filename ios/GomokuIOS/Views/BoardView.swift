import SwiftUI

struct BoardView: View {
    let board: GomokuBoard
    @Binding var scale: CGFloat
    let highlighted: [BoardPoint]
    var onTap: (BoardPoint) -> Void

    @State private var dragOffset: CGSize = .zero
    @State private var lastDragValue: CGSize = .zero
    @State private var lastScaleValue: CGFloat = 1.0

    var body: some View {
        GeometryReader { geometry in
            let baseSize = min(geometry.size.width, geometry.size.height)
            let cellSize = baseSize / CGFloat(GomokuBoard.size)

            ZStack {
                boardBackground(cellSize: cellSize)
                stones(cellSize: cellSize)
                highlights(cellSize: cellSize)
            }
            .frame(width: baseSize, height: baseSize)
            .scaleEffect(scale)
            .offset(dragOffset)
            .gesture(magnificationGesture)
            .gesture(dragGesture)
            .simultaneousGesture(tapGesture(cellSize: cellSize))
            .contentShape(Rectangle())
            .onChange(of: scale) { newValue in
                lastScaleValue = newValue
            }
        }
    }

    private func boardBackground(cellSize: CGFloat) -> some View {
        Canvas { context, size in
            let boardRect = CGRect(origin: .zero, size: size)
            context.stroke(Path(boardRect), with: .color(.primary), lineWidth: 2)

            for index in 0...GomokuBoard.size {
                let offset = CGFloat(index) * cellSize
                var hLine = Path()
                hLine.move(to: CGPoint(x: 0, y: offset))
                hLine.addLine(to: CGPoint(x: size.width, y: offset))
                context.stroke(hLine, with: .color(.secondary), lineWidth: 1)

                var vLine = Path()
                vLine.move(to: CGPoint(x: offset, y: 0))
                vLine.addLine(to: CGPoint(x: offset, y: size.height))
                context.stroke(vLine, with: .color(.secondary), lineWidth: 1)
            }
            let starPoints = [3, 7, 11]
            for row in starPoints {
                for column in starPoints {
                    let center = CGPoint(x: CGFloat(column) * cellSize + cellSize / 2,
                                         y: CGFloat(row) * cellSize + cellSize / 2)
                    let starRect = CGRect(x: center.x - cellSize * 0.12,
                                          y: center.y - cellSize * 0.12,
                                          width: cellSize * 0.24,
                                          height: cellSize * 0.24)
                    context.fill(Ellipse().path(in: starRect), with: .color(.secondary))
                }
            }
        }
    }

    private func stones(cellSize: CGFloat) -> some View {
        ForEach(board.moves, id: \.self) { move in
            Circle()
                .fill(move.player == .black ? Color.black : Color.white)
                .frame(width: cellSize * 0.8, height: cellSize * 0.8)
                .shadow(radius: 1)
                .position(x: CGFloat(move.position.column) * cellSize + cellSize / 2,
                          y: CGFloat(move.position.row) * cellSize + cellSize / 2)
        }
    }

    private func highlights(cellSize: CGFloat) -> some View {
        ForEach(highlighted, id: \.self) { point in
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.orange, lineWidth: 2)
                .frame(width: cellSize * 0.9, height: cellSize * 0.9)
                .position(x: CGFloat(point.column) * cellSize + cellSize / 2,
                          y: CGFloat(point.row) * cellSize + cellSize / 2)
                .animation(.easeInOut, value: highlighted)
        }
    }

    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let newScale = lastScaleValue * value
                scale = min(max(newScale, 0.8), 2.5)
            }
            .onEnded { _ in
                lastScaleValue = scale
            }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = CGSize(width: lastDragValue.width + value.translation.width,
                                     height: lastDragValue.height + value.translation.height)
            }
            .onEnded { _ in
                lastDragValue = dragOffset
            }
    }

    private func tapGesture(cellSize: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onEnded { value in
                let translation = value.translation
                guard abs(translation.width) < 5, abs(translation.height) < 5 else { return }
                handleTap(at: value.location, cellSize: cellSize)
            }
    }

    private func handleTap(at location: CGPoint, cellSize: CGFloat) {
        let adjustedX = (location.x - dragOffset.width) / scale
        let adjustedY = (location.y - dragOffset.height) / scale
        let column = Int(adjustedX / cellSize)
        let row = Int(adjustedY / cellSize)
        guard (0..<GomokuBoard.size).contains(row), (0..<GomokuBoard.size).contains(column) else { return }
        onTap(BoardPoint(row: row, column: column))
    }
}
