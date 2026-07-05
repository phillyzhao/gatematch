import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        TabView {
            NavigationStack {
                if appState.isCheckedIn {
                    checkedInPlaceholder
                } else {
                    AirportCheckInView()
                }
            }
            .tabItem { Label("Nearby", systemImage: "person.2.fill") }

            NavigationStack {
                ContentUnavailableView(
                    "No matches yet",
                    systemImage: "heart",
                    description: Text("When you and another traveler like each other, they show up here.")
                )
                .navigationTitle("Matches")
            }
            .tabItem { Label("Matches", systemImage: "heart.fill") }

            NavigationStack {
                ContentUnavailableView(
                    "Settings coming soon",
                    systemImage: "gearshape",
                    description: Text("Profile, safety, and privacy controls will live here.")
                )
                .navigationTitle("Settings")
            }
            .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .tint(Theme.brand)
    }

    // Temporary landing spot until the traveler feed arrives.
    private var checkedInPlaceholder: some View {
        ContentUnavailableView(
            "Checked in at \(appState.checkIn?.airportCode ?? "")",
            systemImage: "checkmark.circle",
            description: Text("The traveler feed is coming next.")
        )
        .navigationTitle("Nearby")
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
