import Foundation
import Observation

/// Where a connection was made — the city pin they appear at on the map.
struct ConnectionPlace: Equatable {
    let cityLabel: String
    let latitude: Double
    let longitude: Double
}

/// Single source of truth for the local-only prototype.
/// No networking — everything lives in memory, seeded from MockData.
/// V2: discovery is location-based (Connect map), not event-based.
@Observable
@MainActor
final class AppState {
    // MARK: Current user
    var currentUser: UserProfile?

    // MARK: Mock world
    /// Everyone the app knows about: legacy mock travelers (existing chats,
    /// previews) plus the Connect-map nearby people.
    let travelers: [UserProfile]
    /// People who already asked to meet the current user (mock) —
    /// adding them back creates an instant connection.
    let incomingRequests: Set<UUID>

    // MARK: Interactions
    var requestedIDs: Set<UUID> = []
    var connections: [Connection] = []
    /// Where each connection was made, for the friends map.
    var connectionPlaces: [UUID: ConnectionPlace] = [:]
    /// Chat threads keyed by connection ID.
    var messages: [UUID: [ChatMessage]] = [:]
    var blockedIDs: Set<UUID> = []
    /// Set when a mutual connect just happened; drives the "You're connected" sheet.
    var pendingCelebration: Connection?
    /// The helper-bot thread, available to every user (guests included).
    var botMessages: [ChatMessage] = [HelperBot.greeting]

    var hasOnboarded: Bool { currentUser != nil }

    init(
        travelers: [UserProfile] = MockData.travelers + MockPeople.profiles,
        incomingRequests: Set<UUID> = MockData.incomingRequests.union(MockPeople.instantConnectIDs)
    ) {
        self.travelers = travelers
        self.incomingRequests = incomingRequests
    }

    func traveler(withID id: UUID) -> UserProfile? {
        travelers.first { $0.id == id }
    }

    // MARK: Connecting

    /// Asks to meet someone. If they already asked too (mock), you're connected.
    @discardableResult
    func connect(with person: UserProfile, place: ConnectionPlace? = nil) -> Connection? {
        requestedIDs.insert(person.id)
        if let place { connectionPlaces[person.id] = place }
        guard incomingRequests.contains(person.id) else { return nil }
        let connection = Connection(travelerID: person.id)
        connections.append(connection)
        messages[connection.id] = [MockData.greeting(from: person, connectionID: connection.id)]
        pendingCelebration = connection
        return connection
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

    /// Fully set-up state for SwiftUI previews: onboarded, one connection
    /// made from the Connect map in Chicago.
    static var preview: AppState {
        let state = AppState()
        state.currentUser = MockData.previewUser
        if let tessa = MockPeople.profiles.first {
            state.connect(
                with: tessa,
                place: ConnectionPlace(cityLabel: "Chicago, IL", latitude: 41.9, longitude: -87.65)
            )
            state.pendingCelebration = nil
        }
        return state
    }
}
