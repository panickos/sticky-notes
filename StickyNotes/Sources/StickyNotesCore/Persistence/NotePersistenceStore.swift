import Foundation

/// JSON persistence for note sessions in Application Support (Spec 04).
public actor NotePersistenceStore {
    private let configuration: NotePersistenceConfiguration
    private let fileURL: URL
    private let scheduler: any NoteAutosaveScheduling
    private var pendingSnapshot: NoteSessionSnapshot?

    public init(
        configuration: NotePersistenceConfiguration = .v1,
        fileURL: URL? = nil,
        scheduler: (any NoteAutosaveScheduling)? = nil
    ) throws {
        self.configuration = configuration

        if let fileURL {
            self.fileURL = fileURL
        } else if let defaultURL = configuration.notesFileURL() {
            self.fileURL = defaultURL
            try configuration.ensureStorageDirectoryExists()
        } else {
            throw NotePersistenceError.storageLocationUnavailable
        }

        self.scheduler = scheduler ?? DebouncedNoteAutosaveScheduler(
            interval: configuration.autosaveDebounceInterval
        )
    }

    public func load() throws -> NoteSessionSnapshot {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return .empty
        }

        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(Self.decodeDate)
        return try decoder.decode(NoteSessionSnapshot.self, from: data)
    }

    public func save(_ snapshot: NoteSessionSnapshot) throws {
        let data = try Self.encode(snapshot)
        try data.write(to: fileURL, options: .atomic)
    }

    public func scheduleAutosave(_ snapshot: NoteSessionSnapshot) {
        pendingSnapshot = snapshot
        let url = fileURL
        scheduler.scheduleSave {
            NotePersistenceStore.atomicWrite(snapshot, to: url)
        }
    }

    public func flushPendingAutosave() {
        scheduler.flushPendingSave()
    }

    private static func encode(_ snapshot: NoteSessionSnapshot) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom(encodeDate)
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(snapshot)
    }

    private static func makeDateFormatter() -> ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }

    private static func encodeDate(_ date: Date, encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(makeDateFormatter().string(from: date))
    }

    private static func decodeDate(_ decoder: Decoder) throws -> Date {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        guard let date = makeDateFormatter().date(from: value) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid ISO8601 date: \(value)"
            )
        }
        return date
    }

    private static func atomicWrite(_ snapshot: NoteSessionSnapshot, to url: URL) {
        do {
            let data = try encode(snapshot)
            try data.write(to: url, options: .atomic)
        } catch {
            NSLog("StickyNotes: autosave failed: \(error)")
        }
    }
}
