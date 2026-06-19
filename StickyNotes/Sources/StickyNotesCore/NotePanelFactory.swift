import AppKit

public enum NotePanelFactory {
    @MainActor
    public static func makePanel(
        configuration: NotePanelConfiguration,
        contentRect: NSRect
    ) -> NSPanel {
        let panel = NotePanel(
            contentRect: contentRect,
            styleMask: configuration.styleMask,
            backing: .buffered,
            defer: false
        )

        panel.isFloatingPanel = configuration.isFloatingPanel
        panel.becomesKeyOnlyIfNeeded = configuration.becomesKeyOnlyIfNeeded
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.isReleasedWhenClosed = false
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.hidesOnDeactivate = configuration.hidesOnDeactivate

        // Set level last — NSPanel may reset to .floating when isFloatingPanel is assigned.
        panel.level = configuration.level
        panel.collectionBehavior = configuration.collectionBehavior

        return panel
    }
}
