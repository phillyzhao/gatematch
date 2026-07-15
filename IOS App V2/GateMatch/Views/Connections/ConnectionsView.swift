import SwiftUI

struct ConnectionsView: View {
    @Environment(AppState.self) private var appState

    private var visibleConnections: [Connection] {
        appState.connections
            .filter { !appState.blockedIDs.contains($0.travelerID) }
            .sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        List {
            // The helper bot is always here, for every user.
            Section {
                NavigationLink(value: BotRoute()) {
                    botRow
                }
            }

            if visibleConnections.isEmpty {
                Section {
                    Text("When you and someone you add both want to meet, your chat starts here.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else {
                Section("People") {
                    ForEach(visibleConnections) { connection in
                        if let traveler = appState.traveler(withID: connection.travelerID) {
                            NavigationLink(value: connection) {
                                connectionRow(connection: connection, traveler: traveler)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Messages")
        .navigationBarTitleDisplayMode(.inline)
        .notificationBell()
        .navigationDestination(for: Connection.self) { connection in
            ChatView(connection: connection)
        }
        .navigationDestination(for: BotRoute.self) { _ in
            BotChatView()
        }
    }

    private var botRow: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(Theme.brand)
                Image(systemName: "sparkles")
                    .font(.title3)
                    .foregroundStyle(.white)
            }
            .frame(width: 48, height: 48)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(HelperBot.name)
                        .font(.headline)
                    Text("BOT")
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(.tertiarySystemFill), in: Capsule())
                        .foregroundStyle(.secondary)
                }
                Text(appState.botMessages.last?.text ?? "Ask me how GateMatch works")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }

    private func connectionRow(connection: Connection, traveler: UserProfile) -> some View {
        HStack(spacing: 12) {
            AvatarView(profile: traveler, size: 48)
            VStack(alignment: .leading, spacing: 3) {
                Text(traveler.firstName)
                    .font(.headline)
                if let lastMessage = appState.messages[connection.id]?.last {
                    Text(lastMessage.text)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
            Text(connection.createdAt.formatted(date: .omitted, time: .shortened))
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

#Preview("With connections") {
    NavigationStack {
        ConnectionsView()
    }
    .environment(AppState.preview)
}

#Preview("Bot only") {
    NavigationStack {
        ConnectionsView()
    }
    .environment(AppState())
}
