import SwiftUI
import SwiftData

@main
struct VeyaApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([VeyaSession.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                RootView()
                    .modelContainer(sharedModelContainer)
            } else {
                OnboardingView {
                    hasCompletedOnboarding = true
                }
            }
        }
    }
}
