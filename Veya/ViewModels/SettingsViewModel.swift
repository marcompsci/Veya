import Foundation
import SwiftUI
import AVFoundation
import Speech
import SwiftData

enum ImageRetentionPolicy: String, CaseIterable, Identifiable {
    case dontSave          = "Don't save images"
    case deleteAfter24h    = "Delete images after 24 hours"
    case keepUntilDeleted  = "Keep until I delete"

    var id: String { rawValue }

    var detail: String {
        switch self {
        case .dontSave:
            return "Images are never stored on your device after analysis."
        case .deleteAfter24h:
            return "Images are automatically removed 24 hours after a guide is created."
        case .keepUntilDeleted:
            return "Images remain saved until you manually delete the guide."
        }
    }
}

// Cross-platform permission status summary
enum VeyaPermissionStatus {
    case granted, denied, notDetermined, restricted

    var label: String {
        switch self {
        case .granted:      return "Allowed"
        case .denied:       return "Denied — tap to open Settings"
        case .restricted:   return "Restricted by device policy"
        case .notDetermined: return "Not yet requested"
        }
    }

    var isDenied: Bool { self == .denied }
}

@MainActor
@Observable
final class SettingsViewModel {
    var microphoneStatus: VeyaPermissionStatus = .notDetermined
    var speechStatus: VeyaPermissionStatus = .notDetermined
    var showDeleteAllConfirmation = false
    var retentionPolicy: ImageRetentionPolicy = .dontSave

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func refreshPermissions() {
        microphoneStatus = currentMicrophoneStatus()
        speechStatus = currentSpeechStatus()
    }

    private func currentMicrophoneStatus() -> VeyaPermissionStatus {
        let avStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        switch avStatus {
        case .authorized:  return .granted
        case .denied:      return .denied
        case .restricted:  return .restricted
        default:           return .notDetermined
        }
    }

    private func currentSpeechStatus() -> VeyaPermissionStatus {
        switch SFSpeechRecognizer.authorizationStatus() {
        case .authorized:    return .granted
        case .denied:        return .denied
        case .restricted:    return .restricted
        default:             return .notDetermined
        }
    }

    func deleteAllGuides() {
        try? modelContext.delete(model: VeyaSession.self)
        try? modelContext.save()
    }

    func openSettings() {
        #if os(iOS)
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
        #elseif os(macOS)
        NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Library/PreferencePanes/Security.prefPane"))
        #endif
    }

    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}
