import Foundation
import SwiftData

@MainActor
final class SessionStore {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func save(_ session: VeyaSession) throws {
        modelContext.insert(session)
        try modelContext.save()
    }

    func delete(_ session: VeyaSession) throws {
        modelContext.delete(session)
        try modelContext.save()
    }

    func deleteAll() throws {
        try modelContext.delete(model: VeyaSession.self)
        try modelContext.save()
    }

    func fetchAll() throws -> [VeyaSession] {
        let descriptor = FetchDescriptor<VeyaSession>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
}
