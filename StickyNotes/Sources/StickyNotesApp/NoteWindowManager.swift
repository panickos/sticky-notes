import AppKit
import Combine
import StickyNotesCore
import SwiftUI

extension NoteColor {
    var fillColor: Color {
        switch self {
        case .yellow:
            Color(red: 1.0, green: 0.95, blue: 0.6)
        case .pink:
            Color(red: 1.0, green: 0.85, blue: 0.9)
        case .blue:
            Color(red: 0.85, green: 0.92, blue: 1.0)
        case .green:
            Color(red: 0.85, green: 0.97, blue: 0.85)
        }
    }
}

@MainActor
final class NoteWindowManager {
    private let persistenceStore: NotePersistenceStore
    private var notes: [StickyNote] = []
    private var controllers: [UUID: NotePanelController] = [:]
    private var notesVisible = true

    var notesAreVisible: Bool { notesVisible }
    var onVisibilityChanged: (() -> Void)?

    init(persistenceStore: NotePersistenceStore) {
        self.persistenceStore = persistenceStore
    }

    func bootstrap() async {
        do {
            let snapshot = try await persistenceStore.load()
            notes = restoredNotesForCurrentDisplays(snapshot.notes)
                .sorted { $0.zIndex < $1.zIndex }
        } catch {
            NSLog("StickyNotes: failed to load notes: \(error)")
            notes = []
        }

        if notes.isEmpty {
            createNote(startEditing: false)
        } else {
            for note in notes {
                openPanel(for: note)
            }
            syncPanelZOrder()
        }

        notesVisible = true
    }

    func createNote(startEditing: Bool = true) {
        let zIndex = (notes.map(\.zIndex).max() ?? -1) + 1
        let origin = defaultOrigin(forIndex: notes.count)
        let content = notes.isEmpty ? StickyNoteMarkdownFeatures.sampleDocument : ""
        var note = StickyNote.new(at: origin, zIndex: zIndex, content: content)
        note.touchFrame(
            NoteFrame(
                x: origin.x,
                y: origin.y,
                width: NoteAppearanceDefaults.defaultWidth,
                height: NoteAppearanceDefaults.defaultHeight
            )
        )
        notes.append(note)
        openPanel(for: note, startEditing: startEditing)
        syncPanelZOrder()
        persistSoon()
    }

    func deleteNote(id: UUID) {
        guard let outcome = NoteCollectionEditor.delete(noteID: id, from: notes) else { return }

        switch outcome.editResult {
        case .deleted(let removedID):
            closePanel(for: removedID)
        case .deletedLastNote(let replacedWith):
            closePanel(for: id)
            openPanel(for: replacedWith)
        case .duplicated, .colorChanged:
            return
        }

        notes = outcome.notes
        persistSoon()
    }

    func duplicateNote(id: UUID) {
        guard let outcome = NoteCollectionEditor.duplicate(noteID: id, from: notes) else { return }
        guard case .duplicated(let newNote) = outcome.editResult else { return }

        notes = outcome.notes
        openPanel(for: newNote)
        syncPanelZOrder()
        persistSoon()
    }

    func changeNoteColor(id: UUID, to color: NoteColor) {
        guard let outcome = NoteCollectionEditor.changeColor(noteID: id, to: color, in: notes) else {
            return
        }

        notes = outcome.notes
        if let note = notes.first(where: { $0.id == id }) {
            controllers[id]?.updateNote(note)
        }
        persistSoon()
    }

    func toggleAllVisibility() {
        notesVisible.toggle()
        for controller in controllers.values {
            if notesVisible {
                controller.show()
            } else {
                controller.hide()
            }
        }
        onVisibilityChanged?()
    }

    func flushOnTerminate() async {
        await persistenceStore.flushPendingAutosave()
    }

    func focusNote(id: UUID) {
        guard let update = NoteZOrderEditor.bringToFront(noteID: id, in: notes) else {
            controllers[id]?.orderForStacking()
            return
        }

        notes = update.notes
        syncPanelZOrder()
        persistSoon()
    }

    private func openPanel(for note: StickyNote, startEditing: Bool = false) {
        let bindings = StickyNoteHotkeyBindings.v1Defaults
        let controller = NotePanelController(
            note: note,
            toggleShortcut: bindings.chord(for: .toggleVisibility).displayString,
            newNoteShortcut: bindings.chord(for: .createNewNote).displayString,
            onContentChange: { [weak self] noteID, content in
                self?.updateContent(noteID: noteID, content: content)
            },
            onFrameChange: { [weak self] noteID, frame in
                self?.updateFrame(noteID: noteID, frame: frame)
            },
            onDelete: { [weak self] noteID in
                self?.deleteNote(id: noteID)
            },
            onDuplicate: { [weak self] noteID in
                self?.duplicateNote(id: noteID)
            },
            onColorChange: { [weak self] noteID, color in
                self?.changeNoteColor(id: noteID, to: color)
            },
            onFocus: { [weak self] noteID in
                self?.focusNote(id: noteID)
            }
        )
        controllers[note.id] = controller
        if notesVisible {
            controller.show()
        }
        if startEditing {
            controller.beginEditing()
        }
    }

    private func closePanel(for noteID: UUID) {
        guard let controller = controllers.removeValue(forKey: noteID) else { return }
        controller.close()
    }

    private func updateContent(noteID: UUID, content: String) {
        guard let index = notes.firstIndex(where: { $0.id == noteID }) else { return }
        notes[index].touchContent(content)
        persistSoon()
    }

    private func updateFrame(noteID: UUID, frame: NoteFrame) {
        guard let index = notes.firstIndex(where: { $0.id == noteID }) else { return }
        guard notes[index].frame != frame else { return }
        notes[index].touchFrame(frame)
        persistSoon()
    }

    private func persistSoon() {
        let snapshot = NoteSessionSnapshot(notes: notes)
        Task {
            await persistenceStore.scheduleAutosave(snapshot)
        }
    }

    private func defaultOrigin(forIndex index: Int) -> CGPoint {
        let screenFrame = currentDisplayLayout().primaryVisibleFrame
            ?? NSRect(x: 100, y: 100, width: 800, height: 600)
        let noteSize = NoteAppearanceDefaults.defaultSize
        let offset = CGFloat(index * 28)
        return CGPoint(
            x: screenFrame.maxX - noteSize.width - NoteFrameRestorer.edgePadding - offset,
            y: screenFrame.maxY - noteSize.height - NoteFrameRestorer.edgePadding - offset
        )
    }

    private func currentDisplayLayout() -> NoteDisplayLayout {
        NoteDisplayLayout.v1(
            visibleFrames: NSScreen.screens.map(\.visibleFrame)
        )
    }

    private func restoredNotesForCurrentDisplays(_ loadedNotes: [StickyNote]) -> [StickyNote] {
        let layout = currentDisplayLayout()
        let restored = NoteFrameRestorer.restoredNotes(loadedNotes, within: layout)
        guard restored != loadedNotes else { return restored }

        let snapshot = NoteSessionSnapshot(notes: restored)
        Task {
            await persistenceStore.scheduleAutosave(snapshot)
        }
        return restored
    }

    private func syncPanelZOrder() {
        for note in notes.sorted(by: { $0.zIndex < $1.zIndex }) {
            controllers[note.id]?.orderForStacking()
        }
    }
}

@MainActor
final class NoteEditingState: ObservableObject {
    @Published var isEditing = false
}

@MainActor
final class NotePanelController: NSObject {
    let panel: NSPanel
    private let noteID: UUID
    private let editingState = NoteEditingState()
    private let frameObserver: NotePanelFrameObserver
    private let viewCallbacks: NoteViewCallbacks

    init(
        note: StickyNote,
        toggleShortcut: String,
        newNoteShortcut: String,
        onContentChange: @escaping (UUID, String) -> Void,
        onFrameChange: @escaping (UUID, NoteFrame) -> Void,
        onDelete: @escaping (UUID) -> Void,
        onDuplicate: @escaping (UUID) -> Void,
        onColorChange: @escaping (UUID, NoteColor) -> Void,
        onFocus: @escaping (UUID) -> Void
    ) {
        noteID = note.id
        frameObserver = NotePanelFrameObserver()
        viewCallbacks = NoteViewCallbacks(
            noteID: note.id,
            toggleShortcut: toggleShortcut,
            newNoteShortcut: newNoteShortcut,
            onContentChange: onContentChange,
            onDelete: onDelete,
            onDuplicate: onDuplicate,
            onColorChange: onColorChange
        )

        let contentRect = NSRect(
            x: note.frame.x,
            y: note.frame.y,
            width: note.frame.width,
            height: note.frame.height
        )

        panel = NotePanelFactory.makePanel(
            configuration: .aerospaceCompatible,
            contentRect: contentRect
        )

        super.init()

        frameObserver.onFrameChange = { frame in
            onFrameChange(
                note.id,
                NoteFrame(
                    x: frame.origin.x,
                    y: frame.origin.y,
                    width: frame.size.width,
                    height: frame.size.height
                )
            )
        }
        frameObserver.onBecameKey = {
            onFocus(note.id)
        }
        frameObserver.onResignKey = { [weak self] in
            self?.editingState.isEditing = false
        }
        panel.delegate = frameObserver
        panel.contentView = NSHostingView(rootView: makeRootView(for: note))
    }

    func show() {
        panel.orderFrontRegardless()
    }

    func orderForStacking() {
        panel.orderFront(nil)
    }

    func hide() {
        panel.orderOut(nil)
    }

    func close() {
        panel.close()
    }

    func updateNote(_ note: StickyNote) {
        panel.contentView = NSHostingView(rootView: makeRootView(for: note))
    }

    func activateForEditing() {
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
    }

    func beginEditing() {
        editingState.isEditing = true
        activateForEditing()
    }

    private func makeRootView(for note: StickyNote) -> StickyNoteView {
        StickyNoteView(
            note: note,
            editingState: editingState,
            toggleShortcut: viewCallbacks.toggleShortcut,
            newNoteShortcut: viewCallbacks.newNoteShortcut,
            onContentChange: { [viewCallbacks] content in
                viewCallbacks.onContentChange(viewCallbacks.noteID, content)
            },
            onDelete: { [viewCallbacks] in
                viewCallbacks.onDelete(viewCallbacks.noteID)
            },
            onDuplicate: { [viewCallbacks] in
                viewCallbacks.onDuplicate(viewCallbacks.noteID)
            },
            onColorChange: { [viewCallbacks] color in
                viewCallbacks.onColorChange(viewCallbacks.noteID, color)
            },
            onFocus: { [weak self] in
                self?.activateForEditing()
            }
        )
    }
}

@MainActor
private struct NoteViewCallbacks {
    let noteID: UUID
    let toggleShortcut: String
    let newNoteShortcut: String
    let onContentChange: (UUID, String) -> Void
    let onDelete: (UUID) -> Void
    let onDuplicate: (UUID) -> Void
    let onColorChange: (UUID, NoteColor) -> Void
}

@MainActor
final class NotePanelFrameObserver: NSObject, NSWindowDelegate {
    var onFrameChange: ((NSRect) -> Void)?
    var onBecameKey: (() -> Void)?
    var onResignKey: (() -> Void)?

    func windowDidBecomeKey(_ notification: Notification) {
        NSApp.activate(ignoringOtherApps: true)
        onBecameKey?()
    }

    func windowDidResignKey(_ notification: Notification) {
        onResignKey?()
    }

    func windowDidMove(_ notification: Notification) {
        deliverFrame(from: notification)
    }

    func windowDidResize(_ notification: Notification) {
        deliverFrame(from: notification)
    }

    private func deliverFrame(from notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }
        onFrameChange?(window.frame)
    }
}
