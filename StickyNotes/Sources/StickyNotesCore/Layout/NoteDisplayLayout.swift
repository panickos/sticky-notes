import CoreGraphics

/// Visible bounds of connected displays for frame restoration (Spec 02).
public struct NoteDisplayLayout: Equatable, Sendable {
    public let visibleFrames: [CGRect]

    public init(visibleFrames: [CGRect]) {
        self.visibleFrames = visibleFrames
    }

    public static func v1(visibleFrames: [CGRect]) -> NoteDisplayLayout {
        NoteDisplayLayout(visibleFrames: visibleFrames)
    }

    /// First frame is treated as the primary display (matches `NSScreen.screens` ordering).
    public var primaryVisibleFrame: CGRect? {
        visibleFrames.first
    }
}
