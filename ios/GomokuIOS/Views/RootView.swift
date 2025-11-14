import SwiftUI

struct RootView: View {
    @EnvironmentObject private var userStore: UserProfileStore
    @State private var selectedTab: Int = 0

    var body: some View {
        Group {
            if userStore.activeProfile == nil {
                AuthenticationView()
            } else {
                TabView(selection: $selectedTab) {
                    DashboardView()
                        .tabItem {
                            Label("Play", systemImage: "gamecontroller")
                        }
                        .tag(0)

                    StatsView()
                        .tabItem {
                            Label("Stats", systemImage: "chart.bar")
                        }
                        .tag(1)

                    ProfileView()
                        .tabItem {
                            Label("Profile", systemImage: "person")
                        }
                        .tag(2)
                }
            }
        }
        .animation(.spring(), value: userStore.activeProfile)
    }
}
