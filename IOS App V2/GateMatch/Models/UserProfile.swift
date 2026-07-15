import Foundation

enum TravelPurpose: String, Codable, CaseIterable, Identifiable {
    case business = "Business"
    case leisure = "Leisure"
    case visitingFamily = "Visiting family"
    case studying = "Studying"
    case relocating = "Relocating"

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .business: "briefcase.fill"
        case .leisure: "sun.max.fill"
        case .visitingFamily: "house.fill"
        case .studying: "book.fill"
        case .relocating: "shippingbox.fill"
        }
    }
}

struct UserProfile: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var firstName: String
    var age: Int
    var travelPurpose: TravelPurpose
    var bio: String
    /// Privacy: gate is only shown to others when the traveler opts in.
    var showsExactGate: Bool
    /// Contact email — stored locally in the prototype.
    var email: String = ""

    var initials: String {
        String(firstName.prefix(1)).uppercased()
    }
}
