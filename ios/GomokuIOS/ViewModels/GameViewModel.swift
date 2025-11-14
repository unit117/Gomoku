import Foundation
import SwiftUI

@MainActor
final class GameViewModel: ObservableObject {
    @Published private(set) var board = GomokuBoard()
    @Published var isGamePresented = false
    @Published var statusText = ""
    @Published var boardScale: CGFloat = 1.0
    @Published var highlightedPoints: [BoardPoint] = []
    @Published var isDiscovering = false
    @Published var isUndoPromptVisible = false

    private var mode: GameMode = .none
    private var aiEngine: AIEngineProtocol?
    private var onlineManager: OnlineSessionManager?
    private weak var profileStore: UserProfileStore?

    var gameTitle: String {
        switch mode {
        case .vsAI(let difficulty):
            return "Vs AI - \(difficulty.displayName)"
        case .online:
            return "Online Match"
        case .none:
            return "Gomoku"
        }
    }

    var canRetract: Bool {
        switch mode {
        case .vsAI:
            return board.moves.count >= 2
        case .online:
            return onlineManager?.canSendUndoRequest == true
        case .none:
            return false
        }
    }

    func startAIGame(difficulty: AIDifficulty, store: UserProfileStore) {
        board = GomokuBoard()
        mode = .vsAI(difficulty)
        aiEngine = AIEngine(difficulty: difficulty)
        statusText = "Your turn"
        highlightedPoints = []
        boardScale = 1.0
        isGamePresented = true
        profileStore = store
        isUndoPromptVisible = false
    }

    func beginOnlineGame(profile: UserProfile, store: UserProfileStore) {
        board = GomokuBoard()
        mode = .online
        onlineManager = OnlineSessionManager(playerID: profile.username)
        onlineManager?.delegate = self
        onlineManager?.start()
        isDiscovering = true
        isGamePresented = true
        highlightedPoints = []
        boardScale = 1.0
        profileStore = store
        statusText = "Waiting for opponent…"
        isUndoPromptVisible = false
    }

    func endCurrentGame() {
        mode = .none
        onlineManager?.stop()
        onlineManager = nil
        isDiscovering = false
        isUndoPromptVisible = false
        board = GomokuBoard()
    }

    func handleBoardTap(point: BoardPoint) {
        switch mode {
        case .vsAI:
            handleHumanMove(point: point)
        case .online:
            onlineManager?.placeStone(point: point)
        case .none:
            break
        }
    }

    func requestRetract(profile: UserProfile) {
        switch mode {
        case .vsAI:
            guard board.moves.count >= 2 else { return }
            mutateBoard { mutableBoard in
                _ = mutableBoard.undoLastMove()
                _ = mutableBoard.undoLastMove()
            }
            statusText = "Move undone"
            highlightedPoints = board.moves.suffix(1).map { $0.position }
        case .online:
            guard profile.allowRetracts else { return }
            onlineManager?.requestUndo()
            statusText = "Retract requested"
        case .none:
            break
        }
    }

    func respondToUndoRequest(accepted: Bool) {
        isUndoPromptVisible = false
        onlineManager?.respondToUndoRequest(accepted: accepted)
    }

    func resign() {
        switch mode {
        case .vsAI:
            statusText = "You resigned"
            profileStore?.record(result: .loss)
        case .online:
            onlineManager?.resign()
        case .none:
            break
        }
    }

    private func handleHumanMove(point: BoardPoint) {
        let didPlace = mutateBoard { mutableBoard in
            mutableBoard.placeStone(at: point, player: .black)
        }
        guard didPlace else { return }
        highlightedPoints = [point]
        if board.hasWin(for: .black) {
            statusText = "You win!"
            profileStore?.record(result: .win)
            return
        }
        statusText = "AI thinking…"
        Task { await performAIMove() }
    }

    private func performAIMove() async {
        guard let move = aiEngine?.nextMove(for: board, player: .white) else { return }
        DispatchQueue.main.async {
            let _ = self.mutateBoard { mutableBoard in
                mutableBoard.placeStone(at: move, player: .white)
            }
            self.highlightedPoints = [move]
            if self.board.hasWin(for: .white) {
                self.statusText = "AI wins"
                self.profileStore?.record(result: .loss)
            } else {
                self.statusText = "Your turn"
            }
        }
    }

    @discardableResult
    private func mutateBoard<T>(_ mutation: (inout GomokuBoard) -> T) -> T {
        var newBoard = board
        let result = mutation(&newBoard)
        board = newBoard
        return result
    }
}

private enum GameMode {
    case vsAI(AIDifficulty)
    case online
    case none
}

extension GameViewModel: OnlineSessionDelegate {
    func sessionDidUpdate(board: GomokuBoard, status: String, highlights: [BoardPoint]) {
        self.board = board
        self.statusText = status
        self.highlightedPoints = highlights
    }

    func sessionDidFinish(result: GameResult) {
        switch result {
        case .win:
            statusText = "You won!"
        case .loss:
            statusText = "Defeat"
        case .none:
            break
        }
        profileStore?.record(result: result)
    }

    func sessionDiscoveryStateChanged(isDiscovering: Bool) {
        self.isDiscovering = isDiscovering
    }

    func sessionDidReceiveUndoRequest() {
        isUndoPromptVisible = true
    }
}
