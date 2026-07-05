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

    /// Mock travelers who have already liked the current user —
    /// liking them back creates an instant match.
    static let incomingLikes: Set<UUID> = [uuid(1), uuid(3), uuid(6)]

    /// A sample "you" for SwiftUI previews.
    static let previewUser = UserProfile(
        id: uuid(100), firstName: "Alex", age: 30, travelPurpose: .business,
        bio: "Product designer who spends too much time in Terminal 1.",
        showsExactGate: false
    )
}
