import CoreGraphics
import Foundation
import Testing
@testable import StickyNotesCore

@Suite("NoteSnapConfiguration — Spec 09 thresholds")
struct NoteSnapConfigurationTests {
    @Test("v1 uses 12 pt attraction, 2 pt gap, and 15 pt release")
    func v1Thresholds() {
        let config = NoteSnapConfiguration.v1
        #expect(config.attractionZone == 12)
        #expect(config.snappedGap == 2)
        #expect(config.releaseThreshold == 15)
    }
}

@Suite("NoteSnapResolver — Spec 09 note-to-note snapping")
struct NoteSnapResolverTests {
    private let config = NoteSnapConfiguration.v1

    @Test("side snap engages within attraction zone with 2 pt gap and no overlap")
    func sideSnapEngagesWithinAttractionZone() {
        let target = makeNote(id: 1, frame: NoteFrame(x: 100, y: 100, width: 200, height: 200))
        let moving = makeNote(id: 2, frame: NoteFrame(x: 303, y: 120, width: 150, height: 150))
        let proposed = NoteFrame(x: 303, y: 120, width: 150, height: 150)

        let result = NoteSnapResolver.snappedFrame(
            proposed: proposed,
            noteID: moving.id,
            otherNotes: [target],
            configuration: config
        )

        #expect(result.frame.x == 302)
        #expect(result.frame.y == proposed.y)
        #expect(result.frame.width == proposed.width)
        #expect(result.frame.height == proposed.height)
        #expect(result.engagement != nil)
        #expect(framesDoNotOverlap(result.frame, target.frame))
        #expect(gapBetweenVerticalEdges(result.frame.minX, target.frame.maxX) == 2)
    }

    @Test("corner snap engages within attraction zone with 2 pt gap on both axes")
    func cornerSnapEngagesWithinAttractionZone() {
        let target = makeNote(id: 1, frame: NoteFrame(x: 100, y: 100, width: 200, height: 200))
        let moving = makeNote(id: 2, frame: NoteFrame(x: 303, y: 303, width: 120, height: 120))
        let proposed = NoteFrame(x: 303, y: 303, width: 120, height: 120)

        let result = NoteSnapResolver.snappedFrame(
            proposed: proposed,
            noteID: moving.id,
            otherNotes: [target],
            configuration: config
        )

        #expect(result.frame.x == 302)
        #expect(result.frame.y == 302)
        #expect(result.engagement != nil)
        #expect(gapBetweenVerticalEdges(result.frame.minX, target.frame.maxX) == 2)
        #expect(gapBetweenHorizontalEdges(result.frame.minY, target.frame.maxY) == 2)
    }

    @Test("no snap beyond attraction zone")
    func noSnapBeyondAttractionZone() {
        let target = makeNote(id: 1, frame: NoteFrame(x: 100, y: 100, width: 200, height: 200))
        let moving = makeNote(id: 2, frame: NoteFrame(x: 313, y: 120, width: 150, height: 150))
        let proposed = NoteFrame(x: 313, y: 120, width: 150, height: 150)

        let result = NoteSnapResolver.snappedFrame(
            proposed: proposed,
            noteID: moving.id,
            otherNotes: [target],
            configuration: config
        )

        #expect(result.frame == proposed)
        #expect(result.engagement == nil)
    }

    @Test("release after dragging more than release threshold from engaged snap position")
    func releaseAfterDraggingAway() {
        let target = makeNote(id: 1, frame: NoteFrame(x: 100, y: 100, width: 200, height: 200))
        let moving = makeNote(id: 2, frame: NoteFrame(x: 303, y: 120, width: 150, height: 150))
        let engaged = NoteSnapResolver.snappedFrame(
            proposed: NoteFrame(x: 303, y: 120, width: 150, height: 150),
            noteID: moving.id,
            otherNotes: [target],
            configuration: config
        )
        #expect(engaged.engagement != nil)

        let stillSnapped = NoteSnapResolver.snappedFrame(
            proposed: NoteFrame(x: 310, y: 120, width: 150, height: 150),
            noteID: moving.id,
            otherNotes: [target],
            configuration: config,
            previousEngagement: engaged.engagement
        )
        #expect(stillSnapped.frame.x == 302)
        #expect(stillSnapped.engagement != nil)

        let released = NoteSnapResolver.snappedFrame(
            proposed: NoteFrame(x: 318, y: 120, width: 150, height: 150),
            noteID: moving.id,
            otherNotes: [target],
            configuration: config,
            previousEngagement: engaged.engagement
        )

        #expect(released.frame == NoteFrame(x: 318, y: 120, width: 150, height: 150))
        #expect(released.engagement == nil)
    }

    @Test("side snap compares parallel edges only")
    func sideSnapIgnoresCrossAxisEdgeValues() {
        let target = makeNote(id: 1, frame: NoteFrame(x: 100, y: 100, width: 200, height: 100))
        let moving = makeNote(id: 2, frame: NoteFrame(x: 197, y: 120, width: 150, height: 50))
        let proposed = NoteFrame(x: 197, y: 120, width: 150, height: 50)

        let result = NoteSnapResolver.snappedFrame(
            proposed: proposed,
            noteID: moving.id,
            otherNotes: [target],
            configuration: config
        )

        #expect(result.frame == proposed)
        #expect(result.engagement == nil)
    }

    @Test("closest candidate wins and side beats corner on equal distance")
    func tieBreakPrefersSideOverCorner() {
        let target = makeNote(id: 1, frame: NoteFrame(x: 100, y: 100, width: 200, height: 200))
        let moving = makeNote(id: 2, frame: NoteFrame(x: 303, y: 300, width: 120, height: 120))
        let proposed = NoteFrame(x: 303, y: 300, width: 120, height: 120)

        let result = NoteSnapResolver.snappedFrame(
            proposed: proposed,
            noteID: moving.id,
            otherNotes: [target],
            configuration: config
        )

        #expect(result.frame.x == 302)
        #expect(result.frame.y == 300)
        #expect(result.engagement?.kind == .side(.left))
    }

    @Test("resize considers dragged edges only")
    func resizeConsidersDraggedEdgesOnly() {
        let target = makeNote(id: 1, frame: NoteFrame(x: 100, y: 100, width: 200, height: 200))
        let moving = makeNote(id: 2, frame: NoteFrame(x: 400, y: 120, width: 150, height: 150))
        let proposed = NoteFrame(x: 410, y: 120, width: 148, height: 150)

        let result = NoteSnapResolver.snappedFrame(
            proposed: proposed,
            noteID: moving.id,
            otherNotes: [target],
            configuration: config,
            resizeEdges: [.left]
        )

        #expect(result.frame == proposed)
        #expect(result.engagement == nil)
    }

    @Test("resize snaps dragged right edge within attraction zone from outside")
    func resizeSnapsDraggedRightEdge() {
        let target = makeNote(id: 1, frame: NoteFrame(x: 100, y: 100, width: 200, height: 200))
        let moving = makeNote(id: 2, frame: NoteFrame(x: 50, y: 120, width: 48, height: 150))
        let proposed = NoteFrame(x: 50, y: 120, width: 49, height: 150)

        let result = NoteSnapResolver.snappedFrame(
            proposed: proposed,
            noteID: moving.id,
            otherNotes: [target],
            configuration: config,
            resizeEdges: [.right]
        )

        #expect(result.frame.x == 49)
        #expect(result.frame.width == 49)
        #expect(result.frame.maxX == 98)
        #expect(result.engagement?.kind == .side(.right))
    }

    @Test("snap re-engages when shadow returns to attraction zone after release")
    func snapReEngagesAfterReleaseWithinSameGesture() {
        let target = makeNote(id: 1, frame: NoteFrame(x: 100, y: 100, width: 200, height: 200))
        let moving = makeNote(id: 2, frame: NoteFrame(x: 303, y: 120, width: 150, height: 150))
        let engaged = NoteSnapResolver.snappedFrame(
            proposed: NoteFrame(x: 303, y: 120, width: 150, height: 150),
            noteID: moving.id,
            otherNotes: [target],
            configuration: config
        )
        #expect(engaged.engagement != nil)

        let released = NoteSnapResolver.snappedFrame(
            proposed: NoteFrame(x: 318, y: 120, width: 150, height: 150),
            noteID: moving.id,
            otherNotes: [target],
            configuration: config,
            previousEngagement: engaged.engagement
        )
        #expect(released.engagement == nil)
        #expect(released.frame.x == 318)

        let reEngaged = NoteSnapResolver.snappedFrame(
            proposed: NoteFrame(x: 310, y: 120, width: 150, height: 150),
            noteID: moving.id,
            otherNotes: [target],
            configuration: config,
            previousEngagement: released.engagement
        )

        #expect(reEngaged.frame.x == 302)
        #expect(reEngaged.engagement != nil)
    }

    @Test("snap switches to a closer neighbor during the same gesture")
    func snapSwitchesToCloserNeighbor() {
        let left = makeNote(id: 1, frame: NoteFrame(x: 100, y: 100, width: 200, height: 200))
        let right = makeNote(
            id: 2,
            frame: NoteFrame(x: 520, y: 100, width: 200, height: 200)
        )
        let moving = makeNote(id: 3, frame: NoteFrame(x: 303, y: 120, width: 150, height: 150))

        let snappedLeft = NoteSnapResolver.snappedFrame(
            proposed: NoteFrame(x: 303, y: 120, width: 150, height: 150),
            noteID: moving.id,
            otherNotes: [left, right],
            configuration: config
        )
        #expect(snappedLeft.frame.x == 302)

        let snappedRight = NoteSnapResolver.snappedFrame(
            proposed: NoteFrame(x: 368, y: 120, width: 150, height: 150),
            noteID: moving.id,
            otherNotes: [left, right],
            configuration: config,
            previousEngagement: snappedLeft.engagement
        )
        #expect(snappedRight.frame.x == 368)
        #expect(snappedRight.frame.maxX == 518)
        #expect(snappedRight.engagement?.kind == .side(.right))
    }

    @Test("side snap engages bottom-to-top from outside with 2 pt gap")
    func sideSnapEngagesBottomToTopFromOutside() {
        let target = makeNote(id: 1, frame: NoteFrame(x: 100, y: 100, width: 200, height: 200))
        let moving = makeNote(id: 2, frame: NoteFrame(x: 120, y: 303, width: 150, height: 150))
        let proposed = NoteFrame(x: 120, y: 303, width: 150, height: 150)

        let result = NoteSnapResolver.snappedFrame(
            proposed: proposed,
            noteID: moving.id,
            otherNotes: [target],
            configuration: config
        )

        #expect(result.frame.y == 302)
        #expect(result.frame.x == proposed.x)
        #expect(result.engagement?.kind == .side(.bottom))
        #expect(framesDoNotOverlap(result.frame, target.frame))
        #expect(gapBetweenHorizontalEdges(result.frame.minY, target.frame.maxY) == 2)
    }

    @Test("side snap engages top-to-bottom from outside with 2 pt gap")
    func sideSnapEngagesTopToBottomFromOutside() {
        let target = makeNote(id: 1, frame: NoteFrame(x: 100, y: 100, width: 200, height: 200))
        let moving = makeNote(id: 2, frame: NoteFrame(x: 120, y: 50, width: 150, height: 48))
        let proposed = NoteFrame(x: 120, y: 50, width: 150, height: 48)

        let result = NoteSnapResolver.snappedFrame(
            proposed: proposed,
            noteID: moving.id,
            otherNotes: [target],
            configuration: config
        )

        #expect(result.frame.maxY == 98)
        #expect(result.frame.x == proposed.x)
        #expect(result.engagement?.kind == .side(.top))
        #expect(framesDoNotOverlap(result.frame, target.frame))
        #expect(target.frame.minY - result.frame.maxY == 2)
    }

    @Test("side snap does not engage from the inside of a neighbor edge")
    func sideSnapDoesNotEngageFromInside() {
        let target = makeNote(id: 1, frame: NoteFrame(x: 100, y: 100, width: 200, height: 200))
        let moving = makeNote(id: 2, frame: NoteFrame(x: 290, y: 120, width: 40, height: 150))
        let proposed = NoteFrame(x: 290, y: 120, width: 40, height: 150)

        let leftEdgeResult = NoteSnapResolver.snappedFrame(
            proposed: proposed,
            noteID: moving.id,
            otherNotes: [target],
            configuration: config
        )

        #expect(leftEdgeResult.frame == proposed)
        #expect(leftEdgeResult.engagement == nil)

        let rightEdgeOverlap = makeNote(
            id: 3,
            frame: NoteFrame(x: 80, y: 120, width: 230, height: 150)
        )
        let rightProposed = NoteFrame(x: 80, y: 120, width: 230, height: 150)

        let rightEdgeResult = NoteSnapResolver.snappedFrame(
            proposed: rightProposed,
            noteID: rightEdgeOverlap.id,
            otherNotes: [target],
            configuration: config
        )

        #expect(rightEdgeResult.frame == rightProposed)
        #expect(rightEdgeResult.engagement == nil)

        let bottomEdgeOverlap = makeNote(
            id: 4,
            frame: NoteFrame(x: 120, y: 290, width: 150, height: 40)
        )
        let bottomProposed = NoteFrame(x: 120, y: 290, width: 150, height: 40)

        let bottomEdgeResult = NoteSnapResolver.snappedFrame(
            proposed: bottomProposed,
            noteID: bottomEdgeOverlap.id,
            otherNotes: [target],
            configuration: config
        )

        #expect(bottomEdgeResult.frame == bottomProposed)
        #expect(bottomEdgeResult.engagement == nil)

        let topEdgeOverlap = makeNote(
            id: 5,
            frame: NoteFrame(x: 120, y: 90, width: 150, height: 40)
        )
        let topProposed = NoteFrame(x: 120, y: 90, width: 150, height: 40)

        let topEdgeResult = NoteSnapResolver.snappedFrame(
            proposed: topProposed,
            noteID: topEdgeOverlap.id,
            otherNotes: [target],
            configuration: config
        )

        #expect(topEdgeResult.frame == topProposed)
        #expect(topEdgeResult.engagement == nil)
    }

    @Test("notes do not snap to themselves and single-note session is unchanged")
    func ignoresSelfAndSingleNoteSession() {
        let only = makeNote(id: 1, frame: NoteFrame(x: 100, y: 100, width: 200, height: 200))
        let proposed = NoteFrame(x: 140, y: 140, width: 200, height: 200)

        let selfSnap = NoteSnapResolver.snappedFrame(
            proposed: proposed,
            noteID: only.id,
            otherNotes: [only],
            configuration: config
        )
        let soloSnap = NoteSnapResolver.snappedFrame(
            proposed: proposed,
            noteID: only.id,
            otherNotes: [],
            configuration: config
        )

        #expect(selfSnap.frame == proposed)
        #expect(selfSnap.engagement == nil)
        #expect(soloSnap.frame == proposed)
        #expect(soloSnap.engagement == nil)
    }
}

private extension NoteFrame {
    var minX: CGFloat { x }
    var maxX: CGFloat { x + width }
    var minY: CGFloat { y }
    var maxY: CGFloat { y + height }
}

private func makeNote(id: Int, frame: NoteFrame) -> StickyNote {
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

private func framesDoNotOverlap(_ lhs: NoteFrame, _ rhs: NoteFrame) -> Bool {
    lhs.maxX <= rhs.minX
        || rhs.maxX <= lhs.minX
        || lhs.maxY <= rhs.minY
        || rhs.maxY <= lhs.minY
}

private func gapBetweenVerticalEdges(_ movingMinX: CGFloat, _ targetMaxX: CGFloat) -> CGFloat {
    movingMinX - targetMaxX
}

private func gapBetweenHorizontalEdges(_ movingMinY: CGFloat, _ targetMaxY: CGFloat) -> CGFloat {
    movingMinY - targetMaxY
}
