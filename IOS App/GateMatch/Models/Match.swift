import Foundation

struct Match: Identifiable, Codable, Equatable {
    let id: UUID
    /// The other traveler in the match (the current user is implicit).
    let travelerID: UUID
    let createdAt: Date

    init(id: UUID = UUID(), travelerID: UUID, createdAt: Date = .now) {
        self.id = id
        self.travelerID = travelerID
        self.createdAt = createdAt
    }
}
