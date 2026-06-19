import Foundation
import Testing
@testable import StickyNotesCore

@Suite("NoteDragHandleConfiguration — Spec 03 move interaction")
struct NoteDragHandleConfigurationTests {
    @Test("v1 drag handle uses the note header region")
    func headerRegion() {
        #expect(NoteDragHandleConfiguration.v1.region == .noteHeader)
    }

    @Test("v1 drag handle has a usable minimum height")
    func minimumHeight() {
        #expect(NoteDragHandleConfiguration.v1.minimumHeightPoints >= 28)
    }

    @Test("v1 drag handle shows a grip indicator")
    func gripIndicator() {
        #expect(NoteDragHandleConfiguration.v1.showsGripIndicator)
    }
}

@Suite("NoteInteractionConfiguration — Spec 03 focus and move")
struct NoteInteractionConfigurationTests {
    @Test("v1 allows dragging from header and body in view mode")
    func draggableRegions() {
        #expect(NoteInteractionConfiguration.v1.draggableRegions == [.noteHeader, .noteBody])
    }

    @Test("v1 focuses from drag handle, preview, and editor")
    func focusRegions() {
        #expect(
            NoteInteractionConfiguration.v1.focusRegions
                == [.dragHandle, .markdownPreview, .editor]
        )
    }

    @Test("v1 embeds drag handle configuration")
    func dragHandleConfiguration() {
        #expect(NoteInteractionConfiguration.v1.dragHandle == .v1)
    }

    @Test("region helpers identify draggable and focusable surfaces")
    func regionHelpers() {
        let config = NoteInteractionConfiguration.v1
        #expect(config.isDraggable(.noteHeader))
        #expect(config.isDraggable(.noteBody))
        #expect(config.isFocusable(.dragHandle))
        #expect(config.isFocusable(.markdownPreview))
        #expect(config.isFocusable(.editor))
        #expect(config.draggableRegions.count == 2)
        #expect(config.focusRegions.count == 3)
    }
}
