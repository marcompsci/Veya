import SwiftUI
import SwiftData
import PhotosUI

struct HomeView: View {
    @Environment(HomeViewModel.self) private var viewModel
    @Environment(AnalyzeViewModel.self) private var analyzeViewModel
    @Environment(AppRouter.self) private var router

    @State private var photosItem: PhotosPickerItem?
    @State private var showHowItWorks = false

    var body: some View {
        ZStack {
            LinearGradient.veyaBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: VeyaSpacing.lg) {
                    headerSection
                    heroCard
                    actionButtons
                    trustLine
                    recentGuidesSection
                }
                .padding(.horizontal, VeyaSpacing.screenPadding)
                .padding(.top, VeyaSpacing.md)
                .padding(.bottom, VeyaSpacing.xxxl)
            }
        }
        .veyaHideNavBar()
        .onAppear { viewModel.onAppear() }
        .onChange(of: photosItem) { _, newItem in
            loadPickedPhoto(newItem)
        }
        .sheet(isPresented: $showHowItWorks) {
            HowVeyaWorksSheet()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.greeting)
                    .font(.veyaSubheadline)
                    .foregroundStyle(Color.veyaTextSecondary)
                HStack(spacing: 6) {
                    Text("V")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(LinearGradient.veyaAccent)
                    Text("Veya")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundStyle(Color.veyaTextPrimary)
                }
            }

            Spacer()

            Button {
                router.navigate(to: .settings)
            } label: {
                Image(systemName: "person.circle")
                    .font(.system(size: 26, weight: .light))
                    .foregroundStyle(Color.veyaTextSecondary)
            }
            .accessibilityLabel("Settings")
        }
    }

    // MARK: - Hero Card
    private var heroCard: some View {
        VeyaCard(padding: VeyaSpacing.xl) {
            VStack(spacing: VeyaSpacing.lg) {
                VeyaOrbView(size: 110)

                VStack(spacing: VeyaSpacing.xs) {
                    Text("What can I help you see?")
                        .font(.veyaTitle2)
                        .foregroundStyle(Color.veyaTextPrimary)
                        .multilineTextAlignment(.center)

                    Text("Share a screenshot and ask me anything about it.")
                        .font(.veyaSubheadline)
                        .foregroundStyle(Color.veyaTextSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: VeyaSpacing.sm) {
            VeyaButton("Ask Veya", systemImage: "mic.fill") {
                analyzeViewModel.reset()
                router.navigate(to: .analyze)
            }

            PhotosPicker(selection: $photosItem, matching: .screenshots) {
                QuickActionCard(
                    systemImage: "photo.on.rectangle",
                    title: "Import a Screenshot",
                    subtitle: "Pick from your photo library",
                    action: {}
                )
            }
            .buttonStyle(.plain)

            if viewModel.clipboardImage != nil {
                Button {
                    if let img = viewModel.clipboardImage {
                        analyzeViewModel.reset()
                        analyzeViewModel.setImage(img)
                        router.navigate(to: .analyze)
                    }
                } label: {
                    QuickActionCard(
                        systemImage: "doc.on.clipboard",
                        title: "Paste from Clipboard",
                        subtitle: "Use the image you copied",
                        action: {}
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Trust Line
    private var trustLine: some View {
        HStack(spacing: VeyaSpacing.xs) {
            Image(systemName: "lock.fill")
                .font(.veyaCaption2)
            Text("Veya only analyzes what you choose to share.")
                .font(.veyaCaption)
        }
        .foregroundStyle(Color.veyaTextTertiary)
    }

    // MARK: - Recent Guides
    private var recentGuidesSection: some View {
        VStack(alignment: .leading, spacing: VeyaSpacing.sm) {
            HStack {
                Text("Recent Guides")
                    .font(.veyaTitle3)
                    .foregroundStyle(Color.veyaTextPrimary)

                Spacer()

                Button("How Veya works") {
                    showHowItWorks = true
                }
                .font(.veyaCaption.weight(.medium))
                .foregroundStyle(Color.veyaAccent)
            }

            if viewModel.recentSessions.isEmpty {
                EmptyStateView(
                    systemImage: "doc.text.magnifyingglass",
                    title: "Your guides will appear here",
                    subtitle: "Share a screenshot and ask Veya a question to get started.",
                    actionTitle: "Ask Veya"
                ) {
                    analyzeViewModel.reset()
                    router.navigate(to: .analyze)
                }
                .background(Color.veyaCard)
                .clipShape(RoundedRectangle(cornerRadius: VeyaSpacing.cardCornerRadius))
            } else {
                VeyaCard(padding: 0) {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.recentSessions) { session in
                            RecentSessionRow(
                                session: session,
                                onTap: {
                                    if let response = session.guideResponse {
                                        analyzeViewModel.setImage(nil)
                                        analyzeViewModel.question = session.userQuestion
                                        analyzeViewModel.result = response
                                        analyzeViewModel.savedSession = session
                                        router.navigate(to: .result)
                                    }
                                },
                                onDelete: {
                                    viewModel.deleteSession(session)
                                }
                            )

                            if session.id != viewModel.recentSessions.last?.id {
                                Divider()
                                    .background(Color.veyaGlassBorder)
                                    .padding(.leading, 64)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Photo Loading
    private func loadPickedPhoto(_ item: PhotosPickerItem?) {
        guard let item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self) {
                #if canImport(UIKit)
                let image = UIImage(data: data)
                #elseif canImport(AppKit)
                let image = NSImage(data: data)
                #endif
                if let image {
                    analyzeViewModel.reset()
                    analyzeViewModel.setImage(image)
                    router.navigate(to: .analyze)
                }
            }
            photosItem = nil
        }
    }
}

// MARK: - How Veya Works Sheet
private struct HowVeyaWorksSheet: View {
    @Environment(\.dismiss) private var dismiss

    private let steps: [(String, String, String)] = [
        ("1", "Share an image", "Import a screenshot or photo — Veya never accesses your screen without you sharing it first."),
        ("2", "Ask your question", "Type or speak anything: \"What do I tap next?\", \"Explain this simply\", or \"Help me fix this\"."),
        ("3", "Get a visual guide", "Veya returns numbered annotations on your image and clear step-by-step instructions."),
        ("4", "Take action", "Choose from suggested next steps — each requires your tap to proceed.")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.veyaBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: VeyaSpacing.lg) {
                        ForEach(steps, id: \.0) { step in
                            HStack(alignment: .top, spacing: VeyaSpacing.md) {
                                ZStack {
                                    Circle()
                                        .fill(LinearGradient.veyaAccent)
                                        .frame(width: 32, height: 32)
                                    Text(step.0)
                                        .font(.veyaFootnote.weight(.bold))
                                        .foregroundStyle(.white)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(step.1)
                                        .font(.veyaHeadline)
                                        .foregroundStyle(Color.veyaTextPrimary)
                                    Text(step.2)
                                        .font(.veyaCallout)
                                        .foregroundStyle(Color.veyaTextSecondary)
                                }
                            }
                        }

                        PrivacyPromiseCard()
                    }
                    .padding(VeyaSpacing.screenPadding)
                }
            }
            .navigationTitle("How Veya Works")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.veyaAccent)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .environment(HomeViewModel(modelContext: try! ModelContainer(for: VeyaSession.self).mainContext))
    .environment(AnalyzeViewModel(guideService: MockGuideService(), modelContext: try! ModelContainer(for: VeyaSession.self).mainContext))
    .environment(AppRouter())
}
