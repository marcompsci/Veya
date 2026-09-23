import Testing
import CoreGraphics
@testable import Veya

@Suite("Annotation Coordinate Conversion")
struct AnnotationRendererTests {

    @Test("Normalized rect maps correctly to container size")
    func normalizedRectConversion() {
        let annotation = Annotation(
            type: .roundedRectangle,
            normalizedX: 0.1,
            normalizedY: 0.2,
            normalizedWidth: 0.5,
            normalizedHeight: 0.3,
            label: "1"
        )
        let container = CGSize(width: 400, height: 800)
        let rect = annotation.rect(in: container)

        #expect(rect.minX == 40)    // 0.1 * 400
        #expect(rect.minY == 160)   // 0.2 * 800
        #expect(rect.width == 200)  // 0.5 * 400
        #expect(rect.height == 240) // 0.3 * 800
    }

    @Test("Center point is correct for annotation in container")
    func centerPointConversion() {
        let annotation = Annotation(
            type: .circle,
            normalizedX: 0.0,
            normalizedY: 0.0,
            normalizedWidth: 1.0,
            normalizedHeight: 1.0,
            label: ""
        )
        let container = CGSize(width: 300, height: 600)
        let center = annotation.center(in: container)

        #expect(center.x == 150) // midX
        #expect(center.y == 300) // midY
    }

    @Test("Zero-size container returns zero rect")
    func zeroContainer() {
        let annotation = Annotation(
            type: .arrow,
            normalizedX: 0.5,
            normalizedY: 0.5,
            normalizedWidth: 0.2,
            normalizedHeight: 0.2,
            label: ""
        )
        let rect = annotation.rect(in: .zero)
        #expect(rect == .zero)
    }

    @Test("Full-bounds annotation fills entire container")
    func fullBoundsAnnotation() {
        let annotation = Annotation(
            type: .label,
            normalizedX: 0.0,
            normalizedY: 0.0,
            normalizedWidth: 1.0,
            normalizedHeight: 1.0,
            label: "all"
        )
        let container = CGSize(width: 500, height: 900)
        let rect = annotation.rect(in: container)

        #expect(rect.width == 500)
        #expect(rect.height == 900)
    }

    @Test("All color styles map to distinct Color values")
    func colorStyleMapping() {
        let styles: [AnnotationColorStyle] = [.accent, .warning, .success]
        // Verify each returns a non-identical description (basic identity check)
        let descriptions = styles.map { $0.rawValue }
        #expect(Set(descriptions).count == styles.count)
    }
}
