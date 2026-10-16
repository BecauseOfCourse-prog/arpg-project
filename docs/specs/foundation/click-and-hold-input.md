# ARPG-015: Click and Hold Input

- **Status:** Complete
- **Owner:** Project owner
- **Created:** 2026-10-16
- **Related specifications:** [ARPG-003](player-movement-navigation.md); [ARPG-004](basic-combat.md); [ARPG-011](cache-interaction-and-gold-pickup.md); [ARPG-013](procedural-exploration-zones.md); [ARPG-014](world-interaction-and-inventory-feedback.md)
- **Related ADRs:** [ADR-0002](../../decisions/ADR-0002-game-system-boundaries.md)

## Summary

Separate explicit clicks from movement while holding the left mouse button. Following the player with the camera must not turn an existing attack or interaction into a new command.

## Behavior

- A short press and release on an enemy starts the existing repeating attack and approach behavior. A short click on a cache, gold pile, or vendor starts its existing approach-and-interact behavior.
- Defer an object click until button release so holding directly on an object cannot activate it before the gesture becomes a movement hold.
- Holding the button only updates movement. Hovering over enemies, caches, gold, or vendors during a hold never requests attack, opening, collection, or trading.
- Ground presses begin movement immediately. An object press becomes a movement hold after 0.20 seconds or a drag of at least 8 viewport pixels; these are initial input tuning values.
- Store pointer position in viewport coordinates and convert it through the current camera transform when producing movement goals. Capture the clicked object on press and dispatch it on short release, so camera movement does not change click identity.
- New movement commands cancel attack or pending interaction. Once a click has been released, camera movement alone does not issue new commands.
- World regeneration cancels any incomplete pointer gesture. Existing contact-based equipment pickup behavior is unchanged.

## Acceptance criteria

- [x] Short clicks start attacks and cache/gold/vendor interaction exactly once.
- [x] Holding directly on an object, or hovering over one during ground movement, issues movement only.
- [x] Camera following does not cancel an enemy or interaction selected by a released click.
- [x] Movement continues to follow the viewport cursor with the moving camera.
- [x] Regeneration clears incomplete gestures.
- [x] Regression tests and the existing full suite pass.
- [x] The project owner verifies click and hold behavior in Godot Editor.

## Verification plan and results

Seven new GdUnit4 tests exercise mouse press/release and motion handlers with viewport coordinates, including a released attack click surviving 18 frames of camera following, short clicks on cache/gold/vendor, long holds directly on all object types, hovering objects during a ground hold, drag detection, camera-relative ground movement, and gesture cancellation during regeneration. The existing viewport input test now also checks that its exact clicked world destination is preserved after release. The full suite passes in normal display mode: 64 cases, 0 errors, 0 failures, 0 orphans (`reports/report_69/index.html`). On 2026-10-16 the project owner manually verified the input and camera changes in Godot Editor and confirmed they work correctly.

## Documentation impact

- [x] Update project context, backlog, and specification index.
- [x] Link the later input behavior from completed movement and generation records.

## Open questions

None. The project owner explicitly requested clicks for attacks/opening and movement only while holding.

## Change record

| Date | Update |
| --- | --- |
| 2026-10-16 | Project owner requested correction of camera-induced target cancellation and specified that holding the mouse button must trigger movement only. |
| 2026-10-16 | Implemented viewport-based pointer tracking, click dispatch on short release, movement-only holds/drags, and gesture reset during regeneration. All 64 tests pass; owner Editor verification remains pending. |
| 2026-10-16 | Project owner confirmed successful manual verification of input and camera behavior. All acceptance criteria are satisfied; ARPG-015 is complete. |
