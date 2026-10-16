# ARPG-014: World Interaction and Inventory Feedback

- **Status:** Complete
- **Owner:** Project owner
- **Created:** 2026-10-16
- **Related specifications:** [ARPG-003](player-movement-navigation.md); [ARPG-007](hub-vendor.md); [ARPG-011](cache-interaction-and-gold-pickup.md)
- **Related ADRs:** [ADR-0002](../../decisions/ADR-0002-game-system-boundaries.md); [ADR-0004](../../decisions/ADR-0004-player-gold-balance-ownership.md)

## Summary

Correct world draw order around the cache, display the player's current gold in inventory, and require approaching the vendor before opening its window.

## Scope and behavior

- Sort the player, cache, vendor, and other world objects by their ground position across the hub and exploration area. A player below the cache is drawn in front; a player above it is drawn behind. Ground remains behind actors.
- The cache is a non-blocking interaction marker, with no physics collision or navigation obstruction. The player can walk through its footprint while it is closed or open. Clicking the cache still requests approach and opening; clicking ground beyond it allows traversal through it.
- Show gold in the inventory even when it contains no items. Refresh the balance immediately after collection, purchase, sale, buyback, initialization, and save restoration. Player Character & Progression remains its sole owner.
- Clicking the vendor cancels repeated attacks and approaches the vendor. Open trading only when the remaining traversable path is within 40 world units. The vendor's click radius remains 24 units.
- Ground, enemy, or other interaction commands replace a pending vendor approach. An unreachable vendor does not open remotely or teleport the player.
- Retain existing vendor transactions and buyback behavior. This change does not introduce automatic window closure when walking away.

## Affected systems

- World & Areas, Input & Interaction, User Interface, Player Character & Progression, Hub Services

## Acceptance criteria

- [x] World sorting uses ground position across both areas, with ground behind actors.
- [x] The player can traverse through the center of both closed and open caches without collision or a navigation detour.
- [x] Inventory displays current gold and reacts to collection, transactions, and load.
- [x] A distant vendor click approaches without opening immediately; reaching interaction range opens the window.
- [x] Replacement commands cancel vendor approach, and unreachable vendors remain closed.
- [x] Automated tests cover these changes and existing tests pass.
- [x] The project owner verifies draw order, the inventory balance, and vendor approach in Godot Editor.

## Verification plan and results

GdUnit4 full suite in normal display mode: 51 cases passed, 0 errors, 0 failures, 0 orphans (`reports/report_64/index.html`). A rendered-image regression uses an offscreen viewport to compare overlap pixels with the player below and above the cache across their different area parents, and checks both boundary walls remain visible above ground. Cache and vendor tests verify inventory gold after rewards, purchase, sale, buyback, and load. Vendor tests verify delayed opening after approach, cancellation, and unreachable targets. The project owner confirmed the changes in Godot Editor before selecting ARPG-013.

Follow-up verification: all 10 cache tests pass (`reports/report_65/index.html`), including actual player traversal through both closed and open cache centers. No gameplay-code change was required: the cache already has no collision body or navigation obstruction.

## Documentation impact

- [x] Update project context, specification index, and backlog.
- [x] Record the project owner's ARPG-011 verification and the remaining draw-order correction.

## Implementation notes

The world and both area parents enable Y sorting, so actor and object subtrees sort together by their ground position. Ground keeps a negative Z index; boundary-wall visuals use the normal object layer so sorting does not place them under the ground. `PlayerProgression.gold_changed` updates the inventory label on every balance change, including restoration. The vendor uses `WorldInteractable` and the same reachable-path approach controller as the cache and gold pile.

## Open questions

None. Interaction distances are initial tuning values.

## Change record

| Date | Update |
| --- | --- |
| 2026-10-16 | Project owner confirmed cache interaction and reported cache overlap, missing inventory gold, and remote vendor opening. Implementation of the requested corrections is authorized. |
| 2026-10-16 | Implemented the three corrections and verified all 51 tests, including rendered overlap and boundary visibility. Editor rechecking of this follow-up remains pending. |
| 2026-10-16 | Project owner explicitly confirmed that the cache must have no physics collision and allow walking through its footprint. Retain the existing non-blocking scene and add traversal regression coverage. |
| 2026-10-16 | Project owner confirmed the corrections work and requested procedural generation next. ARPG-014 is complete. |
