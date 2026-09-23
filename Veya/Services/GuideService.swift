import Foundation

protocol GuideService: Sendable {
    func createGuide(imageData: Data, userQuestion: String) async throws -> GuideResponse
}
