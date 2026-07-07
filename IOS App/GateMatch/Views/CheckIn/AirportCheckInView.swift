import SwiftUI

struct AirportCheckInView: View {
    @Environment(AppState.self) private var appState

    @State private var selectedAirport: Airport?
    @State private var airportQuery = ""
    @State private var terminal = ""
    @State private var gate = ""
    @State private var hasFlightTime = false
    @State private var flightTime = Date().addingTimeInterval(2 * 3600)

    /// The event's primary airports lead; a selection made via search stays visible.
    private var suggestedAirports: [Airport] {
        let primaries = appState.joinedEvent?.primaryAirportCodes.compactMap(Airport.named) ?? []
        guard let selectedAirport, !primaries.contains(selectedAirport) else { return primaries }
        return primaries + [selectedAirport]
    }

    private var airportResults: [Airport] {
        let query = airportQuery.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return [] }
        return Airport.all.filter {
            $0.code.localizedCaseInsensitiveContains(query)
                || $0.name.localizedCaseInsensitiveContains(query)
                || $0.city.localizedCaseInsensitiveContains(query)
        }
    }

    private var isSearchingAirports: Bool {
        !airportQuery.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var canCheckIn: Bool {
        selectedAirport != nil
            && !terminal.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                airportSection
                locationSection
                flightTimeSection
                privacyNote
            }
            .padding(24)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Check in")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) { checkInButton }
    }

    private var airportSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Your airport")
            airportSearchField

            if !isSearchingAirports {
                if let event = appState.joinedEvent {
                    Text("Suggested for \(event.name)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                ForEach(suggestedAirports) { airport in
                    airportRow(airport)
                }
                Text("Flying from somewhere else? Search all \(Airport.all.count) airports above.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            } else if airportResults.isEmpty {
                SearchEmptyStateView(
                    query: airportQuery,
                    message: "No airports match. Try a code like ORD or a city name.",
                    suggestions: appState.joinedEvent?.primaryAirportCodes ?? ["ORD", "JFK", "LAX"],
                    onSuggestion: { airportQuery = $0 },
                    onClear: { airportQuery = "" }
                )
            } else {
                ForEach(airportResults) { airport in
                    airportRow(airport)
                }
            }
        }
    }

    private var airportSearchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search airports", text: $airportQuery)
                .autocorrectionDisabled()
            if !airportQuery.isEmpty {
                Button {
                    airportQuery = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.tertiary)
                }
                .accessibilityLabel("Clear airport search")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    private func airportRow(_ airport: Airport) -> some View {
        let isSelected = selectedAirport == airport
        return Button {
            selectedAirport = airport
            // Back to the suggested list, with the pick visible and checked.
            withAnimation(.snappy) { airportQuery = "" }
        } label: {
            HStack(spacing: 14) {
                Text(airport.code)
                    .font(Theme.mono(15))
                    .frame(width: 56, height: 38)
                    .background(
                        isSelected ? Theme.brand : Color(.tertiarySystemFill),
                        in: RoundedRectangle(cornerRadius: 8)
                    )
                    .foregroundStyle(isSelected ? .white : .primary)
                VStack(alignment: .leading, spacing: 2) {
                    Text(airport.name)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                    Text(airport.city)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Theme.brand)
                }
            }
            .padding(12)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? Theme.brand : .clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Where in the airport?")
            HStack(spacing: 12) {
                TextField("Terminal 1", text: $terminal)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
                TextField("Gate B12 (optional)", text: $gate)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var flightTimeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Flight time (optional)")
            VStack(spacing: 0) {
                Toggle("I know my departure time", isOn: $hasFlightTime.animation())
                    .tint(Theme.brand)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                if hasFlightTime {
                    Divider().padding(.leading, 14)
                    DatePicker(
                        "Departs",
                        selection: $flightTime,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .tint(Theme.brand)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                }
            }
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.secondary)
    }

    private var privacyNote: some View {
        Label {
            Text("Your terminal and gate are only used to sort travelers near you. Your exact gate is never shown to others unless you choose to share it.")
        } icon: {
            Image(systemName: "lock.fill")
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
    }

    private var checkInButton: some View {
        Button(action: checkIn) {
            Text(selectedAirport.map { "Check in at \($0.code)" } ?? "Check in")
                .font(Theme.heading(17))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Theme.brand, in: RoundedRectangle(cornerRadius: 14))
        }
        .disabled(!canCheckIn)
        .opacity(canCheckIn ? 1 : 0.4)
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(.bar)
    }

    private func checkIn() {
        guard let airport = selectedAirport, let user = appState.currentUser else { return }
        appState.checkIn = AirportCheckIn(
            userID: user.id,
            airportCode: airport.code,
            terminal: terminal.trimmingCharacters(in: .whitespaces),
            gate: gate.trimmingCharacters(in: .whitespaces).uppercased(),
            flightTime: hasFlightTime ? flightTime : nil
        )
    }
}

#Preview {
    NavigationStack {
        AirportCheckInView()
    }
    .environment(AppState())
}
