import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var appState

    @State private var firstName = ""
    @State private var age = 28
    @State private var purpose: TravelPurpose = .leisure
    @State private var bio = ""

    private var trimmedName: String {
        firstName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                header
                photoPlaceholder
                fields
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color(.systemGroupedBackground))
        .safeAreaInset(edge: .bottom) { continueButton }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.2.wave.2.fill")
                .font(.system(size: 40))
                .foregroundStyle(Theme.brand)
            Text("Create your profile")
                .font(Theme.display(26))
            Text("You need a profile before you can connect with people near you.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var photoPlaceholder: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color(.secondarySystemGroupedBackground))
                Circle()
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [6]))
                    .foregroundStyle(.tertiary)
                Image(systemName: "camera.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 96, height: 96)
            Text("Photo coming in a later version")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Profile photo placeholder")
    }

    private var fields: some View {
        VStack(spacing: 16) {
            labeledField("First name") {
                TextField("e.g. Jordan", text: $firstName)
                    .textContentType(.givenName)
                    .autocorrectionDisabled()
            }

            labeledField("Age") {
                Picker("Age", selection: $age) {
                    ForEach(18...99, id: \.self) { value in
                        Text("\(value)").tag(value)
                    }
                }
                .pickerStyle(.menu)
                .tint(Theme.brand)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            labeledField("Why are you traveling?") {
                Picker("Travel purpose", selection: $purpose) {
                    ForEach(TravelPurpose.allCases) { purpose in
                        Label(purpose.rawValue, systemImage: purpose.symbolName)
                            .tag(purpose)
                    }
                }
                .pickerStyle(.menu)
                .tint(Theme.brand)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            labeledField("Short bio") {
                TextField("A sentence about you…", text: $bio, axis: .vertical)
                    .lineLimit(2...4)
            }
        }
    }

    private func labeledField(_ label: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(Theme.heading(13))
                .foregroundStyle(.secondary)
            content()
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var continueButton: some View {
        Button(action: completeOnboarding) {
            Text("Continue")
                .font(Theme.heading(17))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Theme.brand, in: RoundedRectangle(cornerRadius: 14))
        }
        .disabled(trimmedName.isEmpty)
        .opacity(trimmedName.isEmpty ? 0.4 : 1)
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(.bar)
    }

    private func completeOnboarding() {
        appState.currentUser = UserProfile(
            id: UUID(),
            firstName: trimmedName,
            age: age,
            travelPurpose: purpose,
            bio: bio.trimmingCharacters(in: .whitespacesAndNewlines),
            showsExactGate: false
        )
    }
}

#Preview {
    OnboardingView()
        .environment(AppState())
}
