/// GFM markdown constructs required for sticky note v1 (Spec 03).
public enum StickyNoteMarkdownFeature: String, CaseIterable, Hashable, Sendable {
    case heading
    case emphasis
    case strong
    case unorderedList
    case orderedList
    case taskList
    case link
    case inlineCode
    case codeBlock
    case blockquote
}
