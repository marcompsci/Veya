import SwiftUI

// MARK: - Colors
extension Color {
    // Backgrounds — deep midnight navy
    static let veyaBackground      = Color(red: 0.05, green: 0.07, blue: 0.14)
    static let veyaSurface         = Color(red: 0.09, green: 0.12, blue: 0.21)
    static let veyaCard            = Color(red: 0.12, green: 0.16, blue: 0.27)
    static let veyaCardElevated    = Color(red: 0.15, green: 0.20, blue: 0.32)

    // Accent — electric lavender → mint
    static let veyaAccent          = Color(red: 0.61, green: 0.47, blue: 0.98)
    static let veyaMint            = Color(red: 0.36, green: 0.93, blue: 0.78)

    // Text
    static let veyaTextPrimary     = Color(red: 0.95, green: 0.95, blue: 0.98)
    static let veyaTextSecondary   = Color(red: 0.63, green: 0.66, blue: 0.78)
    static let veyaTextTertiary    = Color(red: 0.42, green: 0.45, blue: 0.58)

    // Semantic
    static let veyaWarning         = Color(red: 0.98, green: 0.77, blue: 0.35)
    static let veyaSuccess         = Color(red: 0.35, green: 0.93, blue: 0.60)
    static let veyaError           = Color(red: 0.98, green: 0.42, blue: 0.42)

    // Glass surface
    static let veyaGlass           = Color.white.opacity(0.06)
    static let veyaGlassBorder     = Color.white.opacity(0.10)
}

// MARK: - Gradients
extension LinearGradient {
    static let veyaAccent = LinearGradient(
        colors: [.veyaAccent, .veyaMint],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let veyaAccentDiagonal = LinearGradient(
        colors: [.veyaAccent, .veyaMint],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let veyaBackground = LinearGradient(
        colors: [Color(red: 0.05, green: 0.07, blue: 0.14),
                 Color(red: 0.08, green: 0.10, blue: 0.20)],
        startPoint: .top,
        endPoint: .bottom
    )
}

extension RadialGradient {
    static func veyaOrbGlow(radius: CGFloat) -> RadialGradient {
        RadialGradient(
            colors: [Color.veyaAccent.opacity(0.45), Color.veyaMint.opacity(0.20), .clear],
            center: .center,
            startRadius: 0,
            endRadius: radius
        )
    }
}
