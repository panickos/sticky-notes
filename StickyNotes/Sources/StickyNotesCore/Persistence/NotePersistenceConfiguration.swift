import Foundation

/// Persistence location and autosave policy (Spec 04).
public struct NotePersistenceConfiguration: Equatable, Sendable {
    public static let v1 = NotePersistenceConfiguration(
        directoryName: "StickyNotes",
        fileName: "notes.json",
        autosaveDebounceInterval: 1.5
    )

    public let directoryName: String
    public let fileName: String
    public let autosaveDebounceInterval: TimeInterval

    public init(
        directoryName: String,
        fileName: String,
        autosaveDebounceInterval: TimeInterval
    ) {
        self.directoryName = directoryName
        self.fileName = fileName
        self.autosaveDebounceInterval = autosaveDebounceInterval
    }

    public func storageDirectoryURL(fileManager: FileManager = .default) -> URL? {
        guard let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        return appSupport.appendingPathComponent(directoryName, isDirectory: true)
    }

    public func notesFileURL(fileManager: FileManager = .default) -> URL? {
        guard let directoryURL = storageDirectoryURL(fileManager: fileManager) else {
            return nil
        }
        return directoryURL.appendingPathComponent(fileName)
    }

    public func ensureStorageDirectoryExists(fileManager: FileManager = .default) throws {
        guard let directoryURL = storageDirectoryURL(fileManager: fileManager) else {
            throw NotePersistenceError.storageLocationUnavailable
        }
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
    }
}

public enum NotePersistenceError: Error, Equatable, Sendable {
    case storageLocationUnavailable
    case encodeFailed
    case writeFailed
}
