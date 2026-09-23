import Foundation
import SwiftUI
import SwiftData

@MainActor
@Observable
final class HomeViewModel {
    var recentSessions: [VeyaSession] = []
    var clipboardImage: PlatformImage?
    var showHowVeyaWorks = false

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func onAppear() {
        loadRecentSessions()
        checkClipboard()
    }

    func loadRecentSessions() {
        let descriptor = FetchDescriptor<VeyaSession>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        recentSessions = (try? modelContext.fetch(descriptor)) ?? []
    }

    func checkClipboard() {
        #if os(iOS)
        let pasteboard = UIPasteboard.general
        if pasteboard.hasImages, let image = pasteboard.image {
            clipboardImage = image
        } else {
            clipboardImage = nil
        }
        #endif
    }

    func deleteSession(_ session: VeyaSession) {
        modelContext.delete(session)
        try? modelContext.save()
        loadRecentSessions()
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<21: return "Good evening"
        default:      return "Good night"
        }
    }
}
