import AppKit
import Carbon
import SwiftUI

/// AppKit text editor for sticky notes — reliable first responder in non-activating panels.
struct NoteTextEditor: NSViewRepresentable {
    @Binding var text: String
    var isEditing: Bool
    var onBeginEditing: () -> Void
    var onFinishEditing: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = false

        let textView = NoteTextEditorView()
        textView.onBeginEditing = {
            context.coordinator.parent.onBeginEditing()
        }
        textView.onFinishEditing = {
            context.coordinator.parent.onFinishEditing()
        }
        configure(textView, coordinator: context.coordinator)
        context.coordinator.textView = textView
        scrollView.documentView = textView

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NoteTextEditorView else { return }
        context.coordinator.parent = self
        textView.onBeginEditing = {
            context.coordinator.parent.onBeginEditing()
        }
        textView.onFinishEditing = {
            context.coordinator.parent.onFinishEditing()
        }
        if textView.string != text {
            textView.string = text
        }

        let becameEditing = isEditing && !context.coordinator.wasEditing
        context.coordinator.wasEditing = isEditing

        if becameEditing {
            context.coordinator.focusWhenReady(textView)
        } else if isEditing, textView.window?.firstResponder != textView {
            textView.window?.makeFirstResponder(textView)
        }
    }

    private func configure(_ textView: NSTextView, coordinator: Coordinator) {
        textView.delegate = coordinator
        textView.isRichText = false
        textView.isEditable = true
        textView.isSelectable = true
        textView.drawsBackground = false
        textView.backgroundColor = .clear
        textView.font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        textView.textColor = .black
        textView.insertionPointColor = .black
        textView.textContainer?.lineFragmentPadding = 4
        textView.textContainerInset = CGSize(width: 2, height: 4)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainer?.widthTracksTextView = true
        textView.string = text
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        var parent: NoteTextEditor
        weak var textView: NSTextView?
        var wasEditing = false

        init(parent: NoteTextEditor) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
        }

        func focusWhenReady(_ textView: NSTextView) {
            Task { @MainActor in
                Self.focus(textView)
            }
        }

        @MainActor
        private static func focus(_ textView: NSTextView) {
            NSApp.activate(ignoringOtherApps: true)
            textView.window?.makeKeyAndOrderFront(nil)
            textView.window?.makeFirstResponder(textView)

            if textView.window?.firstResponder != textView {
                Task { @MainActor in
                    textView.window?.makeFirstResponder(textView)
                }
            }
        }
    }
}

/// Ensures click-to-edit activates the app and promotes the text view to first responder.
final class NoteTextEditorView: NSTextView {
    var onBeginEditing: (() -> Void)?
    var onFinishEditing: (() -> Void)?

    override func mouseDown(with event: NSEvent) {
        onBeginEditing?()
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
        window?.makeFirstResponder(self)
        super.mouseDown(with: event)
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == UInt16(kVK_Escape) {
            onFinishEditing?()
            window?.makeFirstResponder(nil)
            return
        }
        super.keyDown(with: event)
    }

    override var acceptsFirstResponder: Bool { true }
}
