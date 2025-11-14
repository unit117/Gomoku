import Foundation

struct BoardPoint: Hashable, Codable {
    let row: Int
    let column: Int
}

enum StonePlayer: Int, Codable {
    case black = 1
    case white = 2

    var opponent: StonePlayer {
        self == .black ? .white : .black
    }
}

struct Move: Hashable, Codable {
    let position: BoardPoint
    let player: StonePlayer
    let timestamp: Date
}

struct GomokuBoard: Codable {
    static let size = 15
    private(set) var grid: [[StonePlayer?]]
    private(set) var moves: [Move]

    init() {
        let row = Array(repeating: Optional<StonePlayer>.none, count: Self.size)
        grid = Array(repeating: row, count: Self.size)
        moves = []
    }

    mutating func reset() {
        let row = Array(repeating: Optional<StonePlayer>.none, count: Self.size)
        grid = Array(repeating: row, count: Self.size)
        moves.removeAll()
    }

    func stone(at point: BoardPoint) -> StonePlayer? {
        guard (0..<Self.size).contains(point.row), (0..<Self.size).contains(point.column) else { return nil }
        return grid[point.row][point.column]
    }

    mutating func placeStone(at point: BoardPoint, player: StonePlayer) -> Bool {
        guard stone(at: point) == nil else { return false }
        grid[point.row][point.column] = player
        moves.append(Move(position: point, player: player, timestamp: Date()))
        return true
    }

    mutating func undoLastMove() -> Move? {
        guard let lastMove = moves.popLast() else { return nil }
        grid[lastMove.position.row][lastMove.position.column] = nil
        return lastMove
    }

    func hasWin(for player: StonePlayer) -> Bool {
        for row in 0..<Self.size {
            for column in 0..<Self.size {
                guard grid[row][column] == player else { continue }
                if checkDirection(row: row, column: column, deltaRow: 1, deltaColumn: 0, player: player) { return true }
                if checkDirection(row: row, column: column, deltaRow: 0, deltaColumn: 1, player: player) { return true }
                if checkDirection(row: row, column: column, deltaRow: 1, deltaColumn: 1, player: player) { return true }
                if checkDirection(row: row, column: column, deltaRow: 1, deltaColumn: -1, player: player) { return true }
            }
        }
        return false
    }

    private func checkDirection(row: Int, column: Int, deltaRow: Int, deltaColumn: Int, player: StonePlayer) -> Bool {
        for offset in 1..<5 {
            let nextRow = row + deltaRow * offset
            let nextColumn = column + deltaColumn * offset
            guard (0..<Self.size).contains(nextRow), (0..<Self.size).contains(nextColumn) else { return false }
            if grid[nextRow][nextColumn] != player { return false }
        }
        return true
    }

    func availableMoves() -> [BoardPoint] {
        var points: Set<BoardPoint> = []
        for move in moves {
            for row in -1...1 {
                for column in -1...1 {
                    let point = BoardPoint(row: move.position.row + row, column: move.position.column + column)
                    if (0..<Self.size).contains(point.row), (0..<Self.size).contains(point.column), stone(at: point) == nil {
                        points.insert(point)
                    }
                }
            }
        }
        if points.isEmpty {
            return [BoardPoint(row: Self.size / 2, column: Self.size / 2)]
        }
        return Array(points)
    }
}
