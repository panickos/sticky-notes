import CoreGraphics
import Foundation
import Testing
@testable import StickyNotesCore

@Suite("NoteAction — Spec 03 per-note action catalog")
struct NoteActionCatalogTests {
    @Test("v1 per-note hover actions are delete, color, and duplicate")
    func requiredActions() {
        #expect(NoteAction.v1PerNoteActions == [.delete, .changeColor, .duplicate])
    }

    @Test("v1 global note actions include create and resize")
    func globalActions() {
        #expect(NoteAction.v1GlobalActions.contains(.create))
        #expect(NoteAction.v1GlobalActions.contains(.resize))
    }
}

@Suite("NoteChromeConfiguration — Spec 03 hover controls")
struct NoteChromeConfigurationTests {
    @Test("hover chrome shows close, color, and duplicate controls")
    func hoverControls() {
        #expect(NoteChromeConfiguration.v1.hoverControls == [.delete, .changeColor, .duplicate])
    }

    @Test("each hover control maps to its Spec 03 action")
    func controlActionMapping() {
        #expect(NoteChromeConfiguration.v1.action(for: .delete) == .delete)
        #expect(NoteChromeConfiguration.v1.action(for: .changeColor) == .changeColor)
        #expect(NoteChromeConfiguration.v1.action(for: .duplicate) == .duplicate)
    }
}

@Suite("NoteCollectionEditor — delete")
struct NoteCollectionEditorDeleteTests {
    @Test("delete removes the targeted note from the collection")
    func deleteNote() {
        let first = makeNote(id: 1, zIndex: 0)
        let second = makeNote(id: 2, zIndex: 1)
        let notes = [first, second]

        let result = NoteCollectionEditor.delete(noteID: first.id, from: notes)

        #expect(result?.notes.count == 1)
        #expect(result?.notes.first?.id == second.id)
        #expect(result?.editResult == .deleted(removedID: first.id))
    }

    @Test("deleting the last note replaces it with a fresh empty note at the same frame")
    func deleteLastNote() {
        var only = makeNote(id: 1, zIndex: 0, content: "Keep me gone")
        only.frame.width = 280
        only.frame.height = 320

        let notes = [only]
        let result = NoteCollectionEditor.delete(noteID: only.id, from: notes)

        #expect(result?.notes.count == 1)
        let replacement = result?.notes.first
        #expect(replacement?.id != only.id)
        #expect(replacement?.content.isEmpty == true)
        #expect(replacement?.frame == only.frame)
        #expect(replacement?.zIndex == 0)

        if case .deletedLastNote(let replacedWith) = result?.editResult {
            #expect(replacedWith.id == replacement?.id)
        } else {
            Issue.record("Expected deletedLastNote result")
        }
    }

    @Test("delete returns nil when note id is missing")
    func deleteMissingNote() {
        let note = makeNote(id: 1, zIndex: 0)
        #expect(NoteCollectionEditor.delete(noteID: UUID(), from: [note]) == nil)
    }
}

@Suite("NoteCollectionEditor — duplicate")
struct NoteCollectionEditorDuplicateTests {
    @Test("duplicate appends a copy with the next zIndex and default offset")
    func duplicateNote() {
        let original = makeNote(id: 1, zIndex: 2, content: "# Copy me")
        let peer = makeNote(id: 2, zIndex: 5)
        let notes = [original, peer]

        let result = NoteCollectionEditor.duplicate(noteID: original.id, from: notes)

        #expect(result?.notes.count == 3)
        #expect(result?.notes.map(\.zIndex).sorted() == [2, 5, 6])

        if case .duplicated(let newNote) = result?.editResult {
            #expect(newNote.id != original.id)
            #expect(newNote.content == original.content)
            #expect(newNote.frame.x == original.frame.x + 28)
            #expect(newNote.frame.y == original.frame.y - 28)
            #expect(newNote.zIndex == 6)
        } else {
            Issue.record("Expected duplicated result")
        }
    }

    @Test("duplicate returns nil when note id is missing")
    func duplicateMissingNote() {
        let note = makeNote(id: 1, zIndex: 0)
        #expect(NoteCollectionEditor.duplicate(noteID: UUID(), from: [note]) == nil)
    }
}

@Suite("NoteCollectionEditor — change color")
struct NoteCollectionEditorColorTests {
    @Test("changeColor updates the targeted note and bumps updatedAt")
    func changeColor() {
        let created = Date(timeIntervalSince1970: 1_700_000_000)
        let updated = Date(timeIntervalSince1970: 1_700_000_100)
        let note = StickyNote.new(
            at: CGPoint(x: 10, y: 20),
            zIndex: 0,
            content: "Hello",
            color: .yellow,
            now: created
        )
        let notes = [note]

        let result = NoteCollectionEditor.changeColor(
            noteID: note.id,
            to: .blue,
            in: notes,
            at: updated
        )

        #expect(result?.notes.first?.color == .blue)
        #expect(result?.notes.first?.updatedAt == updated)
        #expect(result?.notes.first?.createdAt == created)

        if case .colorChanged(let noteID, let color) = result?.editResult {
            #expect(noteID == note.id)
            #expect(color == .blue)
        } else {
            Issue.record("Expected colorChanged result")
        }
    }

    @Test("changeColor returns nil when note id is missing")
    func changeColorMissingNote() {
        let note = makeNote(id: 1, zIndex: 0)
        #expect(
            NoteCollectionEditor.changeColor(noteID: UUID(), to: .pink, in: [note]) == nil
        )
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
