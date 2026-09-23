import SwiftUI

enum VeyaButtonVariant {
    case primary
    case secondary
    case destructive
    case ghost
}

struct VeyaButton: View {
    let title: String
    let systemImage: String?
    let variant: VeyaButtonVariant
    let isLoading: Bool
    let action: () -> Void

    init(
        _ title: String,
        systemImage: String? = nil,
        variant: VeyaButtonVariant = .primary,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.variant = variant
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: VeyaSpacing.xs) {
                if isLoading {
                    ProgressView()
                        .tint(foregroundColor)
                        .scaleEffect(0.85)
                } else if let systemImage {
                    Image(systemName: systemImage)
                        .font(.veyaSubheadline.weight(.semibold))
                }
                Text(title)
                    .font(.veyaHeadline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, VeyaSpacing.md)
            .background(backgroundContent)
            .foregroundStyle(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: VeyaSpacing.buttonCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: VeyaSpacing.buttonCornerRadius)
                    .strokeBorder(borderColor, lineWidth: variant == .ghost ? 1.5 : 0)
            )
        }
        .disabled(isLoading)
        .accessibilityLabel(title)
    }

    @ViewBuilder
    private var backgroundContent: some View {
        switch variant {
        case .primary:
            LinearGradient.veyaAccent
        case .secondary:
            Color.veyaCard
        case .destructive:
            Color.veyaError.opacity(0.18)
        case .ghost:
            Color.clear
        }
    }

    private var foregroundColor: Color {
        switch variant {
        case .primary:     return .white
        case .secondary:   return .veyaTextPrimary
        case .destructive: return .veyaError
        case .ghost:       return .veyaAccent
        }
    }

    private var borderColor: Color {
        variant == .ghost ? Color.veyaAccent.opacity(0.4) : .clear
    }
}

#Preview {
    VStack(spacing: VeyaSpacing.md) {
        VeyaButton("Create My Guide", systemImage: "sparkles") {}
        VeyaButton("Import a Screenshot", systemImage: "photo.on.rectangle", variant: .secondary) {}
        VeyaButton("Delete Guide", systemImage: "trash", variant: .destructive) {}
        VeyaButton("How Veya Works", variant: .ghost) {}
        VeyaButton("Analyzing…", isLoading: true) {}
    }
    .padding()
    .background(Color.veyaBackground)
}
