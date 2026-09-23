import Foundation
import SwiftUI

struct ImageSafetyService {
    private let maxBytes = 20 * 1024 * 1024 // 20 MB

    func validate(_ image: PlatformImage) -> ImageValidationResult {
        #if canImport(UIKit)
        guard let data = image.jpegData(compressionQuality: 0.85) else {
            return .invalid(reason: "The image could not be read.")
        }
        #elseif canImport(AppKit)
        guard let tiff = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff),
              let data = bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.85]) else {
            return .invalid(reason: "The image could not be read.")
        }
        #endif
        guard data.count < maxBytes else {
            return .invalid(reason: "The image is too large. Please use a smaller screenshot.")
        }
        return .valid(data: data)
    }
}

enum ImageValidationResult {
    case valid(data: Data)
    case invalid(reason: String)
}
