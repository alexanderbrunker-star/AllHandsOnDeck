import Foundation
import CoreMedia
import LiveKit

/// Publishes the host iPhone's camera feed to a LiveKit room as a buffer-driven
/// video track. The web viewer (gated on `VITE_ENABLE_LIVEKIT_BETA`) subscribes
/// to this room and renders the first remote video track.
///
/// The host already owns an `AVCaptureSession` via `CameraService`, so we cannot
/// use LiveKit's built-in `CameraCapturer` (which would try to start a second
/// capture session on the same device). Instead we use `BufferCapturer`, which
/// accepts `CMSampleBuffer`s pushed from the existing video-data-output delegate.
///
/// API notes:
///   - `LocalVideoTrack.createBufferTrack(...)` constructs a track whose
///     `.capturer` is a `BufferCapturer`. The default source is `.screenShareVideo`
///     so we override to `.camera` for the host feed.
///   - `BufferCapturer.capture(_ sampleBuffer:)` takes the CMSampleBuffer directly.
///
/// Out of scope for this pass (TODOs):
///   - Throttling / frame-rate adaptation: we forward every buffer the camera
///     emits. The SDK already discards late frames internally, but on slower
///     networks we may want to drop frames here too.
///   - Reconnect / token-refresh backoff: a single failed `start()` surfaces the
///     error to the caller; there is no auto-retry loop.
///   - Audio: the host publishes video only.
@MainActor
final class LiveKitHostPublisher {
    private let sessionID: String
    private let participantID: String

    private let room: Room
    private var localVideoTrack: LocalVideoTrack?
    private var publication: LocalTrackPublication?
    private var bufferCapturer: BufferCapturer?

    private(set) var isConnected: Bool = false

    init(sessionID: String, participantID: String) {
        self.sessionID = sessionID
        self.participantID = participantID
        self.room = Room()
    }

    /// Fetch a fresh token, connect to the room, create the buffer-driven video
    /// track, and publish it. Throws on token-fetch failure or connect failure.
    func start() async throws {
        let token = try await LiveKitTokenClient.fetch(
            sessionID: sessionID,
            participantID: participantID
        )

        try await room.connect(url: token.url, token: token.token)
        isConnected = true

        // .camera so the webapp's track-source filter picks this up as the host
        // viewfinder rather than a screenshare.
        let track = LocalVideoTrack.createBufferTrack(
            name: "host_camera",
            source: .camera
        )
        self.localVideoTrack = track
        self.bufferCapturer = track.capturer as? BufferCapturer

        self.publication = try await room.localParticipant.publish(videoTrack: track)
    }

    /// Forward a CMSampleBuffer from the camera's video-data-output delegate.
    /// Safe to call before `start()` resolves — it just no-ops until the
    /// capturer exists.
    nonisolated func ingest(sampleBuffer: CMSampleBuffer) {
        // Hop to the main actor to read the capturer reference. The capturer
        // itself is `@unchecked Sendable` and its `capture(_:)` is fine to call
        // off-main, but we read the optional under MainActor isolation.
        Task { @MainActor [weak self] in
            self?.bufferCapturer?.capture(sampleBuffer)
        }
    }

    /// Unpublish + disconnect. Idempotent.
    /// We don't call `stopCapture()` on the track explicitly — the SDK marks it
    /// `internal`, and `unpublish` + `disconnect` already tear down the capturer.
    func stop() async {
        if let publication {
            try? await room.localParticipant.unpublish(publication: publication)
        }
        await room.disconnect()
        localVideoTrack = nil
        publication = nil
        bufferCapturer = nil
        isConnected = false
    }
}
