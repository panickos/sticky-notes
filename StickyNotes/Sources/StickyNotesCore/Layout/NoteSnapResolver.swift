import CoreGraphics
import Foundation

public struct NoteSnapEngagement: Equatable, Sendable {
    public enum Kind: Equatable, Sendable {
        case side(NoteSnapEdge)
        case corner(NoteSnapCorner)
    }

    public let kind: Kind
    public let resultingFrame: NoteFrame

    public init(kind: Kind, resultingFrame: NoteFrame) {
        self.kind = kind
        self.resultingFrame = resultingFrame
    }
}

public struct NoteSnapResult: Equatable, Sendable {
    public let frame: NoteFrame
    public let engagement: NoteSnapEngagement?

    public init(frame: NoteFrame, engagement: NoteSnapEngagement?) {
        self.frame = frame
        self.engagement = engagement
    }
}

public struct NoteSnapResizeEdges: OptionSet, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let left = NoteSnapResizeEdges(rawValue: 1 << 0)
    public static let right = NoteSnapResizeEdges(rawValue: 1 << 1)
    public static let bottom = NoteSnapResizeEdges(rawValue: 1 << 2)
    public static let top = NoteSnapResizeEdges(rawValue: 1 << 3)
}

public enum NoteSnapEdge: CaseIterable, Equatable, Sendable {
    case left
    case right
    case bottom
    case top
}

public enum NoteSnapCorner: CaseIterable, Equatable, Sendable {
    case bottomLeft
    case bottomRight
    case topLeft
    case topRight
}

/// Resolves magnetic snap targets for note move and resize gestures (Spec 09).
public enum NoteSnapResolver {
    public static func snappedFrame(
        proposed: NoteFrame,
        noteID: UUID,
        otherNotes: [StickyNote],
        configuration: NoteSnapConfiguration = .v1,
        previousEngagement: NoteSnapEngagement? = nil,
        resizeEdges: NoteSnapResizeEdges? = nil
    ) -> NoteSnapResult {
        let neighbors = otherNotes.filter { $0.id != noteID }
        guard !neighbors.isEmpty else {
            return NoteSnapResult(frame: proposed, engagement: nil)
        }

        if let previousEngagement, !shouldRelease(
            proposed: proposed,
            engagement: previousEngagement,
            threshold: configuration.releaseThreshold
        ) {
            let locked = lockedFrame(
                proposed: proposed,
                engagement: previousEngagement,
                resizeEdges: resizeEdges
            )
            return NoteSnapResult(frame: locked, engagement: previousEngagement)
        }

        guard let candidate = bestCandidate(
            proposed: proposed,
            neighbors: neighbors,
            configuration: configuration,
            resizeEdges: resizeEdges
        ) else {
            return NoteSnapResult(frame: proposed, engagement: nil)
        }

        let engagement = NoteSnapEngagement(
            kind: candidate.kind,
            resultingFrame: candidate.frame
        )
        return NoteSnapResult(frame: candidate.frame, engagement: engagement)
    }

    public static func resizeEdges(from previous: NoteFrame, to proposed: NoteFrame) -> NoteSnapResizeEdges {
        var edges: NoteSnapResizeEdges = []
        if proposed.x != previous.x {
            edges.insert(.left)
        }
        if proposed.maxX != previous.maxX {
            edges.insert(.right)
        }
        if proposed.y != previous.y {
            edges.insert(.bottom)
        }
        if proposed.maxY != previous.maxY {
            edges.insert(.top)
        }
        return edges
    }

    private struct Candidate {
        let kind: NoteSnapEngagement.Kind
        let frame: NoteFrame
        let distance: CGFloat
        let isSide: Bool
    }

    private static func bestCandidate(
        proposed: NoteFrame,
        neighbors: [StickyNote],
        configuration: NoteSnapConfiguration,
        resizeEdges: NoteSnapResizeEdges?
    ) -> Candidate? {
        var candidates: [Candidate] = []

        for neighbor in neighbors {
            candidates.append(
                contentsOf: sideCandidates(
                    proposed: proposed,
                    target: neighbor.frame,
                    configuration: configuration,
                    resizeEdges: resizeEdges
                )
            )
            candidates.append(
                contentsOf: cornerCandidates(
                    proposed: proposed,
                    target: neighbor.frame,
                    configuration: configuration,
                    resizeEdges: resizeEdges
                )
            )
        }

        return candidates.min { lhs, rhs in
            if lhs.distance != rhs.distance {
                return lhs.distance < rhs.distance
            }
            if lhs.isSide != rhs.isSide {
                return lhs.isSide
            }
            return candidateOrder(lhs) < candidateOrder(rhs)
        }
    }

    private static func candidateOrder(_ candidate: Candidate) -> Int {
        switch candidate.kind {
        case .side(let edge):
            switch edge {
            case .left: 0
            case .right: 1
            case .bottom: 2
            case .top: 3
            }
        case .corner(let corner):
            switch corner {
            case .bottomLeft: 4
            case .bottomRight: 5
            case .topLeft: 6
            case .topRight: 7
            }
        }
    }

    private static func sideCandidates(
        proposed: NoteFrame,
        target: NoteFrame,
        configuration: NoteSnapConfiguration,
        resizeEdges: NoteSnapResizeEdges?
    ) -> [Candidate] {
        let movingEdges = eligibleSideEdges(resizeEdges: resizeEdges)
        var candidates: [Candidate] = []

        for movingEdge in movingEdges {
            for (targetEdge, snappedValue) in outsideSideTargets(
                for: movingEdge,
                target: target,
                gap: configuration.snappedGap
            ) {
                let movingValue = proposed.edgeValue(movingEdge)
                let targetValue = target.edgeValue(targetEdge)
                let distance = abs(movingValue - targetValue)

                guard distance <= configuration.attractionZone else { continue }
                guard canApproachSideSnap(
                    proposed: proposed,
                    target: target,
                    movingEdge: movingEdge,
                    targetEdge: targetEdge,
                    zone: configuration.attractionZone
                ) else { continue }
                guard perpendicularOverlap(
                    proposed: proposed,
                    target: target,
                    movingEdge: movingEdge
                ) else { continue }

                let snappedFrame = proposed.withEdge(movingEdge, value: snappedValue)
                guard !framesOverlap(snappedFrame, target) else { continue }

                candidates.append(
                    Candidate(
                        kind: .side(movingEdge),
                        frame: snappedFrame,
                        distance: distance,
                        isSide: true
                    )
                )
            }
        }

        return candidates
    }

    private static func cornerCandidates(
        proposed: NoteFrame,
        target: NoteFrame,
        configuration: NoteSnapConfiguration,
        resizeEdges: NoteSnapResizeEdges?
    ) -> [Candidate] {
        var candidates: [Candidate] = []

        for movingCorner in NoteSnapCorner.allCases {
            guard cornerIsEligible(movingCorner, resizeEdges: resizeEdges) else { continue }

            let movingPoint = proposed.cornerPoint(movingCorner)

            for (targetCorner, snappedPoint) in outsideCornerTargets(
                for: movingCorner,
                target: target,
                gap: configuration.snappedGap
            ) {
                let targetPoint = target.cornerPoint(targetCorner)
                let distance = hypot(movingPoint.x - targetPoint.x, movingPoint.y - targetPoint.y)
                guard distance <= configuration.attractionZone else { continue }
                guard canApproachCornerSnap(
                    proposed: proposed,
                    target: target,
                    movingCorner: movingCorner,
                    targetCorner: targetCorner,
                    zone: configuration.attractionZone
                ) else { continue }

                let snappedFrame = proposed.withCorner(movingCorner, point: snappedPoint)
                guard !framesOverlap(snappedFrame, target) else { continue }

                candidates.append(
                    Candidate(
                        kind: .corner(movingCorner),
                        frame: snappedFrame,
                        distance: distance,
                        isSide: false
                    )
                )
            }
        }

        return candidates
    }

    /// Outside snap positions for each moving edge relative to a target edge.
    private static func outsideSideTargets(
        for movingEdge: NoteSnapEdge,
        target: NoteFrame,
        gap: CGFloat
    ) -> [(NoteSnapEdge, CGFloat)] {
        switch movingEdge {
        case .left:
            [
                (.right, target.maxX + gap),
                (.left, target.minX - gap),
            ]
        case .right:
            [
                (.left, target.minX - gap),
                (.right, target.maxX + gap),
            ]
        case .bottom:
            [
                (.top, target.maxY + gap),
                (.bottom, target.minY - gap),
            ]
        case .top:
            [
                (.bottom, target.minY - gap),
                (.top, target.maxY + gap),
            ]
        }
    }

    private static func canApproachSideSnap(
        proposed: NoteFrame,
        target: NoteFrame,
        movingEdge: NoteSnapEdge,
        targetEdge: NoteSnapEdge,
        zone: CGFloat
    ) -> Bool {
        switch (movingEdge, targetEdge) {
        case (.right, .left):
            return proposed.maxX <= target.minX + zone && proposed.maxX <= target.minX
        case (.left, .right):
            return proposed.minX >= target.maxX - zone && proposed.minX >= target.maxX
        case (.left, .left):
            return proposed.maxX <= target.minX + zone && proposed.minX <= target.minX
        case (.right, .right):
            return proposed.minX >= target.maxX - zone && proposed.maxX >= target.maxX
        case (.bottom, .top):
            return proposed.minY >= target.maxY - zone && proposed.minY >= target.maxY
        case (.top, .bottom):
            return proposed.maxY <= target.minY + zone && proposed.maxY <= target.minY
        case (.bottom, .bottom):
            return proposed.maxY <= target.minY + zone && proposed.minY <= target.minY
        case (.top, .top):
            return proposed.minY >= target.maxY - zone && proposed.maxY >= target.maxY
        default:
            return false
        }
    }

    private static func outsideCornerTargets(
        for movingCorner: NoteSnapCorner,
        target: NoteFrame,
        gap: CGFloat
    ) -> [(NoteSnapCorner, CGPoint)] {
        switch movingCorner {
        case .bottomLeft:
            [
                (.bottomRight, CGPoint(x: target.maxX + gap, y: target.minY - gap)),
                (.topLeft, CGPoint(x: target.minX - gap, y: target.maxY + gap)),
                (.topRight, CGPoint(x: target.maxX + gap, y: target.maxY + gap)),
                (.bottomLeft, CGPoint(x: target.minX - gap, y: target.minY - gap)),
            ]
        case .bottomRight:
            [
                (.bottomLeft, CGPoint(x: target.minX - gap, y: target.minY - gap)),
                (.topRight, CGPoint(x: target.maxX + gap, y: target.maxY + gap)),
                (.topLeft, CGPoint(x: target.minX - gap, y: target.maxY + gap)),
                (.bottomRight, CGPoint(x: target.maxX + gap, y: target.minY - gap)),
            ]
        case .topLeft:
            [
                (.topRight, CGPoint(x: target.maxX + gap, y: target.maxY + gap)),
                (.bottomLeft, CGPoint(x: target.minX - gap, y: target.minY - gap)),
                (.bottomRight, CGPoint(x: target.maxX + gap, y: target.minY - gap)),
                (.topLeft, CGPoint(x: target.minX - gap, y: target.maxY + gap)),
            ]
        case .topRight:
            [
                (.topLeft, CGPoint(x: target.minX - gap, y: target.maxY + gap)),
                (.bottomRight, CGPoint(x: target.maxX + gap, y: target.minY - gap)),
                (.bottomLeft, CGPoint(x: target.minX - gap, y: target.minY - gap)),
                (.topRight, CGPoint(x: target.maxX + gap, y: target.maxY + gap)),
            ]
        }
    }

    private static func canApproachCornerSnap(
        proposed: NoteFrame,
        target: NoteFrame,
        movingCorner: NoteSnapCorner,
        targetCorner: NoteSnapCorner,
        zone: CGFloat
    ) -> Bool {
        switch (movingCorner, targetCorner) {
        case (.bottomLeft, .bottomRight), (.topLeft, .topRight):
            return proposed.minX >= target.maxX - zone
        case (.bottomRight, .bottomLeft), (.topRight, .topLeft):
            return proposed.maxX <= target.minX + zone
        case (.bottomLeft, .topLeft), (.bottomRight, .topRight):
            return proposed.minY >= target.maxY - zone
        case (.topLeft, .bottomLeft), (.topRight, .bottomRight):
            return proposed.maxY <= target.minY + zone
        case (.bottomLeft, .topRight):
            return proposed.minX >= target.maxX - zone && proposed.minY >= target.maxY - zone
        case (.bottomRight, .topLeft):
            return proposed.maxX <= target.minX + zone && proposed.minY >= target.maxY - zone
        case (.topLeft, .bottomRight):
            return proposed.minX >= target.maxX - zone && proposed.maxY <= target.minY + zone
        case (.topRight, .bottomLeft):
            return proposed.maxX <= target.minX + zone && proposed.maxY <= target.minY + zone
        case (.bottomLeft, .bottomLeft):
            return proposed.maxX <= target.minX + zone && proposed.maxY <= target.minY + zone
        case (.bottomRight, .bottomRight):
            return proposed.minX >= target.maxX - zone && proposed.maxY <= target.minY + zone
        case (.topLeft, .topLeft):
            return proposed.maxX <= target.minX + zone && proposed.minY >= target.maxY - zone
        case (.topRight, .topRight):
            return proposed.minX >= target.maxX - zone && proposed.maxY >= target.maxY - zone
        }
    }

    private static func framesOverlap(_ lhs: NoteFrame, _ rhs: NoteFrame) -> Bool {
        lhs.minX < rhs.maxX
            && lhs.maxX > rhs.minX
            && lhs.minY < rhs.maxY
            && lhs.maxY > rhs.minY
    }

    private static func eligibleSideEdges(resizeEdges: NoteSnapResizeEdges?) -> [NoteSnapEdge] {
        guard let resizeEdges else {
            return NoteSnapEdge.allCases
        }

        return NoteSnapEdge.allCases.filter { edge in
            switch edge {
            case .left:
                resizeEdges.contains(.left)
            case .right:
                resizeEdges.contains(.right)
            case .bottom:
                resizeEdges.contains(.bottom)
            case .top:
                resizeEdges.contains(.top)
            }
        }
    }

    private static func cornerIsEligible(
        _ corner: NoteSnapCorner,
        resizeEdges: NoteSnapResizeEdges?
    ) -> Bool {
        guard let resizeEdges else { return true }

        switch corner {
        case .bottomLeft:
            return resizeEdges.contains(.bottom) && resizeEdges.contains(.left)
        case .bottomRight:
            return resizeEdges.contains(.bottom) && resizeEdges.contains(.right)
        case .topLeft:
            return resizeEdges.contains(.top) && resizeEdges.contains(.left)
        case .topRight:
            return resizeEdges.contains(.top) && resizeEdges.contains(.right)
        }
    }

    private static func perpendicularOverlap(
        proposed: NoteFrame,
        target: NoteFrame,
        movingEdge: NoteSnapEdge
    ) -> Bool {
        switch movingEdge {
        case .left, .right:
            return proposed.minY <= target.maxY && proposed.maxY >= target.minY
        case .bottom, .top:
            return proposed.minX <= target.maxX && proposed.maxX >= target.minX
        }
    }

    private static func shouldRelease(
        proposed: NoteFrame,
        engagement: NoteSnapEngagement,
        threshold: CGFloat
    ) -> Bool {
        switch engagement.kind {
        case .side(let edge):
            let current = proposed.edgeValue(edge)
            let engaged = engagement.resultingFrame.edgeValue(edge)
            return abs(current - engaged) > threshold
        case .corner(let corner):
            let current = proposed.cornerPoint(corner)
            let engaged = engagement.resultingFrame.cornerPoint(corner)
            return hypot(current.x - engaged.x, current.y - engaged.y) > threshold
        }
    }

    private static func lockedFrame(
        proposed: NoteFrame,
        engagement: NoteSnapEngagement,
        resizeEdges: NoteSnapResizeEdges?
    ) -> NoteFrame {
        switch engagement.kind {
        case .side(let edge):
            let engagedValue = engagement.resultingFrame.edgeValue(edge)
            return proposed.withEdge(edge, value: engagedValue)
        case .corner(let corner):
            let engagedPoint = engagement.resultingFrame.cornerPoint(corner)
            return proposed.withCorner(corner, point: engagedPoint)
        }
    }
}

private extension NoteFrame {
    var minX: CGFloat { x }
    var maxX: CGFloat { x + width }
    var minY: CGFloat { y }
    var maxY: CGFloat { y + height }

    func edgeValue(_ edge: NoteSnapEdge) -> CGFloat {
        switch edge {
        case .left:
            minX
        case .right:
            maxX
        case .bottom:
            minY
        case .top:
            maxY
        }
    }

    func withEdge(_ edge: NoteSnapEdge, value: CGFloat) -> NoteFrame {
        var copy = self
        switch edge {
        case .left:
            copy.x = value
        case .right:
            copy.x = value - copy.width
        case .bottom:
            copy.y = value
        case .top:
            copy.y = value - copy.height
        }
        return copy
    }

    func cornerPoint(_ corner: NoteSnapCorner) -> CGPoint {
        switch corner {
        case .bottomLeft:
            CGPoint(x: minX, y: minY)
        case .bottomRight:
            CGPoint(x: maxX, y: minY)
        case .topLeft:
            CGPoint(x: minX, y: maxY)
        case .topRight:
            CGPoint(x: maxX, y: maxY)
        }
    }

    func withCorner(_ corner: NoteSnapCorner, point: CGPoint) -> NoteFrame {
        var copy = self
        switch corner {
        case .bottomLeft:
            copy.x = point.x
            copy.y = point.y
        case .bottomRight:
            copy.x = point.x - copy.width
            copy.y = point.y
        case .topLeft:
            copy.x = point.x
            copy.y = point.y - copy.height
        case .topRight:
            copy.x = point.x - copy.width
            copy.y = point.y - copy.height
        }
        return copy
    }
}
