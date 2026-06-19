import AppKit
import Testing
@testable import StickyNotesCore

@Suite("NotePanelConfiguration — AeroSpace compatibility invariants")
struct NotePanelConfigurationTests {
    @Test("aerospaceCompatible uses statusBar level or higher")
    func windowLevelIsElevated() {
        let config = NotePanelConfiguration.aerospaceCompatible
        #expect(config.level.rawValue >= NSWindow.Level.statusBar.rawValue)
    }

    @Test("aerospaceCompatible joins all spaces")
    func joinsAllSpaces() {
        let config = NotePanelConfiguration.aerospaceCompatible
        #expect(config.collectionBehavior.contains(.canJoinAllSpaces))
    }

    @Test("aerospaceCompatible is stationary across workspace switches")
    func isStationary() {
        let config = NotePanelConfiguration.aerospaceCompatible
        #expect(config.collectionBehavior.contains(.stationary))
    }

    @Test("aerospaceCompatible ignores window cycle (Cmd+Tab)")
    func ignoresCycle() {
        let config = NotePanelConfiguration.aerospaceCompatible
        #expect(config.collectionBehavior.contains(.ignoresCycle))
    }

    @Test("aerospaceCompatible shows on fullscreen auxiliary spaces")
    func fullScreenAuxiliary() {
        let config = NotePanelConfiguration.aerospaceCompatible
        #expect(config.collectionBehavior.contains(.fullScreenAuxiliary))
    }

    @Test("aerospaceCompatible uses non-activating borderless resizable panel")
    func panelStyleMask() {
        let config = NotePanelConfiguration.aerospaceCompatible
        #expect(config.styleMask.contains(.borderless))
        #expect(config.styleMask.contains(.nonactivatingPanel))
        #expect(config.styleMask.contains(.resizable))
    }

    @Test("aerospaceCompatible is a floating panel that becomes key only when needed")
    func floatingPanelBehavior() {
        let config = NotePanelConfiguration.aerospaceCompatible
        #expect(config.isFloatingPanel)
        #expect(config.becomesKeyOnlyIfNeeded)
        #expect(!config.hidesOnDeactivate)
    }
}

@Suite("NotePanelFactory")
@MainActor
struct NotePanelFactoryTests {
    @Test("factory applies configuration to NSPanel")
    func appliesConfiguration() {
        let config = NotePanelConfiguration.aerospaceCompatible
        let rect = NSRect(x: 100, y: 200, width: 240, height: 180)

        let panel = NotePanelFactory.makePanel(configuration: config, contentRect: rect)

        #expect(panel.level == config.level)
        #expect(panel.collectionBehavior == config.collectionBehavior)
        #expect(panel.styleMask == config.styleMask)
        #expect(panel.isFloatingPanel == config.isFloatingPanel)
        #expect(panel.becomesKeyOnlyIfNeeded == config.becomesKeyOnlyIfNeeded)
        #expect(panel.hidesOnDeactivate == config.hidesOnDeactivate)
        #expect(panel.isOpaque == false)
        #expect(panel.backgroundColor == .clear)
        #expect(panel.hasShadow == true)
        #expect(panel.isReleasedWhenClosed == false)
    }

    @Test("factory sets frame from content rect")
    func setsFrame() {
        let rect = NSRect(x: 50, y: 75, width: 300, height: 200)
        let panel = NotePanelFactory.makePanel(
            configuration: .aerospaceCompatible,
            contentRect: rect
        )
        #expect(panel.frame == rect)
    }

    @Test("factory preserves elevated level after isFloatingPanel assignment")
    func levelSetAfterFloatingPanelFlag() {
        let panel = NotePanelFactory.makePanel(
            configuration: .aerospaceCompatible,
            contentRect: NSRect(x: 0, y: 0, width: 200, height: 150)
        )
        #expect(panel.level == .statusBar)
    }

    @Test("factory panel can become key for text editing")
    func canBecomeKey() {
        let panel = NotePanelFactory.makePanel(
            configuration: .aerospaceCompatible,
            contentRect: NSRect(x: 0, y: 0, width: 200, height: 150)
        )
        #expect(panel.canBecomeKey)
        #expect(!panel.canBecomeMain)
    }
}
