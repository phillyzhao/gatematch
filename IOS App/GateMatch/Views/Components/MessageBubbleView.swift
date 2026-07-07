import SwiftUI

struct MessageBubble: View {
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
