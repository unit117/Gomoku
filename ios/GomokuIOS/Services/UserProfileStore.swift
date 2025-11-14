import Foundation

@MainActor
final class UserProfileStore: ObservableObject {
    @Published private(set) var profiles: [UserProfile] = []
    @Published private(set) var activeProfile: UserProfile?
    private let storageKey = "gomoku.userprofiles"

    init() {
        load()
    }

    func register(username: String, pin: String) throws {
        guard !profiles.contains(where: { $0.username == username }) else {
            throw AuthError.usernameTaken
        }
        let profile = UserProfile(username: username, pin: pin)
        profiles.append(profile)
        activeProfile = profile
        persist()
    }

    func signIn(username: String, pin: String) throws {
        guard let profile = profiles.first(where: { $0.username == username && $0.pin == pin }) else {
            throw AuthError.invalidCredentials
        }
        activeProfile = profile
    }

    func signOut() {
        activeProfile = nil
    }

    func record(result: GameResult) {
        guard let profile = activeProfile, result != .none else { return }
        if let index = profiles.firstIndex(where: { $0.id == profile.id }) {
            profiles[index] = profile.updatedAfterGame(result: result)
            activeProfile = profiles[index]
            persist()
        }
    }

    func updateAllowRetracts(_ allow: Bool) {
        guard let profile = activeProfile else { return }
        if let index = profiles.firstIndex(where: { $0.id == profile.id }) {
            profiles[index].allowRetracts = allow
            activeProfile = profiles[index]
            persist()
        }
    }

    func requireProfile() -> UserProfile {
        guard let profile = activeProfile else {
            fatalError("Profile required before starting game")
        }
        return profile
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        if let decoded = try? JSONDecoder().decode([UserProfile].self, from: data) {
            profiles = decoded
        }
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(profiles) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}

enum AuthError: LocalizedError {
    case usernameTaken
    case invalidCredentials

    var errorDescription: String? {
        switch self {
        case .usernameTaken:
            return "That username is already registered."
        case .invalidCredentials:
            return "Incorrect username or PIN."
        }
    }
}
