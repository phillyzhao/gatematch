import CoreLocation
import Foundation

/// A mock person surfaced on the V2 Connect map — a friend, mutual,
/// or someone the user may know near the searched city.
struct NearbyPerson: Identifiable {
    let profile: UserProfile
    let relationship: String
    /// Degrees offset from the searched city center.
    let latitudeOffset: Double
    let longitudeOffset: Double

    var id: UUID { profile.id }

    func coordinate(around center: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        .init(latitude: center.latitude + latitudeOffset,
              longitude: center.longitude + longitudeOffset)
    }

    /// Rough distance from the city center, for the list view.
    var distanceMiles: Double {
        let miles = ((latitudeOffset * 69).magnitude.squared() + (longitudeOffset * 53).magnitude.squared()).squareRoot()
        return (miles * 10).rounded() / 10
    }
}

private extension Double {
    func squared() -> Double { self * self }
}

/// Fictional people pool for the V2 research build. Every search picks a
/// city-seeded subset so the same city always shows the same faces.
enum MockPeople {
    private static func uuid(_ n: Int) -> UUID {
        UUID(uuidString: String(format: "00000000-0000-0000-0000-%012d", 100 + n))!
    }

    /// All nearby-people profiles, for seeding AppState's people directory.
    static var profiles: [UserProfile] { pool.map(\.profile) }

    /// Nearby people who already asked to meet the current user (mock) —
    /// adding them creates an instant connection with a greeting message.
    static let instantConnectIDs: Set<UUID> = [
        uuid(1),  // Tessa
        uuid(4),  // Chris
        uuid(8),  // Diego
        uuid(11), // Monica
        uuid(12), // Ben
    ]

    private static let pool: [(profile: UserProfile, relationship: String)] = [
        (UserProfile(id: uuid(1), firstName: "Tessa", age: 27, travelPurpose: .leisure,
                     bio: "Weekend hiker, weekday designer.", showsExactGate: false),
         "3 mutual friends"),
        (UserProfile(id: uuid(2), firstName: "Jordan", age: 31, travelPurpose: .business,
                     bio: "Product manager who overpacks.", showsExactGate: false),
         "Friend of Maya"),
        (UserProfile(id: uuid(3), firstName: "Elena", age: 25, travelPurpose: .studying,
                     bio: "Med student, playlist maker.", showsExactGate: false),
         "In your contacts"),
        (UserProfile(id: uuid(4), firstName: "Chris", age: 35, travelPurpose: .business,
                     bio: "Startup founder, coffee snob.", showsExactGate: false),
         "5 mutual friends"),
        (UserProfile(id: uuid(5), firstName: "Nadia", age: 29, travelPurpose: .leisure,
                     bio: "Food-truck cartographer.", showsExactGate: false),
         "Went to your school"),
        (UserProfile(id: uuid(6), firstName: "Sam", age: 33, travelPurpose: .relocating,
                     bio: "New in town, knows nobody yet.", showsExactGate: false),
         "2 mutual friends"),
        (UserProfile(id: uuid(7), firstName: "Ava", age: 26, travelPurpose: .leisure,
                     bio: "Marathon-in-every-state project.", showsExactGate: false),
         "Friend of Noah"),
        (UserProfile(id: uuid(8), firstName: "Diego", age: 30, travelPurpose: .business,
                     bio: "Sales engineer, trivia champion.", showsExactGate: false),
         "4 mutual friends"),
        (UserProfile(id: uuid(9), firstName: "Ruth", age: 40, travelPurpose: .visitingFamily,
                     bio: "Auntie of the year, three years running.", showsExactGate: false),
         "In your contacts"),
        (UserProfile(id: uuid(10), firstName: "Kai", age: 24, travelPurpose: .studying,
                     bio: "Film school, always storyboarding.", showsExactGate: false),
         "1 mutual friend"),
        (UserProfile(id: uuid(11), firstName: "Monica", age: 32, travelPurpose: .business,
                     bio: "Recruiter who actually replies.", showsExactGate: false),
         "Friend of Sofia"),
        (UserProfile(id: uuid(12), firstName: "Ben", age: 28, travelPurpose: .leisure,
                     bio: "Board-game host, deep-dish loyalist.", showsExactGate: false),
         "6 mutual friends"),
        (UserProfile(id: uuid(13), firstName: "Layla", age: 34, travelPurpose: .relocating,
                     bio: "Serial city-hopper, plant rescuer.", showsExactGate: false),
         "Went to your school"),
        (UserProfile(id: uuid(14), firstName: "Owen", age: 37, travelPurpose: .business,
                     bio: "Consultant, airport-lounge critic.", showsExactGate: false),
         "2 mutual friends"),
    ]

    /// Varied distances from the city center so pins don't form a neat ring.
    private static let baseRadii: [Double] = [0.16, 0.11, 0.19, 0.13, 0.21, 0.15, 0.18, 0.10]

    /// Pins are placed by compass bearing. Inland cities use the full
    /// circle; waterfront cities fan across their land wedge only, so
    /// nobody floats in a lake or the ocean.
    static func people(near city: USCity) -> [NearbyPerson] {
        // String.hashValue is per-launch randomized; sum scalars for a stable seed.
        let seed = city.id.unicodeScalars.reduce(UInt64(0)) { $0 &* 31 &+ UInt64($1.value) }
        var generator = SplitMix64(seed: seed)
        let count = 6 + Int(generator.next() % 3)
        let picks = pool.shuffled(using: &generator).prefix(count)

        func jitter(_ span: Double) -> Double {
            (Double(generator.next() % 1000) / 1000 - 0.5) * span
        }

        return picks.enumerated().map { index, pick in
            let radius = (baseRadii[index % baseRadii.count] + jitter(0.024)) * city.pinScale
            let bearing: Double
            if let inland = city.inlandBearing {
                let fraction = count > 1 ? Double(index) / Double(count - 1) : 0.5
                bearing = inland - city.wedgeHalfAngle
                    + fraction * (2 * city.wedgeHalfAngle)
                    + jitter(12)
            } else {
                bearing = Double(index) / Double(count) * 360 + jitter(24)
            }
            let radians = bearing * .pi / 180
            return NearbyPerson(
                profile: pick.profile,
                relationship: pick.relationship,
                latitudeOffset: cos(radians) * radius,
                // Divide by cos(latitude) so the spread looks circular on screen.
                longitudeOffset: sin(radians) * radius / cos(city.latitude * .pi / 180)
            )
        }
    }
}

/// Tiny seedable generator so mock results are stable per city.
private struct SplitMix64: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) { state = seed }

    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}
