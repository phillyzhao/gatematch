import SwiftUI

enum Theme {
    /// GateMatch brand blue — strong and direct. Always used as a flat fill,
    /// never behind shadows, glows, or dimming overlays.
    static let brand = Color(red: 22 / 255, green: 86 / 255, blue: 219 / 255)

    /// Deterministic avatar tint so each traveler keeps their color everywhere.
    static func avatarColor(for profile: UserProfile) -> Color {
        let palette: [Color] = [.teal, .indigo, .purple, .orange, .pink, .green, .cyan, .mint]
        let value = profile.id.uuidString.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return palette[value % palette.count]
    }
}
