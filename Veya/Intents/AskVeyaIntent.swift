import AppIntents
import SwiftUI

// MARK: - Ask Veya Intent
struct AskVeyaIntent: AppIntent {
    static let title: LocalizedStringResource = "Ask Veya"
    static let description = IntentDescription("Open Veya to create a visual guide from a screenshot or question.")

    static let openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        return .result()
    }
}
