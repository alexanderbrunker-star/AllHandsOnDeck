import Foundation

/// Thin client for the Cloud Run LiveKit token endpoint.
///
/// Server contract (see `server/src/livekitToken.ts`):
///   POST { session_id, participant_id }  →  { token, url, room }
enum LiveKitTokenError: Error, LocalizedError {
    case notConfigured
    case http(status: Int, body: String)
    case malformedResponse

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "LiveKit token endpoint is not configured."
        case .http(let status, let body):
            return "LiveKit token request failed (\(status)): \(body)"
        case .malformedResponse:
            return "LiveKit token response was not valid JSON."
        }
    }
}

struct LiveKitTokenResponse: Decodable, Sendable {
    let token: String
    let url: String
    let room: String
}

enum LiveKitTokenClient {
    private struct RequestBody: Encodable {
        let session_id: String
        let participant_id: String
    }

    /// POST to `LiveKitConfig.tokenEndpoint`, returning the decoded payload or throwing.
    static func fetch(sessionID: String,
                      participantID: String,
                      session: URLSession = .shared) async throws -> LiveKitTokenResponse {
        guard let endpoint = LiveKitConfig.tokenEndpoint else {
            throw LiveKitTokenError.notConfigured
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try JSONEncoder().encode(
            RequestBody(session_id: sessionID, participant_id: participantID)
        )

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw LiveKitTokenError.malformedResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw LiveKitTokenError.http(status: http.statusCode, body: body)
        }

        do {
            return try JSONDecoder().decode(LiveKitTokenResponse.self, from: data)
        } catch {
            throw LiveKitTokenError.malformedResponse
        }
    }
}
