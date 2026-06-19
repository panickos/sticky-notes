# Spec 07: v1 Boundaries & Definition of Done

**Status:** ✅ Approved  
**Depends on:** All prior specs

## In scope (v1)

- macOS menu-bar sticky note overlay
- Always-on-top, draggable, resizable notes
- Markdown with live preview
- Preset color palette
- Create, delete, resize, color, duplicate
- Debounced local persistence + full session restore
- Global hotkeys: toggle visibility + new note
- Polished, daily-usable Mac-native UX
- **AeroSpace window manager compatibility** (notes on top regardless)

## Out of scope (v1) — confirmed

| Item | Status |
|------|--------|
| Cloud sync / accounts | ❌ Out |
| Sharing / collaboration | ❌ Out |
| Image & file attachments | ❌ Out |
| Windows / Linux | ❌ Out |

## Not discussed — treat as deferred unless you say otherwise

| Item | Default assumption |
|------|-------------------|
| Full-text search across notes | Deferred (not v1) |
| Dark mode / app theming | Deferred (note colors only) |
| Export / import | Deferred |
| Note titles / naming | Deferred (content-only) |
| Trash / undo delete | Deferred (confirm if you want undo) |
| iCloud backup | Deferred |

## Definition of done

v1 is complete when:

1. All specs 01–06 acceptance criteria are met
2. App runs as menu-bar accessory with no dock icon
3. Notes persist across relaunch with positions and content intact
4. Global show/hide and new-note hotkeys work from any app
5. UX feels polished enough for **daily personal use** (your bar)
6. AeroSpace test matrix in [08-aerospace-compatibility](./08-aerospace-compatibility.md) passes

## Approval checklist

Approved 2026-06-12:

- [x] Spec 01 — Core vision
- [x] Spec 02 — Platform & overlay
- [x] Spec 03 — Note model
- [x] Spec 04 — Persistence
- [x] Spec 05 — System integration
- [x] Spec 06 — Tech stack
- [x] Spec 07 — Boundaries
- [x] Spec 08 — AeroSpace compatibility
