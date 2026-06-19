import AppKit
import StickyNotesCore
import SwiftUI

@main
struct StickyNotesApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var noteManager: NoteWindowManager?
    private var menuBarController: MenuBarController?
    private var hotkeyRegistry: CarbonGlobalHotkeyRegistry?
    private var persistenceStore: NotePersistenceStore?
    private var loginItemController: LoginItemController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        do {
            let store = try NotePersistenceStore()
            persistenceStore = store

            let loginItems = LoginItemController()
            loginItemController = loginItems
            loginItems.applyOnLaunch()

            let manager = NoteWindowManager(persistenceStore: store)
            noteManager = manager
            menuBarController = MenuBarController(
                noteManager: manager,
                loginItemController: loginItems
            )
            manager.onVisibilityChanged = { [weak self] in
                self?.menuBarController?.refreshMenu()
            }

            Task {
                await manager.bootstrap()
            }

            let registry = CarbonGlobalHotkeyRegistry(handlerQueue: .main)
            hotkeyRegistry = registry

            try registry.register(
                bindings: .v1Defaults,
                handlers: [
                    .toggleVisibility: { [weak manager] in
                        Task { @MainActor in
                            manager?.toggleAllVisibility()
                        }
                    },
                    .createNewNote: { [weak manager] in
                        Task { @MainActor in
                            manager?.createNote()
                        }
                    },
                ]
            )
        } catch {
            NSLog("StickyNotes: failed to start: \(error)")
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        guard let noteManager else { return }
        let semaphore = DispatchSemaphore(value: 0)
        Task {
            await noteManager.flushOnTerminate()
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: .now() + 2)
    }
}
