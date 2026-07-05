import Foundation

struct Airport: Identifiable, Codable, Equatable, Hashable {
    let code: String
    let name: String
    let city: String

    var id: String { code }

    static let ord = Airport(code: "ORD", name: "O'Hare International", city: "Chicago")
    static let jfk = Airport(code: "JFK", name: "John F. Kennedy International", city: "New York")
    static let lax = Airport(code: "LAX", name: "Los Angeles International", city: "Los Angeles")
    static let atl = Airport(code: "ATL", name: "Hartsfield-Jackson International", city: "Atlanta")

    static let all: [Airport] = [.ord, .jfk, .lax, .atl]

    static func named(_ code: String) -> Airport? {
        all.first { $0.code == code }
    }
}
