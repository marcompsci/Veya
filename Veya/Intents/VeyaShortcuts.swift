import AppIntents

struct VeyaShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AskVeyaIntent(),
            phrases: [
                "Ask \(.applicationName)",
                "Open \(.applicationName)",
                "Get help from \(.applicationName)"
            ],
            shortTitle: "Ask Veya",
            systemImageName: "sparkles"
        )
    }
}
