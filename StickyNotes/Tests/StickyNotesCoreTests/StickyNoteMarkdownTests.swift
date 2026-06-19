import Foundation
import Testing
@testable import StickyNotesCore

@Suite("StickyNoteMarkdownFeatures — v1 GFM subset")
struct StickyNoteMarkdownFeaturesTests {
    @Test("catalog defines every required v1 feature")
    func requiredFeaturesAreCataloged() {
        let required: Set<StickyNoteMarkdownFeature> = [
            .heading,
            .emphasis,
            .strong,
            .unorderedList,
            .orderedList,
            .taskList,
            .link,
            .inlineCode,
            .codeBlock,
            .blockquote,
        ]
        #expect(StickyNoteMarkdownFeatures.required == required)
    }

    @Test("sample document exercises every required feature")
    func sampleDocumentCoversRequiredFeatures() {
        let detected = MarkdownStructureAnalyzer().detectedFeatures(
            in: StickyNoteMarkdownFeatures.sampleDocument
        )
        #expect(detected.isSuperset(of: StickyNoteMarkdownFeatures.required))
    }

    @Test("each feature has an isolated sample snippet")
    func featureSamplesAreIsolated() {
        for feature in StickyNoteMarkdownFeatures.required {
            let detected = MarkdownStructureAnalyzer().detectedFeatures(
                in: StickyNoteMarkdownFeatures.sample(for: feature)
            )
            #expect(detected.contains(feature), "Missing sample for \(feature)")
        }
    }
}

@Suite("MarkdownStructureAnalyzer — cmark-gfm parsing path")
struct MarkdownStructureAnalyzerTests {
    @Test("detects headings")
    func headings() {
        let features = MarkdownStructureAnalyzer().detectedFeatures(in: "# Title\n## Sub")
        #expect(features.contains(.heading))
    }

    @Test("detects emphasis and strong")
    func inlineStyles() {
        let features = MarkdownStructureAnalyzer().detectedFeatures(in: "*italic* and **bold**")
        #expect(features.contains(.emphasis))
        #expect(features.contains(.strong))
    }

    @Test("detects lists and task items")
    func lists() {
        let features = MarkdownStructureAnalyzer().detectedFeatures(
            in: """
            1. first
            2. second
            - bullet
            - [x] done
            - [ ] todo
            """
        )
        #expect(features.contains(.orderedList))
        #expect(features.contains(.unorderedList))
        #expect(features.contains(.taskList))
    }

    @Test("detects links and code")
    func linksAndCode() {
        let features = MarkdownStructureAnalyzer().detectedFeatures(
            in: """
            Visit [docs](https://example.com) and use `code`.

            ```
            let x = 1
            ```
            """
        )
        #expect(features.contains(.link))
        #expect(features.contains(.inlineCode))
        #expect(features.contains(.codeBlock))
    }

    @Test("detects blockquotes")
    func blockquotes() {
        let features = MarkdownStructureAnalyzer().detectedFeatures(in: "> quoted text")
        #expect(features.contains(.blockquote))
    }

    @Test("extracts plain text without markup")
    func plainTextExtraction() {
        let plain = MarkdownStructureAnalyzer().plainText(
            from: "# Title\n\n**bold** and [link](https://x.test)"
        )
        #expect(plain.contains("Title"))
        #expect(plain.contains("bold"))
        #expect(plain.contains("link"))
        #expect(!plain.contains("**"))
        #expect(!plain.contains("["))
    }
}

@Suite("Markdown parse performance — live-preview budget")
struct MarkdownParsePerformanceTests {
    @Test("parses typical note content within live-preview budget")
    func parseBudget() {
        let source = StickyNoteMarkdownFeatures.sampleDocument
        let iterations = 200
        let start = CFAbsoluteTimeGetCurrent()

        for _ in 0 ..< iterations {
            _ = MarkdownStructureAnalyzer().detectedFeatures(in: source)
        }

        let elapsedMs = (CFAbsoluteTimeGetCurrent() - start) * 1000
        let perKeystrokeMs = elapsedMs / Double(iterations)

        // Budget: < 2 ms per re-parse simulating a keystroke in a small note window.
        #expect(perKeystrokeMs < 2.0)
    }
}

@Suite("MarkdownLibraryEvaluation — spike decision criteria")
struct MarkdownLibraryEvaluationTests {
    @Test("MarkdownUI scores higher than raw cmark-gfm path for v1 needs")
    func evaluationRecommendsMarkdownUI() {
        let evaluation = MarkdownLibraryEvaluation.compare()
        #expect(evaluation.recommended == .markdownUI)
        #expect(evaluation.markdownUIScore > evaluation.cmarkGFMScore)
    }

    @Test("cmark-gfm path lacks SwiftUI renderer")
    func cmarkPathRequiresCustomRenderer() {
        let evaluation = MarkdownLibraryEvaluation.compare()
        #expect(evaluation.cmarkGFMPath.hasSwiftUIRenderer == false)
        #expect(evaluation.markdownUIPath.hasSwiftUIRenderer == true)
    }
}
