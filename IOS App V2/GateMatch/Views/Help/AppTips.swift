import SwiftUI
import TipKit

/// Contextual help for the spots a first-time user is most likely
/// to find confusing. Each tip shows once, then stays dismissed.

/// A map icon with a BETA tag doesn't explain itself.
struct MapTip: Tip {
    var title: Text {
        Text("Friends map (beta)")
    }
    var message: Text? {
        Text("See your connections pinned to the cities where you met them.")
    }
    var image: Image? {
        Image(systemName: "map.fill")
    }
}
