import Foundation

struct UserProfile: Identifiable, Codable, Equatable {
    let id: UUID
    var username: String
    var pin: String
    var wins: Int
    var losses: Int
    var longestStreak: Int
    var currentStreak: Int
    var allowRetracts: Bool
    var createdAt: Date

    init(id: UUID = UUID(), username: String, pin: String) {
        self.id = id
        self.username = username
        self.pin = pin
        self.wins = 0
        self.losses = 0
        self.longestStreak = 0
        self.currentStreak = 0
        self.allowRetracts = true
        self.createdAt = Date()
    }

    var winRate: Double {
        let total = Double(wins + losses)
        guard total > 0 else { return 0 }
        return Double(wins) / total
    }

    func updatedAfterGame(result: GameResult) -> UserProfile {
        var copy = self
        switch result {
        case .win:
            copy.wins += 1
            copy.currentStreak += 1
            copy.longestStreak = max(copy.longestStreak, copy.currentStreak)
        case .loss:
            copy.losses += 1
            copy.currentStreak = 0
        case .none:
            break
        }
        return copy
    }
}

enum GameResult {
    case win
    case loss
    case none
}
