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

    static let all: [Airport] = [
        ord,
        Airport(code: "MDW", name: "Chicago Midway International", city: "Chicago"),
        jfk,
        Airport(code: "LGA", name: "LaGuardia", city: "New York"),
        Airport(code: "EWR", name: "Newark Liberty International", city: "Newark"),
        lax,
        Airport(code: "BUR", name: "Hollywood Burbank", city: "Burbank"),
        Airport(code: "SNA", name: "John Wayne", city: "Orange County"),
        atl,
        Airport(code: "DFW", name: "Dallas/Fort Worth International", city: "Dallas"),
        Airport(code: "DEN", name: "Denver International", city: "Denver"),
        Airport(code: "SFO", name: "San Francisco International", city: "San Francisco"),
        Airport(code: "SEA", name: "Seattle–Tacoma International", city: "Seattle"),
        Airport(code: "MIA", name: "Miami International", city: "Miami"),
        Airport(code: "BOS", name: "Boston Logan International", city: "Boston"),
        Airport(code: "PHX", name: "Phoenix Sky Harbor International", city: "Phoenix"),
    ]

    static func named(_ code: String) -> Airport? {
        all.first { $0.code == code }
    }
}
