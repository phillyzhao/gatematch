import SwiftUI

/// Route marker for the settings screen.
struct SettingsRoute: Hashable {}

/// Route marker for editing personal info.
struct PersonalInfoRoute: Hashable {}

struct AccountView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        List {
            if let user = appState.currentUser {
                Section {
                    HStack(spacing: 14) {
                        AvatarView(profile: user, size: 64)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("\(user.firstName), \(user.age)")
                                .font(.title3.bold())
                            Label(user.travelPurpose.rawValue, systemImage: user.travelPurpose.symbolName)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                    if !user.bio.isEmpty {
                        Text(user.bio)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    NavigationLink(value: PersonalInfoRoute()) {
                        Label("Personal info", systemImage: "person.text.rectangle")
                    }
                } footer: {
                    Text("Name, email, age, and bio.")
                }

                Section("Your connections") {
                    LabeledContent("Connected", value: "\(appState.connections.count)")
                }
            } else {
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Browsing as guest")
                            .font(.headline)
                        Text("Add someone from the Connect tab to create your profile and start chatting.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }

            Section {
                NavigationLink(value: SettingsRoute()) {
                    Label("Settings", systemImage: "gearshape.fill")
                }
            }
        }
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
        .notificationBell()
        .navigationDestination(for: SettingsRoute.self) { _ in
            SettingsView()
        }
        .navigationDestination(for: PersonalInfoRoute.self) { _ in
            PersonalInfoView()
        }
    }
}

#Preview("Signed in") {
    NavigationStack {
        AccountView()
    }
    .environment(AppState.preview)
}

#Preview("Guest") {
    NavigationStack {
        AccountView()
    }
    .environment(AppState())
}
