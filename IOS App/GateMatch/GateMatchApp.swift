import CoreText
import SwiftUI
import TipKit

@main
struct GateMatchApp: App {
    @State private var appState = AppState()

    init() {
        Self.registerBundledFonts()
        Self.configureNavigationBarFonts()
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

    /// The brand fonts ship as loose .ttf files; register them at runtime
    /// so no Info.plist entries are needed.
    private static func registerBundledFonts() {
        for url in Bundle.main.urls(forResourcesWithExtension: "ttf", subdirectory: nil) ?? [] {
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }

    /// Centered navigation titles in the brand font, on every page.
    private static func configureNavigationBarFonts() {
        let appearance = UINavigationBar.appearance()
        if let title = UIFont(name: "Montserrat-SemiBold", size: 17) {
            appearance.titleTextAttributes = [.font: title]
        }
        if let largeTitle = UIFont(name: "Montserrat-Bold", size: 32) {
            appearance.largeTitleTextAttributes = [.font: largeTitle]
        }
    }
}
