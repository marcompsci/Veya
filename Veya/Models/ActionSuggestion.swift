import Foundation

enum ActionType: String, Codable, CaseIterable, Hashable {
    case openSettings
    case createReminder
    case createNote
    case openMaps
    case copyText
    case shareGuide
}

struct ActionSuggestion: Codable, Identifiable, Equatable, Hashable {
    let id: UUID
    let title: String
    let subtitle: String
    let systemImage: String
    let actionType: ActionType
    let requiresConfirmation: Bool

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        systemImage: String,
        actionType: ActionType,
        requiresConfirmation: Bool = true
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.actionType = actionType
        self.requiresConfirmation = requiresConfirmation
    }
}
