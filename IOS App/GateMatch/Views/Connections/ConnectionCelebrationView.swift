import SwiftUI

/// Shown the moment a mutual connect happens.
/// Flat brand blue, no shadows or glows — the color carries the moment.
struct ConnectionCelebrationView: View {
    let currentUser: UserProfile
    let traveler: UserProfile
    /// Called with `true` if the user wants to jump to Connections.
    let onFinish: (_ openConnections: Bool) -> Void

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            HStack(spacing: -12) {
                avatarWithRing(currentUser)
                avatarWithRing(traveler)
            }

            VStack(spacing: 8) {
                Text("You're connected!")
                    .font(.largeTitle.bold())
                Text("You and \(traveler.firstName) both want to meet. Say hi before boarding.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .opacity(0.85)
            }

            Spacer()

            VStack(spacing: 12) {
                Button {
                    onFinish(true)
                } label: {
                    Text("Open Connections")
                        .font(.headline)
                        .foregroundStyle(Theme.brand)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.white, in: RoundedRectangle(cornerRadius: 14))
                }

                Button {
                    onFinish(false)
                } label: {
                    Text("Keep browsing")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
            }
        }
        .padding(28)
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.brand)
    }

    private func avatarWithRing(_ profile: UserProfile) -> some View {
        AvatarView(profile: profile, size: 88)
            .background(Circle().fill(.white).padding(-4))
    }
}

#Preview {
    ConnectionCelebrationView(
        currentUser: MockData.previewUser,
        traveler: MockData.travelers[0],
        onFinish: { _ in }
    )
}
