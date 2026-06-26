# Sticky Notes — Agent Context

**READ FIRST:** Specs in `specs/` are locked (approved 2026-06-12). Implementation progress lives in `PROGRESS.md`.

## What this is

macOS menu-bar utility: floating sticky notes always on top of other windows, markdown content, local persistence, global hotkeys. Solo personal tool — no cloud, no sharing.

## Current focus

**v1.0.0 released** — Specs 00–09 implemented; automated sign-off gate passes (157 tests). Future work uses [semantic versioning](https://semver.org/) (`MAJOR.MINOR.PATCH`); bump `DistributionConfiguration.v1.bundleVersion` and tag `v*` before publishing.

## Repo layout

```
specs/           Locked product specs (00–09)
PROGRESS.md      Task board, TDD log, lessons learned
StickyNotes/     Swift package + macOS app
  Sources/
    StickyNotesCore/   Testable panel configuration & factory
    StickyNotesApp/    Runnable menu-bar app
  Scripts/
    package-app.sh     Build release .app bundle
  Tests/
    StickyNotesCoreTests/
```

## Invariants (do not violate)

1. Notes must stay on top with **and without** AeroSpace running
2. Notes appear on **all AeroSpace workspaces** (`canJoinAllSpaces`)
3. Hidden state is **not** persisted — notes always visible on relaunch (Spec 00)
4. v1 is macOS-native Swift/SwiftUI only — no Electron/webview

## TDD convention

Write tests in `StickyNotesCoreTests` for any window-level configuration logic before implementing. Manual AeroSpace matrix (Spec 08 table) validates spike behavior that cannot be automated.
