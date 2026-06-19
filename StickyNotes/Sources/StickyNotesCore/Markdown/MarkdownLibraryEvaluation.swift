/// Spike evaluation comparing MarkdownUI vs a raw cmark-gfm (swift-markdown) integration path.
public enum MarkdownLibraryChoice: String, Sendable {
    case markdownUI
    case cmarkGFM
}

public struct MarkdownLibraryPath: Equatable, Sendable {
    public let name: String
    public let hasSwiftUIRenderer: Bool
    public let gfmCompatible: Bool
    public let livePreviewEffort: Int
    public let integrationScore: Int

    public init(
        name: String,
        hasSwiftUIRenderer: Bool,
        gfmCompatible: Bool,
        livePreviewEffort: Int,
        integrationScore: Int
    ) {
        self.name = name
        self.hasSwiftUIRenderer = hasSwiftUIRenderer
        self.gfmCompatible = gfmCompatible
        self.livePreviewEffort = livePreviewEffort
        self.integrationScore = integrationScore
    }

    public var totalScore: Int {
        var score = integrationScore
        if hasSwiftUIRenderer { score += 3 }
        if gfmCompatible { score += 2 }
        score -= livePreviewEffort
        return score
    }
}

public struct MarkdownLibraryEvaluation: Equatable, Sendable {
    public let recommended: MarkdownLibraryChoice
    public let markdownUIPath: MarkdownLibraryPath
    public let cmarkGFMPath: MarkdownLibraryPath
    public let markdownUIScore: Int
    public let cmarkGFMScore: Int
    public let rationale: String

    public static func compare() -> MarkdownLibraryEvaluation {
        let markdownUI = MarkdownLibraryPath(
            name: "MarkdownUI (gonzalezreal/swift-markdown-ui)",
            hasSwiftUIRenderer: true,
            gfmCompatible: true,
            livePreviewEffort: 1,
            integrationScore: 5
        )

        let cmarkGFM = MarkdownLibraryPath(
            name: "swift-markdown / cmark-gfm (parser only)",
            hasSwiftUIRenderer: false,
            gfmCompatible: true,
            livePreviewEffort: 5,
            integrationScore: 3
        )

        let markdownUIScore = markdownUI.totalScore
        let cmarkGFMScore = cmarkGFM.totalScore
        let recommended: MarkdownLibraryChoice = markdownUIScore >= cmarkGFMScore ? .markdownUI : .cmarkGFM

        return MarkdownLibraryEvaluation(
            recommended: recommended,
            markdownUIPath: markdownUI,
            cmarkGFMPath: cmarkGFM,
            markdownUIScore: markdownUIScore,
            cmarkGFMScore: cmarkGFMScore,
            rationale: """
            MarkdownUI provides native SwiftUI GFM rendering (built on cmark) with minimal \
            live-preview wiring. The raw cmark-gfm path via swift-markdown parses correctly but \
            requires a custom SwiftUI renderer for v1 preview — higher effort with no rendering gain.
            """
        )
    }
}
