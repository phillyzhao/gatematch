import SwiftUI

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system, light, dark

    var id: String { rawValue }
    var label: String { rawValue.capitalized }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

/// Applies the user's chosen appearance by overriding the interface style at
/// the window level — the single source of truth. Mixing in SwiftUI's
/// `preferredColorScheme` caused UIKit-backed pieces (paged TabView, pickers)
/// to latch onto stale values when switching, so it is deliberately not used.
struct AppAppearanceModifier: ViewModifier {
    @AppStorage("appearanceMode") private var appearanceRaw = AppearanceMode.system.rawValue

    func body(content: Content) -> some View {
        content
            .onAppear {
                Self.applyWindowOverride(AppearanceMode(rawValue: appearanceRaw) ?? .system)
            }
            .onChange(of: appearanceRaw) {
                Self.applyWindowOverride(AppearanceMode(rawValue: appearanceRaw) ?? .system)
            }
    }

    static func applyWindowOverride(_ mode: AppearanceMode) {
        let style: UIUserInterfaceStyle
        switch mode {
        case .system: style = .unspecified
        case .light: style = .light
        case .dark: style = .dark
        }
        for case let scene as UIWindowScene in UIApplication.shared.connectedScenes {
            for window in scene.windows {
                window.overrideUserInterfaceStyle = style
            }
        }
    }
}

extension View {
    func appAppearance() -> some View {
        modifier(AppAppearanceModifier())
    }
}

enum Theme {
    /// GateMatch brand blue — strong and direct. Always used as a flat fill,
    /// never behind shadows, glows, or dimming overlays.
    static let brand = Color(red: 22 / 255, green: 86 / 255, blue: 219 / 255)

    // MARK: Brand fonts (bundled, registered at launch)

    /// Big display moments: celebration titles, event names on detail pages.
    static func display(_ size: CGFloat) -> Font {
        .custom("Montserrat-Bold", size: size)
    }

    /// Headings and buttons.
    static func heading(_ size: CGFloat) -> Font {
        .custom("Montserrat-SemiBold", size: size)
    }

    /// Codes and airport identifiers.
    static func mono(_ size: CGFloat) -> Font {
        .custom("RobotoMono-Medium", size: size)
    }

    /// Deterministic avatar tint so each traveler keeps their color everywhere.
    static func avatarColor(for profile: UserProfile) -> Color {
        let palette: [Color] = [.teal, .indigo, .purple, .orange, .pink, .green, .cyan, .mint]
        let value = profile.id.uuidString.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return palette[value % palette.count]
    }
}
