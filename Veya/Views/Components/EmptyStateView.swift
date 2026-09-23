import SwiftUI

struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let subtitle: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: VeyaSpacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(Color.veyaTextTertiary)

            VStack(spacing: VeyaSpacing.xs) {
                Text(title)
                    .font(.veyaHeadline)
                    .foregroundStyle(Color.veyaTextPrimary)

                Text(subtitle)
                    .font(.veyaSubheadline)
                    .foregroundStyle(Color.veyaTextSecondary)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.veyaCallout.weight(.medium))
                    .foregroundStyle(Color.veyaAccent)
                    .padding(.top, VeyaSpacing.xs)
            }
        }
        .padding(VeyaSpacing.xl)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    EmptyStateView(
        systemImage: "doc.text.magnifyingglass",
        title: "Your guides will appear here",
        subtitle: "Share a screenshot and ask Veya a question to get started.",
        actionTitle: "Ask Veya",
        action: {}
    )
    .background(Color.veyaBackground)
}
