import SwiftUI

/// The app's landing screen: anyone can browse official events without an
/// account. Tapping an event asks for sign-up first (if needed), then the code.
struct EventSelectionView: View {
    @Environment(AppState.self) private var appState

    @State private var selectedEvent: Event?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    ForEach(appState.events) { event in
                        eventCard(event)
                    }
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Events")
            .sheet(item: $selectedEvent) { event in
                // No account yet → sign up first; the sheet then flows
                // straight into code entry for the tapped event.
                if appState.hasOnboarded {
                    EventJoinView(event: event)
                } else {
                    OnboardingView()
                        .presentationDetents([.large])
                }
            }
        }
        .tint(Theme.brand)
    }

    private var header: some View {
        Text("Explore official events on GateMatch. Tap one to join with your registration code — you'll create a profile the first time.")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding(.bottom, 4)
    }

    private func eventCard(_ event: Event) -> some View {
        Button {
            selectedEvent = event
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                imagePlaceholder(for: event)

                HStack {
                    Text(event.category)
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Theme.brand, in: Capsule())
                        .foregroundStyle(.white)
                    Spacer()
                    Label("Code required", systemImage: "lock.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(event.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                    Text(event.organizer)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 14) {
                    Label(event.city, systemImage: "mappin.and.ellipse")
                    Label(dateRange(event), systemImage: "calendar")
                    Label("\(appState.attendeeCount(for: event)) travelers", systemImage: "person.2")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    /// Placeholder box where the event image will go in a later version.
    private func imagePlaceholder(for event: Event) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.tertiarySystemFill))
            .frame(height: 130)
            .overlay {
                Image(systemName: "photo")
                    .font(.title)
                    .foregroundStyle(.tertiary)
            }
            .overlay(alignment: .topTrailing) {
                connectionsBadge(for: event)
                    .padding(8)
            }
    }

    /// Circular pfp-style badge: how many of your connections are going.
    private func connectionsBadge(for event: Event) -> some View {
        let count = appState.connectionsAttending(event)
        return ZStack {
            Circle()
                .fill(Theme.brand)
            Text("\(count)")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
        }
        .frame(width: 34, height: 34)
        .overlay(Circle().strokeBorder(.white, lineWidth: 2))
        .accessibilityLabel("\(count) of your connections are going")
    }

    private func dateRange(_ event: Event) -> String {
        let start = event.startDate.formatted(.dateTime.month(.abbreviated).day())
        let end = event.endDate.formatted(.dateTime.month(.abbreviated).day())
        return "\(start) – \(end)"
    }
}

#Preview("Browsing, no account") {
    EventSelectionView()
        .environment(AppState())
}

#Preview("With connections") {
    EventSelectionView()
        .environment({
            let state = AppState.preview
            state.leaveEvent()
            return state
        }())
}
