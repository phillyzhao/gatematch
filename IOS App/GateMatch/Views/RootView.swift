import SwiftUI

struct RootView: View {
    @AppStorage("appearanceMode") private var appearanceRaw = AppearanceMode.system.rawValue

    var body: some View {
        MainShellView()
            .preferredColorScheme(AppearanceMode(rawValue: appearanceRaw)?.colorScheme)
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
