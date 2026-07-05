import Foundation

struct ChatMessage: Identifiable, Codable, Equatable {
    let id: UUID
    let matchID: UUID
    let senderID: UUID
    var text: String
    var sentAt: Date

    init(id: UUID = UUID(), matchID: UUID, senderID: UUID, text: String, sentAt: Date = .now) {
        self.id = id
        self.matchID = matchID
        self.senderID = senderID
        self.text = text
        self.sentAt = sentAt
    }
}
