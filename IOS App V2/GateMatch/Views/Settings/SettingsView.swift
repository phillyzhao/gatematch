import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState

    @AppStorage("appearanceMode") private var appearanceRaw = AppearanceMode.system.rawValue
    @State private var showReportAlert = false

    var body: some View {
        Form {
            appearanceSection
            safetySection
            aboutSection
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Report a problem", isPresented: $showReportAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("In this prototype, reporting is a placeholder. A real reporting flow ships with the backend version.")
        }
    }

    private var appearanceSection: some View {
        Section {
            Picker("Theme", selection: $appearanceRaw) {
                ForEach(AppearanceMode.allCases) { mode in
                    Text(mode.label).tag(mode.rawValue)
                }
            }
            .pickerStyle(.segmented)
            // Apply instantly from here too — this page is where staleness shows.
            .onChange(of: appearanceRaw) {
                AppAppearanceModifier.applyWindowOverride(
                    AppearanceMode(rawValue: appearanceRaw) ?? .system
                )
            }
        } header: {
            Text("Appearance")
        } footer: {
            Text("Dark mode applies across the whole app.")
        }
    }

    private var safetySection: some View {
        Section("Safety") {
            if appState.blockedIDs.isEmpty {
                Label {
                    Text("No blocked people")
                        .foregroundStyle(.secondary)
                } icon: {
                    Image(systemName: "hand.raised")
                        .foregroundStyle(.secondary)
                }
            } else {
                ForEach(Array(appState.blockedIDs), id: \.self) { id in
                    if let person = appState.traveler(withID: id) {
                        HStack {
                            Label(person.firstName, systemImage: "hand.raised.fill")
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

    private var aboutSection: some View {
        Section {
            LabeledContent("Version", value: "2.0 (research prototype)")
        } footer: {
            Text("GateMatch V2 runs entirely on this device with sample people. No account, location, or network access.")
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environment(AppState.preview)
}
