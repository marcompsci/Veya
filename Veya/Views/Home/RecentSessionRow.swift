import SwiftUI

struct RecentSessionRow: View {
    let session: VeyaSession
    let onTap: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: VeyaSpacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.veyaCard)
                        .frame(width: 44, height: 44)
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color.veyaAccent)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(session.userQuestion)
                        .font(.veyaSubheadline.weight(.medium))
                        .foregroundStyle(Color.veyaTextPrimary)
                        .lineLimit(1)

                    Text(session.summary)
                        .font(.veyaCaption)
                        .foregroundStyle(Color.veyaTextSecondary)
                        .lineLimit(2)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(session.formattedDate)
                        .font(.veyaCaption2)
                        .foregroundStyle(Color.veyaTextTertiary)
                    Image(systemName: "chevron.right")
                        .font(.veyaCaption2.weight(.semibold))
                        .foregroundStyle(Color.veyaTextTertiary)
                }
            }
            .padding(VeyaSpacing.sm)
            .contentShape(Rectangle())
        }
        .accessibilityLabel("Guide: \(session.userQuestion). \(session.formattedDate)")
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
