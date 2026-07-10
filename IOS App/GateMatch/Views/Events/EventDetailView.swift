import SwiftUI

/// Full event page: image placeholder, description, and a plus button
/// (bottom right) that starts the join flow — sign-up first if needed.
struct EventDetailView: View {
    @Environment(AppState.self) private var appState
    let event: Event

    @State private var showJoinSheet = false

    private var isJoined: Bool {
        appState.joinedEvent?.id == event.id
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                imagePlaceholder

                HStack {
                    Text(event.category)
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Theme.brand, in: Capsule())
                        .foregroundStyle(.white)
                    Spacer()
                    Label(isJoined ? "Joined" : "Code required", systemImage: isJoined ? "checkmark.seal.fill" : "lock.fill")
                        .font(.caption2)
                        .foregroundStyle(isJoined ? Theme.brand : .secondary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(event.name)
                        .font(Theme.display(22))
                    Text(event.organizer)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Label(event.city, systemImage: "mappin.and.ellipse")
                    Label(dateRange, systemImage: "calendar")
                    Label("\(appState.attendeeCount(for: event)) travelers going", systemImage: "person.2")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("About this event")
                        .font(Theme.heading(13))
                        .foregroundStyle(.secondary)
                    Text(event.details)
                        .font(.body)
                }
            }
            .padding(20)
        }
        .contentMargins(.bottom, 100, for: .scrollContent)
        .background(Color(.systemGroupedBackground))
        .navigationTitle(event.name)
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .bottomTrailing) { joinButton }
        .sheet(isPresented: $showJoinSheet) {
            // No account yet → sign up first; the sheet then flows
            // straight into code entry for this event.
            if appState.hasOnboarded {
                EventJoinView(event: event)
            } else {
                OnboardingView()
                    .presentationDetents([.large])
            }
        }
    }

    private var imagePlaceholder: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(Color(.tertiarySystemFill))
            .frame(height: 200)
            .overlay {
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundStyle(.tertiary)
            }
            .overlay(alignment: .topTrailing) {
                connectionsBadge
                    .padding(10)
            }
    }

    private var connectionsBadge: some View {
        let count = appState.connectionsAttending(event)
        return ZStack {
            Circle().fill(Theme.brand)
            Text("\(count)")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
        }
        .frame(width: 34, height: 34)
        .overlay(Circle().strokeBorder(Color(.systemBackground), lineWidth: 2))
        .accessibilityLabel("\(count) of your connections are going")
    }

    @ViewBuilder
    private var joinButton: some View {
        if isJoined {
            NavigationLink(value: EventHomeRoute()) {
                Image(systemName: "arrow.right")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(Circle().fill(Theme.brand))
            }
            .padding(20)
            .accessibilityLabel("Enter event")
        } else {
            Button {
                showJoinSheet = true
            } label: {
                Image(systemName: "plus")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(Circle().fill(Theme.brand))
            }
            .padding(20)
            .accessibilityLabel("Join event")
        }
    }

    private var dateRange: String {
        let start = event.startDate.formatted(.dateTime.month(.abbreviated).day())
        let end = event.endDate.formatted(.dateTime.month(.abbreviated).day())
        return "\(start) – \(end)"
    }
}

#Preview {
    NavigationStack {
        EventDetailView(event: MockData.events[0])
    }
    .environment(AppState())
}
