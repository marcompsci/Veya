import SwiftUI

struct VoiceQuestionButton: View {
    let isRecording: Bool
    let onPressStart: () -> Void
    let onPressEnd: () -> Void

    @State private var isPressed = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: VeyaSpacing.sm) {
            ZStack {
                Circle()
                    .fill(Color.veyaError.opacity(isRecording ? 0.18 : 0))
                    .frame(width: 80, height: 80)
                    .scaleEffect(isRecording && !reduceMotion ? 1.3 : 1)
                    .animation(
                        isRecording ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true) : .default,
                        value: isRecording
                    )

                Circle()
                    .fill(
                        isRecording
                            ? LinearGradient(colors: [.veyaError, Color(red: 0.85, green: 0.25, blue: 0.25)], startPoint: .top, endPoint: .bottom)
                            : LinearGradient.veyaAccentDiagonal
                    )
                    .frame(width: 64, height: 64)
                    .scaleEffect(isPressed ? 0.92 : 1)
                    .shadow(color: (isRecording ? Color.veyaError : Color.veyaAccent).opacity(0.5), radius: 12)

                Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(.white)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                            veyaImpact(.medium)
                            onPressStart()
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                        veyaImpact(.light)
                        onPressEnd()
                    }
            )

            Text(isRecording ? "Recording — release to stop" : "Hold to speak")
                .font(.veyaCaption)
                .foregroundStyle(isRecording ? Color.veyaError : Color.veyaTextSecondary)
                .animation(.easeInOut(duration: 0.2), value: isRecording)
        }
        .accessibilityLabel(isRecording ? "Stop recording" : "Hold to record voice question")
        .accessibilityHint("Press and hold to speak your question")
    }
}

#Preview {
    HStack(spacing: 48) {
        VoiceQuestionButton(isRecording: false, onPressStart: {}, onPressEnd: {})
        VoiceQuestionButton(isRecording: true, onPressStart: {}, onPressEnd: {})
    }
    .padding()
    .background(Color.veyaBackground)
}
