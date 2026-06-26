/// Spec 09 automated and manual acceptance scenarios for note-to-note snapping.
public enum NoteSnapScenario: String, CaseIterable, Sendable {
    case sideSnapEngagement
    case cornerSnapEngagement
    case attractionZoneBoundary
    case releaseThreshold
    case tieBreak
    case resizeDraggedEdges
    case noSelfSnap
    case liveDragSnap
    case liveReleaseOverlap
    case liveResizeSnap
    case createDuplicateUnchanged
    case aerospaceDragResize
}

/// Configuration and resolver behaviors that automated tests verify before manual runs.
public enum NoteSnapVerificationPrerequisite: String, CaseIterable, Sendable {
    case tunedThresholds
    case sideSnapBehavior
    case cornerSnapBehavior
    case attractionZoneBoundary
    case releaseBehavior
    case tieBreakBehavior
    case resizeEdgeScope
    case noSelfSnap
}

public enum NoteSnapVerificationKind: String, Sendable {
    case automatedPrerequisite
    case manualAcceptance
}

/// One row in the Spec 09 acceptance matrix.
public struct NoteSnapAcceptanceCase: Equatable, Sendable {
    public let scenario: NoteSnapScenario
    public let userAction: String
    public let expectedBehavior: String
    public let verificationKind: NoteSnapVerificationKind
    public let configurationPrerequisites: [NoteSnapVerificationPrerequisite]

    public init(
        scenario: NoteSnapScenario,
        userAction: String,
        expectedBehavior: String,
        verificationKind: NoteSnapVerificationKind,
        configurationPrerequisites: [NoteSnapVerificationPrerequisite]
    ) {
        self.scenario = scenario
        self.userAction = userAction
        self.expectedBehavior = expectedBehavior
        self.verificationKind = verificationKind
        self.configurationPrerequisites = configurationPrerequisites
    }
}

/// Catalog of Spec 09 acceptance scenarios with expected behavior and prerequisite mapping.
public struct NoteSnapAcceptanceMatrix: Equatable, Sendable {
    public let cases: [NoteSnapAcceptanceCase]

    public init(cases: [NoteSnapAcceptanceCase]) {
        self.cases = cases
    }

    public var manualCases: [NoteSnapAcceptanceCase] {
        cases.filter { $0.verificationKind == .manualAcceptance }
    }

    public var automatedPrerequisiteCases: [NoteSnapAcceptanceCase] {
        cases.filter { $0.verificationKind == .automatedPrerequisite }
    }

    public static let v1 = NoteSnapAcceptanceMatrix(cases: [
        NoteSnapAcceptanceCase(
            scenario: .sideSnapEngagement,
            userAction: "Move a note edge within the attraction zone of a neighbor",
            expectedBehavior: "Side snap engages with a 2 pt gap and no overlap",
            verificationKind: .automatedPrerequisite,
            configurationPrerequisites: [.tunedThresholds, .sideSnapBehavior]
        ),
        NoteSnapAcceptanceCase(
            scenario: .cornerSnapEngagement,
            userAction: "Move a note corner within the attraction zone of a neighbor corner",
            expectedBehavior: "Corner snap aligns with a 2 pt gap on both axes",
            verificationKind: .automatedPrerequisite,
            configurationPrerequisites: [.tunedThresholds, .cornerSnapBehavior]
        ),
        NoteSnapAcceptanceCase(
            scenario: .attractionZoneBoundary,
            userAction: "Move a note edge beyond the attraction zone",
            expectedBehavior: "No snap engages; proposed frame is unchanged",
            verificationKind: .automatedPrerequisite,
            configurationPrerequisites: [.attractionZoneBoundary]
        ),
        NoteSnapAcceptanceCase(
            scenario: .releaseThreshold,
            userAction: "Drag more than the release threshold away from an engaged snap",
            expectedBehavior: "Snap releases and free movement (including overlap) is allowed",
            verificationKind: .automatedPrerequisite,
            configurationPrerequisites: [.releaseBehavior]
        ),
        NoteSnapAcceptanceCase(
            scenario: .tieBreak,
            userAction: "Present side and corner candidates at equal distance",
            expectedBehavior: "Closest candidate wins; side snap beats corner on ties",
            verificationKind: .automatedPrerequisite,
            configurationPrerequisites: [.tieBreakBehavior]
        ),
        NoteSnapAcceptanceCase(
            scenario: .resizeDraggedEdges,
            userAction: "Resize only the left edge near a neighbor",
            expectedBehavior: "Only dragged edges seek snap targets",
            verificationKind: .automatedPrerequisite,
            configurationPrerequisites: [.resizeEdgeScope]
        ),
        NoteSnapAcceptanceCase(
            scenario: .noSelfSnap,
            userAction: "Move the only note in the session",
            expectedBehavior: "Notes do not snap to themselves; single-note session unchanged",
            verificationKind: .automatedPrerequisite,
            configurationPrerequisites: [.noSelfSnap]
        ),
        NoteSnapAcceptanceCase(
            scenario: .liveDragSnap,
            userAction: "Drag a note header within the attraction zone of a neighbor",
            expectedBehavior: "Live snap during drag with a visible 2 pt gap",
            verificationKind: .manualAcceptance,
            configurationPrerequisites: []
        ),
        NoteSnapAcceptanceCase(
            scenario: .liveReleaseOverlap,
            userAction: "Drag past the release threshold from a snapped position",
            expectedBehavior: "Note moves freely; overlap is allowed",
            verificationKind: .manualAcceptance,
            configurationPrerequisites: []
        ),
        NoteSnapAcceptanceCase(
            scenario: .liveResizeSnap,
            userAction: "Resize the bottom or right edge near a neighbor",
            expectedBehavior: "Only the dragged edge snaps live during resize",
            verificationKind: .manualAcceptance,
            configurationPrerequisites: []
        ),
        NoteSnapAcceptanceCase(
            scenario: .createDuplicateUnchanged,
            userAction: "Create or duplicate a note",
            expectedBehavior: "Placement is unchanged — no automatic snapping",
            verificationKind: .manualAcceptance,
            configurationPrerequisites: []
        ),
        NoteSnapAcceptanceCase(
            scenario: .aerospaceDragResize,
            userAction: "Create, drag, or resize a note with AeroSpace active",
            expectedBehavior: "AeroSpace does not snap or retile the note (Spec 08 matrix row)",
            verificationKind: .manualAcceptance,
            configurationPrerequisites: []
        ),
    ])
}
