import SwiftUI

/// Shown after onboarding, before any travel info: the user must join
/// an official event with its registration code.
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
            .navigationTitle("Your event")
            .sheet(item: $selectedEvent) { event in
                EventJoinView(event: event)
            }
        }
        .tint(Theme.brand)
    }

    private var header: some View {
        Text("GateMatch works around official events. Join yours with the code from your registration to meet fellow attendees while you travel.")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding(.bottom, 4)
    }

    private func eventCard(_ event: Event) -> some View {
        Button {
            selectedEvent = event
        } label: {
            VStack(alignment: .leading, spacing: 10) {
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

    private func dateRange(_ event: Event) -> String {
        let start = event.startDate.formatted(.dateTime.month(.abbreviated).day())
        let end = event.endDate.formatted(.dateTime.month(.abbreviated).day())
        return "\(start) – \(end)"
    }
}

#Preview {
    EventSelectionView()
        .environment(AppState())
}
