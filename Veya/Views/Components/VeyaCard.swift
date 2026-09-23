import SwiftUI

struct VeyaCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = VeyaSpacing.cardPadding
    var cornerRadius: CGFloat = VeyaSpacing.cardCornerRadius

    init(
        padding: CGFloat = VeyaSpacing.cardPadding,
        cornerRadius: CGFloat = VeyaSpacing.cardCornerRadius,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(Color.veyaCard)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

struct VeyaGlassCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = VeyaSpacing.cardPadding

    init(padding: CGFloat = VeyaSpacing.cardPadding, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(.ultraThinMaterial)
            .background(Color.veyaGlass)
            .clipShape(RoundedRectangle(cornerRadius: VeyaSpacing.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: VeyaSpacing.cardCornerRadius)
                    .strokeBorder(Color.veyaGlassBorder, lineWidth: 1)
            )
    }
}
