import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var router = AppRouter()
    @State private var homeViewModel: HomeViewModel?
    @State private var analyzeViewModel: AnalyzeViewModel?
    @State private var settingsViewModel: SettingsViewModel?

    var body: some View {
        Group {
            if let homeVM = homeViewModel,
               let analyzeVM = analyzeViewModel,
               let settingsVM = settingsViewModel {
                NavigationStack(path: Binding(
                    get: { router.path },
                    set: { router.path = $0 }
                )) {
                    HomeView()
                        .navigationDestination(for: AppRoute.self) { route in
                            switch route {
                            case .analyze:
                                AnalyzeView()
                            case .result:
                                ResultView()
                            case .settings:
                                SettingsView()
                            }
                        }
                }
                .environment(router)
                .environment(homeVM)
                .environment(analyzeVM)
                .environment(settingsVM)
                .preferredColorScheme(.dark)
                .tint(.veyaAccent)
            }
        }
        .onAppear {
            guard homeViewModel == nil else { return }
            homeViewModel = HomeViewModel(modelContext: modelContext)
            // TODO: Replace MockGuideService() with LiveGuideService() once backend is ready.
            // LiveGuideService lives in Services/LiveGuideService.swift (create it to conform to GuideService).
            // APIClient.swift already scaffolds the request/response shape — just update the baseURL and add auth.
            analyzeViewModel = AnalyzeViewModel(guideService: MockGuideService(), modelContext: modelContext)
            settingsViewModel = SettingsViewModel(modelContext: modelContext)
        }
        .onOpenURL { url in
            handleIncomingURL(url)
        }
    }

    private func handleIncomingURL(_ url: URL) {
        // veya://import — triggered by Share Extension
        guard url.scheme == "veya", url.host == "import" else { return }
        if let data = SharedImageInbox.pendingImageData(),
           let image = PlatformImage(data: data) {
            analyzeViewModel?.reset()
            analyzeViewModel?.setImage(image)
            router.navigate(to: .analyze)
        }
    }
}

#Preview {
    RootView()
        .modelContainer(for: VeyaSession.self, inMemory: true)
}
