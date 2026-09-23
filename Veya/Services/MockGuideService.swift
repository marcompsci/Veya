import Foundation

/// Deterministic mock — fully functional without a backend.
struct MockGuideService: GuideService {
    func createGuide(imageData: Data, userQuestion: String) async throws -> GuideResponse {
        try await Task.sleep(for: .seconds(2))
        return .preview
    }
}
