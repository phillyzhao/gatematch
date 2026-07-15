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
            question: "How do I join an event?",
            answer: "Open an event from the Events tab and tap the plus button. Enter the registration code from your event confirmation email. For this demo, try MTS2026 for the Midwest Tech Summit.",
            keywords: ["join", "code", "register", "sign up", "passcode", "event"]
        ),
        FAQ(
            question: "What does Connect do?",
            answer: "Connect sends a request to meet another attendee. If they want to meet too, you're connected and can chat here in Messages. Skipping someone is never shown to them.",
            keywords: ["connect", "skip", "match", "meet", "request"]
        ),
        FAQ(
            question: "Who can see my gate?",
            answer: "Nobody — unless you turn on \"Show my exact gate\" in Account → Settings → Privacy. Other travelers only ever see your terminal, and your exact location is never shared.",
            keywords: ["gate", "privacy", "location", "see me", "terminal"]
        ),
        FAQ(
            question: "How do I check in at my airport?",
            answer: "After joining an event, open it from the Events tab and choose your airport, terminal, and gate. No GPS — you enter it yourself.",
            keywords: ["check in", "checkin", "airport", "flight"]
        ),
        FAQ(
            question: "How do I block or report someone?",
            answer: "Open their profile and tap the ••• menu in the top corner. Blocked travelers disappear from your feed and messages; you can unblock them in Account → Settings → Safety.",
            keywords: ["block", "report", "safety", "unblock", "harass"]
        ),
        FAQ(
            question: "What is the Friends Map?",
            answer: "A beta feature — the globe button at the bottom right opens a world map showing where your connections are checked in. Meet-up spots, ride splitting, and gate view are coming later.",
            keywords: ["map", "globe", "friends", "beta", "world"]
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
