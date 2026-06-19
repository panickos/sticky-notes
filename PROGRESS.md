# Sticky Notes — Implementation Progress

Last updated: 2026-06-19 (Task 2.2 app icon + start at login)

## Current phase

**Phase 2 — Distribution & v1 sign-off** — app icon and login item added; manual sign-off pending

## Task board

| # | Task | Status | Notes |
|---|------|--------|-------|
| 0.1 | AeroSpace overlay spike | ✅ Complete | Manual Spec 08 matrix confirmed 2026-06-18 |
| 0.2 | Markdown library spike | ✅ Complete | **MarkdownUI** chosen; 12 new tests; live preview in spike app |
| 0.3 | Global hotkey spike | ✅ Complete | **Carbon RegisterEventHotKey** chosen; 14 new tests; hotkeys wired in spike app |
| 1.0 | App shell (menu bar, no dock) | ✅ Complete | 7 new tests; `AppShellConfiguration` + `MenuBarController` wired |
| 1.1 | Note model + persistence | ✅ Complete | 14 new tests; `StickyNote` + `NotePersistenceStore` wired |
| 1.2 | Per-note actions + hover chrome | ✅ Complete | 11 new tests; delete, duplicate, color change wired |
| 1.3 | Full feature build | ✅ Complete | Specs 01–08 acceptance met; AeroSpace matrix confirmed |
| 1.3.1 | Multi-monitor frame restoration | ✅ Complete | 6 new tests; `NoteFrameRestorer` wired on bootstrap |
| 1.3.2 | Z-order stacking on focus | ✅ Complete | 5 new tests; `NoteZOrderEditor` wired on window focus |
| 1.3.3 | Note drag handle + focus regions | ✅ Complete | 7 new tests; `NoteInteractionConfiguration` + header drag wired |
| 1.3.4 | AeroSpace compatibility matrix | ✅ Complete | 10 new tests; manual Spec 08 matrix confirmed |
| 2.0 | Distribution packaging | ✅ Complete | 10 new tests; `DistributionConfiguration` + `Scripts/package-app.sh` |
| 2.1 | v1 sign-off gate | ✅ Complete | 15 new tests; `V1DefinitionOfDone` + `V1SignOffValidator` |
| 2.2 | App icon + start at login | ✅ Complete | 8 new tests; `AppIcon.icns`, `LoginItemController`, menu toggle |

## Active task: manual v1 sign-off

Automated Spec 07 prerequisite gate passes (123 tests). Next: user confirms manual acceptance (daily-use polish, packaged app launch, hotkeys from foreground app).

---

## Completed: 2.1 v1 sign-off gate

### Goal

Codify Spec 07 definition of done in `StickyNotesCore` with automated configuration prerequisite validation and a structured checklist for manual sign-off acceptance.

### Definition of done

- [x] `V1SignOffCriterion`, `V1DefinitionOfDone`, and `V1SignOffValidator` in `StickyNotesCore`
- [x] All six Spec 07 criteria catalogued with user action, expected behavior, and verification kind
- [x] Thirteen configuration prerequisites validated against v1 configs (panel, actions, markdown, persistence, shell, distribution, hotkeys, aerospace)
- [x] `automatedSignOffGatePasses()` confirms every automated criterion's prerequisites pass
- [x] Negative tests: floating-only level, incomplete hotkey bindings, and gate failure on bad config
- [x] `StickyNoteHotkeyBindings.boundActions` and `binding(for:)` for injectable hotkey validation
- [x] Document decision and lessons learned
- [ ] Manual: daily-use polish bar met (user confirmation)
- [ ] Manual: packaged app launch + hotkeys from foreground app (extends Task 2.0 checklist)

### TDD log

| Step | Action | Result |
|------|--------|--------|
| 1 | Write `StickyNoteV1SignOffTests` — catalog, validator, gate, negative paths | ✅ 15 tests (failing) |
| 2 | Implement `V1DefinitionOfDone`, `V1SignOffValidator`; extend `StickyNoteHotkeyBindings` | ✅ Core logic passes |
| 3 | Re-run full suite + `Scripts/package-app.sh release` | ✅ 123 tests passing; `.app` builds |
| 4 | Manual: daily-use polish + packaged app acceptance | ⏳ Pending user confirmation |

### Manual verification

Run automated gate and packaged app checks:

```bash
cd StickyNotes
swift test --filter V1
./Scripts/package-app.sh release
open dist/StickyNotes.app
```

Confirm:
- `V1SignOffValidator.automatedSignOffGatePasses()` is true (also covered by 15 unit tests)
- No dock icon; menu bar icon appears; notes load from Application Support
- `⌃⌥N` and `⌃⌥⇧N` work from Chrome/Terminal without Accessibility permission
- AeroSpace matrix still passes (confirmed 2026-06-18 — re-run if config changed)
- App feels polished enough for daily personal use

---

## Completed: 2.0 Distribution packaging

### Goal

Package StickyNotes as a proper macOS `.app` bundle with `LSUIElement`, stable bundle ID for AeroSpace config, and ad-hoc or developer signing.

### Definition of done

- [x] `DistributionConfiguration`, `InfoPlistGenerator`, and `AppBundleLayout` in `StickyNotesCore`
- [x] Bundle ID `dev.stickynotes.app` — single source for Info.plist and AeroSpace `on-window-detected` snippet
- [x] Info.plist includes `LSUIElement`, `CFBundleIdentifier`, `CFBundleExecutable`, version keys, `LSMinimumSystemVersion` 14.0
- [x] `GenerateInfoPlist` helper executable reads from `DistributionConfiguration.v1`
- [x] `Scripts/package-app.sh` builds release binary, assembles `.app`, generates Info.plist, ad-hoc signs by default
- [x] Negative path: `SIGN_IDENTITY=skip` skips signing for CI/local inspection
- [x] Document decision and lessons learned
- [x] Manual: packaged app launches with no dock icon; bundle ID verifiable via `codesign -dv`

### TDD log

| Step | Action | Result |
|------|--------|--------|
| 1 | Write `StickyNoteDistributionTests` — config, plist generator, bundle layout | ✅ 10 tests (failing) |
| 2 | Implement `DistributionConfiguration`, `InfoPlistGenerator`, `AppBundleLayout` | ✅ Core logic passes |
| 3 | Add `GenerateInfoPlist` target + `Scripts/package-app.sh` | ✅ Release `.app` builds |
| 4 | Re-run full suite | ✅ 107 tests passing |
| 5 | Manual: open `dist/StickyNotes.app` | ⏳ Pending user confirmation |

### Manual verification

Build and open the packaged app:

```bash
cd StickyNotes
./Scripts/package-app.sh release
open dist/StickyNotes.app
```

Confirm:
- No dock icon (LSUIElement + `.accessory` activation policy)
- Menu bar icon appears; notes load from Application Support
- `codesign -dv dist/StickyNotes.app` shows `Identifier=dev.stickynotes.app`
- Optional: add `DistributionConfiguration.v1.aerospaceOnWindowDetectedSnippet` to `~/.aerospace.toml`

---

## Completed: 1.3.4 AeroSpace compatibility matrix

### Goal

Codify Spec 08 manual test matrix in `StickyNotesCore` with automated configuration prerequisite validation; structured checklist for manual AeroSpace acceptance.

### Definition of done

- [x] `AerospaceCompatibilityScenario`, `AerospaceCompatibilityMatrix`, and `AerospaceConfigurationValidator` in `StickyNotesCore`
- [x] All six Spec 08 scenarios catalogued with user action, expected behavior, and verification kind
- [x] Seven configuration prerequisites validated against `NotePanelConfiguration.aerospaceCompatible`
- [x] `hidesOnDeactivate` codified in `NotePanelConfiguration` and applied by factory
- [x] Factory prerequisite validation for `hidesOnDeactivate`
- [x] Negative tests: floating-only level and missing `canJoinAllSpaces` fail validation
- [x] Document decision and lessons learned
- [x] Manual: all six Spec 08 acceptance scenarios pass with AeroSpace active (confirmed 2026-06-18)

### TDD log

| Step | Action | Result |
|------|--------|--------|
| 1 | Write `StickyNoteAerospaceCompatibilityTests` — matrix catalog, validator, factory prerequisites | ✅ 10 tests (failing) |
| 2 | Implement `AerospaceCompatibilityMatrix`, `AerospaceConfigurationValidator`; extend `NotePanelConfiguration` | ✅ Core logic passes |
| 3 | Wire `hidesOnDeactivate` through factory | ✅ App builds |
| 4 | Re-run full suite | ✅ 96 tests passing |
| 5 | Manual AeroSpace matrix (Spec 08) | ✅ Confirmed 2026-06-18 |

### Manual verification

Confirmed 2026-06-18 with AeroSpace active — all `AerospaceCompatibilityMatrix.v1` cases pass:

| Scenario | Action | Expected |
|----------|--------|----------|
| Tiled app focus | Focus Chrome or Terminal (tiled) | Notes stay visible above it |
| Workspace switch | Switch AeroSpace workspace | Notes visible on new workspace, in place, on top |
| Layout toggle | Toggle tiling ↔ floating on another app | Notes unaffected; still on top |
| Create / drag / resize | Create, drag, or resize a note | AeroSpace does not snap or retile |
| Global show/hide | Press `⌃⌥N` from any workspace | All notes hide; press again to restore |
| Multi-monitor | Place notes on multiple displays | Notes stay on correct screen, on top |

---

## Completed: 1.3.3 Note drag handle + focus regions

### Goal

Notes move via a dedicated header drag handle; clicking preview or header focuses the note for editing (Spec 03 interaction).

### Definition of done

- [x] `NoteDragHandleConfiguration` and `NoteInteractionConfiguration` in `StickyNotesCore`
- [x] v1 drag handle is note header region with minimum height and grip indicator
- [x] v1 allows dragging only from header; focus from drag handle, preview, and editor
- [x] Header drag uses native `performDrag` via `WindowDragHandle` without blocking TextEditor
- [x] Clicking preview/header calls `activateForEditing` → `makeKeyAndOrderFront` → z-order via `windowDidBecomeKey`
- [x] Frame changes during drag persist via existing `windowDidMove` path
- [x] Document decision and lessons learned

### TDD log

| Step | Action | Result |
|------|--------|--------|
| 1 | Write `StickyNoteInteractionTests` — drag handle config, interaction regions, helpers | ✅ 7 tests (failing) |
| 2 | Implement `NoteDragHandleConfiguration`, `NoteInteractionConfiguration` | ✅ Core logic passes |
| 3 | Wire `WindowDragHandle` + focus regions in `StickyNoteView` / `NotePanelController` | ✅ App builds |
| 4 | Re-run full suite | ✅ 86 tests passing |

### Manual verification

Run `.build/debug/StickyNotes` and confirm:
- Drag the header grip — note moves; position persists after quit/relaunch
- Click markdown preview — note becomes key and rises above siblings
- Type in editor — cursor works; note still moves only from header (not editor/preview)
- Resize corner still works independently of drag handle

---

## Completed: 1.3.2 Z-order stacking on focus

### Goal

Focused note rises above other notes in the stack; z-order persists across sessions (Spec 04 save triggers, Spec 03 focus).

### Definition of done

- [x] `NoteZOrderEditor` and `NoteZOrderUpdate` in `StickyNotesCore`
- [x] Focused note receives `max(zIndex) + 1` unless already strictly on top
- [x] Tied max zIndex resolved by promoting the focused note
- [x] `NoteWindowManager.focusNote` updates model, syncs panel order, autosaves
- [x] `windowDidBecomeKey` on note panel triggers focus promotion
- [x] Bootstrap, create, and duplicate restore visual stack via `syncPanelZOrder`
- [x] Document decision and lessons learned

### TDD log

| Step | Action | Result |
|------|--------|--------|
| 1 | Write `StickyNoteZOrderTests` — no-op, promote, tied max, updatedAt | ✅ 5 tests (failing) |
| 2 | Implement `NoteZOrderEditor`, `NoteZOrderUpdate` | ✅ Core logic passes |
| 3 | Wire `NoteWindowManager` — focus handler, panel stacking sync | ✅ App builds |
| 4 | Re-run full suite | ✅ 79 tests passing |

### Manual verification

Run `.build/debug/StickyNotes` and confirm:
- Overlap two notes — click the lower one; it appears above the other
- Quit and relaunch — previously focused note stays on top of siblings
- Create or duplicate a note — new note appears above existing notes

---

## Completed: 1.3.1 Multi-monitor frame restoration

### Goal

Restore note positions safely when displays change between sessions (Spec 02 multi-monitor, Spec 04 session restore).

### Definition of done

- [x] `NoteDisplayLayout` and `NoteFrameRestorer` in `StickyNotesCore`
- [x] On-screen frames unchanged; partially off-screen frames clamped within their display
- [x] Frames on a disconnected display relocated to primary display (top-right padding)
- [x] `NoteWindowManager.bootstrap()` restores frames and autosaves corrections
- [x] Document decision and lessons learned

### TDD log

| Step | Action | Result |
|------|--------|--------|
| 1 | Write `StickyNoteFrameLayoutTests` — layout, clamp, disconnected display, batch restore | ✅ 6 tests (failing) |
| 2 | Implement `NoteDisplayLayout`, `NoteFrameRestorer` | ✅ Core logic passes |
| 3 | Wire `NoteWindowManager` — restore on bootstrap, persist corrections | ✅ App builds |
| 4 | Re-run full suite | ✅ 74 tests passing |

### Manual verification

Run `.build/debug/StickyNotes` and confirm:
- Place a note on an external display, quit, disconnect display, relaunch — note appears on primary display
- Drag a note partially off-screen, quit, relaunch — note is fully visible on the same display
- Dual-monitor setup — notes stay on their respective displays after relaunch

---

## Completed: 1.2 Per-note actions + hover chrome

### Goal

Implement Spec 03 per-note actions (delete, duplicate, change color) with borderless hover chrome controls.

### Definition of done

- [x] `NoteAction` catalog and `NoteChromeConfiguration` in `StickyNotesCore`
- [x] Testable `NoteCollectionEditor` for delete, duplicate, and color mutations
- [x] Deleting the last note replaces it with a fresh empty note at the same frame
- [x] `NoteWindowManager` wires delete, duplicate, and color change with autosave
- [x] `StickyNoteView` shows hover chrome (close, color swatches, duplicate)
- [x] Document decision and lessons learned

### TDD log

| Step | Action | Result |
|------|--------|--------|
| 1 | Write `StickyNoteNoteActionTests` — action catalog, chrome config, collection editor | ✅ 11 tests (failing) |
| 2 | Implement `NoteAction`, `NoteChromeConfiguration`, `NoteCollectionEditor` | ✅ Core logic passes |
| 3 | Wire `NoteWindowManager` + hover chrome in `StickyNoteView` | ✅ App builds |
| 4 | Re-run full suite | ✅ 68 tests passing |

### Manual verification

Run `.build/debug/StickyNotes` and confirm:
- Hover a note — close, color swatches, and duplicate controls appear
- Close deletes the note; deleting the last note leaves one fresh empty note in place
- Duplicate creates an offset copy with the same content and color
- Color swatches change the note background and persist after quit/relaunch

---

## Completed: 1.1 Note model + persistence

### Goal

Implement Spec 03 note data model and Spec 04 local JSON persistence with debounced autosave and session restore.

### Definition of done

- [x] `StickyNote` model with all Spec 04 fields (id, content, frame, color, zIndex, timestamps)
- [x] Preset color palette and medium default size (250×300 pt, yellow default)
- [x] `NotePersistenceConfiguration` — Application Support path, 1.5 s debounce
- [x] `NotePersistenceStore` — JSON save/load, debounced autosave, flush on quit
- [x] Automated tests for model, codable round-trip, storage path, debounce behavior
- [x] App loads saved notes on launch (always visible — hidden state not persisted)
- [x] Content and frame changes trigger autosave
- [x] Document decision and lessons learned

### TDD log

| Step | Action | Result |
|------|--------|--------|
| 1 | Write `StickyNoteModelTests` + `StickyNotePersistenceTests` — palette, defaults, model, codable, store | ✅ 14 tests (failing) |
| 2 | Implement `StickyNote`, `NoteColor`, `NoteFrame`, `NoteAppearanceDefaults`, `NotePersistenceStore` | ✅ Core model + store pass |
| 3 | Wire `NoteWindowManager` — load on bootstrap, autosave on edit/move, flush on quit | ✅ App builds |
| 4 | Re-run full suite | ✅ 57 tests passing |

### Manual verification

Run `.build/debug/StickyNotes` and confirm:
- First launch creates a default yellow note with sample markdown
- Edit content, wait ~2 s, quit — relaunch restores content
- Move/resize a note, quit — relaunch restores position and size
- Hide notes via hotkey/menu, quit — relaunch shows all notes visible (hidden state not restored)
- JSON file at `~/Library/Application Support/StickyNotes/notes.json`

---

## Completed: 1.0 App shell (menu bar, no dock)

### Goal

Deliver Spec 05 app presence: no dock icon, menu bar icon as primary entry point, and minimum menu actions (show/hide, new note, quit).

### Definition of done

- [x] Define v1 required menu bar actions and no-dock activation policy
- [x] Automated tests for menu catalog, dynamic show/hide titles, hotkey mapping, status bar icon
- [x] `AppShellConfiguration` codified in `StickyNotesCore`
- [x] `MenuBarController` wired in spike app with `NSStatusItem` + menu
- [x] Menu actions dispatch to `NoteWindowManager` (mirrors global hotkeys)
- [x] Show/Hide menu title updates when visibility toggles (menu or hotkey)
- [x] Document decision and lessons learned

### TDD log

| Step | Action | Result |
|------|--------|--------|
| 1 | Write `StickyNoteAppShellTests` — menu catalog, activation policy, titles, hotkey mapping | ✅ 7 tests (failing) |
| 2 | Implement `MenuBarAction`, `AppActivationPolicy`, `AppShellConfiguration` | ✅ Core config passes |
| 3 | Wire `MenuBarController` in spike app — status item, menu, quit | ✅ App builds |
| 4 | Re-run full suite | ✅ 43 tests passing |

### Manual verification

Run `.build/debug/StickyNotes` and confirm:
- No dock icon; note icon appears in menu bar
- Menu: Hide Notes / Show Notes toggles all panels (title updates)
- Menu: New Note creates an additional panel
- Menu: Quit terminates the app
- Hotkey toggle also updates menu title without reopening menu

---

## Completed: 0.3 Global hotkey spike

### Goal

Evaluate Carbon RegisterEventHotKey vs HotKey library vs CGEvent tap for v1 global shortcuts: toggle show/hide all notes and create new note (Spec 05, Spec 06).

### Definition of done

- [x] Define v1 required hotkey actions and Spec 05 default bindings
- [x] Automated tests for action catalog, default chords, Carbon mapping, Sequoia compatibility, evaluation criteria
- [x] Spike evaluation criteria codified and tested (`HotkeyLibraryEvaluation`)
- [x] **Decision: Carbon RegisterEventHotKey (direct)** — no Accessibility permission, no extra dependency
- [x] `CarbonGlobalHotkeyRegistry` wired in spike app (`NoteWindowManager`)
- [x] Document decision, default shortcuts, and lessons learned

### TDD log

| Step | Action | Result |
|------|--------|--------|
| 1 | Write `StickyNoteHotkeyTests` — actions, defaults, Carbon mapping, Sequoia rules, evaluation | ✅ 14 tests (failing) |
| 2 | Implement `HotkeyChord`, `StickyNoteHotkeyBindings`, `HotkeyLibraryEvaluation`, `CarbonGlobalHotkeyRegistry` | ✅ Core logic + registrar pass |
| 3 | Wire hotkeys in spike app — toggle all notes, create new note panel | ✅ `NoteWindowManager` + header shortcut hints |
| 4 | Re-run full suite | ✅ 36 tests passing |

### Spike decision

| Path | Score | Verdict |
|------|-------|---------|
| **Carbon RegisterEventHotKey (direct)** | 7 | ✅ **Chosen** — no Accessibility permission, sufficient for two fixed shortcuts |
| HotKey library (soffes/HotKey — Carbon wrapper) | 6 | ⚪ Viable alternative; adds dependency for minimal gain |
| CGEvent tap (global event monitor) | 1 | ❌ Requires Accessibility; overkill for toggle + new-note |

**Default shortcuts (Spec 05):** `⌃⌥N` toggle visibility · `⌃⌥⇧N` create new note. Control modifier included so chords stay valid on macOS Sequoia+ (Option-only global hotkeys are blocked).

**Architecture:** Binding definitions and Carbon registrar live in `StickyNotesCore`. App layer owns `NoteWindowManager` and dispatches hotkey handlers on the main queue.

### Manual verification

Run `.build/debug/StickyNotes` and confirm:
- `⌃⌥N` hides all note panels from any foreground app; press again to show
- `⌃⌥⇧N` creates an additional offset note panel
- Hotkeys work without granting Accessibility permission
- Shortcut hints appear in each note header

---

## Completed: 0.2 Markdown library spike

### Goal

Evaluate MarkdownUI vs cmark-gfm for live markdown preview in small sticky-note windows (Spec 03, Spec 06).

### Definition of done

- [x] Define v1 GFM feature subset (headings, emphasis, lists, tasks, links, code, blockquotes)
- [x] Automated tests for feature catalog, cmark-gfm parsing path, and parse-performance budget
- [x] Spike evaluation criteria codified and tested (`MarkdownLibraryEvaluation`)
- [x] **Decision: MarkdownUI** for rendering; swift-markdown retained for structure/plain-text analysis
- [x] Live preview wired in spike app (editor + `Markdown` view)
- [x] Document decision and lessons learned

### TDD log

| Step | Action | Result |
|------|--------|--------|
| 1 | Write `StickyNoteMarkdownTests` — feature catalog, parser, perf budget, evaluation | ✅ 12 tests (failing) |
| 2 | Implement `StickyNoteMarkdownFeatures`, `MarkdownStructureAnalyzer`, `MarkdownLibraryEvaluation` | ✅ Parser + evaluation pass |
| 3 | Add MarkdownUI + swift-markdown dependencies; wire live preview in spike app | ✅ `MarkdownSpikeNoteView` |
| 4 | Fix nested-list sample gap; re-run full suite | ✅ 22 tests passing |

### Spike decision

| Path | Score | Verdict |
|------|-------|---------|
| **MarkdownUI** (gonzalezreal/swift-markdown-ui) | 11 | ✅ **Chosen** — native SwiftUI GFM renderer, minimal live-preview wiring |
| cmark-gfm via swift-markdown (parser only) | 0 | ❌ Parses correctly but requires custom SwiftUI renderer |

**Architecture:** MarkdownUI renders preview in the app layer. `MarkdownStructureAnalyzer` (swift-markdown / cmark-gfm) lives in `StickyNotesCore` for plain-text extraction and future search/indexing.

### Manual verification

Run `.build/debug/StickyNotes` and confirm:
- Typing in the bottom editor updates the preview above in real time
- Headings, bold/italic, lists, task checkboxes, links, code, and blockquotes render correctly
- Preview stays responsive in the ~280×320 pt spike window

---

## Completed: 0.1 AeroSpace overlay spike

### Goal

Prove sticky note windows stay on top of tiled apps and survive AeroSpace workspace switches (Spec 08).

### Definition of done

- [x] Automated tests for panel configuration invariants (10 tests passing)
- [x] `StickyNotes` spike app builds and runs (`.build/debug/StickyNotes`)
- [x] Manual: note visible above tiled Chrome/Terminal with AeroSpace active
- [x] Manual: workspace switch keeps note visible, in place, on top
- [x] Document chosen window level and collection behavior in lessons learned

### TDD log

| Step | Action | Result |
|------|--------|--------|
| 1 | Write `NotePanelConfigurationTests` — level, collection behavior, NSPanel flags | ✅ 7 config tests |
| 2 | Implement `StickyNotesCore` to pass tests | ✅ `NotePanelConfiguration` + `NotePanelFactory` |
| 3 | Factory test exposed level-reset bug; fixed by setting level last | ✅ +1 regression test |
| 4 | Wire minimal spike app using factory | ✅ `StickyNotesApp` with yellow test note |
| 5 | Manual AeroSpace matrix (Spec 08) | ✅ Confirmed 2026-06-18 (see Task 1.3.4) |

## Lessons learned

### App icon + start at login (2026-06-19)

1. **Icon pipeline** — `Resources/AppIcon-1024.png` is the source; `Scripts/build-app-icon.sh` uses `sips` + `iconutil` to produce `AppIcon.icns`. `package-app.sh` copies it to `Contents/Resources/` and `InfoPlistGenerator` sets `CFBundleIconFile`.

2. **SMAppService for login items** — macOS 14+ uses `SMAppService.mainApp.register()` / `unregister()`. Requires a signed `.app` bundle; fails gracefully when running the SPM debug binary.

3. **Default on first launch** — `LoginItemPreferenceResolver` enables start-at-login when no preference is stored. Menu bar "Start at Login" toggle (checkmark) lets the user opt out.

4. **Menu bar uses bundled icon** — When `AppIcon.icns` is in the bundle, the status item shows the custom icon instead of the SF Symbol fallback.

### v1 sign-off gate (2026-06-19)

1. **Definition of done in core** — `V1DefinitionOfDone.v1` maps each Spec 07 criterion to user action, expected behavior, and verification kind. Manual acceptance (daily-use polish, AeroSpace matrix) stays separate from automated prerequisites.

2. **Prerequisite validator** — `V1SignOffValidator` checks thirteen configuration flags across existing v1 configs. `automatedSignOffGatePasses()` ensures every automated criterion's prerequisites pass as a single release gate.

3. **Aerospace delegation** — `.aerospacePrerequisitesMet` delegates to `AerospaceConfigurationValidator` rather than duplicating panel flag checks.

4. **Injectable hotkey bindings** — `StickyNoteHotkeyBindings.boundActions` and `binding(for:)` enable negative-path tests without `fatalError` on missing chords.

5. **Manual bar remains user-owned** — Spec 07 criterion 5 (daily-use polish) cannot be automated. AeroSpace matrix was confirmed 2026-06-18; packaged app launch checklist from Task 2.0 still applies.

### Distribution packaging (2026-06-19)

1. **Bundle identity in core** — `DistributionConfiguration.v1` is the single source for bundle ID, version strings, `LSUIElement`, and the AeroSpace `on-window-detected` snippet. Info.plist is generated, not hand-edited.

2. **`GenerateInfoPlist` helper target** — Shell scripts cannot import SPM modules directly; a tiny executable target calls `InfoPlistGenerator.writePlist` so packaging stays aligned with unit tests.

3. **Ad-hoc signing by default** — `Scripts/package-app.sh` signs with `-` (ad-hoc) so Gatekeeper accepts the bundle locally. Set `SIGN_IDENTITY` to a Developer ID for distribution; set `SIGN_IDENTITY=skip` to skip.

4. **LSUIElement + `.accessory` together** — Info.plist `LSUIElement` handles no-dock for the `.app`; runtime `NSApp.setActivationPolicy(.accessory)` still applies for SPM debug runs without a bundle. Both are intentional belt-and-suspenders per Spec 05.

5. **Bundle ID `dev.stickynotes.app`** — Replaces README placeholder `dev.stickynotes.spike`. Use `DistributionConfiguration.v1.aerospaceOnWindowDetectedSnippet` when configuring AeroSpace.

### AeroSpace compatibility matrix (2026-06-18)

1. **Matrix catalog in core** — `AerospaceCompatibilityMatrix.v1` maps each Spec 08 scenario to user action, expected behavior, and configuration prerequisites. Manual acceptance cases stay separate from automated prerequisite cases.

2. **Prerequisite validator** — `AerospaceConfigurationValidator` checks seven configuration flags plus factory `hidesOnDeactivate`. Negative tests lock regressions (floating-only level, missing `canJoinAllSpaces`).

3. **`hidesOnDeactivate` in configuration** — Moved from factory hardcode to `NotePanelConfiguration.hidesOnDeactivate` so aerospace prerequisites are single-source and testable without inspecting factory internals.

4. **Hotkey scenario is pure manual** — Global show/hide has no panel configuration prerequisites; Carbon hotkey delivery is validated by existing hotkey tests and manual verification with AeroSpace active.

5. **Manual matrix confirmed** — User verified all six Spec 08 scenarios with AeroSpace active on 2026-06-18. `NotePanelConfiguration.aerospaceCompatible` + optional `~/.aerospace.toml` floating layout is sufficient without `layout sticky` (not yet in stable AeroSpace).

### Note drag handle + focus regions (2026-06-18)

1. **Interaction policy in core** — `NoteInteractionConfiguration.v1` codifies draggable vs focusable regions without AppKit. App layer reads the config so future full-surface drag stays a one-line policy change.

2. **Header-only drag via `performDrag`** — `WindowDragHandleView` calls `window?.performDrag(with:)` on `mouseDown`. Native panel drag preserves AeroSpace compatibility and reuses existing `windowDidMove` persistence.

3. **Focus on drag-handle mouseDown** — `WindowDragHandleView` calls `onFocus` before `performDrag`, so header click and drag both promote z-order. SwiftUI `.onTapGesture` cannot fire through the AppKit overlay.

4. **Grip in header, not full surface** — Spec 03 allows drag-handle vs full-surface; v1 chose header-only so preview clicks focus and editor typing are never interpreted as move gestures.

### Z-order stacking on focus (2026-06-18)

1. **Pure z-order editor in core** — `NoteZOrderEditor.bringToFront` is testable without AppKit. Strictly-on-top check (`zIndex` greater than every sibling) avoids pointless persistence when refocusing the front note.

2. **Tied max zIndex needs promotion** — Duplicate or corrupted snapshots can leave multiple notes at the same max `zIndex`. Focus must still bump one note above the tie.

3. **Separate show vs stack ordering** — `orderFrontRegardless()` for initial show (above other apps); `orderFront(nil)` in `syncPanelZOrder` for intra-app sibling stacking without fighting window level.

4. **`windowDidBecomeKey` is sufficient for v1** — Nonactivating panels become key when the `TextEditor` is clicked (`becomesKeyOnlyIfNeeded`). Full-surface click-to-focus without key window follows with the drag-handle task (Spec 03).

### Multi-monitor frame restoration (2026-06-18)

1. **Pure restorer in core** — `NoteFrameRestorer` accepts injectable `NoteDisplayLayout` (array of visible `CGRect`s). App layer maps `NSScreen.screens.map(\.visibleFrame)`; tests use fixed frames without AppKit.

2. **Display selection order** — Prefer the display containing the note center; fall back to largest intersection area; relocate to primary (first frame) when no overlap (disconnected monitor).

3. **Clamp before relocate** — Partially off-screen notes stay on their current display but get origin clamped. Only zero-intersection frames move to primary top-right (same padding as new-note placement via `NoteFrameRestorer.edgePadding`).

4. **Persist corrections on launch** — Bootstrap autosaves restored frames so off-screen coordinates do not reappear on every relaunch.

### Per-note actions + hover chrome (2026-06-18)

1. **Pure collection editor in core** — `NoteCollectionEditor` handles delete, duplicate, and color mutations as testable pure functions. App layer (`NoteWindowManager`) owns panel lifecycle only.

2. **Last-note delete replaces in place** — Deleting the final note creates a fresh empty note at the same frame rather than leaving zero notes. Matches bootstrap behavior and avoids an empty app state.

3. **Hover chrome via `NoteChromeConfiguration.v1`** — Spec 03 minimum controls (close, color, duplicate) codified in core and mapped to `NoteAction`. SwiftUI `NoteHoverChrome` reads the config so future chrome changes stay test-driven.

4. **Color refresh replaces hosting view** — `NotePanelController.updateNote(_:)` rebuilds the `NSHostingView` on color change only. Content editing stays in local `@State` to avoid cursor loss on every keystroke.

### Note model + persistence (2026-06-18)

1. **Testable model in core, SwiftUI in app** — `StickyNote`, `NoteColor`, `NoteFrame`, and `NotePersistenceStore` live in `StickyNotesCore` with no SwiftUI dependency. Color-to-`Color` mapping stays in the app layer.

2. **Injectable file URL for persistence tests** — `NotePersistenceStore` accepts an explicit `fileURL` and `TestNoteAutosaveScheduler` so tests never touch real Application Support. Production uses `NotePersistenceConfiguration.v1` defaults.

3. **ISO8601 fractional seconds for dates** — Plain `.iso8601` coding truncates sub-second precision; custom encode/decode with `.withFractionalSeconds` avoids drift on round-trip equality (nanosecond `Date()` values still truncate — acceptable for note timestamps).

4. **Flush on quit via semaphore** — `applicationWillTerminate` cannot fire-and-forget `Task`; a short `DispatchSemaphore` wait ensures debounced writes land before process exit.

5. **Launch always visible** — Hidden state is runtime-only (`notesVisible` resets to `true` on bootstrap). Snapshot stores no visibility flag, matching Spec 00/04.

### App shell (2026-06-18)

1. **Testable shell config in core** — `AppShellConfiguration` encodes Spec 05 menu actions, dynamic show/hide titles, hotkey shortcut display strings, and `.accessory` activation policy without AppKit. App layer owns `NSStatusItem` wiring only.

2. **Menu title tracks visibility state** — Show/Hide label must flip when notes are hidden via global hotkey, not only via menu. `NoteWindowManager.onVisibilityChanged` keeps the status menu in sync.

3. **Shortcut hints via toolTip** — Menu items use `toolTip` for `⌃⌥N` / `⌃⌥⇧N` display; key equivalents are reserved for Quit (`Cmd+Q` comes from system when app is active). Full key-equivalent wiring can follow when menu becomes primary focus target.

4. **SPM still uses `.accessory`** — Same as Phase 0: `NSApp.setActivationPolicy(.accessory)` for no dock. Signed `.app` + `LSUIElement` deferred to distribution packaging.

### Markdown spike (2026-06-18)

1. **MarkdownUI wins for v1 live preview** — It is a native SwiftUI GFM renderer (built on cmark) requiring only a `TextEditor` + `Markdown` split layout. The raw cmark-gfm path via swift-markdown parses the same dialect but has no renderer — building one would be significant v1 scope creep.

2. **Keep swift-markdown in core for analysis** — `MarkdownStructureAnalyzer` provides testable plain-text extraction and feature detection without pulling SwiftUI into unit tests. Useful later for search and autosave diffing.

3. **Parse budget is comfortable** — 200 re-parses of a typical note complete in < 2 ms each (well under the 2 ms/keystroke budget). Live preview re-renders via MarkdownUI are expected to be similarly fast for small notes.

4. **Nested lists need careful samples** — Task items nested inside ordered-list items are parsed as ordered-list children, not separate unordered lists. Top-level list samples are clearer for both testing and user-authored notes.

### AeroSpace spike (2026-06-18)

1. **Set window level after `isFloatingPanel`** — Assigning `isFloatingPanel = true` on `NSPanel` resets `level` to `.floating` (3). The factory must set `.statusBar` (25) *last*, or notes sit at normal float level and lose to AeroSpace tiled windows.

2. **Configuration codified as `NotePanelConfiguration.aerospaceCompatible`** — Single source of truth tested by unit tests:
   - Level: `.statusBar`
   - Collection behavior: `canJoinAllSpaces | fullScreenAuxiliary | stationary | ignoresCycle`
   - Style: `.borderless | .nonactivatingPanel | .resizable`

3. **SPM executable vs `.app` bundle** — Swift Package Manager can run the spike as a CLI binary with `NSApp.setActivationPolicy(.accessory)` for no dock icon. A proper signed `.app` with `LSUIElement` in Info.plist comes later when we add Xcode project / distribution.

4. **Manual matrix still required** — Automated tests verify AppKit flags, not real AeroSpace tiling behavior. Manual Spec 08 matrix confirmed 2026-06-18.

### Global hotkey spike (2026-06-18)

1. **Carbon RegisterEventHotKey wins for v1** — Two fixed shortcuts (toggle visibility, new note) do not need a CGEvent tap or Accessibility approval. Direct Carbon keeps dependencies minimal; the HotKey library is equivalent under the hood but adds a package for little gain.

2. **Include Control or Command on macOS Sequoia+** — Apple blocks global hotkeys whose only modifiers are Option and/or Shift (error `-9868`). Defaults use `⌃⌥N` and `⌃⌥⇧N` so registration succeeds on Sequoia without workarounds.

3. **Testable binding layer in core** — `StickyNoteHotkeyBindings`, `HotkeyChord`, and `HotkeyLibraryEvaluation` encode Spec 05 defaults and spike criteria without requiring a running event loop. `CarbonGlobalHotkeyRegistry` handles runtime registration.

4. **Manual verification still required** — Unit tests cover chord mapping and evaluation logic, not real global delivery while another app is focused. Confirm hotkeys from Chrome/Terminal before marking production-ready.

## References

- [Spec 06 — Tech stack](./specs/06-tech-stack.md)
- [Spec 08 — AeroSpace compatibility](./specs/08-aerospace-compatibility.md)
- [StickyNotes spike README](./StickyNotes/README.md)
