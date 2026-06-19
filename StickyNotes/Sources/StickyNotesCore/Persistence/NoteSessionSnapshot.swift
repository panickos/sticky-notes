/// On-disk representation of all notes in the current session (Spec 04).
public struct NoteSessionSnapshot: Codable, Equatable, Sendable {
    public static let empty = NoteSessionSnapshot(notes: [], schemaVersion: 1)

    public var notes: [StickyNote]
    public var schemaVersion: Int

    public init(notes: [StickyNote], schemaVersion: Int = 1) {
        self.notes = notes
        self.schemaVersion = schemaVersion
    }
}
