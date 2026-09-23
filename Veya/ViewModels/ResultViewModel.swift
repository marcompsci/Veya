import Foundation
import SwiftUI
import SwiftData

@MainActor
@Observable
final class ResultViewModel {
    var selectedStepIndex: Int?
    var selectedAnnotationID: UUID?
    var showDeleteConfirmation = false
    var showActionConfirmation: ActionSuggestion?
    var isDeleted = false

    let response: GuideResponse
    let image: PlatformImage?
    private var session: VeyaSession?
    private let modelContext: ModelContext

    init(
        response: GuideResponse,
        image: PlatformImage?,
        session: VeyaSession? = nil,
        modelContext: ModelContext
    ) {
        self.response = response
        self.image = image
        self.session = session
        self.modelContext = modelContext
    }

    func selectStep(at index: Int) {
        selectedStepIndex = (selectedStepIndex == index) ? nil : index
        if let idx = selectedStepIndex, idx < response.annotations.count {
            selectedAnnotationID = response.annotations[idx].id
        } else {
            selectedAnnotationID = nil
        }
    }

    func selectAnnotation(id: UUID) {
        selectedAnnotationID = (selectedAnnotationID == id) ? nil : id
        selectedStepIndex = response.annotations.firstIndex(where: { $0.id == id })
    }

    func deleteSession() {
        if let session {
            modelContext.delete(session)
            try? modelContext.save()
        }
        isDeleted = true
    }

    func guideShareText() -> String {
        var lines = ["Veya Guide", ""]
        lines.append("Summary: \(response.summary)")
        lines.append("")
        for step in response.steps {
            lines.append("\(step.number). \(step.title)")
            lines.append("   \(step.detail)")
            lines.append("")
        }
        if let notice = response.safetyNotice {
            lines.append("Note: \(notice)")
        }
        return lines.joined(separator: "\n")
    }
}
