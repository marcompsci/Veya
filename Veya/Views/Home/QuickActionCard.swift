import SwiftUI

struct QuickActionCard: View {
    let systemImage: String
    let title: String
    let subtitle: String
    var isAccent: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: VeyaSpacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isAccent ? LinearGradient.veyaAccent : LinearGradient(colors: [Color.veyaCard], startPoint: .top, endPoint: .bottom))
                        .frame(width: 48, height: 48)
                    Image(systemName: systemImage)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(isAccent ? .white : .veyaAccent)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.veyaSubheadline.weight(.semibold))
                        .foregroundStyle(Color.veyaTextPrimary)
                    Text(subtitle)
                        .font(.veyaCaption)
                        .foregroundStyle(Color.veyaTextSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.veyaCaption.weight(.semibold))
                    .foregroundStyle(Color.veyaTextTertiary)
            }
            .padding(VeyaSpacing.md)
            .background(Color.veyaCard)
            .clipShape(RoundedRectangle(cornerRadius: VeyaSpacing.cardCornerRadius))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(subtitle)")
    }
}

#Preview {
    VStack(spacing: 12) {
        QuickActionCard(
            systemImage: "mic.fill",
            title: "Ask Veya",
            subtitle: "Speak or type a question",
            isAccent: true,
            action: {}
        )
        QuickActionCard(
            systemImage: "photo.on.rectangle",
            title: "Import a Screenshot",
            subtitle: "Pick from your photo library",
            action: {}
        )
    }
    .padding()
    .background(Color.veyaBackground)
}
