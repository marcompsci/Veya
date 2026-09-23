// Platform compatibility shim so the codebase compiles on iOS, macOS, and visionOS.
// On iOS/visionOS, PlatformImage = UIImage.
// On macOS, PlatformImage = NSImage.

#if canImport(UIKit)
import UIKit
public typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
public typealias PlatformImage = NSImage
#endif

import SwiftUI

extension Image {
    init(platformImage: PlatformImage) {
        #if canImport(UIKit)
        self.init(uiImage: platformImage)
        #elseif canImport(AppKit)
        self.init(nsImage: platformImage)
        #endif
    }
}

// Haptic feedback — no-op on macOS
func veyaImpact(_ style: VeyaHapticStyle = .light) {
    #if os(iOS)
    let generator: UIImpactFeedbackGenerator
    switch style {
    case .light:  generator = UIImpactFeedbackGenerator(style: .light)
    case .medium: generator = UIImpactFeedbackGenerator(style: .medium)
    }
    generator.impactOccurred()
    #endif
}

func veyaNotificationFeedback(_ type: VeyaNotificationStyle = .success) {
    #if os(iOS)
    let generator = UINotificationFeedbackGenerator()
    switch type {
    case .success: generator.notificationOccurred(.success)
    case .error:   generator.notificationOccurred(.error)
    }
    #endif
}

enum VeyaHapticStyle { case light, medium }
enum VeyaNotificationStyle { case success, error }
