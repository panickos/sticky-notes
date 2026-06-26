/// macOS `.app` bundle identity and distribution metadata (Spec 05, Spec 08).
/// Release versions follow semantic versioning (`MAJOR.MINOR.PATCH`); bump before tagging.
public struct DistributionConfiguration: Equatable, Sendable {
    public static let v1 = DistributionConfiguration(
        bundleIdentifier: "dev.stickynotes.app",
        bundleName: "StickyNotes",
        bundleDisplayName: "Sticky Notes",
        bundleExecutable: "StickyNotes",
        bundleVersion: "1.0.0",
        bundleShortVersion: "1.0",
        isUIElement: true,
        minimumSystemVersion: "14.0",
        iconFileName: "AppIcon"
    )

    public let bundleIdentifier: String
    public let bundleName: String
    public let bundleDisplayName: String
    public let bundleExecutable: String
    public let bundleVersion: String
    public let bundleShortVersion: String
    public let isUIElement: Bool
    public let minimumSystemVersion: String
    public let iconFileName: String

    public init(
        bundleIdentifier: String,
        bundleName: String,
        bundleDisplayName: String,
        bundleExecutable: String,
        bundleVersion: String,
        bundleShortVersion: String,
        isUIElement: Bool,
        minimumSystemVersion: String,
        iconFileName: String
    ) {
        self.bundleIdentifier = bundleIdentifier
        self.bundleName = bundleName
        self.bundleDisplayName = bundleDisplayName
        self.bundleExecutable = bundleExecutable
        self.bundleVersion = bundleVersion
        self.bundleShortVersion = bundleShortVersion
        self.isUIElement = isUIElement
        self.minimumSystemVersion = minimumSystemVersion
        self.iconFileName = iconFileName
    }

    /// Optional AeroSpace `on-window-detected` snippet (Spec 08).
    public var aerospaceOnWindowDetectedSnippet: String {
        """
        [[on-window-detected]]
        if.app-id = '\(bundleIdentifier)'
        run = ['layout floating']
        """
    }
}
