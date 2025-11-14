import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var userStore: UserProfileStore
    @StateObject private var viewModel = GameViewModel()
    @State private var isOnlinePresented = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    SectionHeader(title: "Solo vs AI")

                    ForEach(AIDifficulty.allCases, id: \.self) { difficulty in
                        Button {
                            viewModel.startAIGame(difficulty: difficulty, store: userStore)
                        } label: {
                            GameCard(title: difficulty.displayName,
                                     subtitle: difficulty.description,
                                     iconName: difficulty.iconName)
                        }
                    }

                    SectionHeader(title: "Multiplayer")

                    Button {
                        isOnlinePresented = true
                    } label: {
                        GameCard(title: "Online Match",
                                 subtitle: "Invite or auto-match players",
                                 iconName: "network")
                    }
                }
                .padding()
            }
            .navigationTitle("Gomoku")
            .sheet(isPresented: $viewModel.isGamePresented, onDismiss: viewModel.endCurrentGame) {
                GameView(viewModel: viewModel)
                    .environmentObject(userStore)
            }
            .sheet(isPresented: $isOnlinePresented) {
                OnlineMatchmakerView(viewModel: viewModel)
                    .environmentObject(userStore)
            }
        }
    }
}

private struct SectionHeader: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
        }
    }
}

private struct GameCard: View {
    let title: String
    let subtitle: String
    let iconName: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: 28))
                .frame(width: 48, height: 48)
                .background(Color.accentColor.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}
