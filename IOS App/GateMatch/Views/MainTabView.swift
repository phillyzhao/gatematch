import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                ContentUnavailableView(
                    "Airport check-in coming next",
                    systemImage: "airplane",
                    description: Text("Check in to your airport to see travelers nearby.")
                )
                .navigationTitle("Nearby")
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
}

#Preview {
    MainTabView()
        .environment(AppState.preview)
}
