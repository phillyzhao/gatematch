import MapKit
import SwiftUI

/// Beta: a map showing where your connections are, pinned to the city
/// where you met them. Later: meet-up spots, plans, shared maps.
struct FriendsMapView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    private struct FriendPin: Identifiable {
        let id: UUID
        let profile: UserProfile
        let place: ConnectionPlace

        var coordinate: CLLocationCoordinate2D {
            .init(latitude: place.latitude, longitude: place.longitude)
        }
    }

    private var pins: [FriendPin] {
        appState.connections.compactMap { connection in
            guard let profile = appState.traveler(withID: connection.travelerID),
                  !appState.blockedIDs.contains(profile.id),
                  let place = appState.connectionPlaces[profile.id]
            else { return nil }
            return FriendPin(id: profile.id, profile: profile, place: place)
        }
    }

    var body: some View {
        ZStack {
            Map {
                ForEach(pins) { pin in
                    Annotation("\(pin.profile.firstName) · \(pin.place.cityLabel)", coordinate: pin.coordinate) {
                        AvatarView(profile: pin.profile, size: 36)
                            .background(Circle().fill(Color(.systemBackground)).padding(-3))
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
                .font(Theme.heading(17))
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
                Text("Add people from the Connect tab — once you're connected, they'll appear here in their city.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("\(pins.count) connection\(pins.count == 1 ? "" : "s") on the map")
                    .font(.subheadline.weight(.semibold))
            }
            Text("Coming soon: meet-up spots, plans, and shared maps with friends.")
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
