import SwiftUI

struct MatchesView: View {
    @Environment(AppState.self) private var appState

    private var visibleMatches: [Match] {
        appState.matches
            .filter { !appState.blockedIDs.contains($0.travelerID) }
            .sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        Group {
            if visibleMatches.isEmpty {
                ContentUnavailableView(
                    "No matches yet",
                    systemImage: "heart",
                    description: Text("When you and another traveler like each other, they show up here.")
                )
            } else {
                List(visibleMatches) { match in
                    if let traveler = appState.traveler(withID: match.travelerID) {
                        NavigationLink(value: match) {
                            matchRow(match: match, traveler: traveler)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Matches")
        .navigationDestination(for: Match.self) { match in
            ChatView(match: match)
        }
    }

    private func matchRow(match: Match, traveler: UserProfile) -> some View {
        HStack(spacing: 12) {
            AvatarView(profile: traveler, size: 48)
            VStack(alignment: .leading, spacing: 3) {
                Text(traveler.firstName)
                    .font(.headline)
                if let lastMessage = appState.messages[match.id]?.last {
                    Text(lastMessage.text)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
            Text(match.createdAt.formatted(date: .omitted, time: .shortened))
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        MatchesView()
    }
    .environment(AppState.preview)
}
