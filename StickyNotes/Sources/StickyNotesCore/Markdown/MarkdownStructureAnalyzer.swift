import Markdown

/// Analyzes markdown source using swift-markdown (cmark-gfm) for structure detection and plain-text extraction.
public struct MarkdownStructureAnalyzer: Sendable {
    public init() {}

    public func detectedFeatures(in source: String) -> Set<StickyNoteMarkdownFeature> {
        let document = Document(parsing: source)
        var collector = FeatureCollector()
        collector.visit(document)
        return collector.features
    }

    public func plainText(from source: String) -> String {
        let document = Document(parsing: source)
        var extractor = PlainTextExtractor()
        extractor.visit(document)
        return extractor.text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private struct FeatureCollector: MarkupWalker {
    var features = Set<StickyNoteMarkdownFeature>()

    mutating func visitHeading(_ heading: Heading) {
        features.insert(.heading)
    }

    mutating func visitEmphasis(_ emphasis: Emphasis) {
        features.insert(.emphasis)
    }

    mutating func visitStrong(_ strong: Strong) {
        features.insert(.strong)
    }

    mutating func visitUnorderedList(_ unorderedList: UnorderedList) {
        features.insert(.unorderedList)
        descendInto(unorderedList)
    }

    mutating func visitOrderedList(_ orderedList: OrderedList) {
        features.insert(.orderedList)
        descendInto(orderedList)
    }

    mutating func visitListItem(_ listItem: ListItem) {
        if listItem.checkbox != nil {
            features.insert(.taskList)
        }
        descendInto(listItem)
    }

    mutating func visitLink(_ link: Link) {
        features.insert(.link)
    }

    mutating func visitInlineCode(_ inlineCode: InlineCode) {
        features.insert(.inlineCode)
    }

    mutating func visitCodeBlock(_ codeBlock: CodeBlock) {
        features.insert(.codeBlock)
    }

    mutating func visitBlockQuote(_ blockQuote: BlockQuote) {
        features.insert(.blockquote)
        descendInto(blockQuote)
    }
}

private struct PlainTextExtractor: MarkupWalker {
    var text = ""

    mutating func visitText(_ text: Text) {
        self.text += text.string
    }

    mutating func visitSoftBreak(_ softBreak: SoftBreak) {
        text += " "
    }

    mutating func visitLineBreak(_ lineBreak: LineBreak) {
        text += "\n"
    }

    mutating func visitParagraph(_ paragraph: Paragraph) {
        descendInto(paragraph)
        text += "\n"
    }

    mutating func visitHeading(_ heading: Heading) {
        descendInto(heading)
        text += "\n"
    }
}
