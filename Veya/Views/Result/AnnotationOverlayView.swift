import SwiftUI

struct AnnotationOverlayView: View {
    let image: PlatformImage
    let annotations: [Annotation]
    let selectedAnnotationID: UUID?
    let onSelectAnnotation: (UUID) -> Void

    @State private var scale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastScale: CGFloat = 1
    @State private var lastOffset: CGSize = .zero
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { geo in
            let displaySize = imageDisplaySize(in: geo.size)
            let imageOffsetX = (geo.size.width - displaySize.width) / 2
            let imageOffsetY = (geo.size.height - displaySize.height) / 2

            ZStack(alignment: .topLeading) {
                Image(platformImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width, height: geo.size.height)

                ForEach(annotations) { annotation in
                    let rect = annotation.rect(in: displaySize)
                    let isSelected = annotation.id == selectedAnnotationID
                    let color = annotation.colorStyle.color

                    annotationView(
                        annotation: annotation,
                        rect: rect,
                        xOff: imageOffsetX,
                        yOff: imageOffsetY,
                        color: color,
                        isSelected: isSelected
                    )
                    .onTapGesture {
                        withAnimation(reduceMotion ? nil : .spring(duration: 0.25)) {
                            onSelectAnnotation(annotation.id)
                        }
                        veyaImpact(.light)
                    }
                }
            }
            .scaleEffect(scale)
            .offset(offset)
            .gesture(
                SimultaneousGesture(
                    MagnificationGesture()
                        .onChanged { value in
                            scale = min(max(lastScale * value, 1), 4)
                        }
                        .onEnded { _ in
                            lastScale = scale
                            if scale < 1.05 {
                                withAnimation { scale = 1; offset = .zero }
                                lastScale = 1; lastOffset = .zero
                            }
                        },
                    DragGesture()
                        .onChanged { value in
                            guard scale > 1 else { return }
                            offset = CGSize(
                                width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height
                            )
                        }
                        .onEnded { _ in lastOffset = offset }
                )
            )
        }
        .clipped()
    }

    @ViewBuilder
    private func annotationView(
        annotation: Annotation,
        rect: CGRect,
        xOff: CGFloat,
        yOff: CGFloat,
        color: Color,
        isSelected: Bool
    ) -> some View {
        let x = rect.minX + xOff
        let y = rect.minY + yOff
        let lineWidth: CGFloat = isSelected ? 2.5 : 1.8

        switch annotation.type {
        case .roundedRectangle:
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(color, lineWidth: lineWidth)
                .background(RoundedRectangle(cornerRadius: 8).fill(color.opacity(isSelected ? 0.20 : 0.08)))
                .frame(width: rect.width, height: rect.height)
                .position(x: x + rect.width / 2, y: y + rect.height / 2)
                .overlay(annotationLabel(annotation, x: x, y: y, color: color))

        case .circle:
            Ellipse()
                .strokeBorder(color, lineWidth: lineWidth)
                .background(Ellipse().fill(color.opacity(isSelected ? 0.20 : 0.08)))
                .frame(width: rect.width, height: rect.height)
                .position(x: x + rect.width / 2, y: y + rect.height / 2)
                .overlay(annotationLabel(annotation, x: x, y: y, color: color))

        case .arrow:
            ArrowShape()
                .fill(color)
                .frame(width: rect.width, height: rect.height)
                .position(x: x + rect.width / 2, y: y + rect.height / 2)

        case .label:
            Text(annotation.label)
                .font(.veyaCaption.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(color)
                .clipShape(Capsule())
                .position(x: x + rect.width / 2, y: y + rect.height / 2)
        }
    }

    @ViewBuilder
    private func annotationLabel(_ annotation: Annotation, x: CGFloat, y: CGFloat, color: Color) -> some View {
        if !annotation.label.isEmpty {
            Text(annotation.label)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(color)
                .clipShape(Circle())
                .position(x: x + 11, y: y + 11)
        }
    }

    private func imageDisplaySize(in containerSize: CGSize) -> CGSize {
        let imageAspect = image.size.width / image.size.height
        let containerAspect = containerSize.width / containerSize.height
        if imageAspect > containerAspect {
            return CGSize(width: containerSize.width, height: containerSize.width / imageAspect)
        } else {
            return CGSize(width: containerSize.height * imageAspect, height: containerSize.height)
        }
    }
}

// MARK: - Arrow Shape
private struct ArrowShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midX = rect.midX
        let w = rect.width
        let h = rect.height
        path.move(to: CGPoint(x: midX, y: rect.minY))
        path.addLine(to: CGPoint(x: midX + w * 0.4, y: rect.minY + h * 0.45))
        path.addLine(to: CGPoint(x: midX + w * 0.18, y: rect.minY + h * 0.45))
        path.addLine(to: CGPoint(x: midX + w * 0.18, y: rect.maxY))
        path.addLine(to: CGPoint(x: midX - w * 0.18, y: rect.maxY))
        path.addLine(to: CGPoint(x: midX - w * 0.18, y: rect.minY + h * 0.45))
        path.addLine(to: CGPoint(x: midX - w * 0.40, y: rect.minY + h * 0.45))
        path.closeSubpath()
        return path
    }
}
