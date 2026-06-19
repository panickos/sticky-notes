import CoreGraphics
import Foundation

public enum NoteCollectionEditResult: Equatable, Sendable {
    case deleted(removedID: UUID)
    case deletedLastNote(replacedWith: StickyNote)
    case duplicated(newNote: StickyNote)
    case colorChanged(noteID: UUID, color: NoteColor)
}

public struct NoteCollectionEditOutcome: Equatable, Sendable {
    public let notes: [StickyNote]
    public let editResult: NoteCollectionEditResult

    public init(notes: [StickyNote], editResult: NoteCollectionEditResult) {
        self.notes = notes
        self.editResult = editResult
    }
}

/// Pure collection mutations for per-note actions (Spec 03).
public enum NoteCollectionEditor {
    public static func delete(
        noteID: UUID,
        from notes: [StickyNote]
    ) -> NoteCollectionEditOutcome? {
        guard let index = notes.firstIndex(where: { $0.id == noteID }) else {
            return nil
        }

        if notes.count == 1 {
            let removed = notes[index]
            var replacement = StickyNote.new(
                at: removed.frame.origin,
                zIndex: 0,
                content: ""
            )
            replacement.frame = removed.frame
            return NoteCollectionEditOutcome(
                notes: [replacement],
                editResult: .deletedLastNote(replacedWith: replacement)
            )
        }

        var updated = notes
        updated.remove(at: index)
        return NoteCollectionEditOutcome(
            notes: updated,
            editResult: .deleted(removedID: noteID)
        )
    }

    public static func duplicate(
        noteID: UUID,
        from notes: [StickyNote],
        offset: CGPoint = CGPoint(x: 28, y: -28)
    ) -> NoteCollectionEditOutcome? {
        guard let index = notes.firstIndex(where: { $0.id == noteID }) else {
            return nil
        }

        let nextZIndex = (notes.map(\.zIndex).max() ?? -1) + 1
        let copy = notes[index].duplicate(nextZIndex: nextZIndex, offset: offset)
        var updated = notes
        updated.append(copy)
        return NoteCollectionEditOutcome(
            notes: updated,
            editResult: .duplicated(newNote: copy)
        )
    }

    public static func changeColor(
        noteID: UUID,
        to color: NoteColor,
        in notes: [StickyNote],
        at date: Date = Date()
    ) -> NoteCollectionEditOutcome? {
        guard let index = notes.firstIndex(where: { $0.id == noteID }) else {
            return nil
        }

        var updated = notes
        updated[index].touchColor(color, at: date)
        return NoteCollectionEditOutcome(
            notes: updated,
            editResult: .colorChanged(noteID: noteID, color: color)
        )
    }
}
