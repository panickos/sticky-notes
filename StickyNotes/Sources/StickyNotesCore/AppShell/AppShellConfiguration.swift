/// App shell configuration: menu bar presence and no-dock policy (Spec 05).
public struct AppShellConfiguration: Equatable, Sendable {
    public static let v1 = AppShellConfiguration(
        activationPolicy: .accessory,
        requiredMenuActions: [.showHideNotes, .newNote, .startAtLogin, .quit],
        statusBarIconSystemName: "note.text"
    )

    public let activationPolicy: AppActivationPolicy
    public let requiredMenuActions: [MenuBarAction]
    public let statusBarIconSystemName: String

    public init(
        activationPolicy: AppActivationPolicy,
        requiredMenuActions: [MenuBarAction],
        statusBarIconSystemName: String
    ) {
        self.activationPolicy = activationPolicy
        self.requiredMenuActions = requiredMenuActions
        self.statusBarIconSystemName = statusBarIconSystemName
    }

    public func menuTitle(for action: MenuBarAction, notesVisible: Bool) -> String {
        switch action {
        case .showHideNotes:
            return notesVisible ? "Hide Notes" : "Show Notes"
        case .newNote:
            return "New Note"
        case .startAtLogin:
            return "Start at Login"
        case .quit:
            return "Quit"
        }
    }

    public func hotkeyAction(for action: MenuBarAction) -> StickyNoteHotkeyAction? {
        switch action {
        case .showHideNotes:
            return .toggleVisibility
        case .newNote:
            return .createNewNote
        case .startAtLogin, .quit:
            return nil
        }
    }

    public func menuShortcutDisplay(for action: MenuBarAction) -> String? {
        guard let hotkeyAction = hotkeyAction(for: action) else {
            return nil
        }
        return StickyNoteHotkeyBindings.v1Defaults.chord(for: hotkeyAction).displayString
    }

    /// Menu item title with shortcut right-aligned via tab (display only; hotkeys stay Carbon-global).
    public func menuItemTitle(for action: MenuBarAction, notesVisible: Bool) -> String {
        let title = menuTitle(for: action, notesVisible: notesVisible)
        guard let shortcut = menuShortcutDisplay(for: action) else {
            return title
        }
        return "\(title)\t\(shortcut)"
    }
}
