import AppKit

/// Window configuration for sticky note panels that must stay on top of tiled windows
/// and remain visible across AeroSpace workspace switches (Spec 08).
public struct NotePanelConfiguration: Equatable, Sendable {
    public let level: NSWindow.Level
    public let collectionBehavior: NSWindow.CollectionBehavior
    public let styleMask: NSWindow.StyleMask
    public let isFloatingPanel: Bool
    public let becomesKeyOnlyIfNeeded: Bool
    public let hidesOnDeactivate: Bool

    public init(
        level: NSWindow.Level,
        collectionBehavior: NSWindow.CollectionBehavior,
        styleMask: NSWindow.StyleMask,
        isFloatingPanel: Bool,
        becomesKeyOnlyIfNeeded: Bool,
        hidesOnDeactivate: Bool
    ) {
        self.level = level
        self.collectionBehavior = collectionBehavior
        self.styleMask = styleMask
        self.isFloatingPanel = isFloatingPanel
        self.becomesKeyOnlyIfNeeded = becomesKeyOnlyIfNeeded
        self.hidesOnDeactivate = hidesOnDeactivate
    }

    /// Default configuration tuned for AeroSpace compatibility.
    ///
    /// Uses `.statusBar` level (above normal floating windows) and collection behavior
    /// that keeps notes on all workspaces without participating in window cycling.
    public static let aerospaceCompatible = NotePanelConfiguration(
        level: .statusBar,
        collectionBehavior: [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .stationary,
            .ignoresCycle,
        ],
        styleMask: [.borderless, .nonactivatingPanel, .resizable],
        isFloatingPanel: true,
        becomesKeyOnlyIfNeeded: true,
        hidesOnDeactivate: false
    )
}
