import Foundation
import SwiftUI

enum AnnotationType: String, Codable, CaseIterable, Hashable {
    case circle
    case roundedRectangle
    case arrow
    case label
}

enum AnnotationColorStyle: String, Codable, CaseIterable, Hashable {
    case accent
    case warning
    case success

    var color: Color {
        switch self {
        case .accent:  return .veyaAccent
        case .warning: return .veyaWarning
        case .success: return .veyaSuccess
        }
    }
}

struct Annotation: Codable, Identifiable, Equatable, Hashable {
    let id: UUID
    let type: AnnotationType
    let normalizedX: CGFloat
    let normalizedY: CGFloat
    let normalizedWidth: CGFloat
    let normalizedHeight: CGFloat
    let label: String
    let colorStyle: AnnotationColorStyle

    init(
        id: UUID = UUID(),
        type: AnnotationType,
        normalizedX: CGFloat,
        normalizedY: CGFloat,
        normalizedWidth: CGFloat,
        normalizedHeight: CGFloat,
        label: String,
        colorStyle: AnnotationColorStyle = .accent
    ) {
        self.id = id
        self.type = type
        self.normalizedX = normalizedX
        self.normalizedY = normalizedY
        self.normalizedWidth = normalizedWidth
        self.normalizedHeight = normalizedHeight
        self.label = label
        self.colorStyle = colorStyle
    }

    /// Converts normalized (0–1) coordinates to actual CGRect within a container.
    func rect(in containerSize: CGSize) -> CGRect {
        CGRect(
            x: normalizedX * containerSize.width,
            y: normalizedY * containerSize.height,
            width: normalizedWidth * containerSize.width,
            height: normalizedHeight * containerSize.height
        )
    }

    /// Center point in container coordinates.
    func center(in containerSize: CGSize) -> CGPoint {
        let r = rect(in: containerSize)
        return CGPoint(x: r.midX, y: r.midY)
    }
}
