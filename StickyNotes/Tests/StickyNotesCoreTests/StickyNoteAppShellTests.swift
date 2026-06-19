import Foundation
import Testing
@testable import StickyNotesCore

@Suite("MenuBarAction — Spec 05 required menu actions")
struct MenuBarActionTests {
    @Test("catalog defines every required v1 menu bar action")
    func requiredActionsAreCataloged() {
        let required: [MenuBarAction] = [
            .showHideNotes,
            .newNote,
            .startAtLogin,
            .quit,
        ]
        #expect(AppShellConfiguration.v1.requiredMenuActions == required)
    }
}

@Suite("AppShellConfiguration — no dock, menu bar only")
struct AppShellConfigurationTests {
    @Test("v1 uses accessory activation policy for no dock icon")
    func accessoryActivationPolicy() {
        #expect(AppShellConfiguration.v1.activationPolicy == .accessory)
    }

    @Test("show/hide menu title reflects note visibility")
    func showHideTitles() {
        let config = AppShellConfiguration.v1

        #expect(config.menuTitle(for: .showHideNotes, notesVisible: true) == "Hide Notes")
        #expect(config.menuTitle(for: .showHideNotes, notesVisible: false) == "Show Notes")
    }

    @Test("new note and quit menu titles are stable")
    func staticMenuTitles() {
        let config = AppShellConfiguration.v1

        #expect(config.menuTitle(for: .newNote, notesVisible: true) == "New Note")
        #expect(config.menuTitle(for: .newNote, notesVisible: false) == "New Note")
        #expect(config.menuTitle(for: .startAtLogin, notesVisible: true) == "Start at Login")
        #expect(config.menuTitle(for: .quit, notesVisible: true) == "Quit")
        #expect(config.menuTitle(for: .quit, notesVisible: false) == "Quit")
    }

    @Test("menu actions map to global hotkey actions where applicable")
    func hotkeyActionMapping() {
        let config = AppShellConfiguration.v1

        #expect(config.hotkeyAction(for: .showHideNotes) == .toggleVisibility)
        #expect(config.hotkeyAction(for: .newNote) == .createNewNote)
        #expect(config.hotkeyAction(for: .startAtLogin) == nil)
        #expect(config.hotkeyAction(for: .quit) == nil)
    }

    @Test("menu shortcut display strings match Spec 05 defaults")
    func menuShortcutDisplayStrings() {
        let config = AppShellConfiguration.v1
        let bindings = StickyNoteHotkeyBindings.v1Defaults

        #expect(
            config.menuShortcutDisplay(for: .showHideNotes)
                == bindings.chord(for: .toggleVisibility).displayString
        )
        #expect(
            config.menuShortcutDisplay(for: .newNote)
                == bindings.chord(for: .createNewNote).displayString
        )
        #expect(config.menuShortcutDisplay(for: .quit) == nil)
    }

    @Test("menu item titles include right-aligned shortcut hints")
    func menuItemTitlesWithShortcuts() {
        let config = AppShellConfiguration.v1
        let bindings = StickyNoteHotkeyBindings.v1Defaults
        let toggleShortcut = bindings.chord(for: .toggleVisibility).displayString
        let newNoteShortcut = bindings.chord(for: .createNewNote).displayString

        #expect(config.menuItemTitle(for: .showHideNotes, notesVisible: true) == "Hide Notes\t\(toggleShortcut)")
        #expect(config.menuItemTitle(for: .showHideNotes, notesVisible: false) == "Show Notes\t\(toggleShortcut)")
        #expect(config.menuItemTitle(for: .newNote, notesVisible: true) == "New Note\t\(newNoteShortcut)")
        #expect(config.menuItemTitle(for: .quit, notesVisible: true) == "Quit")
    }

    @Test("status bar icon uses note symbol for menu bar presence")
    func statusBarIconSymbol() {
        #expect(AppShellConfiguration.v1.statusBarIconSystemName == "note.text")
    }
}
