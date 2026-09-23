import Foundation

// MARK: - API Scaffold
// See README → "Replacing MockGuideService" before making live calls.
// API keys and provider secrets must NEVER be embedded in this binary.

struct APIClient: Sendable {
    // TODO: Replace this URL with your production endpoint before going live.
    private let baseURL = URL(string: "https://api.yourdomain.com/v1")!
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func createGuide(imageData: Data, userQuestion: String) async throws -> GuideResponse {
        let endpoint = baseURL.appending(path: "guides")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // TODO: Uncomment and wire up a short-lived session token from your auth layer.
        // Auth token must come from a server-issued session token — never embed a raw API key.
        // request.setValue("Bearer <session-token>", forHTTPHeaderField: "Authorization")

        let body = GuideRequestBody(
            imageBase64: imageData.base64EncodedString(),
            userQuestion: userQuestion,
            deviceLocale: Locale.current.identifier,
            appVersion: Bundle.main.appVersion
        )

        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw VeyaError.analysisFailure("Server returned an error.")
        }

        do {
            return try JSONDecoder().decode(GuideResponse.self, from: data)
        } catch {
            throw VeyaError.decodingFailed
        }
    }
}

private struct GuideRequestBody: Encodable {
    let imageBase64: String
    let userQuestion: String
    let deviceLocale: String
    let appVersion: String
}

extension Bundle {
    var appVersion: String {
        (infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0"
    }
}
