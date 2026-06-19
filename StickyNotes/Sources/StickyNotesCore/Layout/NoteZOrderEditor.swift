import Foundation

public struct NoteZOrderUpdate: Equatable, Sendable {
    public let notes: [StickyNote]
    public let noteID: UUID
    public let zIndex: Int

    public init(notes: [StickyNote], noteID: UUID, zIndex: Int) {
        self.notes = notes
        self.noteID = noteID
        self.zIndex = zIndex
    }
}

/// Pure z-order mutations for note stacking (Spec 04).
public enum NoteZOrderEditor {
    public static func bringToFront(
        noteID: UUID,
        in notes: [StickyNote],
        at date: Date = Date()
    ) -> NoteZOrderUpdate? {
        guard let index = notes.firstIndex(where: { $0.id == noteID }) else {
            return nil
        }

        let focused = notes[index]
        let isStrictlyOnTop = notes.allSatisfy { other in
            other.id == noteID || focused.zIndex > other.zIndex
        }
        if isStrictlyOnTop {
            return nil
        }

        let nextZIndex = (notes.map(\.zIndex).max() ?? -1) + 1
        var updated = notes
        updated[index].touchZIndex(nextZIndex, at: date)
        return NoteZOrderUpdate(notes: updated, noteID: noteID, zIndex: nextZIndex)
    }
}
