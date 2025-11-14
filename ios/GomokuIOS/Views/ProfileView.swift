import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var userStore: UserProfileStore
    @State private var isConfirmingSignOut = false

    var body: some View {
        Form {
            if let profile = userStore.activeProfile {
                Section("Account") {
                    HStack {
                        Text("Username")
                        Spacer()
                        Text(profile.username)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Member Since")
                        Spacer()
                        Text(profile.createdAt.formatted(date: .abbreviated, time: .omitted))
                            .foregroundColor(.secondary)
                    }
                }

                Section("Preferences") {
                    Toggle("Allow Retract Prompts", isOn: Binding(get: {
                        profile.allowRetracts
                    }, set: { newValue in
                        userStore.updateAllowRetracts(newValue)
                    }))
                }

                Section {
                    Button("Sign Out", role: .destructive) {
                        isConfirmingSignOut = true
                    }
                }
            }
        }
        .confirmationDialog("Sign out?", isPresented: $isConfirmingSignOut, actions: {
            Button("Sign Out", role: .destructive) {
                userStore.signOut()
            }
        })
        .navigationTitle("Profile")
    }
}
