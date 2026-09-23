import SwiftUI
import SwiftData

struct ResultView: View {
    @Environment(AnalyzeViewModel.self) private var analyzeViewModel
    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel: ResultViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                ResultContentView(viewModel: vm, onFollowUp: goToFollowUp)
                    .onChange(of: vm.isDeleted) { _, deleted in
                        if deleted { router.popToRoot() }
                    }
            } else {
                Color.veyaBackground.ignoresSafeArea()
                    .onAppear { buildViewModel() }
            }
        }
        .onAppear { buildViewModel() }
        .navigationBarBackButtonHidden()
        
        
    }

    private func buildViewModel() {
        guard viewModel == nil, let response = analyzeViewModel.result else { return }
        viewModel = ResultViewModel(
            response: response,
            image: analyzeViewModel.selectedImage,
            session: analyzeViewModel.savedSession,
            modelContext: modelContext
        )
    }

    private func goToFollowUp() {
        let currentImage = analyzeViewModel.selectedImage
        analyzeViewModel.reset()
        if let image = currentImage { analyzeViewModel.setImage(image) }
        router.pop()
    }
}

// MARK: - Content View
private struct ResultContentView: View {
    @Bindable var viewModel: ResultViewModel
    let onFollowUp: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            LinearGradient.veyaBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: VeyaSpacing.lg) {
                    imageSection
                    summarySection
                    stepsSection
                    actionsSection
                    footerButtons
                }
                .padding(.bottom, VeyaSpacing.xxxl)
            }
        }
        .navigationTitle("Your Guide")
        
        .toolbar { toolbarItems }
        .confirmationDialog("Delete this guide?",
                            isPresented: $viewModel.showDeleteConfirmation,
                            titleVisibility: .visible) {
            Button("Delete Guide", role: .destructive) { viewModel.deleteSession() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("The guide steps and any saved data will be removed.")
        }
        .confirmationDialog(
            "Confirm action?",
            isPresented: Binding(
                get: { viewModel.showActionConfirmation != nil },
                set: { if !$0 { viewModel.showActionConfirmation = nil } }
            ),
            titleVisibility: .visible
        ) {
            if let action = viewModel.showActionConfirmation {
                Button(action.title) { executeAction(action) }
                Button("Cancel", role: .cancel) {}
            }
        } message: {
            Text(viewModel.showActionConfirmation?.subtitle ?? "")
        }
    }


    // MARK: - Image Section
    private var imageSection: some View {
        Group {
            if let image = viewModel.image {
                AnnotationOverlayView(
                    image: image,
                    annotations: viewModel.response.annotations,
                    selectedAnnotationID: viewModel.selectedAnnotationID,
                    onSelectAnnotation: { id in
                        withAnimation(reduceMotion ? nil : .spring(duration: 0.25)) {
                            viewModel.selectAnnotation(id: id)
                        }
                    }
                )
                .frame(height: 280)
                .clipShape(RoundedRectangle(cornerRadius: VeyaSpacing.cardCornerRadius))
                .padding(.horizontal, VeyaSpacing.screenPadding)
            }
        }
    }

    // MARK: - Summary Section
    private var summarySection: some View {
        VStack(alignment: .leading, spacing: VeyaSpacing.sm) {
            Text("Veya's read.")
                .font(.veyaCaption.weight(.semibold))
                .foregroundStyle(Color.veyaAccent)
                .textCase(.uppercase)
                .tracking(1)

            Text(viewModel.response.summary)
                .font(.veyaTitle3)
                .foregroundStyle(Color.veyaTextPrimary)

            if let notice = viewModel.response.safetyNotice {
                HStack(alignment: .top, spacing: VeyaSpacing.xs) {
                    Image(systemName: "info.circle.fill")
                        .font(.veyaCaption)
                        .foregroundStyle(Color.veyaWarning)
                        .padding(.top, 2)
                    Text(notice)
                        .font(.veyaCaption)
                        .foregroundStyle(Color.veyaTextSecondary)
                }
                .padding(VeyaSpacing.sm)
                .background(Color.veyaWarning.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(.horizontal, VeyaSpacing.screenPadding)
    }

    // MARK: - Steps Section
    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: VeyaSpacing.sm) {
            Text("Steps")
                .font(.veyaTitle3)
                .foregroundStyle(Color.veyaTextPrimary)
                .padding(.horizontal, VeyaSpacing.screenPadding)

            ForEach(Array(viewModel.response.steps.enumerated()), id: \.element.id) { index, step in
                GuideStepCard(
                    step: step,
                    isSelected: viewModel.selectedStepIndex == index
                ) {
                    withAnimation(reduceMotion ? nil : .spring(duration: 0.25)) {
                        viewModel.selectStep(at: index)
                    }
                }
                .padding(.horizontal, VeyaSpacing.screenPadding)
            }
        }
    }

    // MARK: - Actions Section
    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: VeyaSpacing.sm) {
            Text("Helpful next actions")
                .font(.veyaTitle3)
                .foregroundStyle(Color.veyaTextPrimary)
                .padding(.horizontal, VeyaSpacing.screenPadding)

            ForEach(viewModel.response.actionSuggestions) { suggestion in
                ActionSuggestionCard(suggestion: suggestion) {
                    if suggestion.requiresConfirmation {
                        viewModel.showActionConfirmation = suggestion
                    } else {
                        executeAction(suggestion)
                    }
                }
                .padding(.horizontal, VeyaSpacing.screenPadding)
            }
        }
    }

    // MARK: - Footer Buttons
    private var footerButtons: some View {
        VStack(spacing: VeyaSpacing.sm) {
            VeyaButton("Ask a follow-up", systemImage: "arrow.uturn.left", variant: .secondary, action: onFollowUp)
            VeyaButton("Delete guide", systemImage: "trash", variant: .destructive) {
                viewModel.showDeleteConfirmation = true
            }
        }
        .padding(.horizontal, VeyaSpacing.screenPadding)
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .automatic) {
            ShareLink(item: viewModel.guideShareText()) {
                Image(systemName: "square.and.arrow.up")
                    .foregroundStyle(Color.veyaAccent)
            }
            .accessibilityLabel("Share guide")
        }
    }

    // MARK: - Action Execution
    private func executeAction(_ suggestion: ActionSuggestion) {
        switch suggestion.actionType {
        case .shareGuide:
            break // ShareLink in toolbar handles sharing
        case .copyText:
            #if os(iOS)
            UIPasteboard.general.string = viewModel.guideShareText()
            #elseif os(macOS)
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(viewModel.guideShareText(), forType: .string)
            #endif
            veyaNotificationFeedback(.success)
        case .openSettings:
            #if os(iOS)
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
            #endif
        case .createNote, .createReminder, .openMaps:
            veyaNotificationFeedback(.success)
        }
        viewModel.showActionConfirmation = nil
    }
}


#Preview {
    NavigationStack {
        ResultView()
    }
    .environment(
        {
            let vm = AnalyzeViewModel(guideService: MockGuideService(), modelContext: try! ModelContainer(for: VeyaSession.self).mainContext)
            vm.result = .preview
            return vm
        }()
    )
    .environment(AppRouter())
}
