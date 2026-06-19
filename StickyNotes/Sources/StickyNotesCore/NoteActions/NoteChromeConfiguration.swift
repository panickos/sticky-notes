/// Borderless note chrome: hover controls and their actions (Spec 03).
public struct NoteChromeConfiguration: Equatable, Sendable {
    public static let v1 = NoteChromeConfiguration(
        hoverControls: [.delete, .changeColor, .duplicate]
    )

    public let hoverControls: [NoteHoverControl]

    public init(hoverControls: [NoteHoverControl]) {
        self.hoverControls = hoverControls
    }

    public func action(for control: NoteHoverControl) -> NoteAction {
        switch control {
        case .delete:
            return .delete
        case .changeColor:
            return .changeColor
        case .duplicate:
            return .duplicate
        }
    }
}
