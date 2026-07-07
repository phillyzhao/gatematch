import Foundation

/// Local-only sample data for the v0.1 prototype. All people are fictional.
enum MockData {
    /// Stable IDs so likes, matches, and previews behave deterministically.
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

    /// Where each mock traveler is right now. Several share ORD Terminal 1
    /// (two at gate B12) so the feed and matching can be demonstrated.
    static let travelerCheckIns: [UUID: AirportCheckIn] = {
        let now = Date()
        let entries: [(Int, String, String, String, TimeInterval?)] = [
            (1, "ORD", "Terminal 1", "B12", 90 * 60),
            (2, "ORD", "Terminal 1", "B14", 120 * 60),
            (3, "ORD", "Terminal 1", "B12", 85 * 60),
            (4, "ORD", "Terminal 3", "K9", 200 * 60),
            (5, "ORD", "Terminal 2", "F2", nil),
            (6, "JFK", "Terminal 4", "B25", 150 * 60),
            (7, "JFK", "Terminal 4", "B22", nil),
            (8, "LAX", "Terminal 5", "51A", 60 * 60),
            (9, "LAX", "Terminal 4", "46B", nil),
            (10, "ATL", "Concourse A", "A12", 240 * 60),
        ]
        var result: [UUID: AirportCheckIn] = [:]
        for (n, airport, terminal, gate, offset) in entries {
            let travelerID = uuid(n)
            result[travelerID] = AirportCheckIn(
                userID: travelerID,
                airportCode: airport,
                terminal: terminal,
                gate: gate,
                flightTime: offset.map { now.addingTimeInterval($0) },
                checkedInAt: now.addingTimeInterval(-20 * 60)
            )
        }
        return result
    }()

    /// Mock travelers who already asked to meet the current user —
    /// connecting with them back creates an instant connection.
    static let incomingRequests: Set<UUID> = [uuid(1), uuid(3), uuid(6)]

    /// Official business events preloaded in the app. All fictional.
    static let events: [Event] = [
        Event(
            id: uuid(201),
            name: "Midwest Tech Summit 2026",
            organizer: "Great Lakes Tech Council",
            city: "Chicago",
            category: "Conference",
            startDate: Date().addingTimeInterval(2 * 86400),
            endDate: Date().addingTimeInterval(4 * 86400),
            code: "MTS2026",
            details: "Three days of talks, workshops, and hallway serendipity with founders, engineers, and operators from across the Midwest. Evening mixers every night, and a closing keynote on the future of regional tech."
        ),
        Event(
            id: uuid(202),
            name: "National Sales Leadership Conference",
            organizer: "Sales Leaders Association",
            city: "New York",
            category: "Conference",
            startDate: Date().addingTimeInterval(5 * 86400),
            endDate: Date().addingTimeInterval(7 * 86400),
            code: "SALES26",
            details: "The flagship gathering for revenue leaders: keynotes on pipeline craft, enablement deep-dives, and roundtables with CROs from the Fortune 500. Ends with the annual President's Club dinner."
        ),
        Event(
            id: uuid(203),
            name: "West Coast Founders Forum",
            organizer: "Pacific Venture Network",
            city: "Los Angeles",
            category: "Summit",
            startDate: Date().addingTimeInterval(3 * 86400),
            endDate: Date().addingTimeInterval(4 * 86400),
            code: "WCFF26",
            details: "An intimate two-day forum where early-stage founders trade playbooks with investors over long lunches and short pitches. Capped at 200 attendees to keep every conversation real."
        ),
        Event(
            id: uuid(204),
            name: "Atlanta Logistics Expo",
            organizer: "Southeast Freight Alliance",
            city: "Atlanta",
            category: "Trade show",
            startDate: Date().addingTimeInterval(6 * 86400),
            endDate: Date().addingTimeInterval(8 * 86400),
            code: "ALX2026",
            details: "Where freight, ports, and last-mile innovators meet. An expo floor with 200+ booths, curated supplier matchmaking, and a live demo yard for autonomous cargo handling."
        ),
    ]

    /// Which event each mock traveler is attending. Most attend the
    /// Midwest Tech Summit so the demo feed has plenty of people.
    static let travelerEventIDs: [UUID: UUID] = [
        uuid(1): uuid(201),  // Maya
        uuid(2): uuid(201),  // Derek
        uuid(3): uuid(201),  // Sofia
        uuid(5): uuid(201),  // Priya
        uuid(6): uuid(201),  // Noah
        uuid(9): uuid(201),  // Grace
        uuid(4): uuid(202),  // James
        uuid(8): uuid(202),  // Leo
        uuid(7): uuid(203),  // Amara
        uuid(10): uuid(204), // Marcus
    ]

    /// Opening line a mock traveler "sends" right after connecting.
    static func greeting(from traveler: UserProfile, connectionID: UUID) -> ChatMessage {
        let lines = [
            "Hey! Looks like we're both stuck here for a bit 👋",
            "Hi! How long until your flight boards?",
            "Hey — up for a coffee near the gate?",
            "Hi there! Where are you headed?",
        ]
        let index = traveler.id.uuidString.unicodeScalars.reduce(0) { $0 + Int($1.value) } % lines.count
        return ChatMessage(connectionID: connectionID, senderID: traveler.id, text: lines[index])
    }

    /// A sample "you" for SwiftUI previews.
    static let previewUser = UserProfile(
        id: uuid(100), firstName: "Alex", age: 30, travelPurpose: .business,
        bio: "Product designer who spends too much time in Terminal 1.",
        showsExactGate: false
    )
}
