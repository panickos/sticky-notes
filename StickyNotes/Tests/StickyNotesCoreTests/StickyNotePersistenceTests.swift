import CoreGraphics
import Foundation
import Testing
@testable import StickyNotesCore

@Suite("NotePersistenceConfiguration — Spec 04 storage")
struct NotePersistenceConfigurationTests {
    @Test("v1 stores notes under Application Support")
    func applicationSupportLocation() {
        let config = NotePersistenceConfiguration.v1
        let fileManager = FileManager.default

        guard let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            Issue.record("Application Support directory unavailable")
            return
        }

        let expected = appSupport
            .appendingPathComponent("StickyNotes", isDirectory: true)
            .appendingPathComponent("notes.json")

        #expect(config.notesFileURL(fileManager: fileManager) == expected)
    }

    @Test("v1 debounced autosave interval is within Spec 04 range")
    func autosaveDebounceInterval() {
        let interval = NotePersistenceConfiguration.v1.autosaveDebounceInterval
        #expect(interval >= 1.0)
        #expect(interval <= 2.0)
    }
}

@Suite("NotePersistenceStore — load and save")
struct NotePersistenceStoreTests {
    private func makeTempFileURL() throws -> URL {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("StickyNotesTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appendingPathComponent("notes.json")
    }

    @Test("load returns empty snapshot when file is missing")
    func loadMissingFile() async throws {
        let fileURL = try makeTempFileURL()
        let store = try NotePersistenceStore(
            configuration: .v1,
            fileURL: fileURL,
            scheduler: TestNoteAutosaveScheduler()
        )

        let snapshot = try await store.load()
        #expect(snapshot == .empty)
    }

    @Test("save and load round-trip preserves notes")
    func saveLoadRoundTrip() async throws {
        let fileURL = try makeTempFileURL()
        let store = try NotePersistenceStore(
            configuration: .v1,
            fileURL: fileURL,
            scheduler: TestNoteAutosaveScheduler()
        )

        let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)
        let note = StickyNote.new(
            at: CGPoint(x: 40, y: 60),
            zIndex: 1,
            content: "Persist me",
            now: fixedDate
        )
        let snapshot = NoteSessionSnapshot(notes: [note])

        try await store.save(snapshot)
        let loaded = try await store.load()

        #expect(loaded == snapshot)
    }

    @Test("autosave debounces rapid writes until flush")
    func debouncedAutosave() async throws {
        let fileURL = try makeTempFileURL()
        let scheduler = TestNoteAutosaveScheduler()
        let store = try NotePersistenceStore(
            configuration: .v1,
            fileURL: fileURL,
            scheduler: scheduler
        )

        let first = StickyNote.new(at: CGPoint(x: 0, y: 0), zIndex: 0, content: "draft")
        var second = first
        second.touchContent("final")

        await store.scheduleAutosave(NoteSessionSnapshot(notes: [first]))
        await store.scheduleAutosave(NoteSessionSnapshot(notes: [second]))

        #expect(scheduler.hasPendingSave)
        #expect(!FileManager.default.fileExists(atPath: fileURL.path))

        await store.flushPendingAutosave()

        let loaded = try await store.load()
        #expect(loaded.notes.first?.content == "final")
    }

    @Test("flush on quit persists last scheduled snapshot")
    func flushPersistsPendingSnapshot() async throws {
        let fileURL = try makeTempFileURL()
        let scheduler = TestNoteAutosaveScheduler()
        let store = try NotePersistenceStore(
            configuration: .v1,
            fileURL: fileURL,
            scheduler: scheduler
        )

        let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)
        let note = StickyNote.new(
            at: CGPoint(x: 10, y: 20),
            zIndex: 0,
            content: "pending",
            now: fixedDate
        )
        await store.scheduleAutosave(NoteSessionSnapshot(notes: [note]))
        await store.flushPendingAutosave()

        let loaded = try await store.load()
        #expect(loaded.notes == [note])
    }
}
