import XCTest
import Combine
@testable import AllHandsOnDeck

@MainActor
final class MockSessionTransportTests: XCTestCase {
    private var subs: Set<AnyCancellable> = []

    override func tearDown() {
        subs.removeAll()
        super.tearDown()
    }

    func test_hostAndViewer_inSameSession_exchangeEvents() async throws {
        let session = PhotoSession(id: "TESTROOM01", hostName: "Captain")

        let host = MockSessionTransport(role: .host, displayName: "Captain")
        let viewer = MockSessionTransport(role: .viewer, displayName: "Crew")

        var hostInbox: [SessionEvent] = []
        var viewerInbox: [SessionEvent] = []
        host.events.sink { hostInbox.append($0) }.store(in: &subs)
        viewer.events.sink { viewerInbox.append($0) }.store(in: &subs)

        try await host.start(session: session)
        try await viewer.start(session: session)

        // The viewer's start auto-broadcasts a participantJoined → host sees it.
        try await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertTrue(hostInbox.contains(where: {
            if case .participantJoined = $0 { return true } else { return false }
        }), "Host should have seen the viewer join")

        // Host broadcasts a countdown → viewer receives it, host doesn't echo.
        let target = Date().addingTimeInterval(10)
        await host.send(.countdownStarted(photoAt: target, duration: 10, startedBy: "h"))
        try await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertTrue(viewerInbox.contains(where: {
            if case .countdownStarted = $0 { return true } else { return false }
        }))
        XCTAssertFalse(hostInbox.contains(where: {
            if case .countdownStarted = $0 { return true } else { return false }
        }), "Sender should not receive its own broadcast")
    }

    func test_differentSessionIDs_areIsolated() async throws {
        let s1 = PhotoSession(id: "ROOM01XXXX", hostName: "A")
        let s2 = PhotoSession(id: "ROOM02XXXX", hostName: "B")

        let h1 = MockSessionTransport(role: .host, displayName: "A")
        let v2 = MockSessionTransport(role: .viewer, displayName: "B")

        var h1Inbox: [SessionEvent] = []
        h1.events.sink { h1Inbox.append($0) }.store(in: &subs)

        try await h1.start(session: s1)
        try await v2.start(session: s2)

        // v2 sends into ROOM02 — h1 listens on ROOM01 and must not see it.
        await v2.send(.captureRequested(by: "v2"))
        try await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertFalse(h1Inbox.contains(where: {
            if case .captureRequested = $0 { return true } else { return false }
        }))
    }

    func test_status_emits_connected_after_start() async throws {
        let host = MockSessionTransport(role: .host, displayName: "A")
        var seen: [TransportConnectionStatus] = []
        host.connectionStatus.sink { seen.append($0) }.store(in: &subs)

        XCTAssertEqual(host.connectionStatus.firstValueSync, .idle)

        try await host.start(session: PhotoSession(id: "ROOMTEST00", hostName: "A"))
        try await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertTrue(seen.contains(.connected))
    }
}

// Tiny helper for tests: pull the current value out of an AnyPublisher that's
// known to be a CurrentValueSubject by virtue of how the transport is built.
private extension Publisher where Failure == Never {
    var firstValueSync: Output? {
        var v: Output?
        let s = sink { v = $0 }
        s.cancel()
        return v
    }
}
