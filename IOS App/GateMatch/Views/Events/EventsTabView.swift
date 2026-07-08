import SwiftUI

/// Route marker for the joined event's traveler experience.
struct EventHomeRoute: Hashable {}

struct EventsTabView: View {
    @Environment(AppState.self) private var appState
    @Binding var path: NavigationPath

    var body: some View {
        NavigationStack(path: $path) {
            EventSelectionView()
                .navigationDestination(for: EventHomeRoute.self) { _ in
                    EventHomeView()
                }
        }
        // Joining drops you straight into the guest list; leaving returns
        // to the browser.
        .onChange(of: appState.joinedEvent?.id) { _, newID in
            if newID != nil {
                path.append(EventHomeRoute())
            } else {
                path = NavigationPath()
            }
        }
    }
}

/// Inside the joined event: meet the people going. Travel details are optional
/// and added from here — never a gate you must clear first.
struct EventHomeView: View {
    var body: some View {
        TravelerFeedView()
    }
}

#Preview {
    EventsTabView(path: .constant(NavigationPath()))
        .environment(AppState.preview)
}
