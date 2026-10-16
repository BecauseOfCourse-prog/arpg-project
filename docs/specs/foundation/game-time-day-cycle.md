# ARPG-012: Game Time and Day Cycle

- **Status:** Complete
- **Owner:** Project owner
- **Created:** 2026-10-16
- **Related specifications:** [Hub Vendor](hub-vendor.md); [Save and Load](save-load.md)

## Summary

Introduce continuous game time, numbered days, four time-of-day periods, smooth world lighting, a compact time indicator, and a daily vendor refresh event. The project owner accepted this scope and timing proposal on 2026-10-16. Clock, presentation, persistence, and refresh events are implemented and verified by automated checks and the project owner.

## Scope

In scope: clock, day counter, period transitions, smooth readable lighting, HUD time indicator, time persistence, and vendor refresh event with safe deferral during trading.

Out of scope: sleeping, waiting/time skipping, NPC schedules, nighttime enemy variants, and finite or randomized vendor stock implementation.

## User-facing behavior and rules

- A full game day lasts 24 real minutes: one game minute passes per real second of active gameplay.
- A new game starts on Day 1 at 08:00.
- Morning is [06:00, 10:00), daytime [10:00, 18:00), evening [18:00, 22:00), and night [22:00, 24:00) plus [00:00, 06:00).
- The day number increments at midnight; the trading day starts at 06:00.
- The supported calendar is Day 1 through Day 100,000 inclusive. Saved days outside this range are invalid. At the final day's end the clock stops at minute 1439.999, preserving a valid save rather than creating Day 100,001.
- Time stops in the pause menu and main menu. Inventory and trading leave time running. Time does not advance while the application is closed.
- Save/load preserves the day number and precise time within the day. Loading does not advance time based on elapsed real-world time or create an extra daily refresh event.
- Lighting changes continuously rather than jumping at period boundaries. Night is darker and cooler, while enemies, pickups, and passages remain legible. Screen-space UI remains readable.
- A compact HUD indicator displays the day and time.
- Each crossing of 06:00 produces a daily vendor refresh event. If trading is open, defer applying the refresh until the window closes so items cannot disappear under the cursor. Multiple pending crossings need only apply the latest trading-day refresh when closing.
- A day transition does not regenerate zones, enemies, or caches.
- The current fixed unlimited vendor stock remains in place; this change supplies the refresh event/integration point for future stock behavior.

## Affected systems and constraints

Session & Flow, Save & Load, World & Areas, Hub Services, and User Interface. Depends on ARPG-007 and integrates with the existing ARPG-009 save contract. Use Godot 4.6 and typed GDScript. Keep game time distinct from real UTC save timestamps. Any save-schema change must follow ADR-0003; legacy-save handling must be documented during implementation.

## Acceptance criteria

- [x] New Game begins on Day 1 at 08:00; the clock advances at the accepted rate and rolls over at midnight.
- [x] The four periods use the exact boundaries above.
- [x] Pause/main menus stop time; inventory/trading do not; application downtime adds no time.
- [x] Save/load restores the day and precise time without an extra refresh event.
- [x] Lighting transitions are smooth, nighttime gameplay remains readable, and the HUD shows day/time.
- [x] Daily refresh is triggered at 06:00 and deferred safely while trading is open.
- [x] Day changes leave the current exploration layout, enemies, and caches intact.

## Verification plan and results

Final documentation/code review: stale pending-verification statements and unchecked acceptance criteria were reconciled with the owner's confirmation. Full pre-commit GdUnit4 run passed: 70 cases across 9 suites, 0 errors, 0 failures, 0 skipped. ARPG-016 remains specified and unimplemented; no finite-stock behavior is claimed by this completed clock feature.

Implemented GameClock with delta-based advancement, four periods, continuous CanvasModulate lighting, a screen-space day/time label, and vendor_refresh_due events deferred by VendorWindow visibility. SceneTree pause and disabled main-menu processing stop the clock; inventory/trading do not pause it. World regeneration does not reset time. The world save payload now includes game_time (day, fractional minute, pending vendor day). This is an additive schema-1 extension: saves without game_time explicitly default to Day 1 at 08:00, present invalid time fields reject the save, and unsupported schema versions remain unavailable under ADR-0003. Loading preserves fractional time and emits no refresh simply for restoring time; a pending refresh is applied once when trading is closed.

Godot import passed. Automated clock tests passed for rate, boundaries, rollover, pause/menu/trading behavior, continuous boundary colors, and deferred refresh. Save tests passed for time round trips, invalid time rejection, and legacy defaults. Initial full run: 68 cases, with failures confined to the existing draw-order pixel comparison because morning lighting changed its expected colors; that test now explicitly uses neutral daytime light to isolate sorting. The project owner subsequently confirmed the system matches the agreed behavior, completing manual lighting and HUD verification.

## Open questions

Follow-up verification: after isolating the sorting test's lighting, the cache suite passed (10 cases, 0 failures). The remaining suites passed in the preceding full run. Visual editor verification was subsequently confirmed by the project owner.

The selected first finite-stock consumer is [ARPG-016: Limited Daily Test Vendor](limited-daily-vendor.md), a separate vendor with one enhanced potion replenished daily. It does not expand ARPG-012's clock/event scope.

- Resolved by ARPG-016 and ADR-0005: finite vendor stock and its daily refresh state persist with game time as a narrow exception to world-state non-persistence. Loading does not replenish stock on its own.

## Documentation impact

- [x] Record the accepted proposal in PROJECT_CONTEXT.md, BACKLOG.md, and the specification index.
- [x] Update save schema/compatibility documentation when implemented.

## Change record

| Date | Update |
| --- | --- |
| 2026-10-16 | Restricted saved days to 1–100,000, capped calendar advancement at the final day, and added boundary/overflow/non-mutation regression coverage. Clock and save suites passed: 12 cases, 0 failures. With the owner's manual verification and the review fix complete, ARPG-012 is Complete. |
| 2026-10-16 | Project owner confirmed the implemented system matches the described behavior and reported no errors. Manual lighting/HUD verification is accepted. Code review reproduced a missing upper bound in saved day validation: day=1e30 passes validation and overflows on restore; keep In Progress until addressed. |
| 2026-10-16 | Project owner accepted the 24-minute day proposal and first implementation scope; recorded as Accepted, without implementation. |
