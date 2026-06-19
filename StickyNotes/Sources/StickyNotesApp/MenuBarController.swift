import AppKit
import StickyNotesCore

@MainActor
final class MenuBarController: NSObject {
    private let configuration = AppShellConfiguration.v1
    private let statusItem: NSStatusItem
    private weak var noteManager: NoteWindowManager?
    private let loginItemController: LoginItemController

    init(noteManager: NoteWindowManager, loginItemController: LoginItemController) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        self.noteManager = noteManager
        self.loginItemController = loginItemController
        super.init()
        configureStatusItem()
        rebuildMenu()
    }

    func refreshMenu() {
        rebuildMenu()
    }

    private func configureStatusItem() {
        guard let button = statusItem.button else { return }
        if let icon = bundledAppIcon() {
            icon.size = NSSize(width: 18, height: 18)
            button.image = icon
            button.image?.isTemplate = false
        } else {
            button.image = NSImage(
                systemSymbolName: configuration.statusBarIconSystemName,
                accessibilityDescription: "Sticky Notes"
            )
            button.image?.isTemplate = true
        }
    }

    private func bundledAppIcon() -> NSImage? {
        guard let iconURL = Bundle.main.url(forResource: "AppIcon", withExtension: "icns") else {
            return nil
        }
        return NSImage(contentsOf: iconURL)
    }

    private func rebuildMenu() {
        let menu = NSMenu()
        let notesVisible = noteManager?.notesAreVisible ?? true

        for action in configuration.requiredMenuActions {
            if action == .quit {
                menu.addItem(.separator())
            }

            let item = NSMenuItem(
                title: configuration.menuItemTitle(for: action, notesVisible: notesVisible),
                action: selector(for: action),
                keyEquivalent: ""
            )
            item.target = self

            if action == .startAtLogin {
                item.state = loginItemController.isEnabled ? .on : .off
            }

            menu.addItem(item)
        }

        statusItem.menu = menu
    }

    private func selector(for action: MenuBarAction) -> Selector {
        switch action {
        case .showHideNotes:
            return #selector(toggleNotesVisibility)
        case .newNote:
            return #selector(createNewNote)
        case .startAtLogin:
            return #selector(toggleStartAtLogin)
        case .quit:
            return #selector(quitApplication)
        }
    }

    @objc private func toggleNotesVisibility() {
        noteManager?.toggleAllVisibility()
        rebuildMenu()
    }

    @objc private func createNewNote() {
        noteManager?.createNote()
    }

    @objc private func toggleStartAtLogin() {
        loginItemController.toggle()
        rebuildMenu()
    }

    @objc private func quitApplication() {
        NSApp.terminate(nil)
    }
}
