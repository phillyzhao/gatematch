import SwiftUI

/// Photo placeholder: a tinted circle with the traveler's initial.
struct AvatarView: View {
    let profile: UserProfile
    var size: CGFloat = 56

    var body: some View {
        ZStack {
            Circle()
                .fill(Theme.avatarColor(for: profile).opacity(0.18))
            Text(profile.initials)
                .font(.system(size: size * 0.42, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.avatarColor(for: profile))
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

#Preview {
    HStack(spacing: 12) {
        ForEach(MockData.travelers.prefix(4)) { traveler in
            AvatarView(profile: traveler)
        }
    }
    .padding()
}
