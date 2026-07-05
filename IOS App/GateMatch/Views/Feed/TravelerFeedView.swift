import SwiftUI

struct TravelerFeedView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Group {
            if appState.nearbyTravelers.isEmpty {
                ContentUnavailableView(
                    "No travelers nearby",
                    systemImage: "person.2",
                    description: Text("Nobody else is checked in at your airport right now. Check back soon.")
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
        .safeAreaInset(edge: .top) { checkInBanner }
    }

    private var feedList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(appState.nearbyTravelers) { traveler in
                    TravelerCardView(
                        traveler: traveler,
                        checkIn: appState.travelerCheckIns[traveler.id],
                        sameTerminal: appState.proximityRank(of: traveler) <= 1,
                        sameGate: appState.proximityRank(of: traveler) == 0,
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

    private var checkInBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "airplane")
                .font(.caption)
                .foregroundStyle(Theme.brand)
            Text(bannerText)
                .font(.footnote.weight(.medium))
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.bar)
    }

    private var bannerText: String {
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
