import SwiftUI

@main
struct GomokuIOSApp: App {
    @StateObject private var userStore = UserProfileStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(userStore)
        }
    }
}
