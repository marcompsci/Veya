import SwiftUI

struct GuideStepCard: View {
    let step: GuideStep
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: VeyaSpacing.md) {
                ZStack {
                    Circle()
                        .fill(isSelected ? LinearGradient.veyaAccent : LinearGradient(colors: [Color.veyaCard], startPoint: .top, endPoint: .bottom))
                        .frame(width: 36, height: 36)
                    Text("\(step.number)")
                        .font(.veyaSubheadline.weight(.bold))
                        .foregroundStyle(isSelected ? .white : .veyaTextSecondary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(step.title)
                        .font(.veyaSubheadline.weight(.semibold))
                        .foregroundStyle(Color.veyaTextPrimary)
                    Text(step.detail)
                        .font(.veyaCaption)
                        .foregroundStyle(Color.veyaTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
            .padding(VeyaSpacing.md)
            .background(isSelected ? Color.veyaAccent.opacity(0.12) : Color.veyaCard)
            .clipShape(RoundedRectangle(cornerRadius: VeyaSpacing.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: VeyaSpacing.cardCornerRadius)
                    .strokeBorder(
                        isSelected ? Color.veyaAccent.opacity(0.5) : Color.clear,
                        lineWidth: 1.5
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Step \(step.number): \(step.title). \(step.detail)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    VStack(spacing: 12) {
        GuideStepCard(step: GuideStep(number: 1, title: "Tap the highlighted option", detail: "It is the most likely place to continue from this screen."), isSelected: true, action: {})
        GuideStepCard(step: GuideStep(number: 2, title: "Review the choices", detail: "Look for wording that matches your goal."), isSelected: false, action: {})
    }
    .padding()
    .background(Color.veyaBackground)
}
