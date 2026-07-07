import SwiftUI

/// The Events tab root: anyone can browse official events without an
/// account. Tapping an event asks for sign-up first (if needed), then the code.
private struct EventsScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct EventSelectionView: View {
    @Environment(AppState.self) private var appState

    @State private var searchText = ""
    @State private var isSearchVisible = true
    @State private var lastScrollOffset: CGFloat = 0
    @FocusState private var searchFocused: Bool

    private var filteredEvents: [Event] {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return appState.events }
        return appState.events.filter {
            $0.name.localizedCaseInsensitiveContains(query)
                || $0.city.localizedCaseInsensitiveContains(query)
                || $0.organizer.localizedCaseInsensitiveContains(query)
                || $0.category.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let joined = appState.joinedEvent {
                        joinedCard(joined)
                    } else {
                        header
                    }
                    if filteredEvents.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                            .padding(.top, 40)
                    }
                    ForEach(filteredEvents) { event in
                        eventCard(event)
                    }
                }
                .padding(20)
                .background(
                    GeometryReader { geo in
                        Color.clear.preference(
                            key: EventsScrollOffsetKey.self,
                            value: geo.frame(in: .named("eventsScroll")).minY
                        )
                    }
                )
            }
            .coordinateSpace(name: "eventsScroll")
            .onPreferenceChange(EventsScrollOffsetKey.self) { offset in
                handleScroll(offset)
            }
            // Floating search, about a third of the way down the screen.
            // Hides while scrolling down; swipe up brings it back.
            .overlay(alignment: .top) {
                if isSearchVisible {
                    searchBar
                        .padding(.horizontal, 28)
                        .padding(.top, proxy.size.height / 3)
                        .transition(.opacity)
                }
            }
        }
        .contentMargins(.bottom, 88, for: .scrollContent)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Events")
        .notificationBell()
        .navigationDestination(for: Event.self) { event in
            EventDetailView(event: event)
        }
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search events", text: $searchText)
                .focused($searchFocused)
                .autocorrectionDisabled()
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.tertiary)
                }
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(Capsule().fill(.ultraThinMaterial))
        .overlay(Capsule().strokeBorder(Color.primary.opacity(0.08)))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
    }

    private func handleScroll(_ offset: CGFloat) {
        defer { lastScrollOffset = offset }
        // Never hide mid-search.
        guard searchText.isEmpty, !searchFocused else { return }
        let delta = offset - lastScrollOffset
        guard abs(delta) > 8 else { return }
        let shouldShow = delta > 0 || offset >= 0
        if shouldShow != isSearchVisible {
            withAnimation(.snappy(duration: 0.25)) {
                isSearchVisible = shouldShow
            }
        }
    }

    private var header: some View {
        Text("Explore official events on GateMatch. Open one to see details and join with your registration code — you'll create a profile the first time.")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding(.bottom, 4)
    }

    /// Entry into the event you've joined: check-in and the traveler feed.
    private func joinedCard(_ event: Event) -> some View {
        NavigationLink(value: EventHomeRoute()) {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Theme.brand, in: Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text("Your event")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(event.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(appState.isCheckedIn ? "Tap to meet travelers" : "Tap to check in at your airport")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(14)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Theme.brand, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }

    private func eventCard(_ event: Event) -> some View {
        NavigationLink(value: event) {
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
    NavigationStack {
        EventSelectionView()
    }
    .environment(AppState())
}

#Preview("Event joined") {
    NavigationStack {
        EventSelectionView()
    }
    .environment(AppState.preview)
}
