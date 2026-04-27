import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var hostName: String = "Captain"

    /// In step 1, viewer Join uses the most recent host-side session created
    /// inside this process (mock transport room). That lets you run host on a
    /// device and viewer on the simulator (same broker if same process), or use
    /// the dev affordance "Mock Viewer" on Home for a quick demo.
    @Published private(set) var lastKnownSessionID: String?

    func remember(sessionID: String) {
        lastKnownSessionID = sessionID
    }
}
