import Foundation

/// A mutual "want to meet" between the current user and another attendee.
struct Connection: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    /// The other traveler in the connection (the current user is implicit).
    let travelerID: UUID
    let createdAt: Date

    init(id: UUID = UUID(), travelerID: UUID, createdAt: Date = .now) {
        self.id = id
        self.travelerID = travelerID
        self.createdAt = createdAt
    }
}
