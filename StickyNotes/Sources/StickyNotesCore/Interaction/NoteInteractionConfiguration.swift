/// Regions of a note window that initiate panel drag (Spec 03).
public enum NoteDraggableRegion: String, CaseIterable, Sendable {
    case noteHeader
    case noteBody
}

/// Regions of a note window that focus the note for editing (Spec 03).
public enum NoteFocusRegion: String, CaseIterable, Sendable {
    case dragHandle
    case markdownPreview
    case editor
}

/// Drag-handle placement and chrome for borderless note move (Spec 03).
public struct NoteDragHandleConfiguration: Equatable, Sendable {
    public static let v1 = NoteDragHandleConfiguration(
        region: .noteHeader,
        minimumHeightPoints: 32,
        showsGripIndicator: true
    )

    public let region: NoteDraggableRegion
    public let minimumHeightPoints: Int
    public let showsGripIndicator: Bool

    public init(
        region: NoteDraggableRegion,
        minimumHeightPoints: Int,
        showsGripIndicator: Bool
    ) {
        self.region = region
        self.minimumHeightPoints = minimumHeightPoints
        self.showsGripIndicator = showsGripIndicator
    }
}

/// Focus and move interaction policy for borderless notes (Spec 03).
public struct NoteInteractionConfiguration: Equatable, Sendable {
    public static let v1 = NoteInteractionConfiguration(
        dragHandle: .v1,
        draggableRegions: [.noteHeader, .noteBody],
        focusRegions: [.dragHandle, .markdownPreview, .editor]
    )

    public let dragHandle: NoteDragHandleConfiguration
    public let draggableRegions: [NoteDraggableRegion]
    public let focusRegions: [NoteFocusRegion]

    public init(
        dragHandle: NoteDragHandleConfiguration,
        draggableRegions: [NoteDraggableRegion],
        focusRegions: [NoteFocusRegion]
    ) {
        self.dragHandle = dragHandle
        self.draggableRegions = draggableRegions
        self.focusRegions = focusRegions
    }

    public func isDraggable(_ region: NoteDraggableRegion) -> Bool {
        draggableRegions.contains(region)
    }

    public func isFocusable(_ region: NoteFocusRegion) -> Bool {
        focusRegions.contains(region)
    }
}
