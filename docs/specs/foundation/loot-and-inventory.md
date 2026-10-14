# ARPG-005: Equipment Drop and Minimal Inventory

- **Status:** Complete
- **Owner:** Project owner
- **Created:** 2026-10-14
- **Related specifications:** [ARPG-001: First Playable Vertical Slice](first-playable-vertical-slice.md); [ARPG-004: Basic Combat](basic-combat.md)
- **Related ADRs:** [ADR-0002: Game System Boundaries](../../decisions/ADR-0002-game-system-boundaries.md)

## Summary

Define the guaranteed equipment drop from the first enemy encounter, mouse-led pickup, and the minimal inventory display needed to complete the first playable loop.

## Motivation

The vertical slice must demonstrate a compact loot loop from enemy defeat through item pickup and return to the hub, without implementing broad randomization or equipment systems.

## Scope

### In scope

- One predefined equipment item, authored as a Godot Resource.
- One guaranteed drop when the first-slice enemy is defeated.
- The item appears in the world near the defeated enemy.
- Clicking the item commands the player to move toward it; the item is collected automatically on contact.
- A minimal inventory list displays the item's name, rarity, and affix.
- The item remains in the inventory when the player traverses back to the hub in the same session.
- The affix is descriptive display data only; it does not change gameplay stats in this slice.

### Out of scope

- Random drop chances, loot tables, broad rarity pools, or multiple item drops.
- Equipping the item or applying its affix to player stats.
- Multiple inventory slots, item sorting, stacking, vendors, storage, or trading.
- Save/load persistence across application sessions.

## User-facing behavior

- Defeating the one enemy creates exactly one predefined equipment drop near its location.
- The player can left-click the item to move toward it. When the player reaches and touches it, it is collected automatically.
- The inventory list shows the item name, rarity, and affix text.
- The collected item remains in the inventory after the player returns to the hub through the continuous world.
- The example item is an `Emberwood Bow`, with `Magic` rarity and the affix `of Cinders` (`+1 Fire Damage`, display-only).

## Rules and data

- Item definition data is authored as a Godot Resource and remains separate from runtime item state.
- Enemy defeat guarantees the one authored equipment item; there is no random roll in this slice.
- A world drop is collected by contact after movement is commanded by clicking it.
- The inventory is a simple list sufficient to show one item and its name, rarity, and affix.
- The affix is shown as text only and has no effect because equipping is out of scope.
- Inventory state is retained during area traversal within the current run; save/load across runs is out of scope.

## Affected systems

- Items & Loot
- Input & Interaction
- Player Character & Progression
- User Interface
- World & Areas

## Dependencies and constraints

- Depends on ARPG-001, ARPG-002, ARPG-003, and ARPG-004.
- Must use Godot 4.6 Stable, typed GDScript where practical, and Godot Resources for authored item definitions.
- Must respect the item ownership boundaries in ADR-0002.

## Acceptance criteria

- [x] Defeating the first-slice enemy creates exactly one `Emberwood Bow` drop on walkable ground near the enemy.
- [x] The drop has the predefined `Magic` rarity and `of Cinders` affix text.
- [x] Left-clicking the item commands movement toward it, and contact collects it automatically.
- [x] The minimal inventory list displays the item name, rarity, and affix.
- [x] The collected item remains in inventory after traversal back to the hub in the same run.
- [x] The affix does not modify player stats in this slice.
- [x] Automated tests verify guaranteed drop, pickup, inventory display data, and retention across area traversal.

## Verification plan and results

Automated verification: all 13 GdUnit4 test cases pass. Coverage includes the guaranteed drop staying on walkable ground, contact pickup, inventory display data, and retention through exploration-to-hub traversal. The project owner confirmed the item, pickup, and inventory presentation work in Godot Editor.

## Documentation impact

- [ ] Update `docs/PROJECT_CONTEXT.md` if the accepted project baseline changes.
- [ ] Add or update an ADR if a lasting architectural decision is made.
- [x] Update related specs and the index.
- [x] Link this specification from the backlog.

## Open questions

None.

## Implementation notes

The item name and affix are fixed sample content for the first slice. Do not infer an equip flow, stat application, or generalized loot-generation system from them. The world item is an `Area2D` whose contact is handled by the inventory controller. The guaranteed drop is offset north of the enemy so it remains within the authored triangular ground boundary.

## Change record

| Date | Update |
| --- | --- |
| 2026-10-14 | Accepted item example, guaranteed drop, click-to-approach/contact pickup, and display-only affix behavior. |
| 2026-10-14 | Implementation started after the project owner reported that the combat drop appeared beyond the map boundary and could not be collected. |
| 2026-10-14 | The project owner confirmed the ground item, contact pickup, and inventory in Godot Editor; ARPG-005 is complete. |
