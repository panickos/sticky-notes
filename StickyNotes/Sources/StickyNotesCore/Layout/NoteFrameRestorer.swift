import CoreGraphics
import Foundation

/// Repositions note frames that fall outside connected displays on session restore (Spec 02).
public enum NoteFrameRestorer {
    public static let edgePadding: CGFloat = 24

    public static func restoredFrame(
        _ frame: NoteFrame,
        within layout: NoteDisplayLayout
    ) -> NoteFrame {
        guard let targetDisplay = display(for: frame, in: layout) else {
            guard let primary = layout.primaryVisibleFrame else { return frame }
            return defaultFrame(size: frame.size, on: primary)
        }

        return clamped(frame, to: targetDisplay)
    }

    public static func restoredNotes(
        _ notes: [StickyNote],
        within layout: NoteDisplayLayout,
        now: Date = Date()
    ) -> [StickyNote] {
        notes.map { note in
            let restoredFrame = restoredFrame(note.frame, within: layout)
            guard restoredFrame != note.frame else { return note }

            var updated = note
            updated.touchFrame(restoredFrame, at: now)
            return updated
        }
    }

    private static func display(for frame: NoteFrame, in layout: NoteDisplayLayout) -> CGRect? {
        let noteRect = CGRect(x: frame.x, y: frame.y, width: frame.width, height: frame.height)
        let center = CGPoint(x: noteRect.midX, y: noteRect.midY)

        if let containing = layout.visibleFrames.first(where: { $0.contains(center) }) {
            return containing
        }

        let ranked = layout.visibleFrames
            .map { display in (display, noteRect.intersection(display).area) }
            .sorted { $0.1 > $1.1 }

        guard let best = ranked.first, best.1 > 0 else { return nil }
        return best.0
    }

    private static func clamped(_ frame: NoteFrame, to bounds: CGRect) -> NoteFrame {
        var copy = frame
        copy.x = min(max(copy.x, bounds.minX), bounds.maxX - copy.width)
        copy.y = min(max(copy.y, bounds.minY), bounds.maxY - copy.height)
        return copy
    }

    private static func defaultFrame(size: CGSize, on display: CGRect) -> NoteFrame {
        NoteFrame(
            x: display.maxX - size.width - edgePadding,
            y: display.maxY - size.height - edgePadding,
            width: size.width,
            height: size.height
        )
    }
}

private extension CGRect {
    var area: CGFloat {
        width * height
    }
}
