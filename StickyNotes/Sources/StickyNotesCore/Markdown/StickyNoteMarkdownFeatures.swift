/// Catalog of v1 markdown requirements and sample snippets for spike verification.
public enum StickyNoteMarkdownFeatures {
    public static let required: Set<StickyNoteMarkdownFeature> = Set(StickyNoteMarkdownFeature.allCases)

    /// Composite sample exercising every required feature in one note-sized document.
    public static let sampleDocument = """
        # Shopping

        Pick up **milk** and *bread* before the meeting.

        1. Check pantry
        2. Buy groceries

        - apples
        - [x] eggs
        - [ ] coffee

        See [store hours](https://example.com/hours) or use `brew list`.

        > Remember reusable bags.

        ```
        brew install sticky-notes
        ```
        """

    public static func sample(for feature: StickyNoteMarkdownFeature) -> String {
        switch feature {
        case .heading:
            "# Heading"
        case .emphasis:
            "*italic text*"
        case .strong:
            "**bold text**"
        case .unorderedList:
            "- item one\n- item two"
        case .orderedList:
            "1. first\n2. second"
        case .taskList:
            "- [x] done\n- [ ] pending"
        case .link:
            "[label](https://example.com)"
        case .inlineCode:
            "Use `code` here"
        case .codeBlock:
            """
            ```
            let x = 1
            ```
            """
        case .blockquote:
            "> quoted text"
        }
    }
}
