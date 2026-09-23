import SwiftUI
import PhotosUI

struct ImagePickerButton: View {
    let image: PlatformImage?
    let onImageSelected: (PlatformImage) -> Void

    @State private var photosItem: PhotosPickerItem?

    var body: some View {
        PhotosPicker(selection: $photosItem, matching: .images) {
            Group {
                if let image {
                    Image(platformImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: VeyaSpacing.cardCornerRadius))
                        .overlay(
                            RoundedRectangle(cornerRadius: VeyaSpacing.cardCornerRadius)
                                .strokeBorder(Color.veyaGlassBorder, lineWidth: 1)
                        )
                        .overlay(replaceLabel, alignment: .bottomTrailing)
                } else {
                    emptyPicker
                }
            }
        }
        .onChange(of: photosItem) { _, newItem in
            loadImage(from: newItem)
        }
        .accessibilityLabel(image == nil ? "Select an image" : "Replace the selected image")
    }

    private var emptyPicker: some View {
        VStack(spacing: VeyaSpacing.sm) {
            Image(systemName: "photo.badge.plus")
                .font(.system(size: 36, weight: .light))
                .foregroundStyle(Color.veyaAccent)
            Text("Tap to add a screenshot or image")
                .font(.veyaSubheadline)
                .foregroundStyle(Color.veyaTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 160)
        .background(Color.veyaCard)
        .clipShape(RoundedRectangle(cornerRadius: VeyaSpacing.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: VeyaSpacing.cardCornerRadius)
                .strokeBorder(Color.veyaAccent.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
        )
    }

    private var replaceLabel: some View {
        Label("Replace", systemImage: "arrow.triangle.2.circlepath")
            .font(.veyaCaption.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, VeyaSpacing.sm)
            .padding(.vertical, 5)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .padding(VeyaSpacing.sm)
    }

    private func loadImage(from item: PhotosPickerItem?) {
        guard let item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self) {
                #if canImport(UIKit)
                if let image = UIImage(data: data) {
                    onImageSelected(image)
                }
                #elseif canImport(AppKit)
                if let image = NSImage(data: data) {
                    onImageSelected(image)
                }
                #endif
            }
            photosItem = nil
        }
    }
}
