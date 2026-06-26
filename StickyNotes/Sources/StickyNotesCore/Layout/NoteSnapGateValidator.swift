import CoreGraphics
import Foundation

public struct NoteSnapPrerequisiteValidation: Equatable, Sendable {
    public let prerequisite: NoteSnapVerificationPrerequisite
    public let passes: Bool
    public let detail: String

    public init(
        prerequisite: NoteSnapVerificationPrerequisite,
        passes: Bool,
        detail: String
    ) {
        self.prerequisite = prerequisite
        self.passes = passes
        self.detail = detail
    }
}

/// Validates snap configuration and resolver smoke scenarios against Spec 09 automated prerequisites.
public enum NoteSnapGateValidator {
    public static func validate(
        configuration: NoteSnapConfiguration = .v1
    ) -> [NoteSnapPrerequisiteValidation] {
        NoteSnapVerificationPrerequisite.allCases.map { prerequisite in
            let passes = check(prerequisite, configuration: configuration)
            return NoteSnapPrerequisiteValidation(
                prerequisite: prerequisite,
                passes: passes,
                detail: detail(for: prerequisite, passes: passes)
            )
        }
    }

    public static func allPrerequisitesPass(
        configuration: NoteSnapConfiguration = .v1
    ) -> Bool {
        validate(configuration: configuration).allSatisfy(\.passes)
    }

    /// True when every automated Spec 09 scenario has passing prerequisites.
    public static func automatedSnapGatePasses(
        configuration: NoteSnapConfiguration = .v1
    ) -> Bool {
        let validations = validate(configuration: configuration)
        let passing = Set(validations.filter(\.passes).map(\.prerequisite))

        return NoteSnapAcceptanceMatrix.v1.automatedPrerequisiteCases.allSatisfy { caseItem in
            caseItem.configurationPrerequisites.allSatisfy { passing.contains($0) }
        }
    }

    private static func check(
        _ prerequisite: NoteSnapVerificationPrerequisite,
        configuration: NoteSnapConfiguration
    ) -> Bool {
        switch prerequisite {
        case .tunedThresholds:
            return configuration.attractionZone == NoteSnapConfiguration.v1.attractionZone
                && configuration.snappedGap == NoteSnapConfiguration.v1.snappedGap
                && configuration.releaseThreshold == NoteSnapConfiguration.v1.releaseThreshold
        case .sideSnapBehavior:
            return sideSnapSmokeTest(configuration: configuration)
        case .cornerSnapBehavior:
            return cornerSnapSmokeTest(configuration: configuration)
        case .attractionZoneBoundary:
            return attractionZoneSmokeTest(configuration: configuration)
        case .releaseBehavior:
            return releaseSmokeTest(configuration: configuration)
        case .tieBreakBehavior:
            return tieBreakSmokeTest(configuration: configuration)
        case .resizeEdgeScope:
            return resizeEdgeScopeSmokeTest(configuration: configuration)
        case .noSelfSnap:
            return noSelfSnapSmokeTest(configuration: configuration)
        }
    }

    private static func detail(
        for prerequisite: NoteSnapVerificationPrerequisite,
        passes: Bool
    ) -> String {
        if passes {
            return "Prerequisite satisfied: \(prerequisite.rawValue)"
        }
        return "Prerequisite failed: \(prerequisite.rawValue)"
    }

    // MARK: - Resolver smoke fixtures (mirrors StickyNoteSnapTests)

    private static func sideSnapSmokeTest(configuration: NoteSnapConfiguration) -> Bool {
        let target = smokeNote(id: 1, frame: NoteFrame(x: 100, y: 100, width: 200, height: 200))
        let moving = smokeNote(id: 2, frame: NoteFrame(x: 303, y: 120, width: 150, height: 150))
        let proposed = NoteFrame(x: 303, y: 120, width: 150, height: 150)

        let result = NoteSnapResolver.snappedFrame(
            proposed: proposed,
            noteID: moving.id,
            otherNotes: [target],
            configuration: configuration
        )

        guard result.engagement != nil else { return false }
        guard result.frame.x == target.frame.maxX + configuration.snappedGap else { return false }
        return framesDoNotOverlap(result.frame, target.frame)
    }

    private static func cornerSnapSmokeTest(configuration: NoteSnapConfiguration) -> Bool {
        let target = smokeNote(id: 1, frame: NoteFrame(x: 100, y: 100, width: 200, height: 200))
        let moving = smokeNote(id: 2, frame: NoteFrame(x: 303, y: 303, width: 120, height: 120))
        let proposed = NoteFrame(x: 303, y: 303, width: 120, height: 120)

        let result = NoteSnapResolver.snappedFrame(
            proposed: proposed,
            noteID: moving.id,
            otherNotes: [target],
            configuration: configuration
        )

        guard result.engagement != nil else { return false }
        return result.frame.x == target.frame.maxX + configuration.snappedGap
            && result.frame.y == target.frame.maxY + configuration.snappedGap
    }

    private static func attractionZoneSmokeTest(configuration: NoteSnapConfiguration) -> Bool {
        let target = smokeNote(id: 1, frame: NoteFrame(x: 100, y: 100, width: 200, height: 200))
        let moving = smokeNote(id: 2, frame: NoteFrame(x: 313, y: 120, width: 150, height: 150))
        let proposed = NoteFrame(
            x: target.frame.maxX + configuration.attractionZone + 1,
            y: 120,
            width: 150,
            height: 150
        )

        let result = NoteSnapResolver.snappedFrame(
            proposed: proposed,
            noteID: moving.id,
            otherNotes: [target],
            configuration: configuration
        )

        return result.frame == proposed && result.engagement == nil
    }

    private static func releaseSmokeTest(configuration: NoteSnapConfiguration) -> Bool {
        let target = smokeNote(id: 1, frame: NoteFrame(x: 100, y: 100, width: 200, height: 200))
        let moving = smokeNote(id: 2, frame: NoteFrame(x: 303, y: 120, width: 150, height: 150))
        let engaged = NoteSnapResolver.snappedFrame(
            proposed: NoteFrame(x: 303, y: 120, width: 150, height: 150),
            noteID: moving.id,
            otherNotes: [target],
            configuration: configuration
        )
        guard engaged.engagement != nil else { return false }

        let stillSnapped = NoteSnapResolver.snappedFrame(
            proposed: NoteFrame(
                x: target.frame.maxX + configuration.snappedGap + configuration.releaseThreshold - 1,
                y: 120,
                width: 150,
                height: 150
            ),
            noteID: moving.id,
            otherNotes: [target],
            configuration: configuration,
            previousEngagement: engaged.engagement
        )
        guard stillSnapped.engagement != nil else { return false }

        let released = NoteSnapResolver.snappedFrame(
            proposed: NoteFrame(
                x: target.frame.maxX + configuration.snappedGap + configuration.releaseThreshold + 1,
                y: 120,
                width: 150,
                height: 150
            ),
            noteID: moving.id,
            otherNotes: [target],
            configuration: configuration,
            previousEngagement: engaged.engagement
        )

        return released.engagement == nil
            && released.frame.x == target.frame.maxX + configuration.snappedGap + configuration.releaseThreshold + 1
    }

    private static func tieBreakSmokeTest(configuration: NoteSnapConfiguration) -> Bool {
        let target = smokeNote(id: 1, frame: NoteFrame(x: 100, y: 100, width: 200, height: 200))
        let moving = smokeNote(id: 2, frame: NoteFrame(x: 303, y: 300, width: 120, height: 120))
        let proposed = NoteFrame(x: 303, y: 300, width: 120, height: 120)

        let result = NoteSnapResolver.snappedFrame(
            proposed: proposed,
            noteID: moving.id,
            otherNotes: [target],
            configuration: configuration
        )

        return result.frame.x == target.frame.maxX + configuration.snappedGap
            && result.frame.y == proposed.y
            && result.engagement?.kind == .side(.left)
    }

    private static func resizeEdgeScopeSmokeTest(configuration: NoteSnapConfiguration) -> Bool {
        let target = smokeNote(id: 1, frame: NoteFrame(x: 100, y: 100, width: 200, height: 200))
        let moving = smokeNote(id: 2, frame: NoteFrame(x: 400, y: 120, width: 150, height: 150))
        let proposed = NoteFrame(x: 410, y: 120, width: 148, height: 150)

        let ignored = NoteSnapResolver.snappedFrame(
            proposed: proposed,
            noteID: moving.id,
            otherNotes: [target],
            configuration: configuration,
            resizeEdges: [.left]
        )
        guard ignored.frame == proposed && ignored.engagement == nil else { return false }

        let snapped = NoteSnapResolver.snappedFrame(
            proposed: NoteFrame(x: 50, y: 120, width: 49, height: 150),
            noteID: moving.id,
            otherNotes: [target],
            configuration: configuration,
            resizeEdges: [.right]
        )

        return snapped.engagement?.kind == .side(.right)
            && snapped.frame.maxX == target.frame.minX - configuration.snappedGap
    }

    private static func noSelfSnapSmokeTest(configuration: NoteSnapConfiguration) -> Bool {
        let only = smokeNote(id: 1, frame: NoteFrame(x: 100, y: 100, width: 200, height: 200))
        let proposed = NoteFrame(x: 140, y: 140, width: 200, height: 200)

        let selfSnap = NoteSnapResolver.snappedFrame(
            proposed: proposed,
            noteID: only.id,
            otherNotes: [only],
            configuration: configuration
        )
        let soloSnap = NoteSnapResolver.snappedFrame(
            proposed: proposed,
            noteID: only.id,
            otherNotes: [],
            configuration: configuration
        )

        return selfSnap.frame == proposed
            && selfSnap.engagement == nil
            && soloSnap.frame == proposed
            && soloSnap.engagement == nil
    }

    private static func smokeNote(id: Int, frame: NoteFrame) -> StickyNote {
        StickyNote(
            id: UUID(uuidString: "00000000-0000-0000-0000-\(String(format: "%012d", id))")!,
            content: "Note \(id)",
            frame: frame,
            color: .yellow,
            zIndex: id,
            createdAt: Date(timeIntervalSince1970: 1_700_000_000),
            updatedAt: Date(timeIntervalSince1970: 1_700_000_000)
        )
    }

    private static func framesDoNotOverlap(_ lhs: NoteFrame, _ rhs: NoteFrame) -> Bool {
        lhs.maxX <= rhs.minX
            || rhs.maxX <= lhs.minX
            || lhs.maxY <= rhs.minY
            || rhs.maxY <= lhs.minY
    }
}

private extension NoteFrame {
    var minX: CGFloat { x }
    var maxX: CGFloat { x + width }
    var minY: CGFloat { y }
    var maxY: CGFloat { y + height }
}
