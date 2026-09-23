import SwiftUI

struct ActionSuggestionCard: View {
    let suggestion: ActionSuggestion
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: VeyaSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient.veyaAccentDiagonal.opacity(0.2))
                        .frame(width: 44, height: 44)
                    Image(systemName: suggestion.systemImage)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(LinearGradient.veyaAccent)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(suggestion.title)
                        .font(.veyaSubheadline.weight(.semibold))
                        .foregroundStyle(Color.veyaTextPrimary)
                    Text(suggestion.subtitle)
                        .font(.veyaCaption)
                        .foregroundStyle(Color.veyaTextSecondary)
                }

                Spacer()

                Image(systemName: suggestion.requiresConfirmation ? "chevron.right" : "arrow.up.forward")
                    .font(.veyaCaption.weight(.semibold))
                    .foregroundStyle(Color.veyaTextTertiary)
            }
            .padding(VeyaSpacing.md)
            .background(Color.veyaCard)
            .clipShape(RoundedRectangle(cornerRadius: VeyaSpacing.cardCornerRadius))
        }
        .accessibilityLabel(suggestion.title)
        .accessibilityHint(suggestion.requiresConfirmation ? "Requires confirmation" : "")
    }
}
