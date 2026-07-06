import SwiftUI

struct TravelerFeedView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Group {
            if appState.eventTravelers.isEmpty {
                ContentUnavailableView(
                    "No attendees yet",
                    systemImage: "person.2",
                    description: Text("You're the first traveler from your event here. Check back soon.")
                )
            } else {
                feedList
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Nearby")
        .navigationDestination(for: UserProfile.self) { traveler in
            ProfileDetailView(traveler: traveler)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Change") {
                    appState.checkIn = nil
                }
                .font(.subheadline)
            }
        }
        .safeAreaInset(edge: .top) { eventBanner }
    }

    private var feedList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(appState.eventTravelers) { traveler in
                    TravelerCardView(
                        traveler: traveler,
                        checkIn: appState.travelerCheckIns[traveler.id],
                        proximity: appState.proximity(of: traveler),
                        onLike: {
                            withAnimation(.snappy) {
                                _ = appState.like(traveler)
                            }
                        },
                        onPass: {
                            withAnimation(.snappy) {
                                appState.pass(traveler)
                            }
                        }
                    )
                }
            }
            .padding(16)
        }
    }

    private var eventBanner: some View {
        VStack(alignment: .leading, spacing: 3) {
            if let event = appState.joinedEvent {
                Text(event.name)
                    .font(.footnote.weight(.semibold))
            }
            HStack(spacing: 6) {
                Image(systemName: "airplane")
                    .font(.caption2)
                    .foregroundStyle(Theme.brand)
                Text(checkInText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.bar)
    }

    private var checkInText: String {
        guard let checkIn = appState.checkIn else { return "" }
        var parts = [checkIn.airportCode, checkIn.terminal]
        if !checkIn.gate.isEmpty {
            parts.append("Gate \(checkIn.gate)")
        }
        return parts.joined(separator: " · ")
    }
}

#Preview {
    NavigationStack {
        TravelerFeedView()
    }
    .environment(AppState.preview)
}
