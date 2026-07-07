import SwiftUI

/// Route marker for the settings screen.
struct SettingsRoute: Hashable {}

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

                if let event = appState.joinedEvent {
                    Section("Your event") {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(event.name)
                                .font(.headline)
                            Text("\(event.organizer) · \(event.city)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }
            } else {
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Browsing as guest")
                            .font(.headline)
                        Text("Join an event from the Events tab to create your traveler profile.")
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
        .navigationDestination(for: SettingsRoute.self) { _ in
            SettingsView()
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
