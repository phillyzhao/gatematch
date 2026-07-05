import SwiftUI

struct ProfileDetailView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    let traveler: UserProfile

    @State private var showBlockConfirm = false
    @State private var showReportConfirmation = false

    /// Like/Pass only make sense while the traveler is still in the feed.
    private var isActionable: Bool {
        appState.nearbyTravelers.contains(traveler)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header
                aboutCard
                locationCard
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(traveler.firstName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        showBlockConfirm = true
                    } label: {
                        Label("Block \(traveler.firstName)", systemImage: "hand.raised")
                    }
                    Button {
                        showReportConfirmation = true
                    } label: {
                        Label("Report \(traveler.firstName)", systemImage: "flag")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .accessibilityLabel("Safety options")
            }
        }
        .confirmationDialog(
            "Block \(traveler.firstName)?",
            isPresented: $showBlockConfirm,
            titleVisibility: .visible
        ) {
            Button("Block", role: .destructive) {
                appState.blockedIDs.insert(traveler.id)
                dismiss()
            }
        } message: {
            Text("They won't appear in your feed anymore. They won't be notified.")
        }
        .alert("Report submitted", isPresented: $showReportConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Thanks for flagging this. In this prototype, reports are placeholders only.")
        }
        .safeAreaInset(edge: .bottom) {
            if isActionable {
                actionBar
            }
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            AvatarView(profile: traveler, size: 96)
            VStack(spacing: 4) {
                Text("\(traveler.firstName), \(traveler.age)")
                    .font(.title2.bold())
                Label(traveler.travelPurpose.rawValue, systemImage: traveler.travelPurpose.symbolName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(traveler.bio.isEmpty ? "No bio yet." : traveler.bio)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    private var locationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("At the airport")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)

            if let checkIn = appState.travelerCheckIns[traveler.id] {
                infoRow(symbol: "airplane", text: checkIn.airportCode)
                infoRow(symbol: "building.2", text: checkIn.terminal)
                if traveler.showsExactGate && !checkIn.gate.isEmpty {
                    infoRow(symbol: "signpost.right", text: "Gate \(checkIn.gate)")
                } else {
                    Label {
                        Text("\(traveler.firstName) keeps their exact gate private.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } icon: {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(.secondary)
                    }
                }
                if let flightTime = checkIn.flightTime {
                    infoRow(
                        symbol: "clock",
                        text: "Departs \(flightTime.formatted(date: .omitted, time: .shortened))"
                    )
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    private func infoRow(symbol: String, text: String) -> some View {
        Label {
            Text(text).font(.subheadline)
        } icon: {
            Image(systemName: symbol)
                .foregroundStyle(Theme.brand)
        }
    }

    private var actionBar: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(.snappy) { appState.pass(traveler) }
                dismiss()
            } label: {
                Label("Pass", systemImage: "xmark")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(.tertiarySystemFill), in: Capsule())
                    .foregroundStyle(.primary)
            }
            .buttonStyle(.plain)

            Button {
                withAnimation(.snappy) {
                    _ = appState.like(traveler)
                }
                dismiss()
            } label: {
                Label("Like", systemImage: "heart.fill")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.brand, in: Capsule())
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.bar)
    }
}

#Preview {
    NavigationStack {
        ProfileDetailView(traveler: MockData.travelers[0])
    }
    .environment(AppState.preview)
}
