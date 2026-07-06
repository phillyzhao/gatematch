import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        // Browse-first: no sign-up gate. The app opens on the event browser;
        // a profile is only created when the user joins their first event.
        Group {
            if appState.hasJoinedEvent {
                MainTabView()
            } else {
                EventSelectionView()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: appState.hasJoinedEvent)
    }
}

#Preview("Browsing") {
    RootView()
        .environment(AppState())
}

#Preview("Event joined") {
    RootView()
        .environment(AppState.preview)
}
