import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) private var appState

    private enum Tab: Hashable {
        case travelers, connections, settings
    }

    @State private var selection: Tab = .travelers

    var body: some View {
        @Bindable var appState = appState
        TabView(selection: $selection) {
            NavigationStack {
                if appState.isCheckedIn {
                    TravelerFeedView()
                } else {
                    AirportCheckInView()
                }
            }
            .tabItem { Label("Travelers", systemImage: "person.2.fill") }
            .tag(Tab.travelers)

            NavigationStack {
                ConnectionsView()
            }
            .tabItem { Label("Connections", systemImage: "person.line.dotted.person.fill") }
            .tag(Tab.connections)

            NavigationStack {
                SettingsView()
            }
            .tabItem { Label("Settings", systemImage: "gearshape.fill") }
            .tag(Tab.settings)
        }
        .tint(Theme.brand)
        .sheet(item: $appState.pendingCelebration) { connection in
            if let traveler = appState.traveler(withID: connection.travelerID),
               let currentUser = appState.currentUser {
                ConnectionCelebrationView(currentUser: currentUser, traveler: traveler) { openConnections in
                    appState.pendingCelebration = nil
                    if openConnections {
                        selection = .connections
                    }
                }
            }
        }
    }
}

#Preview("Needs check-in") {
    MainTabView()
        .environment({
            let state = AppState()
            state.currentUser = MockData.previewUser
            state.joinedEvent = MockData.events.first
            return state
        }())
}

#Preview("Checked in") {
    MainTabView()
        .environment(AppState.preview)
}
