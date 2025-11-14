import SwiftUI

struct StatsView: View {
    @EnvironmentObject private var userStore: UserProfileStore

    var body: some View {
        VStack(spacing: 16) {
            if let profile = userStore.activeProfile {
                Text("Performance Snapshot")
                    .font(.title2)
                    .fontWeight(.semibold)

                StatsRow(title: "Wins", value: "\(profile.wins)")
                StatsRow(title: "Losses", value: "\(profile.losses)")
                StatsRow(title: "Win Rate", value: profile.winRate.formatted(.percent.precision(.fractionLength(1))))
                StatsRow(title: "Longest Streak", value: "\(profile.longestStreak)")
                Spacer()
            } else {
                Text("Sign in to track your progress")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .navigationTitle("Stats")
    }
}

private struct StatsRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .font(.headline)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
