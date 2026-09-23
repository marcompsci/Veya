import SwiftUI

struct SensitiveContentWarning: View {
    @Binding var isDismissed: Bool

    var body: some View {
        if !isDismissed {
            HStack(alignment: .top, spacing: VeyaSpacing.sm) {
                Image(systemName: "exclamationmark.shield")
                    .font(.veyaSubheadline)
                    .foregroundStyle(Color.veyaWarning)
                    .padding(.top, 1)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Before sharing")
                        .font(.veyaSubheadline.weight(.semibold))
                        .foregroundStyle(Color.veyaWarning)

                    Text("Remove passwords, private messages, payment details, or anything you do not want analyzed.")
                        .font(.veyaCaption)
                        .foregroundStyle(Color.veyaTextSecondary)
                }

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isDismissed = true
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.veyaCaption.weight(.semibold))
                        .foregroundStyle(Color.veyaTextTertiary)
                }
                .accessibilityLabel("Dismiss warning")
            }
            .padding(VeyaSpacing.md)
            .background(Color.veyaWarning.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: VeyaSpacing.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: VeyaSpacing.cardCornerRadius)
                    .strokeBorder(Color.veyaWarning.opacity(0.25), lineWidth: 1)
            )
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}
