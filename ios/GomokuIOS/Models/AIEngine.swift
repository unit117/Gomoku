import Foundation

protocol AIEngineProtocol {
    func nextMove(for board: GomokuBoard, player: StonePlayer) -> BoardPoint?
}

struct AIEngine: AIEngineProtocol {
    let difficulty: AIDifficulty

    func nextMove(for board: GomokuBoard, player: StonePlayer) -> BoardPoint? {
        if Double.random(in: 0...1) < difficulty.randomness {
            return board.availableMoves().randomElement()
        }
        let (_, point) = minimax(board: board, player: player, depth: difficulty.searchDepth, maximizing: true)
        return point
    }

    private func minimax(board: GomokuBoard, player: StonePlayer, depth: Int, maximizing: Bool) -> (score: Int, point: BoardPoint?) {
        if board.hasWin(for: player) { return (10000 + depth, nil) }
        if board.hasWin(for: player.opponent) { return (-10000 - depth, nil) }
        if depth == 0 {
            return (evaluate(board: board, player: player), nil)
        }

        var bestScore = maximizing ? Int.min : Int.max
        var bestPoint: BoardPoint?
        for point in board.availableMoves() {
            var newBoard = board
            _ = newBoard.placeStone(at: point, player: maximizing ? player : player.opponent)
            let (score, _) = minimax(board: newBoard, player: player, depth: depth - 1, maximizing: !maximizing)
            if maximizing {
                if score > bestScore {
                    bestScore = score
                    bestPoint = point
                }
            } else {
                if score < bestScore {
                    bestScore = score
                }
            }
        }
        return (bestScore, bestPoint)
    }

    private func evaluate(board: GomokuBoard, player: StonePlayer) -> Int {
        var score = 0
        for move in board.moves {
            score += evaluatePoint(board: board, point: move.position, player: player)
            score -= evaluatePoint(board: board, point: move.position, player: player.opponent)
        }
        return score
    }

    private func evaluatePoint(board: GomokuBoard, point: BoardPoint, player: StonePlayer) -> Int {
        let lines = [
            (dr: 1, dc: 0),
            (dr: 0, dc: 1),
            (dr: 1, dc: 1),
            (dr: 1, dc: -1)
        ]
        var score = 0
        for line in lines {
            let count = contiguousCount(board: board, start: point, dr: line.dr, dc: line.dc, player: player)
            switch count {
            case 5:
                score += 1000
            case 4:
                score += 200
            case 3:
                score += 50
            case 2:
                score += 10
            default:
                break
            }
        }
        return score
    }

    private func contiguousCount(board: GomokuBoard, start: BoardPoint, dr: Int, dc: Int, player: StonePlayer) -> Int {
        var count = 1
        var next = BoardPoint(row: start.row + dr, column: start.column + dc)
        while let stone = board.stone(at: next), stone == player {
            count += 1
            next = BoardPoint(row: next.row + dr, column: next.column + dc)
        }
        next = BoardPoint(row: start.row - dr, column: start.column - dc)
        while let stone = board.stone(at: next), stone == player {
            count += 1
            next = BoardPoint(row: next.row - dr, column: next.column - dc)
        }
        return count
    }
}
