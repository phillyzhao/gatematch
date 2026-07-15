import SwiftUI

/// The app-wide "no search results" pattern:
/// imagery → acknowledgment → suggestions → a way out.
struct SearchEmptyStateView: View {
    let query: String
    let message: String
    let suggestions: [String]
    let onSuggestion: (String) -> Void
    let onClear: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            // Filler imagery for now — layered circles read as an illustration.
            ZStack {
                Circle()
                    .fill(Color(.tertiarySystemFill))
                    .frame(width: 104, height: 104)
                Circle()
                    .fill(Color(.secondarySystemGroupedBackground))
                    .frame(width: 76, height: 76)
                Image(systemName: "binoculars.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(Theme.brand)
            }
            .accessibilityHidden(true)

            VStack(spacing: 6) {
                Text("No results for “\(query)”")
                    .font(Theme.heading(17))
                    .multilineTextAlignment(.center)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            if !suggestions.isEmpty {
                VStack(spacing: 10) {
                    Text("Try one of these")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    HStack(spacing: 8) {
                        ForEach(suggestions, id: \.self) { suggestion in
                            Button {
                                onSuggestion(suggestion)
                            } label: {
                                Text(suggestion)
                                    .font(.caption.weight(.semibold))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Capsule().strokeBorder(Theme.brand, lineWidth: 1.5))
                                    .foregroundStyle(Theme.brand)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            Button(action: onClear) {
                Text("Clear search")
                    .font(Theme.heading(15))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 11)
                    .background(Theme.brand, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal, 16)
    }
}

#Preview {
    SearchEmptyStateView(
        query: "Tokyo",
        message: "No events match what you're looking for yet.",
        suggestions: ["Conference", "Summit", "Chicago"],
        onSuggestion: { _ in },
        onClear: {}
    )
    .background(Color(.systemGroupedBackground))
}
