/// Menu bar actions required for v1 (Spec 05).
public enum MenuBarAction: String, CaseIterable, Sendable, Hashable {
    case showHideNotes
    case newNote
    case startAtLogin
    case quit
}
