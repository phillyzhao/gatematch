import SwiftUI
import TipKit

/// Contextual help for the spots a first-time user is most likely
/// to find confusing. Each tip shows once, then stays dismissed.

/// The connections-count badge on event cards is a bare number in a circle.
struct EventBadgeTip: Tip {
    var title: Text {
        Text("Your people, at a glance")
    }
    var message: Text? {
        Text("The blue circle on each event shows how many of your connections are going.")
    }
    var image: Image? {
        Image(systemName: "person.2.fill")
    }
}

/// Users may expect to message anyone directly — connecting is mutual.
struct ConnectTip: Tip {
    var title: Text {
        Text("Connecting is mutual")
    }
    var message: Text? {
        Text("Tap Connect to ask to meet someone. You'll only chat if they want to meet too — skipping is never shown to them.")
    }
    var image: Image? {
        Image(systemName: "person.badge.plus")
    }
}

/// A globe icon with a BETA tag doesn't explain itself.
struct MapTip: Tip {
    var title: Text {
        Text("Friends map (beta)")
    }
    var message: Text? {
        Text("See where your connections are checked in around the world.")
    }
    var image: Image? {
        Image(systemName: "globe.americas.fill")
    }
}
