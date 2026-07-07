import SwiftUI

/// App shell: swipeable pages behind a floating glass navigation island
/// (Events · Messages · Account) plus a detached map button.
struct MainShellView: View {
    @Environment(AppState.self) private var appState

    enum Tab: Hashable {
        case events, messages, account
    }

    @State private var selection: Tab = .events
    @State private var eventsPath = NavigationPath()
    @State private var messagesPath = NavigationPath()
    @State private var accountPath = NavigationPath()
    @State private var showMap = false

    /// The bar steps aside on detail screens so bottom actions stay reachable.
    private var isBarHidden: Bool {
        switch selection {
        case .events: !eventsPath.isEmpty
        case .messages: !messagesPath.isEmpty
        case .account: !accountPath.isEmpty
        }
    }

    var body: some View {
        @Bindable var appState = appState
        ZStack(alignment: .bottom) {
            TabView(selection: $selection) {
                EventsTabView(path: $eventsPath)
                    .tag(Tab.events)

                NavigationStack(path: $messagesPath) {
                    ConnectionsView()
                        .contentMargins(.bottom, 88, for: .scrollContent)
                }
                .tag(Tab.messages)

                NavigationStack(path: $accountPath) {
                    AccountView()
                        .contentMargins(.bottom, 88, for: .scrollContent)
                }
                .tag(Tab.account)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            floatingBar
                .padding(.horizontal, 16)
                .padding(.bottom, 6)
                .opacity(isBarHidden ? 0 : 1)
                .offset(y: isBarHidden ? 90 : 0)
                .animation(.snappy(duration: 0.25), value: isBarHidden)
                .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .fullScreenCover(isPresented: $showMap) {
            FriendsMapView()
        }
        .sheet(item: $appState.pendingCelebration) { connection in
            if let traveler = appState.traveler(withID: connection.travelerID),
               let currentUser = appState.currentUser {
                ConnectionCelebrationView(currentUser: currentUser, traveler: traveler) { openMessages in
                    appState.pendingCelebration = nil
                    if openMessages {
                        withAnimation(.snappy) { selection = .messages }
                    }
                }
            }
        }
    }

    // MARK: Floating glass bar

    private var floatingBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 0) {
                tabButton(.events, label: "Events", symbol: "calendar")
                tabButton(.messages, label: "Messages", symbol: "bubble.left.and.bubble.right.fill")
                tabButton(.account, label: "Account", symbol: "person.crop.circle.fill")
            }
            .background(Capsule().fill(.ultraThinMaterial))
            .overlay(Capsule().strokeBorder(Color.primary.opacity(0.08)))
            .shadow(color: .black.opacity(0.08), radius: 8, y: 2)

            // Detached from the island on purpose — it's a mode, not a tab.
            mapButton
        }
        .frame(maxWidth: .infinity)
    }

    private var mapButton: some View {
        Button {
            showMap = true
        } label: {
            VStack(spacing: 3) {
                Image(systemName: "globe.americas.fill")
                    .font(.system(size: 17, weight: .semibold))
                Text("Map")
                    .font(.caption2.weight(.medium))
            }
            .frame(width: 72, height: 48)
            .foregroundStyle(Color.secondary)
            .background(Capsule().fill(.ultraThinMaterial))
            .overlay(Capsule().strokeBorder(Color.primary.opacity(0.08)))
            .overlay(alignment: .topTrailing) {
                Text("BETA")
                    .font(.system(size: 7, weight: .bold))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Theme.brand, in: Capsule())
                    .foregroundStyle(.white)
                    .offset(x: 2, y: -4)
            }
            .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Friends map, beta")
    }

    private func tabButton(_ tab: Tab, label: String, symbol: String) -> some View {
        Button {
            withAnimation(.snappy) { selection = tab }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: symbol)
                    .font(.system(size: 17, weight: .semibold))
                Text(label)
                    .font(.caption2.weight(.medium))
            }
            .frame(width: 72, height: 48)
            .foregroundStyle(selection == tab ? Theme.brand : Color.secondary)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selection == tab ? .isSelected : [])
    }
}

#Preview("Browsing") {
    MainShellView()
        .environment(AppState())
}

#Preview("Joined") {
    MainShellView()
        .environment(AppState.preview)
}
