import Foundation

struct GuideResponse: Codable, Identifiable, Equatable, Hashable {
    let id: UUID
    let summary: String
    let safetyNotice: String?
    let steps: [GuideStep]
    let annotations: [Annotation]
    let actionSuggestions: [ActionSuggestion]

    init(
        id: UUID = UUID(),
        summary: String,
        safetyNotice: String? = nil,
        steps: [GuideStep],
        annotations: [Annotation],
        actionSuggestions: [ActionSuggestion]
    ) {
        self.id = id
        self.summary = summary
        self.safetyNotice = safetyNotice
        self.steps = steps
        self.annotations = annotations
        self.actionSuggestions = actionSuggestions
    }
}

// MARK: - Preview Helpers
extension GuideResponse {
    static let preview = GuideResponse(
        id: UUID(),
        summary: "Start with the option highlighted near the top of this screen.",
        safetyNotice: "Review the next screen before confirming any account or payment changes.",
        steps: [
            GuideStep(number: 1,
                      title: "Tap the highlighted option",
                      detail: "It is the most likely place to continue from this screen."),
            GuideStep(number: 2,
                      title: "Review the choices",
                      detail: "Look for wording that matches your goal before changing a setting."),
            GuideStep(number: 3,
                      title: "Confirm only if it looks right",
                      detail: "You can return without saving if you are unsure.")
        ],
        annotations: [
            Annotation(type: .roundedRectangle,
                       normalizedX: 0.05, normalizedY: 0.14,
                       normalizedWidth: 0.90, normalizedHeight: 0.11,
                       label: "1", colorStyle: .accent),
            Annotation(type: .arrow,
                       normalizedX: 0.44, normalizedY: 0.06,
                       normalizedWidth: 0.12, normalizedHeight: 0.08,
                       label: "", colorStyle: .accent)
        ],
        actionSuggestions: [
            ActionSuggestion(title: "Save these steps to Notes",
                             subtitle: "Create a note with your guide steps",
                             systemImage: "note.text",
                             actionType: .createNote),
            ActionSuggestion(title: "Create a reminder to finish later",
                             subtitle: "Set a reminder so you can return to this",
                             systemImage: "bell.badge",
                             actionType: .createReminder),
            ActionSuggestion(title: "Share this guide",
                             subtitle: "Share your guide with others",
                             systemImage: "square.and.arrow.up",
                             actionType: .shareGuide,
                             requiresConfirmation: false)
        ]
    )
}
