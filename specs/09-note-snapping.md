# Spec 09: Note-to-Note Snapping

**Status:** ✅ Approved  
**Depends on:** [03-note-model](./03-note-model.md), [02-platform-overlay](./02-platform-overlay.md), [08-aerospace-compatibility](./08-aerospace-compatibility.md)

## Problem

When arranging notes casually, edges often land *almost* aligned — slightly overlapping or a few pixels off. A gentle magnetic nudge while moving or resizing helps without forcing a rigid layout.

## Goal

**Casual alignment assist** — snap when close, release when the user keeps dragging. Not a grid system; overlapping remains intentional and allowed after breaking snap.

## Scope

| In scope | Out of scope |
|----------|--------------|
| Snap to **other notes** while **dragging** (header move) | Snap to screen / display edges |
| Snap to **other notes** while **resizing** (dragged edges only) | Snap on create or duplicate |
| Side-flush and corner-align candidates | Snap toggle / preference UI |
| Live snap during gesture | “Lock to neighbor” persistence (stored positions are plain coordinates) |
| 5 pt attraction zone; 2 pt gap when snapped | Grid snap, alignment guides UI |

## Snap geometry

### Candidates

For the moving note relative to every **other** note, evaluate:

| Type | Condition | Result |
|------|-----------|--------|
| **Side snap** | A moving edge is within **5 pt** of a target edge on the parallel axis, with overlap on the perpendicular axis | Moving edge stops **2 pt** from target edge; parallel axis aligns to flush (no overlap) |
| **Corner snap** | A moving corner is within **5 pt** of a target corner | Moving corner aligns **2 pt** from target corner on both axes |

All four sides and all four corners are valid snap types.

### Threshold and release

| Parameter | Value |
|-----------|-------|
| Attraction zone | **5 pt** — engage snap when distance ≤ 5 pt |
| Snapped gap | **2 pt** between note edges at rest |
| Release | Once snapped, if the user drags **more than 5 pt** away from the engaged snap position, **break snap** and allow free movement (including overlap) |

Snap applies **live** during drag and resize — not on mouse-up only.

### Tie-break

When multiple candidates are within the attraction zone, pick the **minimum distance**. If distances tie, **side snap beats corner snap**.

### Resize

Only **edges being dragged** by the resize gesture are eligible to snap. Non-resized edges do not seek snap targets.

## Interaction surfaces

| Surface | Behavior |
|---------|----------|
| Header drag (move) | Live snap via existing `windowDidMove` path |
| Resize handle | Live snap on dragged edge(s) via existing `windowDidResize` path |
| Create / duplicate | Unchanged — no automatic snapping |

## AeroSpace invariant

Snapping must not change window type, level, collection behavior, or drag mechanism. Spec 08 matrix row “Create / drag / resize a note” must still pass.

## Verification

### Automated (`StickyNotesCoreTests`)

- [ ] Side snap engages within 5 pt; result has 2 pt gap, no overlap
- [ ] Corner snap engages within 5 pt; result has 2 pt gap on both axes
- [ ] No snap beyond 5 pt attraction zone
- [ ] Release after dragging > 5 pt from engaged snap position
- [ ] Closest candidate wins; side beats corner on equal distance
- [ ] Resize considers dragged edges only
- [ ] Notes do not snap to themselves; single-note session is unchanged

### Manual

- [ ] Drag note within 5 pt of neighbor — live snap with visible 2 pt gap
- [ ] Drag past 5 pt — note moves freely; overlap allowed
- [ ] Resize bottom or right edge near neighbor — edge snaps live
- [ ] Create / duplicate placement unchanged
- [ ] AeroSpace: drag / resize still does not retile notes (Spec 08 matrix)

## Approval

Approved 2026-06-22 (interview + explicit verification of tie-break and resize scope).
