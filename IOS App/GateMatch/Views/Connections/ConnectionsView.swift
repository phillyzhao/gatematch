import SwiftUI

struct ConnectionsView: View {
    @Environment(AppState.self) private var appState

    private var visibleConnections: [Connection] {
        appState.connections
            .filter { !appState.blockedIDs.contains($0.travelerID) }
            .sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        Group {
            if visibleConnections.isEmpty {
                ContentUnavailableView(
                    "No connections yet",
                    systemImage: "person.line.dotted.person",
                    description: Text("When you and another attendee both want to meet, they show up here.")
                )
            } else {
                List(visibleConnections) { connection in
                    if let traveler = appState.traveler(withID: connection.travelerID) {
                        NavigationLink(value: connection) {
                            connectionRow(connection: connection, traveler: traveler)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Connections")
        .navigationDestination(for: Connection.self) { connection in
            ChatView(connection: connection)
        }
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

#Preview {
    NavigationStack {
        ConnectionsView()
    }
    .environment(AppState.preview)
}
