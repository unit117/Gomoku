import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject private var userStore: UserProfileStore
    @State private var username: String = ""
    @State private var pin: String = ""
    @State private var isRegistering: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 24) {
            Text(isRegistering ? "Create Account" : "Welcome Back")
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 12) {
                TextField("Username", text: $username)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))

                SecureField("4-digit PIN", text: $pin)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }

            if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            Button(action: handleAuthAction) {
                Text(isRegistering ? "Create Profile" : "Sign In")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
                    .foregroundColor(.white)
            }
            .disabled(username.isEmpty || pin.count != 4)

            Button(isRegistering ? "I already have an account" : "Create a new account") {
                withAnimation { isRegistering.toggle() }
            }
        }
        .padding()
    }

    private func handleAuthAction() {
        do {
            if isRegistering {
                try userStore.register(username: username, pin: pin)
            } else {
                try userStore.signIn(username: username, pin: pin)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
