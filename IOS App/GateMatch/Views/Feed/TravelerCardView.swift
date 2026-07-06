import SwiftUI

struct TravelerCardView: View {
    let traveler: UserProfile
    /// The traveler's check-in (used for the location line).
    let checkIn: AirportCheckIn?
    /// Informational closeness — attendees may be at a different airport entirely.
    let proximity: Proximity
    let onConnect: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            NavigationLink(value: traveler) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        AvatarView(profile: traveler)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("\(traveler.firstName), \(traveler.age)")
                                .font(.headline)
                            Label(traveler.travelPurpose.rawValue, systemImage: traveler.travelPurpose.symbolName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        proximityChip
                    }

                    Text(traveler.bio)
                        .font(.subheadline)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)

                    if let locationLine {
                        Label(locationLine, systemImage: "mappin.and.ellipse")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            HStack(spacing: 12) {
                Button(action: onSkip) {
                    Label("Skip", systemImage: "xmark")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(.tertiarySystemFill), in: Capsule())
                        .foregroundStyle(.primary)
                }
                .buttonStyle(.plain)

                Button(action: onConnect) {
                    Label("Connect", systemImage: "person.badge.plus")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Theme.brand, in: Capsule())
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    /// Airport and terminal are fine to show; the exact gate only if the traveler opted in.
    private var locationLine: String? {
        guard let checkIn else { return nil }
        var parts = [checkIn.airportCode, checkIn.terminal]
        if traveler.showsExactGate && !checkIn.gate.isEmpty {
            parts.append("Gate \(checkIn.gate)")
        }
        return parts.joined(separator: " · ")
    }

    @ViewBuilder
    private var proximityChip: some View {
        switch proximity {
        case .sameGate where traveler.showsExactGate:
            chip("At your gate", prominent: true)
        case .sameGate, .sameTerminal:
            chip("Same terminal", prominent: false)
        case .sameAirport:
            chip("At your airport", prominent: false)
        case .elsewhere:
            EmptyView()
        }
    }

    private func chip(_ text: String, prominent: Bool) -> some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(prominent ? Theme.brand : Color(.tertiarySystemFill), in: Capsule())
            .foregroundStyle(prominent ? .white : .secondary)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            TravelerCardView(
                traveler: MockData.travelers[0],
                checkIn: MockData.travelerCheckIns[MockData.travelers[0].id],
                proximity: .sameGate,
                onConnect: {},
                onSkip: {}
            )
            TravelerCardView(
                traveler: MockData.travelers[5],
                checkIn: MockData.travelerCheckIns[MockData.travelers[5].id],
                proximity: .elsewhere,
                onConnect: {},
                onSkip: {}
            )
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
