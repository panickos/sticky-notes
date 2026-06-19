import CoreGraphics

/// Default appearance values for new notes (Spec 03).
public enum NoteAppearanceDefaults {
    public static let defaultWidth: CGFloat = 250
    public static let defaultHeight: CGFloat = 300
    public static let defaultColor: NoteColor = .yellow
    public static let colorPalette: [NoteColor] = NoteColor.allCases

    public static var defaultSize: CGSize {
        CGSize(width: defaultWidth, height: defaultHeight)
    }

    public static var defaultFrame: NoteFrame {
        NoteFrame(
            x: 0,
            y: 0,
            width: defaultWidth,
            height: defaultHeight
        )
    }
}
