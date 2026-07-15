import SwiftUI

/// Edit the basics of your profile: name, email, age, purpose, bio.
struct PersonalInfoView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Form {
            Section("Name") {
                TextField("First name", text: binding(\.firstName, default: ""))
                    .textContentType(.givenName)
                    .autocorrectionDisabled()
            }

            Section {
                TextField("you@example.com", text: binding(\.email, default: ""))
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            } header: {
                Text("Email")
            } footer: {
                Text("Stored on this device only in the prototype — no account server yet.")
            }

            Section("About you") {
                Picker("Age", selection: binding(\.age, default: 28)) {
                    ForEach(18...99, id: \.self) { value in
                        Text("\(value)").tag(value)
                    }
                }
                .tint(Theme.brand)

                Picker("Travel purpose", selection: binding(\.travelPurpose, default: .leisure)) {
                    ForEach(TravelPurpose.allCases) { purpose in
                        Label(purpose.rawValue, systemImage: purpose.symbolName)
                            .tag(purpose)
                    }
                }
                .tint(Theme.brand)

                TextField("Short bio", text: binding(\.bio, default: ""), axis: .vertical)
                    .lineLimit(2...4)
            }
        }
        .navigationTitle("Personal info")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func binding<T>(_ keyPath: WritableKeyPath<UserProfile, T>, default defaultValue: T) -> Binding<T> {
        Binding(
            get: { appState.currentUser?[keyPath: keyPath] ?? defaultValue },
            set: { appState.currentUser?[keyPath: keyPath] = $0 }
        )
    }
}

#Preview {
    NavigationStack {
        PersonalInfoView()
    }
    .environment(AppState.preview)
}
