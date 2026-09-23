import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void

    @State private var page = 0

    var body: some View {
        ZStack {
            LinearGradient.veyaBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $page) {
                    OnboardingPage1()
                        .tag(0)
                    OnboardingPage2()
                        .tag(1)
                    OnboardingPage3(onComplete: onComplete)
                        .tag(2)
                }
                .veyaPageTabStyle()
                .animation(.easeInOut, value: page)

                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Capsule()
                            .fill(index == page ? Color.veyaAccent : Color.veyaTextTertiary.opacity(0.4))
                            .frame(width: index == page ? 24 : 8, height: 8)
                            .animation(.spring(duration: 0.3), value: page)
                    }
                }
                .padding(.bottom, VeyaSpacing.xl)

                // Navigation arrows (pages 0 and 1)
                if page < 2 {
                    Button {
                        withAnimation { page += 1 }
                    } label: {
                        HStack(spacing: VeyaSpacing.xs) {
                            Text("Next")
                            Image(systemName: "chevron.right")
                        }
                        .font(.veyaHeadline)
                        .foregroundStyle(Color.veyaAccent)
                    }
                    .padding(.bottom, VeyaSpacing.xxl)
                    .accessibilityLabel("Next onboarding page")
                } else {
                    Spacer().frame(height: VeyaSpacing.xxl + 22)
                }
            }
        }
    }
}

// MARK: - Page 1: Meet Veya
private struct OnboardingPage1: View {
    var body: some View {
        VStack(spacing: VeyaSpacing.xl) {
            Spacer()

            VeyaOrbView(size: 140)

            VStack(spacing: VeyaSpacing.sm) {
                Text("Meet Veya")
                    .font(.veyaLargeTitle)
                    .foregroundStyle(Color.veyaTextPrimary)

                Text("A clearer way to understand\nwhat's on your screen.")
                    .font(.veyaTitle3)
                    .foregroundStyle(Color.veyaTextSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, VeyaSpacing.screenPadding)
    }
}

// MARK: - Page 2: Privacy
private struct OnboardingPage2: View {
    var body: some View {
        ScrollView {
            VStack(spacing: VeyaSpacing.xl) {
                Spacer().frame(height: VeyaSpacing.xl)

                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 56, weight: .light))
                    .foregroundStyle(LinearGradient.veyaAccent)

                VStack(spacing: VeyaSpacing.sm) {
                    Text("You choose\nwhat Veya sees")
                        .font(.veyaTitle)
                        .foregroundStyle(Color.veyaTextPrimary)
                        .multilineTextAlignment(.center)

                    Text("Veya only analyzes screenshots, photos, and questions you deliberately share.")
                        .font(.veyaCallout)
                        .foregroundStyle(Color.veyaTextSecondary)
                        .multilineTextAlignment(.center)
                }

                PrivacyPromiseCard()

                Spacer()
            }
            .padding(.horizontal, VeyaSpacing.screenPadding)
        }
    }
}

// MARK: - Page 3: Ask. See. Do.
private struct OnboardingPage3: View {
    let onComplete: () -> Void

    private let steps: [(String, String, String)] = [
        ("square.and.arrow.up", "Share", "Drop in a screenshot or image"),
        ("questionmark.bubble.fill", "Ask", "Type or speak your question"),
        ("sparkles", "See", "Get a clear visual guide")
    ]

    var body: some View {
        VStack(spacing: VeyaSpacing.xl) {
            Spacer()

            VStack(spacing: VeyaSpacing.sm) {
                Text("Ask. See. Do.")
                    .font(.veyaLargeTitle)
                    .foregroundStyle(Color.veyaTextPrimary)

                Text("Share a screen, ask a question,\nand get a visual next step.")
                    .font(.veyaCallout)
                    .foregroundStyle(Color.veyaTextSecondary)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: VeyaSpacing.md) {
                ForEach(steps, id: \.0) { step in
                    VStack(spacing: VeyaSpacing.sm) {
                        ZStack {
                            Circle()
                                .fill(Color.veyaCard)
                                .frame(width: 56, height: 56)
                            Image(systemName: step.0)
                                .font(.system(size: 22, weight: .medium))
                                .foregroundStyle(LinearGradient.veyaAccent)
                        }
                        Text(step.1)
                            .font(.veyaFootnote.weight(.semibold))
                            .foregroundStyle(Color.veyaTextPrimary)
                        Text(step.2)
                            .font(.veyaCaption2)
                            .foregroundStyle(Color.veyaTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            Spacer()

            VeyaButton("Continue to Veya", systemImage: "arrow.right", action: onComplete)
                .padding(.horizontal, VeyaSpacing.screenPadding)

            Spacer().frame(height: VeyaSpacing.lg)
        }
        .padding(.horizontal, VeyaSpacing.screenPadding)
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
