# ARPG-019: Click-to-pick-up Enemy Loot

- **Status:** Complete
- **Created:** 2026-10-16
- **Related:** [Loot and Inventory](loot-and-inventory.md), [Cache and Gold](cache-interaction-and-gold-pickup.md)

## Behavior and scope

Enemy equipment drops remain on the ground with a highlighted item-name label. A short left click on the ground item or its label approaches and collects it through the same interaction flow as gold. Touching or walking over loot never collects it. Movement holds never collect loot. If inventory is full the item stays on the ground and can be retried after making space. Collection transfers exactly one item and removes its world representation. Preserve existing loot definition, drop count, inventory layout, session-only drops, and regeneration cleanup.

## Acceptance criteria and verification

- [x] Defeated enemies drop one named ground item.
- [x] Touching and movement holds leave the drop on the ground.
- [x] Clicking the item or name approaches and collects exactly once.
- [x] Full inventory and unreachable targets leave the drop intact.
- [x] Combat, mouse input, inventory, and gold interaction checks pass.

Full display-mode GdUnit4 run: 87/87 passed across 13 suites (reports/report_85). Final expanded loot suite: 4/4 passed (reports/report_86), including real press/release on the label and movement-only holds. Verified no touch collection, click-to-approach, full-inventory retry, exactly-once collection, unreachable targets, existing enemy drop count, and gold/input regressions. Inspected reports/ground-loot.png: the named ground item is visible with a gold outlined label. The project owner confirmed in-game loot behavior works correctly on 2026-10-16.
