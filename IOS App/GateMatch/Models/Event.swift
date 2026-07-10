import Foundation

/// An official business event (conference, summit, expo) that gates access.
/// Users must join one with its registration code before entering travel info.
struct Event: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let name: String
    let organizer: String
    let city: String
    let category: String
    let startDate: Date
    let endDate: Date
    /// Shared join code from the attendee's registration.
    let code: String
    /// Short description shown on the event's detail page.
    let details: String
    /// Airports most attendees fly through — suggested first at check-in.
    let primaryAirportCodes: [String]
}
