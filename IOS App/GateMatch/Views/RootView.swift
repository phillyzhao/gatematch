import SwiftUI

struct RootView: View {
    var body: some View {
        MainShellView()
            .appAppearance()
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
