# Spec 03: Note Model

**Status:** ✅ Approved  
**Depends on:** [02-platform-overlay](./02-platform-overlay.md)

## Content

| Requirement | Value |
|-------------|-------|
| Format | **Markdown** |
| Editing mode | **Live preview** while typing (WYSIWYG-style or split — implementation choice) |
| Attachments | Out of scope (no images/files in v1) |

## Per-note actions (v1)

| Action | Required |
|--------|----------|
| Create | ✅ |
| Delete | ✅ |
| Resize | ✅ |
| Change color | ✅ |
| Duplicate | ✅ |
| Lock position | ❌ |
| Pin/unpin always-on-top per note | ❌ (global always-on-top only) |

## Appearance

| Requirement | Value |
|-------------|-------|
| Colors | **Fixed preset palette** (e.g. yellow, pink, blue, green — exact set TBD) |
| Default size on create | **Medium fixed** (~250×300 pt — exact dimensions TBD) |
| Chrome | **Borderless** — controls appear on hover |
| Title bar | Minimal / on-hover (close, color, duplicate at minimum) |

## Interaction

| Requirement | Value |
|-------------|-------|
| Move | Drag anywhere on note (implementation defines drag handle vs full-surface) |
| Resize | Resize handle (corner or edge) |
| Focus | Click note to focus for editing; click outside to blur |

## Verification

- [x] Markdown with live preview
- [x] Preset colors, medium default, borderless chrome
- [x] Actions: create, delete, resize, color, duplicate only
- [ ] Exact color palette — pick during design
- [ ] Exact default dimensions — pick during design
