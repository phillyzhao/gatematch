import SwiftUI

/// Route marker for the helper-bot conversation.
struct BotRoute: Hashable {}

/// Chat with GateMate, the fixed-Q&A helper bot.
struct BotChatView: View {
    @Environment(AppState.self) private var appState

    @State private var draft = ""

    private var canSend: Bool {
        !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(appState.botMessages) { message in
                        MessageBubble(
                            message: message,
                            isMine: message.senderID != HelperBot.botID
                        )
                        .id(message.id)
                    }
                }
                .padding(16)
            }
            .defaultScrollAnchor(.bottom)
            .onChange(of: appState.botMessages.count) {
                if let last = appState.botMessages.last {
                    withAnimation(.snappy) {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("\(HelperBot.name) · Bot")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) { composer }
    }

    private var composer: some View {
        VStack(spacing: 10) {
            // The bot's whole menu, one tap away.
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(HelperBot.faqs) { faq in
                        Button {
                            appState.sendToBot(faq.question)
                        } label: {
                            Text(faq.question)
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Capsule().strokeBorder(Theme.brand, lineWidth: 1.5))
                                .foregroundStyle(Theme.brand)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }

            HStack(alignment: .bottom, spacing: 10) {
                TextField("Ask \(HelperBot.name)…", text: $draft, axis: .vertical)
                    .lineLimit(1...3)
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
        }
        .padding(.vertical, 10)
        .background(.bar)
    }

    private func send() {
        appState.sendToBot(draft)
        draft = ""
    }
}

#Preview {
    NavigationStack {
        BotChatView()
    }
    .environment(AppState())
}
