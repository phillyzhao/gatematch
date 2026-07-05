import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Group {
            if appState.hasOnboarded {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: appState.hasOnboarded)
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
