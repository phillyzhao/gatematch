import Foundation

/// GateMate — the in-app helper. Not a person: it answers from a fixed
/// Q&A list, available to every user (including guests) in Messages.
enum HelperBot {
    static let name = "GateMate"
    static let botID = UUID(uuidString: "00000000-0000-0000-0000-000000000901")!
    /// Sender used for the user's side before they have a profile.
    static let guestUserID = UUID(uuidString: "00000000-0000-0000-0000-000000000902")!
    /// Thread identifier for the bot conversation.
    static let threadID = UUID(uuidString: "00000000-0000-0000-0000-000000000900")!

    struct FAQ: Identifiable {
        let question: String
        let answer: String
        let keywords: [String]

        var id: String { question }
    }

    static let faqs: [FAQ] = [
        FAQ(
            question: "How do I find people near me?",
            answer: "Open the Connect tab and type your city into the search bar. People you may know — friends of friends, mutuals, and contacts — pop up on the map. Tap the list button in the top right to see them as a list.",
            keywords: ["find", "people", "near", "location", "city", "search", "map"]
        ),
        FAQ(
            question: "What does the plus button do?",
            answer: "The plus sends a request to connect. If they want to connect too, you're matched and can chat here in Messages. Requests you send are never shown publicly.",
            keywords: ["plus", "add", "connect", "match", "meet", "request"]
        ),
        FAQ(
            question: "Why is it US-only?",
            answer: "This version of GateMatch is a US-only research build — search works for US cities and states. More countries are planned for a later release.",
            keywords: ["us", "usa", "country", "international", "abroad", "london", "only"]
        ),
        FAQ(
            question: "How do I block or report someone?",
            answer: "Open their chat and tap the ••• menu in the top corner. Blocked people disappear from your map and messages; you can unblock them in Account → Settings → Safety.",
            keywords: ["block", "report", "safety", "unblock", "harass"]
        ),
    ]

    static var greeting: ChatMessage {
        ChatMessage(
            connectionID: threadID,
            senderID: botID,
            text: "Hi, I'm \(name) — the GateMatch helper bot, not a real person. Tap a question below, or type one and I'll match it to my list."
        )
    }

    /// Fixed-list matching: exact question first, then keyword overlap,
    /// otherwise list what it can answer.
    static func reply(to text: String) -> String {
        let lowered = text.lowercased()
        if let exact = faqs.first(where: { $0.question.lowercased() == lowered }) {
            return exact.answer
        }
        var best: (faq: FAQ, score: Int)?
        for faq in faqs {
            let score = faq.keywords.filter { lowered.contains($0) }.count
            if score > (best?.score ?? 0) {
                best = (faq, score)
            }
        }
        if let best {
            return best.faq.answer
        }
        return "I'm a simple bot — here's what I can answer:\n\n"
            + faqs.map { "• \($0.question)" }.joined(separator: "\n")
    }
}
