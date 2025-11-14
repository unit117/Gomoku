import SwiftUI

struct OnlineMatchmakerView: View {
    @ObservedObject var viewModel: GameViewModel
    @EnvironmentObject private var userStore: UserProfileStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Find another player to start an online match. You can invite specific friends via AirDrop or use automatic discovery.")
                    .font(.callout)
                    .foregroundColor(.secondary)

                Button(action: connect) {
                    Label("Start Discovering", systemImage: "antenna.radiowaves.left.and.right")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isDiscovering)

                if viewModel.isDiscovering {
                    ProgressView("Looking for players…")
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Online Match")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func connect() {
        viewModel.beginOnlineGame(profile: userStore.requireProfile(), store: userStore)
        dismiss()
    }
}
