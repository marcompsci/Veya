import Foundation
import Combine
import Speech

@MainActor
final class SpeechService: ObservableObject {
    @Published var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined

    private let recognizer = SFSpeechRecognizer(locale: .current)

    nonisolated func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    nonisolated func transcribe(url: URL) async throws -> String {
        guard let recognizer = SFSpeechRecognizer(locale: .current),
              recognizer.isAvailable else {
            throw VeyaError.permissionDenied("speech recognition")
        }

        let request = SFSpeechURLRecognitionRequest(url: url)
        request.shouldReportPartialResults = false

        return try await withCheckedThrowingContinuation { continuation in
            recognizer.recognitionTask(with: request) { result, error in
                if let result, result.isFinal {
                    continuation.resume(returning: result.bestTranscription.formattedString)
                } else if let error {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

/// Fallback used in previews and unit tests.
struct MockSpeechService {
    func mockTranscript() -> String {
        "What do I tap next?"
    }
}
