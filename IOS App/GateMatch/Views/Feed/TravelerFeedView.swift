import SwiftUI
import TipKit

/// The event guest list — the first thing you see after joining.
/// Travel details are an optional add-on here, not a required step.
struct TravelerFeedView: View {
    @Environment(AppState.self) private var appState
    @State private var showCheckIn = false

    private var inviteText: String {
        guard let event = appState.joinedEvent else {
            return "Join me on GateMatch to meet other travelers!"
        }
        return "Join me at \(event.name) on GateMatch! Enter code \(event.code) to see who's going and meet up while we travel. https://gatematch.app"
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                travelDetailsCard

                if appState.eventTravelers.isEmpty {
                    firstToJoinCard
                } else {
                    HStack {
                        Text("People going")
                            .font(Theme.heading(15))
                        Spacer()
                        Text("\(appState.eventTravelers.count)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 4)

                    TipView(ConnectTip())

                    ForEach(appState.eventTravelers) { traveler in
                        TravelerCardView(
                            traveler: traveler,
                            checkIn: appState.travelerCheckIns[traveler.id],
                            proximity: appState.proximity(of: traveler),
                            onConnect: {
                                withAnimation(.snappy) {
                                    _ = appState.connect(with: traveler)
                                }
                            },
                            onSkip: {
                                withAnimation(.snappy) {
                                    appState.skip(traveler)
                                }
                            }
                        )
                    }
                }
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Who's going")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: UserProfile.self) { traveler in
            ProfileDetailView(traveler: traveler)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: inviteText) {
                    Image(systemName: "person.badge.plus")
                }
                .accessibilityLabel("Invite a friend")
            }
        }
        .sheet(isPresented: $showCheckIn) {
            NavigationStack {
                AirportCheckInView()
            }
        }
    }

    // MARK: Optional travel details

    private var travelDetailsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let event = appState.joinedEvent {
                Text(event.name)
                    .font(Theme.heading(17))
            }

            Button {
                showCheckIn = true
            } label: {
                if let checkIn = appState.checkIn {
                    HStack(spacing: 10) {
                        Image(systemName: "airplane")
                            .foregroundStyle(Theme.brand)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Your travel details")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(checkInText(checkIn))
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.primary)
                        }
                        Spacer()
                        Text("Edit")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.brand)
                    }
                } else {
                    HStack(spacing: 10) {
                        Image(systemName: "airplane.departure")
                            .foregroundStyle(Theme.brand)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Add your travel details")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.primary)
                            Text("Optional — sorts who's closest to you")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Theme.brand)
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: First to join

    private var firstToJoinCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(.tertiarySystemFill))
                    .frame(width: 96, height: 96)
                Image(systemName: "person.wave.2.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(Theme.brand)
            }
            .accessibilityHidden(true)

            VStack(spacing: 6) {
                Text("You're the first one here")
                    .font(Theme.heading(18))
                Text("Nobody else from this event has joined yet. Invite a friend and start the group.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            ShareLink(item: inviteText) {
                Label("Invite a friend", systemImage: "person.badge.plus")
                    .font(Theme.heading(16))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.brand, in: Capsule())
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    private func checkInText(_ checkIn: AirportCheckIn) -> String {
        var parts = [checkIn.airportCode, checkIn.terminal]
        if !checkIn.gate.isEmpty {
            parts.append("Gate \(checkIn.gate)")
        }
        return parts.joined(separator: " · ")
    }
}

#Preview("Guest list") {
    NavigationStack {
        TravelerFeedView()
    }
    .environment(AppState.preview)
}

#Preview("First to join") {
    NavigationStack {
        TravelerFeedView()
    }
    .environment({
        let state = AppState()
        state.currentUser = MockData.previewUser
        // Join an event nobody else is attending in this stub.
        state.joinedEvent = Event(
            id: UUID(), name: "Preview Meetup", organizer: "GateMatch",
            city: "Chicago", category: "Meetup",
            startDate: .now, endDate: .now, code: "PREVIEW",
            details: "", primaryAirportCodes: ["ORD"]
        )
        return state
    }())
}
