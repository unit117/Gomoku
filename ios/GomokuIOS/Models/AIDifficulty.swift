import Foundation

enum AIDifficulty: CaseIterable {
    case beginner
    case challenger
    case grandmaster

    var searchDepth: Int {
        switch self {
        case .beginner: return 1
        case .challenger: return 2
        case .grandmaster: return 3
        }
    }

    var randomness: Double {
        switch self {
        case .beginner: return 0.6
        case .challenger: return 0.2
        case .grandmaster: return 0.05
        }
    }

    var displayName: String {
        switch self {
        case .beginner: return "Beginner"
        case .challenger: return "Challenger"
        case .grandmaster: return "Grandmaster"
        }
    }

    var description: String {
        switch self {
        case .beginner: return "Fast, casual play"
        case .challenger: return "Balanced offense/defense"
        case .grandmaster: return "Full tactical depth"
        }
    }

    var iconName: String {
        switch self {
        case .beginner: return "hare"
        case .challenger: return "tortoise.fill"
        case .grandmaster: return "crown"
        }
    }
}
