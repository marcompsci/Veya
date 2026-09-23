import Foundation
import SwiftData

@Model
final class VeyaSession {
    var id: UUID
    var createdAt: Date
    var userQuestion: String
    var summary: String
    var imageData: Data?
    var responseData: Data?

    init(
        id: UUID = UUID(),
        createdAt: Date = .now,
        userQuestion: String,
        summary: String,
        imageData: Data? = nil,
        responseData: Data? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.userQuestion = userQuestion
        self.summary = summary
        self.imageData = imageData
        self.responseData = responseData
    }

    var guideResponse: GuideResponse? {
        guard let data = responseData else { return nil }
        return try? JSONDecoder().decode(GuideResponse.self, from: data)
    }

    func encode(response: GuideResponse) {
        responseData = try? JSONEncoder().encode(response)
    }

    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: .now)
    }
}
