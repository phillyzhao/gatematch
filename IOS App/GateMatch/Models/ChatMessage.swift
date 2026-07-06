import Foundation

struct ChatMessage: Identifiable, Codable, Equatable {
    let id: UUID
    let connectionID: UUID
    let senderID: UUID
    var text: String
    var sentAt: Date

    init(id: UUID = UUID(), connectionID: UUID, senderID: UUID, text: String, sentAt: Date = .now) {
        self.id = id
        self.connectionID = connectionID
        self.senderID = senderID
        self.text = text
        self.sentAt = sentAt
    }
}
