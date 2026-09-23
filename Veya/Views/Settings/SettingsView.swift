import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(SettingsViewModel.self) private var viewModel
    @Environment(AppRouter.self) private var router

    var body: some View {
        ZStack {
            Color.veyaBackground.ignoresSafeArea()

            List {
                accountSection
                dataSection
                permissionsSection
                aboutSection
            }
            .scrollContentBackground(.hidden)
            .veyaListStyle()
        }
        .navigationTitle("Settings")
        
        
        
        .onAppear { viewModel.refreshPermissions() }
        .confirmationDialog("Delete all guides?",
                            isPresented: Binding(
                                get: { viewModel.showDeleteAllConfirmation },
                                set: { viewModel.showDeleteAllConfirmation = $0 }
                            ),
                            titleVisibility: .visible) {
            Button("Delete All Guides", role: .destructive) { viewModel.deleteAllGuides() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("All guide steps and saved data will be permanently removed. This cannot be undone.")
        }
    }

    // MARK: - Account
    private var accountSection: some View {
        Section("Veya Account") {
            Label("Sign in or create account", systemImage: "person.circle")
                .foregroundStyle(Color.veyaTextSecondary)
                .listRowBackground(Color.veyaCard)
        }
    }

    // MARK: - Data
    private var dataSection: some View {
        Section {
            retentionPicker

            Button(role: .destructive) {
                viewModel.showDeleteAllConfirmation = true
            } label: {
                Label("Delete all guides", systemImage: "trash")
                    .foregroundStyle(Color.veyaError)
            }
            .listRowBackground(Color.veyaCard)

            Text("Deleting guides removes the question, summary, steps, and any stored images from your device. This cannot be undone.")
                .font(.veyaCaption)
                .foregroundStyle(Color.veyaTextTertiary)
                .listRowBackground(Color.clear)
        } header: {
            Text("Data")
        }
    }

    private var retentionPicker: some View {
        @Bindable var vm = viewModel
        return Picker("Image retention", selection: $vm.retentionPolicy) {
            ForEach(ImageRetentionPolicy.allCases) { policy in
                Text(policy.rawValue).tag(policy)
            }
        }
        .pickerStyle(.menu)
        .listRowBackground(Color.veyaCard)
        .foregroundStyle(Color.veyaTextPrimary)
        .tint(Color.veyaAccent)
    }

    // MARK: - Permissions
    private var permissionsSection: some View {
        Section("Permissions") {
            permissionRow(
                label: "Microphone",
                systemImage: "mic",
                status: viewModel.microphoneStatus.label,
                isDenied: viewModel.microphoneStatus.isDenied
            )

            permissionRow(
                label: "Speech Recognition",
                systemImage: "waveform",
                status: viewModel.speechStatus.label,
                isDenied: viewModel.speechStatus.isDenied
            )

            VStack(alignment: .leading, spacing: 4) {
                Label("Photos access", systemImage: "photo")
                    .font(.veyaBody)
                    .foregroundStyle(Color.veyaTextPrimary)
                Text("Veya uses the system photo picker so it never requires broad library access. Your full photo library is never visible to Veya.")
                    .font(.veyaCaption)
                    .foregroundStyle(Color.veyaTextTertiary)
            }
            .listRowBackground(Color.veyaCard)
        }
    }

    private func permissionRow(label: String, systemImage: String, status: String, isDenied: Bool) -> some View {
        Button {
            if isDenied { viewModel.openSettings() }
        } label: {
            HStack {
                Label(label, systemImage: systemImage)
                    .foregroundStyle(Color.veyaTextPrimary)
                Spacer()
                Text(status)
                    .font(.veyaCaption)
                    .foregroundStyle(isDenied ? Color.veyaError : Color.veyaTextTertiary)
                if isDenied {
                    Image(systemName: "arrow.up.right.square")
                        .font(.veyaCaption)
                        .foregroundStyle(Color.veyaAccent)
                }
            }
        }
        .listRowBackground(Color.veyaCard)
    }

    // MARK: - About
    private var aboutSection: some View {
        Section("About") {
            NavigationLink {
                PrivacyDetailView()
            } label: {
                Label("How Veya protects your privacy", systemImage: "hand.raised.fill")
                    .foregroundStyle(Color.veyaTextPrimary)
            }
            .listRowBackground(Color.veyaCard)

            Link(destination: URL(string: "https://yourdomain.com/terms")!) {
                Label("Terms of Use", systemImage: "doc.text")
                    .foregroundStyle(Color.veyaTextPrimary)
            }
            .listRowBackground(Color.veyaCard)

            Link(destination: URL(string: "https://yourdomain.com/privacy")!) {
                Label("Privacy Policy", systemImage: "lock.doc")
                    .foregroundStyle(Color.veyaTextPrimary)
            }
            .listRowBackground(Color.veyaCard)

            HStack {
                Text("Version")
                    .foregroundStyle(Color.veyaTextPrimary)
                Spacer()
                Text(viewModel.appVersion)
                    .foregroundStyle(Color.veyaTextTertiary)
            }
            .listRowBackground(Color.veyaCard)
        }
    }
}

// MARK: - Privacy Detail View
private struct PrivacyDetailView: View {
    private let points: [(String, String, String)] = [
        ("eye.slash", "No screen monitoring", "Veya never watches your screen in the background. Analysis only happens when you explicitly share an image."),
        ("mic.slash", "Microphone on demand only", "The microphone activates only while you hold the voice button. It stops the moment you release."),
        ("icloud.slash", "No data without consent", "Screenshots are processed for your guide. No raw image content is logged by default."),
        ("trash", "Full deletion control", "You can delete any guide — including its steps and any stored image — at any time."),
        ("lock.shield", "Encrypted transport", "All communication with Veya's servers uses encrypted HTTPS. API keys never live in this app.")
    ]

    var body: some View {
        ZStack {
            Color.veyaBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: VeyaSpacing.lg) {
                    ForEach(points, id: \.0) { point in
                        HStack(alignment: .top, spacing: VeyaSpacing.md) {
                            Image(systemName: point.0)
                                .font(.system(size: 22, weight: .medium))
                                .foregroundStyle(LinearGradient.veyaAccent)
                                .frame(width: 32)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(point.1)
                                    .font(.veyaHeadline)
                                    .foregroundStyle(Color.veyaTextPrimary)
                                Text(point.2)
                                    .font(.veyaCallout)
                                    .foregroundStyle(Color.veyaTextSecondary)
                            }
                        }
                    }
                }
                .padding(VeyaSpacing.screenPadding)
            }
        }
        .navigationTitle("Privacy")
        
        
        
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environment(SettingsViewModel(modelContext: try! ModelContainer(for: VeyaSession.self).mainContext))
    .environment(AppRouter())
}
