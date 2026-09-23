import Foundation
import Combine
import AVFoundation

@MainActor
final class AudioRecorder: NSObject, ObservableObject {
    @Published var isRecording = false

    private var recorder: AVAudioRecorder?
    private(set) var capturedFileURL: URL?

    nonisolated func requestPermission() async -> Bool {
        #if os(iOS)
        return await AVAudioApplication.requestRecordPermission()
        #elseif os(macOS)
        return await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                continuation.resume(returning: granted)
            }
        }
        #else
        return false
        #endif
    }

    func startRecording() async throws {
        guard await requestPermission() else {
            throw VeyaError.permissionDenied("microphone")
        }

        #if os(iOS)
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .default)
        try audioSession.setActive(true)
        #endif

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("m4a")

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        recorder = try AVAudioRecorder(url: url, settings: settings)
        recorder?.record()
        capturedFileURL = url
        isRecording = true
    }

    func stopRecording() {
        recorder?.stop()
        recorder = nil
        isRecording = false
        #if os(iOS)
        try? AVAudioSession.sharedInstance().setActive(false)
        #endif
    }

    func cleanUp() {
        if let url = capturedFileURL {
            try? FileManager.default.removeItem(at: url)
            capturedFileURL = nil
        }
    }
}
