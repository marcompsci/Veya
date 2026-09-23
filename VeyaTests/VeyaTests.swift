import Testing
import SwiftData
@testable import Veya

@Suite("Session Store Behavior")
struct SessionStoreTests {

    @MainActor
    @Test("Session is saved and retrievable")
    func sessionPersists() async throws {
        let container = try ModelContainer(for: VeyaSession.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = container.mainContext

        let session = VeyaSession(userQuestion: "What do I tap next?", summary: "Tap the blue button.")
        context.insert(session)
        try context.save()

        let descriptor = FetchDescriptor<VeyaSession>()
        let results = try context.fetch(descriptor)

        #expect(results.count == 1)
        #expect(results.first?.userQuestion == "What do I tap next?")
    }

    @MainActor
    @Test("Session deletion removes record")
    func sessionDeletion() async throws {
        let container = try ModelContainer(for: VeyaSession.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = container.mainContext

        let session = VeyaSession(userQuestion: "Explain this", summary: "This is a settings screen.")
        context.insert(session)
        try context.save()

        context.delete(session)
        try context.save()

        let descriptor = FetchDescriptor<VeyaSession>()
        let results = try context.fetch(descriptor)
        #expect(results.isEmpty)
    }

    @MainActor
    @Test("GuideResponse encodes into VeyaSession and decodes back")
    func responseEncoding() throws {
        let session = VeyaSession(userQuestion: "Test", summary: "Summary")
        session.encode(response: .preview)

        let decoded = session.guideResponse
        #expect(decoded != nil)
        #expect(decoded?.summary == GuideResponse.preview.summary)
        #expect(decoded?.steps.count == GuideResponse.preview.steps.count)
    }

    @MainActor
    @Test("Delete all sessions clears store")
    func deleteAll() async throws {
        let container = try ModelContainer(for: VeyaSession.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = container.mainContext

        for i in 0..<5 {
            context.insert(VeyaSession(userQuestion: "Q\(i)", summary: "S\(i)"))
        }
        try context.save()

        try context.delete(model: VeyaSession.self)
        try context.save()

        let results = try context.fetch(FetchDescriptor<VeyaSession>())
        #expect(results.isEmpty)
    }
}
