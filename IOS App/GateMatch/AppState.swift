import Foundation
import Observation

/// Single source of truth for the local-only prototype.
/// No networking — everything lives in memory, seeded from MockData.
@Observable
@MainActor
final class AppState {
    // MARK: Current user
    var currentUser: UserProfile?
    var checkIn: AirportCheckIn?

    // MARK: Mock world
    let travelers: [UserProfile]
    let travelerCheckIns: [UUID: AirportCheckIn]
    /// Travelers who have already "liked" the current user (mock).
    let incomingLikes: Set<UUID>

    // MARK: Interactions
    var likedIDs: Set<UUID> = []
    var passedIDs: Set<UUID> = []
    var matches: [Match] = []
    /// Chat threads keyed by match ID.
    var messages: [UUID: [ChatMessage]] = [:]
    var blockedIDs: Set<UUID> = []

    var hasOnboarded: Bool { currentUser != nil }
    var isCheckedIn: Bool { checkIn != nil }

    init(
        travelers: [UserProfile] = MockData.travelers,
        travelerCheckIns: [UUID: AirportCheckIn] = MockData.travelerCheckIns,
        incomingLikes: Set<UUID> = MockData.incomingLikes
    ) {
        self.travelers = travelers
        self.travelerCheckIns = travelerCheckIns
        self.incomingLikes = incomingLikes
    }

    func traveler(withID id: UUID) -> UserProfile? {
        travelers.first { $0.id == id }
    }

    /// Fully set-up state for SwiftUI previews: onboarded and checked in at ORD.
    static var preview: AppState {
        let state = AppState()
        state.currentUser = MockData.previewUser
        state.checkIn = AirportCheckIn(
            userID: MockData.previewUser.id,
            airportCode: "ORD",
            terminal: "Terminal 1",
            gate: "B12",
            flightTime: .now.addingTimeInterval(90 * 60)
        )
        return state
    }
}
