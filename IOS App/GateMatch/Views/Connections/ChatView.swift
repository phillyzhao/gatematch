import SwiftUI

struct ChatView: View {
    @Environment(AppState.self) private var appState
    let connection: Connection

    @State private var draft = ""

    private var thread: [ChatMessage] {
        appState.messages[connection.id] ?? []
    }

    private var traveler: UserProfile? {
        appState.traveler(withID: connection.travelerID)
    }

    private var canSend: Bool {
        !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(thread) { message in
                        MessageBubble(
                            message: message,
                            isMine: message.senderID == appState.currentUser?.id
                        )
                        .id(message.id)
                    }
                }
                .padding(16)
            }
            .defaultScrollAnchor(.bottom)
            .onChange(of: thread.count) {
                if let last = thread.last {
                    withAnimation(.snappy) {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(traveler?.firstName ?? "Chat")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) { composer }
    }

    private var composer: some View {
        HStack(alignment: .bottom, spacing: 10) {
            TextField(
                "Message \(traveler?.firstName ?? "")…",
                text: $draft,
                axis: .vertical
            )
            .lineLimit(1...4)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18))

            Button(action: send) {
                Image(systemName: "arrow.up")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Theme.brand, in: Circle())
            }
            .disabled(!canSend)
            .opacity(canSend ? 1 : 0.4)
            .accessibilityLabel("Send message")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.bar)
    }

    private func send() {
        appState.send(draft, in: connection)
        draft = ""
    }
}

private struct MessageBubble: View {
    let message: ChatMessage
    let isMine: Bool

    var body: some View {
        HStack {
            if isMine { Spacer(minLength: 48) }
            Text(message.text)
                .font(.subheadline)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    isMine ? Theme.brand : Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 18)
                )
                .foregroundStyle(isMine ? Color.white : Color.primary)
            if !isMine { Spacer(minLength: 48) }
        }
        .frame(maxWidth: .infinity, alignment: isMine ? .trailing : .leading)
    }
}

#Preview {
    NavigationStack {
        if let connection = AppState.preview.connections.first {
            ChatView(connection: connection)
        }
    }
    .environment(AppState.preview)
}
