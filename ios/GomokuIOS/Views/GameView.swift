import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    @EnvironmentObject private var userStore: UserProfileStore

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                boardSection
                controlsSection
            }
            .padding()
            .navigationTitle(viewModel.gameTitle)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        viewModel.isGamePresented = false
                    }
                }
            }
        }
        .alert("Retract Request", isPresented: $viewModel.isUndoPromptVisible) {
            Button("Allow", role: .none) {
                viewModel.respondToUndoRequest(accepted: true)
            }
            Button("Deny", role: .cancel) {
                viewModel.respondToUndoRequest(accepted: false)
            }
        } message: {
            Text("Your opponent would like to retract their last move.")
        }
    }

    private var boardSection: some View {
        BoardView(board: viewModel.board,
                  scale: $viewModel.boardScale,
                  highlighted: viewModel.highlightedPoints,
                  onTap: viewModel.handleBoardTap(point:))
            .aspectRatio(1, contentMode: .fit)
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
    }

    private var controlsSection: some View {
        VStack(spacing: 12) {
            Text(viewModel.statusText)
                .font(.headline)

            HStack {
                Button("Retract Move") {
                    viewModel.requestRetract(profile: userStore.requireProfile())
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canRetract)

                Button("Resign", role: .destructive) {
                    viewModel.resign()
                }
            }
        }
    }
}
