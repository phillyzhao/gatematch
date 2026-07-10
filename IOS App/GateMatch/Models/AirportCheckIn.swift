import Foundation

struct AirportCheckIn: Identifiable, Codable, Equatable {
    let id: UUID
    var userID: UUID
    var airportCode: String
    var terminal: String
    var gate: String
    var flightTime: Date?
    var checkedInAt: Date

    init(
        id: UUID = UUID(),
        userID: UUID,
        airportCode: String,
        terminal: String,
        gate: String,
        flightTime: Date? = nil,
        checkedInAt: Date = .now
    ) {
        self.id = id
        self.userID = userID
        self.airportCode = airportCode
        self.terminal = terminal
        self.gate = gate
        self.flightTime = flightTime
        self.checkedInAt = checkedInAt
    }
}
