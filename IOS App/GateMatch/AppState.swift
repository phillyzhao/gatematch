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
    /// Set when a mutual like just happened; drives the "It's a match" sheet.
    var pendingMatchCelebration: Match?

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

    // MARK: Feed

    /// Travelers checked into the same airport whom the user hasn't acted on.
    /// Closest first: same gate, then same terminal, then the rest of the airport.
    var nearbyTravelers: [UserProfile] {
        guard checkIn != nil else { return [] }
        return travelers
            .filter { traveler in
                traveler.id != currentUser?.id
                    && !likedIDs.contains(traveler.id)
                    && !passedIDs.contains(traveler.id)
                    && !blockedIDs.contains(traveler.id)
                    && travelerCheckIns[traveler.id]?.airportCode == checkIn?.airportCode
            }
            .sorted {
                (proximityRank(of: $0), $0.firstName) < (proximityRank(of: $1), $1.firstName)
            }
    }

    /// 0 = same gate, 1 = same terminal, 2 = same airport.
    func proximityRank(of traveler: UserProfile) -> Int {
        guard let checkIn, let theirs = travelerCheckIns[traveler.id] else { return 2 }
        if theirs.terminal == checkIn.terminal {
            if !checkIn.gate.isEmpty && theirs.gate == checkIn.gate { return 0 }
            return 1
        }
        return 2
    }

    /// Records a like. If the traveler already liked the user (mock), it's a match.
    @discardableResult
    func like(_ traveler: UserProfile) -> Match? {
        likedIDs.insert(traveler.id)
        guard incomingLikes.contains(traveler.id) else { return nil }
        let match = Match(travelerID: traveler.id)
        matches.append(match)
        pendingMatchCelebration = match
        return match
    }

    func pass(_ traveler: UserProfile) {
        passedIDs.insert(traveler.id)
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
