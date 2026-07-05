import SwiftUI

struct RootView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "airplane.departure")
                .font(.system(size: 44))
                .foregroundStyle(.tint)
            Text("GateMatch")
                .font(.largeTitle.bold())
            Text("Meet travelers at your gate")
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    RootView()
}
