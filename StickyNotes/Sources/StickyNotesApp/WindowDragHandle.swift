import AppKit
import SwiftUI

enum WindowDragMode: Equatable {
    /// Header-style: native panel drag begins on mouse down.
    case immediate
    /// Body-style: small movement drags; mouse up without drag invokes click.
    case dragOrClick
}

/// Native window drag from a SwiftUI overlay.
struct WindowDragHandle: NSViewRepresentable {
    var mode: WindowDragMode = .immediate
    var onMouseDown: () -> Void
    var onClick: (() -> Void)?

    func makeNSView(context: Context) -> WindowDragHandleView {
        let view = WindowDragHandleView()
        view.mode = mode
        view.onMouseDown = onMouseDown
        view.onClick = onClick
        return view
    }

    func updateNSView(_ nsView: WindowDragHandleView, context: Context) {
        nsView.mode = mode
        nsView.onMouseDown = onMouseDown
        nsView.onClick = onClick
    }
}

final class WindowDragHandleView: NSView {
    var mode: WindowDragMode = .immediate
    var onMouseDown: (() -> Void)?
    var onClick: (() -> Void)?

    private var dragStartMouse: NSPoint?
    private var dragStartWindowOrigin: NSPoint?
    private var didDrag = false

    private let dragThreshold: CGFloat = 4

    override func mouseDown(with event: NSEvent) {
        onMouseDown?()

        switch mode {
        case .immediate:
            window?.performDrag(with: event)
        case .dragOrClick:
            dragStartMouse = NSEvent.mouseLocation
            dragStartWindowOrigin = window?.frame.origin
            didDrag = false
        }
    }

    override func mouseDragged(with event: NSEvent) {
        guard mode == .dragOrClick else { return }
        guard let dragStartMouse, let dragStartWindowOrigin, let window else { return }

        let current = NSEvent.mouseLocation
        let deltaX = current.x - dragStartMouse.x
        let deltaY = current.y - dragStartMouse.y

        if !didDrag, hypot(deltaX, deltaY) < dragThreshold {
            return
        }

        didDrag = true
        window.setFrameOrigin(
            NSPoint(
                x: dragStartWindowOrigin.x + deltaX,
                y: dragStartWindowOrigin.y + deltaY
            )
        )
    }

    override func mouseUp(with event: NSEvent) {
        guard mode == .dragOrClick else { return }

        if !didDrag {
            onClick?()
        }

        dragStartMouse = nil
        dragStartWindowOrigin = nil
        didDrag = false
    }

    override func scrollWheel(with event: NSEvent) {
        nextResponder?.scrollWheel(with: event)
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        bounds.contains(point) ? self : nil
    }
}
