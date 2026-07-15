import SwiftUI

/// Important account and security alerts only — regular chat messages
/// live in the Messages tab.
struct NotificationsView: View {
    @Environment(\.dismiss) private var dismiss

    private struct AppNotification: Identifiable {
        let id = UUID()
        let symbol: String
        let title: String
        let detail: String
        let timeAgo: String
    }

    /// Mock alerts for the local prototype.
    private let notifications: [AppNotification] = [
        AppNotification(
            symbol: "person.crop.circle.badge.checkmark",
            title: "Profile created",
            detail: "Your GateMatch profile is ready — people you add can now see it.",
            timeAgo: "2h"
        ),
        AppNotification(
            symbol: "location.fill",
            title: "New login from Chicago, IL",
            detail: "If this was you, no action is needed.",
            timeAgo: "5h"
        ),
        AppNotification(
            symbol: "lock.rotation",
            title: "Password changed",
            detail: "Your password was updated successfully.",
            timeAgo: "1d"
        ),
        AppNotification(
            symbol: "iphone.badge.exclamationmark",
            title: "New device signed in",
            detail: "iPhone 17 · Chicago, IL. Review your devices if you don't recognize it.",
            timeAgo: "3d"
        ),
    ]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(notifications) { notification in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: notification.symbol)
                                .font(.subheadline)
                                .foregroundStyle(Theme.brand)
                                .frame(width: 34, height: 34)
                                .background(Color(.tertiarySystemFill), in: Circle())
                            VStack(alignment: .leading, spacing: 3) {
                                Text(notification.title)
                                    .font(.subheadline.weight(.semibold))
                                Text(notification.detail)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(notification.timeAgo)
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 4)
                    }
                } footer: {
                    Text("Only important account and security alerts appear here. Messages from your connections are in the Messages tab.")
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

/// Puts the global notifications bell in the top-right of a page.
private struct NotificationBellModifier: ViewModifier {
    @State private var showNotifications = false

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showNotifications = true
                    } label: {
                        Image(systemName: "bell")
                    }
                    .accessibilityLabel("Important notifications")
                }
            }
            .sheet(isPresented: $showNotifications) {
                NotificationsView()
            }
    }
}

extension View {
    /// Adds the global important-notifications bell to this page's toolbar.
    func notificationBell() -> some View {
        modifier(NotificationBellModifier())
    }
}

#Preview {
    NotificationsView()
}
