import AppKit
import SwiftUI

enum WindowDragMode: Equatable {
    /// Tracks mouse delta as a shadow origin; the window manager owns on-screen position (Spec 09 snap).
    case shadowTracked
    /// Small movement drags via shadow tracking; mouse up without drag invokes click.
    case dragOrClick
}

/// Window drag from a SwiftUI overlay. Does not use `performDrag` so snap can lock display while tracking shadow.
struct WindowDragHandle: NSViewRepresentable {
    var mode: WindowDragMode = .shadowTracked
    var onMouseDown: () -> Void
    var onDragBegin: (() -> Void)?
    var onDragEnd: (() -> Void)?
    var onShadowDrag: ((CGPoint) -> Void)?
    var onClick: (() -> Void)?

    func makeNSView(context: Context) -> WindowDragHandleView {
        let view = WindowDragHandleView()
        view.mode = mode
        view.onMouseDown = onMouseDown
        view.onDragBegin = onDragBegin
        view.onDragEnd = onDragEnd
        view.onShadowDrag = onShadowDrag
        view.onClick = onClick
        return view
    }

    func updateNSView(_ nsView: WindowDragHandleView, context: Context) {
        nsView.mode = mode
        nsView.onMouseDown = onMouseDown
        nsView.onDragBegin = onDragBegin
        nsView.onDragEnd = onDragEnd
        nsView.onShadowDrag = onShadowDrag
        nsView.onClick = onClick
    }
}

final class WindowDragHandleView: NSView {
    var mode: WindowDragMode = .shadowTracked
    var onMouseDown: (() -> Void)?
    var onDragBegin: (() -> Void)?
    var onDragEnd: (() -> Void)?
    var onShadowDrag: ((CGPoint) -> Void)?
    var onClick: (() -> Void)?

    private var dragStartMouse: NSPoint?
    private var dragStartWindowOrigin: NSPoint?
    private var didDrag = false

    private let dragThreshold: CGFloat = 4

    override func mouseDown(with event: NSEvent) {
        onMouseDown?()

        dragStartMouse = NSEvent.mouseLocation
        dragStartWindowOrigin = window?.frame.origin
        didDrag = false

        if mode == .shadowTracked {
            onDragBegin?()
        }
    }

    override func mouseDragged(with event: NSEvent) {
        guard let dragStartMouse, let dragStartWindowOrigin else { return }

        let current = NSEvent.mouseLocation
        let deltaX = current.x - dragStartMouse.x
        let deltaY = current.y - dragStartMouse.y

        if mode == .dragOrClick, !didDrag, hypot(deltaX, deltaY) < dragThreshold {
            return
        }

        if !didDrag {
            onDragBegin?()
            didDrag = true
        }

        let shadowOrigin = NSPoint(
            x: dragStartWindowOrigin.x + deltaX,
            y: dragStartWindowOrigin.y + deltaY
        )
        onShadowDrag?(shadowOrigin)
    }

    override func mouseUp(with event: NSEvent) {
        if didDrag {
            onDragEnd?()
        } else if mode == .dragOrClick {
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
