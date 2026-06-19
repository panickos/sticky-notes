import AppKit

/// Sticky note panel that accepts keyboard input while remaining a non-main floating overlay.
final class NotePanel: NSPanel {
    override var canBecomeKey: Bool { true }

    override var canBecomeMain: Bool { false }
}
