# ARPG-017: In-game Time Test Controls

- **Status:** Complete
- **Owner:** Project owner
- **Created:** 2026-10-16
- **Related specifications:** [Game Time](game-time-day-cycle.md), [Limited Vendor](limited-daily-vendor.md)

## Summary and scope

Add an in-game test panel opened with F8 and a visible HUD button during active play. Controls select hour/minute, jump to morning (06:00), day (12:00), evening (18:00), night (22:00), advance one hour or one day, and freeze/resume automatic clock advancement. This is a prototype testing tool, not a sleeping mechanic.

## Rules

Selected times use the next occurrence: an earlier time advances into the next calendar day; selecting the current minute does nothing. All jumps go through GameClock.advance so lighting, HUD, midnight, calendar limits, and vendor refresh/deferral retain their normal rules. Opening the panel does not pause gameplay. Freezing affects automatic clock advancement only; explicit steps still work. Menus block the tool and stop time normally. Freeze is a session-only testing setting, reset by New Game/load and excluded from saves. Resulting calendar time and vendor stock use the existing save contract. No backward calendar edits, speed multiplier, or new save fields.

## Acceptance criteria

- [x] Tool is hidden before starting a session and can be opened/closed by F8 or HUD controls.
- [x] Custom time, presets, hour/day steps update time, lighting, and HUD through normal advancement.
- [x] Crossing 06:00 refreshes finite stock, deferred while trading is open; resulting saves validate.
- [x] Freeze blocks automatic advancement while allowing explicit jumps and respects menu pause.
- [x] New Game/load resets freeze; calendar overflow remains capped.
- [x] Controls fit the viewport alongside inventory and trading.

## Verification

Godot import passed. Full display-mode GdUnit4 run: 82/82 tests passed across 11 suites (reports/report_83), including four new panel tests. Verified session visibility/F8, calendar selection, lighting/HUD, deferred vendor refresh and save validity, freeze/manual steps, pause, reset on load/New Game, invalid inputs, and calendar bounds. Inspected reports/debug-time-panel.png: controls fit the central space between inventory and trading. The initial screenshot test waited indefinitely for a render signal; it now explicitly draws a frame before capture. Human Editor playthrough has not been performed.
