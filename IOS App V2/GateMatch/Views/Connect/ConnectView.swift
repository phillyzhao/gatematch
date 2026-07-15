import MapKit
import SwiftUI

/// V2 first screen: a globe with a "Connect with others" search card.
/// A valid US location zooms the camera in and pops mock people nearby;
/// anything outside the USA is turned away.
struct ConnectView: View {
    private enum Phase: Equatable {
        case globe
        case zoomed(USCity)
    }

    /// Far enough out that the whole planet is visible, centered on the USA.
    private static let globeCamera = MapCamera(
        centerCoordinate: .init(latitude: 39.8, longitude: -98.6),
        distance: 40_000_000
    )

    /// Once zoomed, the camera is fenced to the USA — no wandering abroad.
    private static let usBounds = MapCameraBounds(
        centerCoordinateBounds: MKCoordinateRegion(
            center: .init(latitude: 44.0, longitude: -108.0),
            span: .init(latitudeDelta: 42, longitudeDelta: 104)
        ),
        maximumDistance: 6_500_000
    )

    @State private var phase: Phase = .globe
    @State private var position: MapCameraPosition = .camera(globeCamera)
    @State private var query = ""
    @State private var searchError: String?
    @State private var people: [NearbyPerson] = []
    /// Drives the staggered pop-in of person pins after the zoom lands.
    @State private var visibleIDs: Set<UUID> = []
    @State private var addedIDs: Set<UUID> = []
    @State private var showList = false
    @FocusState private var searchFocused: Bool

    private var zoomedCity: USCity? {
        if case .zoomed(let city) = phase { return city }
        return nil
    }

    var body: some View {
        Map(position: $position, bounds: zoomedCity == nil ? nil : Self.usBounds) {
            if let city = zoomedCity {
                ForEach(people) { person in
                    Annotation(coordinate: person.coordinate(around: city.coordinate)) {
                        if visibleIDs.contains(person.id) {
                            personPin(person)
                                .transition(.scale(scale: 0.3).combined(with: .opacity))
                        }
                    } label: {
                        EmptyView()
                    }
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .excludingAll))
        .ignoresSafeArea()
        .overlay(alignment: .top) { header }
        .sheet(isPresented: $showList) { peopleList }
        .onTapGesture { searchFocused = false }
        .task { await runAutomationHookIfNeeded() }
    }

    // MARK: Header

    @ViewBuilder
    private var header: some View {
        switch phase {
        case .globe:
            searchCard
                .padding(.horizontal, 16)
                .padding(.top, 8)
        case .zoomed(let city):
            zoomedBar(for: city)
                .padding(.horizontal, 16)
                .padding(.top, 8)
        }
    }

    private var searchCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Connect with others")
                .font(Theme.heading(20))

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Enter your location", text: $query)
                    .font(.subheadline)
                    .focused($searchFocused)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                    .submitLabel(.search)
                    .onSubmit(submitSearch)
                if !query.isEmpty {
                    Button(action: submitSearch) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Theme.brand)
                    }
                    .accessibilityLabel("Search location")
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground).opacity(0.6)))
            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.primary.opacity(0.1)))

            if let searchError {
                Label(searchError, systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 20).fill(.ultraThinMaterial))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color.primary.opacity(0.08)))
        .shadow(color: .black.opacity(0.08), radius: 10, y: 3)
    }

    private func zoomedBar(for city: USCity) -> some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundStyle(Theme.brand)
                Text(city.label)
                    .font(Theme.heading(15))
                    .lineLimit(1)
                Button(action: resetToGlobe) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel("Clear location")
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Capsule().fill(.ultraThinMaterial))
            .overlay(Capsule().strokeBorder(Color.primary.opacity(0.08)))

            Spacer()

            Button {
                showList = true
            } label: {
                Image(systemName: "list.bullet")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(.ultraThinMaterial))
                    .overlay(Circle().strokeBorder(Color.primary.opacity(0.08)))
            }
            .accessibilityLabel("Show people as a list")
        }
        .shadow(color: .black.opacity(0.08), radius: 10, y: 3)
    }

    // MARK: Person pins

    private func personPin(_ person: NearbyPerson) -> some View {
        VStack(spacing: 4) {
            AvatarView(profile: person.profile, size: 44)
                .background(Circle().fill(Color(.systemBackground)).padding(-3))
                .overlay(alignment: .bottomTrailing) {
                    addButton(for: person, size: 20)
                        .offset(x: 4, y: 4)
                }

            VStack(spacing: 1) {
                Text(person.profile.firstName)
                    .font(.caption2.weight(.semibold))
                Text(person.relationship)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(Capsule().fill(.ultraThinMaterial))
            .overlay(Capsule().strokeBorder(Color.primary.opacity(0.08)))
        }
    }

    private func addButton(for person: NearbyPerson, size: CGFloat) -> some View {
        let added = addedIDs.contains(person.id)
        return Button {
            withAnimation(.snappy(duration: 0.2)) {
                if added { addedIDs.remove(person.id) } else { addedIDs.insert(person.id) }
            }
        } label: {
            Image(systemName: added ? "checkmark" : "plus")
                .font(.system(size: size * 0.55, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: size, height: size)
                .background(Circle().fill(added ? Color.green : Theme.brand))
                .overlay(Circle().strokeBorder(Color(.systemBackground), lineWidth: 1.5))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(added ? "Added \(person.profile.firstName)" : "Add \(person.profile.firstName)")
    }

    // MARK: List view

    private var peopleList: some View {
        NavigationStack {
            List(people) { person in
                HStack(spacing: 12) {
                    AvatarView(profile: person.profile, size: 44)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(person.profile.firstName)
                            .font(Theme.heading(15))
                        Text("\(person.relationship) · \(person.distanceMiles, specifier: "%.1f") mi away")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    addButton(for: person, size: 28)
                }
                .padding(.vertical, 2)
            }
            .listStyle(.plain)
            .navigationTitle(zoomedCity.map { "People near \($0.name)" } ?? "People nearby")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { showList = false }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    // MARK: Search + camera

    private func submitSearch() {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        switch USPlaces.lookup(trimmed) {
        case .us(let city):
            zoom(to: city)
        case .foreign(let name):
            searchError = "\(name) isn't in the USA — GateMatch V2 is US-only for now."
        case .unknown:
            searchError = "Couldn't find that US location. Try a city like Austin or Chicago."
        }
    }

    private func zoom(to city: USCity) {
        searchError = nil
        searchFocused = false
        people = MockPeople.people(near: city)
        visibleIDs = []
        phase = .zoomed(city)

        withAnimation(.easeInOut(duration: 2.0)) {
            position = .camera(MapCamera(centerCoordinate: city.coordinate, distance: 175_000))
        }

        // Let the zoom land, then pop people in one by one.
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.7))
            guard case .zoomed(city) = phase else { return }
            for person in people {
                withAnimation(.spring(duration: 0.35, bounce: 0.45)) {
                    _ = visibleIDs.insert(person.id)
                }
                try? await Task.sleep(for: .milliseconds(130))
            }
        }
    }

    /// Debug-only demo/verification hook: launch with CONNECT_AUTOZOOM=<city>
    /// (and optionally CONNECT_AUTOLIST=1) to drive the flow hands-free.
    private func runAutomationHookIfNeeded() async {
        #if DEBUG
        let env = ProcessInfo.processInfo.environment
        guard let autoCity = env["CONNECT_AUTOZOOM"], phase == .globe else { return }
        try? await Task.sleep(for: .seconds(1))
        query = autoCity
        submitSearch()
        if env["CONNECT_AUTOLIST"] == "1" {
            try? await Task.sleep(for: .seconds(4))
            showList = true
        }
        #endif
    }

    private func resetToGlobe() {
        phase = .globe
        people = []
        visibleIDs = []
        showList = false
        query = ""
        searchError = nil
        withAnimation(.easeInOut(duration: 1.6)) {
            position = .camera(Self.globeCamera)
        }
    }
}

#Preview {
    ConnectView()
        .environment(AppState())
}
