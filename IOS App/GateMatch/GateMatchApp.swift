import SwiftUI
import TipKit

@main
struct GateMatchApp: App {
    @State private var appState = AppState()

    init() {
        try? Tips.configure([
            .displayFrequency(.immediate),
            .datastoreLocation(.applicationDefault),
        ])
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
        }
    }
}
