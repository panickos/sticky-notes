import Foundation
import Testing
@testable import StickyNotesCore

@Suite("NoteZOrderEditor — Spec 04 z-order on focus")
struct NoteZOrderEditorTests {
    @Test("bringToFront returns nil for an unknown note id")
    func unknownNote() {
        let note = makeNote(id: 1, zIndex: 0)
        #expect(NoteZOrderEditor.bringToFront(noteID: UUID(), in: [note]) == nil)
    }

    @Test("bringToFront is a no-op when the note is already strictly on top")
    func alreadyOnTop() {
        let bottom = makeNote(id: 1, zIndex: 0)
        let top = makeNote(id: 2, zIndex: 2)
        let notes = [bottom, top]

        #expect(NoteZOrderEditor.bringToFront(noteID: top.id, in: notes) == nil)
    }

    @Test("bringToFront assigns max plus one when a lower note is focused")
    func lowerNoteFocused() {
        let bottom = makeNote(id: 1, zIndex: 0)
        let middle = makeNote(id: 2, zIndex: 1)
        let top = makeNote(id: 3, zIndex: 2)
        let notes = [bottom, middle, top]

        let update = NoteZOrderEditor.bringToFront(noteID: bottom.id, in: notes)

        #expect(update?.noteID == bottom.id)
        #expect(update?.zIndex == 3)
        #expect(update?.notes.first(where: { $0.id == bottom.id })?.zIndex == 3)
        #expect(update?.notes.map(\.zIndex).sorted() == [1, 2, 3])
    }

    @Test("bringToFront resolves tied max zIndex by promoting the focused note")
    func tiedMaxZIndex() {
        let first = makeNote(id: 1, zIndex: 5)
        let second = makeNote(id: 2, zIndex: 5)
        let notes = [first, second]

        let update = NoteZOrderEditor.bringToFront(noteID: first.id, in: notes)

        #expect(update?.noteID == first.id)
        #expect(update?.zIndex == 6)
        #expect(update?.notes.first(where: { $0.id == first.id })?.zIndex == 6)
        #expect(update?.notes.first(where: { $0.id == second.id })?.zIndex == 5)
    }

    @Test("bringToFront updates updatedAt on the promoted note")
    func touchesUpdatedAt() {
        let bottom = makeNote(id: 1, zIndex: 0)
        let top = makeNote(id: 2, zIndex: 1)
        let focusDate = Date(timeIntervalSince1970: 1_800_000_000)

        let update = NoteZOrderEditor.bringToFront(
            noteID: bottom.id,
            in: [bottom, top],
            at: focusDate
        )

        #expect(update?.notes.first(where: { $0.id == bottom.id })?.updatedAt == focusDate)
        #expect(update?.notes.first(where: { $0.id == top.id })?.updatedAt == top.updatedAt)
    }
}

private func makeNote(
    id: UInt8,
    zIndex: Int,
    content: String = ""
) -> StickyNote {
    StickyNote(
        id: UUID(uuidString: "00000000-0000-0000-0000-\(String(format: "%012x", id))")!,
        content: content,
        frame: NoteFrame(x: 100, y: 200, width: 250, height: 300),
        color: .yellow,
        zIndex: zIndex,
        createdAt: Date(timeIntervalSince1970: 1_700_000_000),
        updatedAt: Date(timeIntervalSince1970: 1_700_000_000)
    )
}
