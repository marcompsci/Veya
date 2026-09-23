import Foundation
import SwiftUI
import SwiftData

@MainActor
@Observable
final class AnalyzeViewModel {
    var selectedImage: PlatformImage?
    var question: String = ""
    var isAnalyzing = false
    var result: GuideResponse?
    var savedSession: VeyaSession?
    var error: VeyaError?
    var isRecording = false
    var showSensitiveWarning = true

    private let guideService: any GuideService
    private let modelContext: ModelContext
    private let audioRecorder = AudioRecorder()
    private let speechService = SpeechService()

    var canCreateGuide: Bool {
        selectedImage != nil
            && !question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !isAnalyzing
    }

    init(guideService: any GuideService, modelContext: ModelContext) {
        self.guideService = guideService
        self.modelContext = modelContext
    }

    func setImage(_ image: PlatformImage?) {
        selectedImage = image
        result = nil
        error = nil
    }

    func applyPromptChip(_ chip: String) {
        question = chip
    }

    func reset() {
        selectedImage = nil
        question = ""
        result = nil
        savedSession = nil
        error = nil
        isRecording = false
        showSensitiveWarning = true
    }

    func startVoiceRecording() async {
        do {
            try await audioRecorder.startRecording()
            isRecording = true
        } catch let veyaError as VeyaError {
            error = veyaError
        } catch {
            self.error = .permissionDenied("microphone")
        }
    }

    func stopVoiceRecording() async {
        audioRecorder.stopRecording()
        isRecording = false

        guard let url = audioRecorder.capturedFileURL else { return }

        do {
            let transcript = try await speechService.transcribe(url: url)
            if !transcript.isEmpty {
                question = transcript
            }
        } catch {
            self.error = .permissionDenied("speech recognition")
        }

        audioRecorder.cleanUp()
    }

    func createGuide() async {
        guard canCreateGuide, let image = selectedImage else { return }

        let safetyService = ImageSafetyService()
        guard case .valid(let imageData) = safetyService.validate(image) else {
            error = .imageProcessingFailed
            return
        }

        isAnalyzing = true
        error = nil

        do {
            let response = try await guideService.createGuide(
                imageData: imageData,
                userQuestion: question
            )

            let session = VeyaSession(
                userQuestion: question,
                summary: response.summary
            )
            session.encode(response: response)
            modelContext.insert(session)
            try? modelContext.save()

            savedSession = session
            result = response
        } catch let veyaError as VeyaError {
            error = veyaError
        } catch {
            self.error = .analysisFailure(error.localizedDescription)
        }

        isAnalyzing = false
    }
}
