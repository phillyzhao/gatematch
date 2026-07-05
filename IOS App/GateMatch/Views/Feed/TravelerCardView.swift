import SwiftUI

struct TravelerCardView: View {
    let traveler: UserProfile
    /// The traveler's check-in (used for the location line).
    let checkIn: AirportCheckIn?
    let sameTerminal: Bool
    /// Only true when the traveler has chosen to share their exact gate.
    let sameGate: Bool
    let onLike: () -> Void
    let onPass: () -> Void

    var body: some View {
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

            if let locationLine {
                Label(locationLine, systemImage: "mappin.and.ellipse")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                Button(action: onPass) {
                    Label("Pass", systemImage: "xmark")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(.tertiarySystemFill), in: Capsule())
                        .foregroundStyle(.primary)
                }
                .buttonStyle(.plain)

                Button(action: onLike) {
                    Label("Like", systemImage: "heart.fill")
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

    /// Terminal is always fine to show; the exact gate only if the traveler opted in.
    private var locationLine: String? {
        guard let checkIn else { return nil }
        if traveler.showsExactGate && !checkIn.gate.isEmpty {
            return "\(checkIn.terminal) · Gate \(checkIn.gate)"
        }
        return checkIn.terminal
    }

    @ViewBuilder
    private var proximityChip: some View {
        if sameGate && traveler.showsExactGate {
            chip("At your gate", prominent: true)
        } else if sameTerminal {
            chip("Same terminal", prominent: false)
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
                sameTerminal: true,
                sameGate: true,
                onLike: {},
                onPass: {}
            )
            TravelerCardView(
                traveler: MockData.travelers[1],
                checkIn: MockData.travelerCheckIns[MockData.travelers[1].id],
                sameTerminal: true,
                sameGate: false,
                onLike: {},
                onPass: {}
            )
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
