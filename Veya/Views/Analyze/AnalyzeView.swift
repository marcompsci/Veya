import SwiftUI
import SwiftData

struct AnalyzeView: View {
    @Environment(AnalyzeViewModel.self) private var viewModel
    @Environment(AppRouter.self) private var router

    private let promptChips = [
        "What do I tap next?",
        "Explain this simply",
        "What does this mean?",
        "Help me fix this"
    ]

    var body: some View {
        ZStack {
            LinearGradient.veyaBackground.ignoresSafeArea()

            if viewModel.isAnalyzing {
                analyzingOverlay
            } else {
                mainContent
            }
        }
        .navigationTitle("New Guide")
        
        
        
        .alert("Error", isPresented: Binding(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.error = nil } }
        )) {
            Button("OK") { viewModel.error = nil }
        } message: {
            Text(viewModel.error?.errorDescription ?? "Something went wrong. Please try again.")
        }
        .onChange(of: viewModel.result) { _, response in
            if response != nil { router.navigate(to: .result) }
        }
    }

    // MARK: - Main Content
    private var mainContent: some View {
        ScrollView {
            VStack(spacing: VeyaSpacing.lg) {
                SensitiveContentWarning(isDismissed: Binding(
                    get: { !viewModel.showSensitiveWarning },
                    set: { viewModel.showSensitiveWarning = !$0 }
                ))

                ImagePickerButton(image: viewModel.selectedImage) { image in
                    viewModel.setImage(image)
                }

                questionSection

                VoiceQuestionButton(
                    isRecording: viewModel.isRecording,
                    onPressStart: { Task { await viewModel.startVoiceRecording() } },
                    onPressEnd:   { Task { await viewModel.stopVoiceRecording() } }
                )

                VeyaButton(
                    "Create My Guide",
                    systemImage: "sparkles",
                    variant: viewModel.canCreateGuide ? .primary : .secondary
                ) {
                    Task { await viewModel.createGuide() }
                }
                .disabled(!viewModel.canCreateGuide)
                .accessibilityHint(viewModel.canCreateGuide ? "Double-tap to analyze your image" : "Add an image and a question first")
            }
            .padding(.horizontal, VeyaSpacing.screenPadding)
            .padding(.vertical, VeyaSpacing.lg)
        }
    }

    // MARK: - Question Section
    private var questionSection: some View {
        @Bindable var vm = viewModel

        return VStack(alignment: .leading, spacing: VeyaSpacing.sm) {
            Text("Your question")
                .font(.veyaSubheadline.weight(.semibold))
                .foregroundStyle(Color.veyaTextSecondary)

            TextField("Ask Veya anything about this screen…", text: $vm.question, axis: .vertical)
                .font(.veyaBody)
                .foregroundStyle(Color.veyaTextPrimary)
                .tint(.veyaAccent)
                .lineLimit(3...6)
                .padding(VeyaSpacing.md)
                .background(Color.veyaCard)
                .clipShape(RoundedRectangle(cornerRadius: VeyaSpacing.cardCornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: VeyaSpacing.cardCornerRadius)
                        .strokeBorder(
                            vm.question.isEmpty ? Color.veyaGlassBorder : Color.veyaAccent.opacity(0.4),
                            lineWidth: 1
                        )
                )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: VeyaSpacing.xs) {
                    ForEach(promptChips, id: \.self) { chip in
                        Button {
                            viewModel.applyPromptChip(chip)
                            veyaImpact(.light)
                        } label: {
                            Text(chip)
                                .font(.veyaCaption.weight(.medium))
                                .foregroundStyle(viewModel.question == chip ? .white : .veyaAccent)
                                .padding(.horizontal, VeyaSpacing.sm)
                                .padding(.vertical, 7)
                                .background(
                                    viewModel.question == chip
                                        ? LinearGradient.veyaAccent
                                        : LinearGradient(colors: [Color.veyaCard], startPoint: .top, endPoint: .bottom)
                                )
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule().strokeBorder(
                                        viewModel.question == chip ? Color.clear : Color.veyaAccent.opacity(0.35),
                                        lineWidth: 1
                                    )
                                )
                        }
                        .accessibilityLabel("Suggested question: \(chip)")
                    }
                }
            }
        }
    }

    // MARK: - Analyzing Overlay
    private var analyzingOverlay: some View {
        VStack(spacing: VeyaSpacing.xl) {
            Spacer()
            LoadingStateView(message: "Veya is looking for the clearest next step…")
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        AnalyzeView()
    }
    .environment(AnalyzeViewModel(guideService: MockGuideService(), modelContext: try! ModelContainer(for: VeyaSession.self).mainContext))
    .environment(AppRouter())
}
