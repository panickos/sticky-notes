# Spec 08: AeroSpace Window Manager Compatibility

**Status:** ✅ Approved  
**Depends on:** [02-platform-overlay](./02-platform-overlay.md), [06-tech-stack](./06-tech-stack.md)

## Requirement

The app must behave **the same** whether or not [AeroSpace](https://github.com/nikitabobko/AeroSpace) is running:

- Sticky notes remain **on top of all windows** (tiled and floating)
- Notes are **not absorbed into AeroSpace tiling layouts**
- Notes are **not repositioned or re-stacked** by workspace switches, focus changes, or layout toggles
- Notes are **visible on all AeroSpace workspaces** (follow across workspace switches)
- Global show/hide hotkey works while AeroSpace is active

This is a **hard v1 requirement** — daily use assumes AeroSpace is the system window manager.

## Context

AeroSpace is an i3-like tiling WM for macOS. Floating windows can slide behind tiled windows under AeroSpace; native always-on-top for floats is a [long-standing open request](https://github.com/nikitabobko/AeroSpace/issues/4). Our app must compensate at the window level, not rely on AeroSpace implementing float-on-top.

## Expected behavior (acceptance tests)

Manual test matrix — all must pass with AeroSpace running:

| Scenario | Expected |
|----------|----------|
| Focus a tiled app window | Notes stay visible above it |
| Switch AeroSpace workspace | Notes remain visible on the new workspace, in place, still on top |
| Toggle tiling ↔ floating on another app | Notes unaffected; still on top |
| Create / drag / resize a note | AeroSpace does not snap or retile the note |
| Global show/hide hotkey | Works from any workspace |
| Multi-monitor (if applicable) | Notes stay on correct screen, still on top |

## Implementation guidance (spike → build)

1. **Window type** — `NSPanel` (non-activating panel) per note, not standard `NSWindow`
2. **Window level** — Elevated level above normal apps; evaluate `.floating`, `.statusBar`, and higher levels. Community references (e.g. SketchyBar) suggest macOS-version-specific tuning may be needed
3. **Collection behavior** — `canJoinAllSpaces` so notes appear on **all workspaces**; validate `fullScreenAuxiliary` and other flags against AeroSpace
4. **Non-participation in tiling** — Windows should present as floating overlays; avoid behaviors that make AeroSpace treat notes as tile candidates
5. **No focus side effects** — Clicking a note to edit must not break AeroSpace focus in unexpected ways (spike interaction with `focus-follows-mouse` if enabled)

## Optional user config (document in README)

Recommend AeroSpace `on-window-detected` so note windows are explicitly floating (and sticky when available):

```toml
[[on-window-detected]]
if.app-id = 'dev.stickynotes.app'
run = ['layout floating']
```

When AeroSpace merges [layout sticky for floating windows](https://github.com/nikitabobko/AeroSpace/pull/2083), update docs to:

```toml
run = ['layout floating', 'layout sticky']
```

App must still work **without** this config — config is a belt-and-suspenders aid, not a requirement.

## Spike findings (2026-06-18)

Implementation in `StickyNotes/Sources/StickyNotesCore/`:

- **`NotePanelConfiguration.aerospaceCompatible`** — `.statusBar` level, all-spaces collection behavior
- **Critical:** set `panel.level` *after* `isFloatingPanel = true`, or AppKit downgrades to `.floating` (3)
- TDD: 96 automated tests; manual Spec 08 matrix confirmed 2026-06-18

## Verification

- [x] User confirms this spec captures the AeroSpace requirement
- [x] Notes visible across all AeroSpace workspaces (manual confirm 2026-06-18)
- [x] Spike: automated panel configuration tests pass (`StickyNotesCoreTests`)
- [x] Spike: single note stays on top over tiled Chrome/Terminal with AeroSpace active
- [x] Spike: workspace switch does not lose or bury notes
- [x] Full test matrix passes before v1 sign-off (confirmed 2026-06-18)
