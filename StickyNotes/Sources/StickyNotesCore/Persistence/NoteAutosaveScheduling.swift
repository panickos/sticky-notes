import Foundation

/// Schedules debounced persistence writes (Spec 04 autosave).
public protocol NoteAutosaveScheduling: Sendable {
    func scheduleSave(_ work: @escaping @Sendable () -> Void)
    func flushPendingSave()
}

/// Immediate scheduler for unit tests — only writes when flushed.
public final class TestNoteAutosaveScheduler: NoteAutosaveScheduling, @unchecked Sendable {
    private let lock = NSLock()
    private var pending: (@Sendable () -> Void)?

    public init() {}

    public var hasPendingSave: Bool {
        lock.withLock { pending != nil }
    }

    public func scheduleSave(_ work: @escaping @Sendable () -> Void) {
        lock.withLock { pending = work }
    }

    public func flushPendingSave() {
        lock.withLock {
            pending?()
            pending = nil
        }
    }
}

/// Production debounced scheduler (~1–2 s after last change).
public final class DebouncedNoteAutosaveScheduler: NoteAutosaveScheduling, @unchecked Sendable {
    private let interval: TimeInterval
    private let queue: DispatchQueue
    private let lock = NSLock()
    private var workItem: DispatchWorkItem?

    public init(interval: TimeInterval, queue: DispatchQueue = DispatchQueue(label: "StickyNotes.Autosave")) {
        self.interval = interval
        self.queue = queue
    }

    public func scheduleSave(_ work: @escaping @Sendable () -> Void) {
        queue.async { [self] in
            lock.withLock {
                workItem?.cancel()
                let item = DispatchWorkItem(block: work)
                workItem = item
                queue.asyncAfter(deadline: .now() + interval, execute: item)
            }
        }
    }

    public func flushPendingSave() {
        queue.sync {
            lock.withLock {
                workItem?.perform()
                workItem?.cancel()
                workItem = nil
            }
        }
    }
}
