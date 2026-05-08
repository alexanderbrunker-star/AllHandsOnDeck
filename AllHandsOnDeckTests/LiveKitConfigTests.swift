import XCTest
@testable import AllHandsOnDeck

final class LiveKitConfigTests: XCTestCase {
    func test_betaDisabledWhenBothEnvVarsEmpty() {
        XCTAssertFalse(LiveKitConfig.evaluate(flagRaw: "", endpointRaw: ""))
    }

    func test_betaDisabledWhenEndpointEmptyEvenIfFlagOn() {
        XCTAssertFalse(LiveKitConfig.evaluate(flagRaw: "YES", endpointRaw: ""))
    }

    func test_betaDisabledWhenFlagOffEvenIfEndpointSet() {
        XCTAssertFalse(LiveKitConfig.evaluate(flagRaw: "NO",
                                              endpointRaw: "https://example.run.app/api/livekit/token"))
    }

    func test_betaEnabledWhenBothSet() {
        XCTAssertTrue(LiveKitConfig.evaluate(flagRaw: "YES",
                                             endpointRaw: "https://example.run.app/api/livekit/token"))
    }

    func test_betaDisabledForMalformedEndpoint() {
        XCTAssertFalse(LiveKitConfig.evaluate(flagRaw: "YES", endpointRaw: "not-a-url"))
    }
}
