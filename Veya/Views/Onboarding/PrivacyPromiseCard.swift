import SwiftUI

struct PrivacyPromise: Identifiable {
    let id = UUID()
    let systemImage: String
    let title: String
    let detail: String
}

private let promises: [PrivacyPromise] = [
    PrivacyPromise(
        systemImage: "eye.slash",
        title: "No background screen watching",
        detail: "Veya only sees what you deliberately share."
    ),
    PrivacyPromise(
        systemImage: "mic.slash",
        title: "No silent microphone recording",
        detail: "The microphone activates only when you hold the voice button."
    ),
    PrivacyPromise(
        systemImage: "trash",
        title: "Delete sessions whenever you want",
        detail: "Remove any guide and its data at any time from within the app."
    )
]

struct PrivacyPromiseCard: View {
    var body: some View {
        VeyaCard {
            VStack(alignment: .leading, spacing: VeyaSpacing.md) {
                Label("Veya's privacy promises", systemImage: "checkmark.shield.fill")
                    .font(.veyaHeadline)
                    .foregroundStyle(Color.veyaAccent)

                Divider()
                    .background(Color.veyaGlassBorder)

                ForEach(promises) { promise in
                    HStack(alignment: .top, spacing: VeyaSpacing.sm) {
                        Image(systemName: promise.systemImage)
                            .font(.veyaSubheadline)
                            .foregroundStyle(Color.veyaMint)
                            .frame(width: 24)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(promise.title)
                                .font(.veyaSubheadline.weight(.semibold))
                                .foregroundStyle(Color.veyaTextPrimary)
                            Text(promise.detail)
                                .font(.veyaCaption)
                                .foregroundStyle(Color.veyaTextSecondary)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    PrivacyPromiseCard()
        .padding()
        .background(Color.veyaBackground)
}
