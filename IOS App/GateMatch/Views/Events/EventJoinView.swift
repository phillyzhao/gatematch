import SwiftUI

/// Code-entry sheet: verifies the event's registration code before joining.
struct EventJoinView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    let event: Event

    @State private var code = ""
    @State private var errorMessage: String?
    @FocusState private var codeFocused: Bool

    private var canJoin: Bool {
        !code.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    summary
                    codeSection
                }
                .padding(24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Join event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) { joinButton }
        }
        .presentationDetents([.medium, .large])
        .onAppear { codeFocused = true }
    }

    private var summary: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(event.name)
                .font(.title3.bold())
            Text("\(event.organizer) · \(event.city)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Label("\(appState.attendeeCount(for: event)) travelers already here", systemImage: "person.2")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 2)
        }
    }

    private var codeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Event code")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
            TextField("From your registration email", text: $code)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .font(.body.monospaced())
                .focused($codeFocused)
                .submitLabel(.join)
                .onSubmit(join)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(errorMessage == nil ? .clear : Color.red, lineWidth: 1.5)
                )
            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            } else {
                Text("Attendees receive this code with their event registration.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var joinButton: some View {
        Button(action: join) {
            Text("Verify & join")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Theme.brand, in: RoundedRectangle(cornerRadius: 14))
        }
        .disabled(!canJoin)
        .opacity(canJoin ? 1 : 0.4)
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(.bar)
    }

    private func join() {
        let entered = code.trimmingCharacters(in: .whitespaces).uppercased()
        guard entered == event.code.uppercased() else {
            errorMessage = "That code doesn't match this event. Check your registration email and try again."
            return
        }
        appState.joinedEvent = event
        dismiss()
    }
}

#Preview {
    EventJoinView(event: MockData.events[0])
        .environment(AppState())
}
