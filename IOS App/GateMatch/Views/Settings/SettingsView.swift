import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState

    @State private var showReportAlert = false

    var body: some View {
        Form {
            profileSection
            privacySection
            safetySection
            checkInSection
            aboutSection
        }
        .navigationTitle("Settings")
        .alert("Report a problem", isPresented: $showReportAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("In this prototype, reporting is a placeholder. A real reporting flow ships with the backend version.")
        }
    }

    private var profileSection: some View {
        Section("Profile") {
            if let user = appState.currentUser {
                HStack(spacing: 12) {
                    AvatarView(profile: user, size: 52)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("\(user.firstName), \(user.age)")
                            .font(.headline)
                        Label(user.travelPurpose.rawValue, systemImage: user.travelPurpose.symbolName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
                if !user.bio.isEmpty {
                    Text(user.bio)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var privacySection: some View {
        Section {
            Toggle(
                "Show my exact gate to others",
                isOn: Binding(
                    get: { appState.currentUser?.showsExactGate ?? false },
                    set: { appState.currentUser?.showsExactGate = $0 }
                )
            )
            .tint(Theme.brand)
        } header: {
            Text("Privacy")
        } footer: {
            Text("Your exact location is never shared. Other travelers only see your terminal — and your gate only if you turn this on.")
        }
    }

    private var safetySection: some View {
        Section("Safety") {
            if appState.blockedIDs.isEmpty {
                Label {
                    Text("No blocked travelers")
                        .foregroundStyle(.secondary)
                } icon: {
                    Image(systemName: "hand.raised")
                        .foregroundStyle(.secondary)
                }
            } else {
                ForEach(Array(appState.blockedIDs), id: \.self) { id in
                    if let traveler = appState.traveler(withID: id) {
                        HStack {
                            Label(traveler.firstName, systemImage: "hand.raised.fill")
                            Spacer()
                            Button("Unblock") {
                                appState.blockedIDs.remove(id)
                            }
                            .font(.subheadline)
                            .foregroundStyle(Theme.brand)
                        }
                    }
                }
            }

            Button {
                showReportAlert = true
            } label: {
                Label("Report a problem", systemImage: "flag")
            }
            .foregroundStyle(.primary)
        }
    }

    @ViewBuilder
    private var checkInSection: some View {
        if let checkIn = appState.checkIn {
            Section("Check-in") {
                LabeledContent("Airport", value: checkIn.airportCode)
                LabeledContent("Terminal", value: checkIn.terminal)
                if !checkIn.gate.isEmpty {
                    LabeledContent("Gate", value: checkIn.gate)
                }
                Button("Check out", role: .destructive) {
                    appState.checkIn = nil
                }
            }
        }
    }

    private var aboutSection: some View {
        Section {
            LabeledContent("Version", value: "0.1 (local prototype)")
        } footer: {
            Text("GateMatch v0.1 runs entirely on this device with sample travelers. No account, location, or network access.")
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environment(AppState.preview)
}
