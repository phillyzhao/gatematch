import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) private var appState

    private enum Tab: Hashable {
        case nearby, matches, settings
    }

    @State private var selection: Tab = .nearby

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
            .tabItem { Label("Nearby", systemImage: "person.2.fill") }
            .tag(Tab.nearby)

            NavigationStack {
                ContentUnavailableView(
                    "No matches yet",
                    systemImage: "heart",
                    description: Text("When you and another traveler like each other, they show up here.")
                )
                .navigationTitle("Matches")
            }
            .tabItem { Label("Matches", systemImage: "heart.fill") }
            .tag(Tab.matches)

            NavigationStack {
                ContentUnavailableView(
                    "Settings coming soon",
                    systemImage: "gearshape",
                    description: Text("Profile, safety, and privacy controls will live here.")
                )
                .navigationTitle("Settings")
            }
            .tabItem { Label("Settings", systemImage: "gearshape.fill") }
            .tag(Tab.settings)
        }
        .tint(Theme.brand)
        .sheet(item: $appState.pendingMatchCelebration) { match in
            if let traveler = appState.traveler(withID: match.travelerID),
               let currentUser = appState.currentUser {
                MatchCelebrationView(currentUser: currentUser, traveler: traveler) { openMatches in
                    appState.pendingMatchCelebration = nil
                    if openMatches {
                        selection = .matches
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
            return state
        }())
}

#Preview("Checked in") {
    MainTabView()
        .environment(AppState.preview)
}
