import SwiftUI

struct LoadingStateView: View {
    let message: String
    @State private var dotCount = 0

    var body: some View {
        VStack(spacing: VeyaSpacing.lg) {
            VeyaOrbView(size: 80)

            Text(message)
                .font(.veyaCallout)
                .foregroundStyle(Color.veyaTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(VeyaSpacing.xl)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Veya Orb
struct VeyaOrbView: View {
    var size: CGFloat = 120
    @State private var pulse = false
    @State private var rotate = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            // Outer pulse ring
            Circle()
                .fill(RadialGradient.veyaOrbGlow(radius: size * 0.75))
                .frame(width: size * 1.5, height: size * 1.5)
                .scaleEffect(reduceMotion ? 1 : (pulse ? 1.12 : 0.95))
                .opacity(reduceMotion ? 0.5 : (pulse ? 0.4 : 0.6))

            // Mid glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.veyaAccent.opacity(0.55), Color.veyaMint.opacity(0.30), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.55
                    )
                )
                .frame(width: size, height: size)
                .scaleEffect(reduceMotion ? 1 : (pulse ? 1.06 : 0.98))

            // Core — the V mark
            ZStack {
                Circle()
                    .fill(LinearGradient.veyaAccentDiagonal)
                    .frame(width: size * 0.52, height: size * 0.52)

                // Lens flare highlight
                Ellipse()
                    .fill(Color.white.opacity(0.22))
                    .frame(width: size * 0.22, height: size * 0.12)
                    .offset(x: -size * 0.07, y: -size * 0.10)
                    .blur(radius: 2)

                Text("V")
                    .font(.system(size: size * 0.22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .rotationEffect(.degrees(reduceMotion ? 0 : (rotate ? 8 : -8)))
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                pulse = true
            }
            withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                rotate = true
            }
        }
        .accessibilityLabel("Veya orb")
        .accessibilityHidden(true)
    }
}

#Preview {
    VStack(spacing: 40) {
        VeyaOrbView(size: 120)
        LoadingStateView(message: "Veya is looking for the clearest next step…")
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.veyaBackground)
}
