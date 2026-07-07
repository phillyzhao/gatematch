import MapKit
import SwiftUI

/// Beta: a world map showing where your connections are checked in.
/// Later: pick meet-up spots, split rides, see friends' gates.
struct FriendsMapView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    private static let airportCoordinates: [String: CLLocationCoordinate2D] = [
        "ORD": .init(latitude: 41.9742, longitude: -87.9073),
        "JFK": .init(latitude: 40.6413, longitude: -73.7781),
        "LAX": .init(latitude: 33.9416, longitude: -118.4085),
        "ATL": .init(latitude: 33.6407, longitude: -84.4277),
    ]

    private struct FriendPin: Identifiable {
        let id: UUID
        let profile: UserProfile
        let airportCode: String
        let coordinate: CLLocationCoordinate2D
    }

    private var pins: [FriendPin] {
        appState.connections.compactMap { connection in
            guard let profile = appState.traveler(withID: connection.travelerID),
                  !appState.blockedIDs.contains(profile.id),
                  let checkIn = appState.travelerCheckIns[profile.id],
                  let coordinate = Self.airportCoordinates[checkIn.airportCode]
            else { return nil }
            return FriendPin(
                id: profile.id,
                profile: profile,
                airportCode: checkIn.airportCode,
                coordinate: coordinate
            )
        }
    }

    var body: some View {
        ZStack {
            Map {
                ForEach(pins) { pin in
                    Annotation("\(pin.profile.firstName) · \(pin.airportCode)", coordinate: pin.coordinate) {
                        AvatarView(profile: pin.profile, size: 36)
                            .background(Circle().fill(.white).padding(-3))
                    }
                }
            }
            .mapStyle(.standard(elevation: .flat))
            .ignoresSafeArea()
        }
        .overlay(alignment: .top) { header }
        .overlay(alignment: .bottom) { footer }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Text("Friends Map")
                .font(.headline)
            Text("BETA")
                .font(.caption2.weight(.bold))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Theme.brand, in: Capsule())
                .foregroundStyle(.white)
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(.ultraThinMaterial))
            }
            .accessibilityLabel("Close map")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.primary.opacity(0.08)))
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: 6) {
            if pins.isEmpty {
                Text("No connections on the map yet")
                    .font(.subheadline.weight(.semibold))
                Text("Connect with travelers at your event and they'll appear here at their airport.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("\(pins.count) connection\(pins.count == 1 ? "" : "s") traveling now")
                    .font(.subheadline.weight(.semibold))
            }
            Text("Coming soon: pick meet-up spots, split rides, and see friends' gates.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.primary.opacity(0.08)))
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

#Preview("With connections") {
    FriendsMapView()
        .environment(AppState.preview)
}

#Preview("Empty") {
    FriendsMapView()
        .environment(AppState())
}
