import MarkdownUI
import StickyNotesCore
import SwiftUI

struct StickyNoteView: View {
    let note: StickyNote
    @ObservedObject var editingState: NoteEditingState
    let toggleShortcut: String
    let newNoteShortcut: String
    let onContentChange: (String) -> Void
    let onDelete: () -> Void
    let onDuplicate: () -> Void
    let onColorChange: (NoteColor) -> Void
    let onFocus: () -> Void

    @State private var markdown: String
    @State private var noteColor: NoteColor
    @State private var isHovering = false

    private let interactionConfiguration = NoteInteractionConfiguration.v1

    init(
        note: StickyNote,
        editingState: NoteEditingState,
        toggleShortcut: String,
        newNoteShortcut: String,
        onContentChange: @escaping (String) -> Void,
        onDelete: @escaping () -> Void,
        onDuplicate: @escaping () -> Void,
        onColorChange: @escaping (NoteColor) -> Void,
        onFocus: @escaping () -> Void
    ) {
        self.note = note
        self.editingState = editingState
        self.toggleShortcut = toggleShortcut
        self.newNoteShortcut = newNoteShortcut
        self.onContentChange = onContentChange
        self.onDelete = onDelete
        self.onDuplicate = onDuplicate
        self.onColorChange = onColorChange
        self.onFocus = onFocus
        _markdown = State(initialValue: note.content)
        _noteColor = State(initialValue: note.color)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(noteColor.fillColor)
                .shadow(color: .black.opacity(0.15), radius: 6, y: 2)

            VStack(alignment: .leading, spacing: 0) {
                noteHeader

                Divider()
                    .padding(.horizontal, 8)

                Group {
                    if editingState.isEditing {
                        NoteTextEditor(
                            text: $markdown,
                            isEditing: editingState.isEditing,
                            onBeginEditing: beginEditing,
                            onFinishEditing: finishEditing
                        )
                        .onChange(of: markdown) { _, newValue in
                            onContentChange(newValue)
                        }
                    } else {
                        markdownPreview
                            .overlay {
                                if interactionConfiguration.isDraggable(.noteBody) {
                                    WindowDragHandle(
                                        mode: .dragOrClick,
                                        onMouseDown: onFocus,
                                        onClick: beginEditing
                                    )
                                }
                            }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, editingState.isEditing ? 8 : 0)
                .padding(.bottom, 8)
            }
        }
        .overlay(alignment: .topTrailing) {
            if isHovering {
                NoteHoverChrome(
                    selectedColor: noteColor,
                    onDelete: onDelete,
                    onDuplicate: onDuplicate,
                    onColorChange: { color in
                        noteColor = color
                        onColorChange(color)
                    }
                )
                .padding(8)
            }
        }
        .frame(minWidth: 200, minHeight: 240)
        .onHover { hovering in
            isHovering = hovering
        }
    }

    private var markdownPreview: some View {
        ScrollView {
            Markdown(markdown)
                .markdownTextStyle(\.text) {
                    FontSize(13)
                    ForegroundColor(.black)
                }
                .markdownBlockStyle(\.codeBlock) { configuration in
                    ScrollView(.horizontal, showsIndicators: false) {
                        configuration.label
                            .markdownTextStyle {
                                FontFamilyVariant(.monospaced)
                                FontSize(.em(0.85))
                            }
                            .padding(8)
                    }
                    .background(Color.black.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
        }
    }

    private func beginEditing() {
        guard interactionConfiguration.isFocusable(.markdownPreview) else { return }
        onFocus()
        editingState.isEditing = true
    }

    private func finishEditing() {
        editingState.isEditing = false
    }

    private var noteHeader: some View {
        let dragHandle = interactionConfiguration.dragHandle

        return HStack(spacing: 6) {
            if dragHandle.showsGripIndicator {
                Image(systemName: "line.3.horizontal")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityLabel("Drag note")
            }

            Text(noteTitle)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.black)
                .lineLimit(1)

            Spacer(minLength: 0)

            Text("\(toggleShortcut) hide · \(newNoteShortcut) new")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .lineLimit(1)
        }
        .frame(minHeight: CGFloat(dragHandle.minimumHeightPoints))
        .padding(.horizontal, 12)
        .padding(.top, 4)
        .contentShape(Rectangle())
        .overlay {
            if interactionConfiguration.isDraggable(dragHandle.region) {
                WindowDragHandle(mode: .immediate, onMouseDown: onFocus)
            }
        }
    }

    private var noteTitle: String {
        let trimmed = markdown.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let firstLine = trimmed.split(separator: "\n", maxSplits: 1).first else {
            return "Note"
        }
        let title = firstLine.trimmingCharacters(in: CharacterSet(charactersIn: "# ").union(.whitespaces))
        return title.isEmpty ? "Note" : String(title.prefix(40))
    }
}

private struct NoteHoverChrome: View {
    let selectedColor: NoteColor
    let onDelete: () -> Void
    let onDuplicate: () -> Void
    let onColorChange: (NoteColor) -> Void

    private let configuration = NoteChromeConfiguration.v1

    var body: some View {
        HStack(spacing: 8) {
            ForEach(configuration.hoverControls, id: \.self) { control in
                controlView(for: control)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.ultraThinMaterial, in: Capsule())
    }

    @ViewBuilder
    private func controlView(for control: NoteHoverControl) -> some View {
        switch control {
        case .delete:
            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.caption.weight(.semibold))
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)
            .help("Delete note")

        case .duplicate:
            Button(action: onDuplicate) {
                Image(systemName: "plus.square.on.square")
                    .font(.caption.weight(.semibold))
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)
            .help("Duplicate note")

        case .changeColor:
            HStack(spacing: 4) {
                ForEach(NoteAppearanceDefaults.colorPalette, id: \.self) { color in
                    Button {
                        onColorChange(color)
                    } label: {
                        Circle()
                            .fill(color.fillColor)
                            .frame(width: 14, height: 14)
                            .overlay {
                                if color == selectedColor {
                                    Circle()
                                        .strokeBorder(.primary.opacity(0.6), lineWidth: 1.5)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .help("Change color")
        }
    }
}
