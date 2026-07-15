import Foundation

/// Local-only sample data for the V2 prototype. All people are fictional.
enum MockData {
    /// Stable IDs so requests, connections, and previews behave deterministically.
    private static func uuid(_ n: Int) -> UUID {
        UUID(uuidString: String(format: "00000000-0000-0000-0000-%012d", n))!
    }

    static let travelers: [UserProfile] = [
        UserProfile(
            id: uuid(1), firstName: "Maya", age: 29, travelPurpose: .business,
            bio: "Management consultant bouncing between Chicago and NYC. Will trade coffee for good podcast recs.",
            showsExactGate: true
        ),
        UserProfile(
            id: uuid(2), firstName: "Derek", age: 34, travelPurpose: .business,
            bio: "Sales, 100k miles a year. Ask me about lounge hacks.",
            showsExactGate: false
        ),
        UserProfile(
            id: uuid(3), firstName: "Sofia", age: 26, travelPurpose: .leisure,
            bio: "Off to chase fall colors in Vermont. Amateur photographer, professional snack critic.",
            showsExactGate: true
        ),
        UserProfile(
            id: uuid(4), firstName: "James", age: 41, travelPurpose: .business,
            bio: "Architect heading home to Denver. Always up for airport ramen.",
            showsExactGate: false
        ),
        UserProfile(
            id: uuid(5), firstName: "Priya", age: 31, travelPurpose: .studying,
            bio: "Grad student flying to a robotics conference. Happy to swap thesis horror stories.",
            showsExactGate: false
        ),
        UserProfile(
            id: uuid(6), firstName: "Noah", age: 27, travelPurpose: .leisure,
            bio: "Backpacking through Portugal next month. Tell me where to eat in Lisbon.",
            showsExactGate: true
        ),
        UserProfile(
            id: uuid(7), firstName: "Amara", age: 30, travelPurpose: .visitingFamily,
            bio: "Flying home to meet my sister's new baby. Knitting a very lopsided blanket en route.",
            showsExactGate: false
        ),
        UserProfile(
            id: uuid(8), firstName: "Leo", age: 38, travelPurpose: .business,
            bio: "Film production. Red-eye regular, espresso enthusiast.",
            showsExactGate: false
        ),
        UserProfile(
            id: uuid(9), firstName: "Grace", age: 24, travelPurpose: .leisure,
            bio: "Chasing surf breaks up the coast. Current airport snack ranking: pretzels #1.",
            showsExactGate: true
        ),
        UserProfile(
            id: uuid(10), firstName: "Marcus", age: 45, travelPurpose: .relocating,
            bio: "Moving to Austin for a fresh start. Everything I own is in two suitcases.",
            showsExactGate: false
        ),
    ]

    /// Legacy mock travelers who already asked to meet the current user.
    static let incomingRequests: Set<UUID> = [uuid(1), uuid(3), uuid(6)]

    /// Opening line a mock person "sends" right after connecting.
    static func greeting(from person: UserProfile, connectionID: UUID) -> ChatMessage {
        let lines = [
            "Hey! Small world — looks like we know some of the same people 👋",
            "Hi! Just saw we're both around here. How's your week going?",
            "Hey — coffee sometime this week?",
            "Hi there! How do we not already know each other?",
        ]
        let index = person.id.uuidString.unicodeScalars.reduce(0) { $0 + Int($1.value) } % lines.count
        return ChatMessage(connectionID: connectionID, senderID: person.id, text: lines[index])
    }

    /// A sample "you" for SwiftUI previews.
    static let previewUser = UserProfile(
        id: uuid(100), firstName: "Alex", age: 30, travelPurpose: .business,
        bio: "Product designer who spends too much time in Terminal 1.",
        showsExactGate: false
    )
}
