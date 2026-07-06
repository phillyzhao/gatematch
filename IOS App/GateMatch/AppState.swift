import Foundation
import Observation

enum Proximity: Int, Comparable {
    case sameGate = 0
    case sameTerminal
    case sameAirport
    case elsewhere

    static func < (lhs: Proximity, rhs: Proximity) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

/// Single source of truth for the local-only prototype.
/// No networking — everything lives in memory, seeded from MockData.
@Observable
@MainActor
final class AppState {
    // MARK: Current user
    var currentUser: UserProfile?
    /// The official event the user has joined with its code. Gates travel info.
    var joinedEvent: Event?
    var checkIn: AirportCheckIn?

    // MARK: Mock world
    let travelers: [UserProfile]
    let travelerCheckIns: [UUID: AirportCheckIn]
    let events: [Event]
    /// Which event each mock traveler is attending.
    let travelerEventIDs: [UUID: UUID]
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
    var hasJoinedEvent: Bool { joinedEvent != nil }
    var isCheckedIn: Bool { checkIn != nil }

    init(
        travelers: [UserProfile] = MockData.travelers,
        travelerCheckIns: [UUID: AirportCheckIn] = MockData.travelerCheckIns,
        events: [Event] = MockData.events,
        travelerEventIDs: [UUID: UUID] = MockData.travelerEventIDs,
        incomingLikes: Set<UUID> = MockData.incomingLikes
    ) {
        self.travelers = travelers
        self.travelerCheckIns = travelerCheckIns
        self.events = events
        self.travelerEventIDs = travelerEventIDs
        self.incomingLikes = incomingLikes
    }

    func traveler(withID id: UUID) -> UserProfile? {
        travelers.first { $0.id == id }
    }

    // MARK: Events

    func attendeeCount(for event: Event) -> Int {
        travelerEventIDs.values.filter { $0 == event.id }.count
    }

    /// Leaving an event also clears travel info — it was scoped to that trip.
    func leaveEvent() {
        joinedEvent = nil
        checkIn = nil
    }

    // MARK: Feed

    /// Attendees of the joined event whom the user hasn't acted on.
    /// The event is the filter; airport proximity only affects sort order.
    var eventTravelers: [UserProfile] {
        guard let joinedEvent else { return [] }
        return travelers
            .filter { traveler in
                traveler.id != currentUser?.id
                    && travelerEventIDs[traveler.id] == joinedEvent.id
                    && !likedIDs.contains(traveler.id)
                    && !passedIDs.contains(traveler.id)
                    && !blockedIDs.contains(traveler.id)
            }
            .sorted {
                (proximity(of: $0).rawValue, $0.firstName) < (proximity(of: $1).rawValue, $1.firstName)
            }
    }

    /// How close another traveler is right now — informational only, never a filter.
    func proximity(of traveler: UserProfile) -> Proximity {
        guard let checkIn,
              let theirs = travelerCheckIns[traveler.id],
              theirs.airportCode == checkIn.airportCode
        else { return .elsewhere }
        if theirs.terminal == checkIn.terminal {
            if !checkIn.gate.isEmpty && theirs.gate == checkIn.gate { return .sameGate }
            return .sameTerminal
        }
        return .sameAirport
    }

    /// Records a like. If the traveler already liked the user (mock), it's a match.
    @discardableResult
    func like(_ traveler: UserProfile) -> Match? {
        likedIDs.insert(traveler.id)
        guard incomingLikes.contains(traveler.id) else { return nil }
        let match = Match(travelerID: traveler.id)
        matches.append(match)
        messages[match.id] = [MockData.greeting(from: traveler, matchID: match.id)]
        pendingMatchCelebration = match
        return match
    }

    // MARK: Chat

    func send(_ text: String, in match: Match) {
        guard let currentUser else { return }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        messages[match.id, default: []].append(
            ChatMessage(matchID: match.id, senderID: currentUser.id, text: trimmed)
        )
    }

    func pass(_ traveler: UserProfile) {
        passedIDs.insert(traveler.id)
    }

    /// Fully set-up state for SwiftUI previews: onboarded and checked in at ORD.
    static var preview: AppState {
        let state = AppState()
        state.currentUser = MockData.previewUser
        state.joinedEvent = MockData.events.first
        state.checkIn = AirportCheckIn(
            userID: MockData.previewUser.id,
            airportCode: "ORD",
            terminal: "Terminal 1",
            gate: "B12",
            flightTime: .now.addingTimeInterval(90 * 60)
        )
        // One existing match with a greeting so Matches/Chat previews have content.
        if let maya = state.travelers.first {
            state.like(maya)
            state.pendingMatchCelebration = nil
        }
        return state
    }
}
