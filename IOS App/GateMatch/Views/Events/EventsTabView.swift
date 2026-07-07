import SwiftUI

/// Route marker for the joined event's traveler experience.
struct EventHomeRoute: Hashable {}

struct EventsTabView: View {
    @Binding var path: NavigationPath

    var body: some View {
        NavigationStack(path: $path) {
            EventSelectionView()
                .navigationDestination(for: EventHomeRoute.self) { _ in
                    EventHomeView()
                }
        }
    }
}

/// Inside the joined event: check in first, then meet travelers.
struct EventHomeView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        if appState.isCheckedIn {
            TravelerFeedView()
        } else {
            AirportCheckInView()
        }
    }
}

#Preview {
    EventsTabView(path: .constant(NavigationPath()))
        .environment(AppState.preview)
}
