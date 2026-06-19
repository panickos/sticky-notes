/// Per-note and global note actions required in v1 (Spec 03).
public enum NoteAction: String, CaseIterable, Sendable {
    case create
    case delete
    case resize
    case changeColor
    case duplicate

    /// Actions exposed on per-note hover chrome.
    public static let v1PerNoteActions: [NoteAction] = [.delete, .changeColor, .duplicate]

    /// Actions triggered globally or via window chrome rather than hover controls.
    public static let v1GlobalActions: [NoteAction] = [.create, .resize]
}

/// Hover chrome controls mapped to per-note actions (Spec 03).
public enum NoteHoverControl: String, CaseIterable, Sendable {
    case delete
    case changeColor
    case duplicate
}
