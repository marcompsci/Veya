import Testing
import Foundation
@testable import Veya

@Suite("GuideResponse JSON Decoding")
struct GuideResponseTests {

    @Test("Encodes and decodes a full GuideResponse round-trip")
    func roundTripCoding() throws {
        let original = GuideResponse.preview

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(GuideResponse.self, from: data)

        #expect(decoded.id == original.id)
        #expect(decoded.summary == original.summary)
        #expect(decoded.safetyNotice == original.safetyNotice)
        #expect(decoded.steps.count == original.steps.count)
        #expect(decoded.annotations.count == original.annotations.count)
        #expect(decoded.actionSuggestions.count == original.actionSuggestions.count)
    }

    @Test("Steps decode with correct ordering and content")
    func stepsDecodeCorrectly() throws {
        let original = GuideResponse.preview
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(GuideResponse.self, from: data)

        for (index, step) in decoded.steps.enumerated() {
            #expect(step.number == original.steps[index].number)
            #expect(step.title == original.steps[index].title)
            #expect(step.detail == original.steps[index].detail)
        }
    }

    @Test("Annotation type enum survives encoding")
    func annotationTypeCoding() throws {
        let annotation = Annotation(
            type: .roundedRectangle,
            normalizedX: 0.1, normalizedY: 0.2,
            normalizedWidth: 0.5, normalizedHeight: 0.1,
            label: "1",
            colorStyle: .accent
        )
        let data = try JSONEncoder().encode(annotation)
        let decoded = try JSONDecoder().decode(Annotation.self, from: data)
        #expect(decoded.type == .roundedRectangle)
        #expect(decoded.colorStyle == .accent)
    }

    @Test("ActionSuggestion actionType encodes correctly")
    func actionTypeCoding() throws {
        let suggestion = ActionSuggestion(
            title: "Test",
            subtitle: "Detail",
            systemImage: "star",
            actionType: .createNote
        )
        let data = try JSONEncoder().encode(suggestion)
        let decoded = try JSONDecoder().decode(ActionSuggestion.self, from: data)
        #expect(decoded.actionType == .createNote)
        #expect(decoded.requiresConfirmation == true)
    }

    @Test("MockGuideService returns deterministic preview response")
    func mockServiceDeterministic() async throws {
        let service = MockGuideService()
        let dummyData = Data([0x00])
        let result = try await service.createGuide(imageData: dummyData, userQuestion: "What do I tap next?")
        #expect(result.summary == GuideResponse.preview.summary)
        #expect(result.steps.count == GuideResponse.preview.steps.count)
        #expect(result.annotations.count == GuideResponse.preview.annotations.count)
    }
}
