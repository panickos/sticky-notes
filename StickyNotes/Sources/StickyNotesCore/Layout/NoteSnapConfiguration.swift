import CoreGraphics

/// Thresholds for note-to-note magnetic snapping (Spec 09).
public struct NoteSnapConfiguration: Equatable, Sendable {
    public let attractionZone: CGFloat
    public let snappedGap: CGFloat
    public let releaseThreshold: CGFloat

    public init(
        attractionZone: CGFloat,
        snappedGap: CGFloat,
        releaseThreshold: CGFloat
    ) {
        self.attractionZone = attractionZone
        self.snappedGap = snappedGap
        self.releaseThreshold = releaseThreshold
    }

    /// Manual polish tuning (2026-06-22): 12 pt attraction feels more magnetic than spec’s 5 pt;
    /// 15 pt release adds hysteresis so snap does not flicker off during small drag jitter.
    public static let v1 = NoteSnapConfiguration(
        attractionZone: 12,
        snappedGap: 2,
        releaseThreshold: 15
    )
}
