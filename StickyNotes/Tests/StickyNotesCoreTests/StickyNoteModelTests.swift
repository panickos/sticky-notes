import CoreGraphics
import Foundation
import Testing
@testable import StickyNotesCore

@Suite("NoteColor — Spec 03 preset palette")
struct NoteColorTests {
    @Test("v1 palette includes yellow, pink, blue, and green")
    func presetPalette() {
        #expect(NoteAppearanceDefaults.colorPalette == [.yellow, .pink, .blue, .green])
    }
}

@Suite("NoteAppearanceDefaults — Spec 03 medium default size")
struct NoteAppearanceDefaultsTests {
    @Test("default note size is medium fixed dimensions")
    func defaultSize() {
        #expect(NoteAppearanceDefaults.defaultWidth == 250)
        #expect(NoteAppearanceDefaults.defaultHeight == 300)
    }

    @Test("default color is yellow")
    func defaultColor() {
        #expect(NoteAppearanceDefaults.defaultColor == .yellow)
    }
}

@Suite("StickyNote — Spec 04 data model")
struct StickyNoteTests {
    @Test("new note uses appearance defaults and provided origin")
    func newNoteDefaults() {
        let origin = CGPoint(x: 120, y: 340)
        let note = StickyNote.new(at: origin, zIndex: 2)

        #expect(note.frame.x == 120)
        #expect(note.frame.y == 340)
        #expect(note.frame.width == NoteAppearanceDefaults.defaultWidth)
        #expect(note.frame.height == NoteAppearanceDefaults.defaultHeight)
        #expect(note.color == .yellow)
        #expect(note.zIndex == 2)
        #expect(note.content.isEmpty)
    }

    @Test("new note stamps createdAt and updatedAt together")
    func timestamps() {
        let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)
        let note = StickyNote.new(
            at: CGPoint(x: 0, y: 0),
            zIndex: 0,
            now: fixedDate
        )

        #expect(note.createdAt == fixedDate)
        #expect(note.updatedAt == fixedDate)
    }

    @Test("touching content bumps updatedAt but preserves createdAt")
    func touchContent() {
        let created = Date(timeIntervalSince1970: 1_700_000_000)
        let updated = Date(timeIntervalSince1970: 1_700_000_100)
        var note = StickyNote.new(
            at: CGPoint(x: 10, y: 20),
            zIndex: 0,
            now: created
        )

        note.touchContent("Hello **world**", at: updated)

        #expect(note.content == "Hello **world**")
        #expect(note.createdAt == created)
        #expect(note.updatedAt == updated)
    }

    @Test("duplicate creates a new id with copied content and incremented zIndex")
    func duplicate() {
        let original = StickyNote.new(
            at: CGPoint(x: 50, y: 75),
            zIndex: 3,
            content: "# Tasks\n- [ ] Ship",
            color: .pink
        )

        let copy = original.duplicate(nextZIndex: 4, offset: CGPoint(x: 28, y: -28))

        #expect(copy.id != original.id)
        #expect(copy.content == original.content)
        #expect(copy.color == original.color)
        #expect(copy.frame.width == original.frame.width)
        #expect(copy.frame.height == original.frame.height)
        #expect(copy.frame.x == original.frame.x + 28)
        #expect(copy.frame.y == original.frame.y - 28)
        #expect(copy.zIndex == 4)
        #expect(copy.createdAt == original.createdAt)
    }
}

@Suite("StickyNote — Codable round-trip")
struct StickyNoteCodableTests {
    @Test("encodes and decodes all Spec 04 fields")
    func roundTrip() throws {
        let created = Date(timeIntervalSince1970: 1_700_000_000)
        let updated = Date(timeIntervalSince1970: 1_700_000_050)
        let note = StickyNote(
            id: UUID(uuidString: "A1B2C3D4-E5F6-7890-ABCD-EF1234567890")!,
            content: "- [ ] Buy milk",
            frame: NoteFrame(x: 100, y: 200, width: 250, height: 300),
            color: .blue,
            zIndex: 7,
            createdAt: created,
            updatedAt: updated
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let data = try encoder.encode(note)
        let decoded = try decoder.decode(StickyNote.self, from: data)

        #expect(decoded == note)
    }
}
