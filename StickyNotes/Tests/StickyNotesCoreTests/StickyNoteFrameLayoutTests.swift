import CoreGraphics
import Foundation
import Testing
@testable import StickyNotesCore

@Suite("NoteDisplayLayout — multi-monitor screen bounds")
struct NoteDisplayLayoutTests {
    @Test("v1 layout requires at least one visible display frame")
    func requiresVisibleFrames() {
        let layout = NoteDisplayLayout.v1(
            visibleFrames: [CGRect(x: 0, y: 0, width: 1440, height: 900)]
        )
        #expect(layout.visibleFrames.count == 1)
        #expect(layout.primaryVisibleFrame == CGRect(x: 0, y: 0, width: 1440, height: 900))
    }
}

@Suite("NoteFrameRestorer — Spec 02 multi-monitor session restore")
struct NoteFrameRestorerTests {
    private let primary = CGRect(x: 0, y: 0, width: 1440, height: 900)
    private let secondary = CGRect(x: 1440, y: 0, width: 1440, height: 900)

    private var dualLayout: NoteDisplayLayout {
        NoteDisplayLayout.v1(visibleFrames: [primary, secondary])
    }

    private var primaryOnlyLayout: NoteDisplayLayout {
        NoteDisplayLayout.v1(visibleFrames: [primary])
    }

    @Test("on-screen frame is unchanged")
    func preservesOnScreenFrame() {
        let frame = NoteFrame(x: 200, y: 400, width: 250, height: 300)
        let restored = NoteFrameRestorer.restoredFrame(frame, within: dualLayout)
        #expect(restored == frame)
    }

    @Test("note on secondary display stays on secondary when both displays are connected")
    func preservesSecondaryDisplayPlacement() {
        let frame = NoteFrame(x: 1600, y: 500, width: 250, height: 300)
        let restored = NoteFrameRestorer.restoredFrame(frame, within: dualLayout)
        #expect(restored == frame)
    }

    @Test("frame entirely on a disconnected display is moved to the primary display")
    func relocatesOffScreenFrameToPrimary() {
        let frame = NoteFrame(x: 1600, y: 500, width: 250, height: 300)
        let restored = NoteFrameRestorer.restoredFrame(frame, within: primaryOnlyLayout)

        #expect(restored.origin.x >= primary.minX)
        #expect(restored.origin.y >= primary.minY)
        #expect(restored.maxX <= primary.maxX)
        #expect(restored.maxY <= primary.maxY)
        #expect(restored.width == frame.width)
        #expect(restored.height == frame.height)
    }

    @Test("partially off-screen frame is clamped within its display")
    func clampsPartiallyOffScreenFrame() {
        let frame = NoteFrame(x: 1300, y: 820, width: 250, height: 300)
        let restored = NoteFrameRestorer.restoredFrame(frame, within: primaryOnlyLayout)

        #expect(restored.origin.x <= primary.maxX - restored.width)
        #expect(restored.origin.y <= primary.maxY - restored.height)
        #expect(restored.origin.x >= primary.minX)
        #expect(restored.origin.y >= primary.minY)
        #expect(restored.width == frame.width)
        #expect(restored.height == frame.height)
    }

    @Test("restoredNotes updates only notes whose frames changed")
    func restoresCollection() {
        let onScreen = makeNote(id: 1, frame: NoteFrame(x: 100, y: 100, width: 250, height: 300))
        let offScreen = makeNote(id: 2, frame: NoteFrame(x: 1600, y: 500, width: 250, height: 300))
        let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)

        let restored = NoteFrameRestorer.restoredNotes(
            [onScreen, offScreen],
            within: primaryOnlyLayout,
            now: fixedDate
        )

        #expect(restored[0].frame == onScreen.frame)
        #expect(restored[0].updatedAt == onScreen.updatedAt)
        #expect(restored[1].frame != offScreen.frame)
        #expect(restored[1].updatedAt == fixedDate)
    }
}

private extension NoteFrame {
    var maxX: CGFloat { x + width }
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
