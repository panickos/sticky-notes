/// Default global hotkey bindings for v1 (Spec 05 suggested defaults).
public struct StickyNoteHotkeyBindings: Equatable, Sendable {
    public static let requiredActions: Set<StickyNoteHotkeyAction> = [
        .toggleVisibility,
        .createNewNote,
    ]

    /// Spec 05 defaults: ⌃⌥N toggle, ⌃⌥⇧N new note.
    /// Control is included so chords remain valid on macOS Sequoia+.
    public static let v1Defaults = StickyNoteHotkeyBindings(chords: [
        .toggleVisibility: HotkeyChord(key: "n", modifiers: [.control, .option]),
        .createNewNote: HotkeyChord(key: "n", modifiers: [.control, .option, .shift]),
    ])

    private let chords: [StickyNoteHotkeyAction: HotkeyChord]

    public init(chords: [StickyNoteHotkeyAction: HotkeyChord]) {
        self.chords = chords
    }

    public var boundActions: Set<StickyNoteHotkeyAction> {
        Set(chords.keys)
    }

    public func binding(for action: StickyNoteHotkeyAction) -> HotkeyChord? {
        chords[action]
    }

    public func chord(for action: StickyNoteHotkeyAction) -> HotkeyChord {
        guard let chord = chords[action] else {
            fatalError("Missing hotkey binding for \(action)")
        }
        return chord
    }
}
