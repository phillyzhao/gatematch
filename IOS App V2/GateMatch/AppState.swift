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
    /// Travelers who already asked to meet the current user (mock).
    let incomingRequests: Set<UUID>

    // MARK: Interactions
    var requestedIDs: Set<UUID> = []
    var skippedIDs: Set<UUID> = []
    var connections: [Connection] = []
    /// Chat threads keyed by connection ID.
    var messages: [UUID: [ChatMessage]] = [:]
    var blockedIDs: Set<UUID> = []
    /// Set when a mutual connect just happened; drives the "You're connected" sheet.
    var pendingCelebration: Connection?
    /// The helper-bot thread, available to every user (guests included).
    var botMessages: [ChatMessage] = [HelperBot.greeting]

    var hasOnboarded: Bool { currentUser != nil }
    var hasJoinedEvent: Bool { joinedEvent != nil }
    var isCheckedIn: Bool { checkIn != nil }

    init(
        travelers: [UserProfile] = MockData.travelers,
        travelerCheckIns: [UUID: AirportCheckIn] = MockData.travelerCheckIns,
        events: [Event] = MockData.events,
        travelerEventIDs: [UUID: UUID] = MockData.travelerEventIDs,
        incomingRequests: Set<UUID> = MockData.incomingRequests
    ) {
        self.travelers = travelers
        self.travelerCheckIns = travelerCheckIns
        self.events = events
        self.travelerEventIDs = travelerEventIDs
        self.incomingRequests = incomingRequests
    }

    func traveler(withID id: UUID) -> UserProfile? {
        travelers.first { $0.id == id }
    }

    // MARK: Events

    func attendeeCount(for event: Event) -> Int {
        travelerEventIDs.values.filter { $0 == event.id }.count
    }

    /// How many of the user's connections are attending the given event.
    func connectionsAttending(_ event: Event) -> Int {
        connections
            .filter {
                travelerEventIDs[$0.travelerID] == event.id
                    && !blockedIDs.contains($0.travelerID)
            }
            .count
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
                    && !requestedIDs.contains(traveler.id)
                    && !skippedIDs.contains(traveler.id)
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

    /// Asks to meet a traveler. If they already asked too (mock), you're connected.
    @discardableResult
    func connect(with traveler: UserProfile) -> Connection? {
        requestedIDs.insert(traveler.id)
        guard incomingRequests.contains(traveler.id) else { return nil }
        let connection = Connection(travelerID: traveler.id)
        connections.append(connection)
        messages[connection.id] = [MockData.greeting(from: traveler, connectionID: connection.id)]
        pendingCelebration = connection
        return connection
    }

    func skip(_ traveler: UserProfile) {
        skippedIDs.insert(traveler.id)
    }

    // MARK: Chat

    func send(_ text: String, in connection: Connection) {
        guard let currentUser else { return }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        messages[connection.id, default: []].append(
            ChatMessage(connectionID: connection.id, senderID: currentUser.id, text: trimmed)
        )
    }

    /// Sends a message to the helper bot; it replies from its fixed Q&A list.
    func sendToBot(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let senderID = currentUser?.id ?? HelperBot.guestUserID
        botMessages.append(
            ChatMessage(connectionID: HelperBot.threadID, senderID: senderID, text: trimmed)
        )
        let reply = HelperBot.reply(to: trimmed)
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(600))
            botMessages.append(
                ChatMessage(connectionID: HelperBot.threadID, senderID: HelperBot.botID, text: reply)
            )
        }
    }

    /// Fully set-up state for SwiftUI previews: onboarded, event joined, checked in at ORD.
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
        // One existing connection with a greeting so Connections/Chat previews have content.
        if let maya = state.travelers.first {
            state.connect(with: maya)
            state.pendingCelebration = nil
        }
        return state
    }
}
