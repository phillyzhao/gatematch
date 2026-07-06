import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Group {
            if !appState.hasOnboarded {
                OnboardingView()
            } else if !appState.hasJoinedEvent {
                EventSelectionView()
            } else {
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: appState.hasOnboarded)
        .animation(.easeInOut(duration: 0.25), value: appState.hasJoinedEvent)
    }
}

#Preview("Onboarding") {
    RootView()
        .environment(AppState())
}

#Preview("Onboarded") {
    RootView()
        .environment(AppState.preview)
}
