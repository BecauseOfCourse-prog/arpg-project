# ARPG-008: Keyboard Ability and Potion Use

- **Status:** Complete
- **Owner:** Project owner
- **Created:** 2026-10-15
- **Related specifications:** [ARPG-003: Player Movement and Navigation](player-movement-navigation.md); [ARPG-004: Basic Combat](basic-combat.md); [ARPG-005: Equipment Drop and Minimal Inventory](loot-and-inventory.md); [ARPG-009: Save and Load](save-load.md)
- **Related ADRs:** [ADR-0002: Game System Boundaries](../../decisions/ADR-0002-game-system-boundaries.md)

## Summary

Add one keyboard-triggered projectile ability and keyboard use of the sample health potion. Introduce current/max player health so potion healing has a gameplay effect.

## Motivation

The prototype currently supports mouse-directed basic attacks and inventory management but has no keyboard ability use or player health. This change begins the ability and consumable loop while keeping the existing training enemy passive.

## Scope

### In scope

- A single ability on Q that fires a projectile in the direction of the cursor; it deals 2 damage and has a 3-second cooldown with no resource cost.
- Current and maximum player health; maximum health is 100 and a new game starts at 50 HP so the potion can be demonstrated with the passive training enemy.
- Using a health potion from the inventory with key 1; it restores 50 HP and consumes one item only if health is below maximum.
- A simple health bar in the HUD.
- Automated tests for ability activation, damage/cooldown behavior, potion use, inventory consumption, and health boundaries.
- Loading a save restores the player to full health; current health is not persisted.

### Out of scope

- Enemy attacks or any other player damage source; the training enemy remains passive as specified by ARPG-004.
- A general skill tree, multiple abilities, mana/resource systems, hotbar UI, or input remapping UI.
- Character death or defeat behavior.

## User-facing behavior

- The player activates the ability with Q; its projectile travels toward the current cursor position, damages an enemy it hits, and is stopped by world obstacles.
- The ability deals 2 damage, can be cast once every 3 seconds, and has no resource cost. Presses during cooldown do not fire or shorten the cooldown.
- The player activates a health potion with key 1. A successful use restores 50 HP and consumes exactly one potion from the inventory stack.
- At full health, or with no health potion in inventory, use has no effect and consumes nothing.
- The HUD shows a simple health bar for the player's current and maximum health.
- The player's health remains clamped between zero and maximum; this prototype does not add player defeat behavior or an enemy damage source.
- A new game starts at 50/100 HP. Loading any available save restores full health; health is not serialized.

## Rules and data

- The project owner selected a cursor-directed projectile ability on Q, for 2 damage every 3 seconds, with no resource cost.
- The project owner selected adding current/max player health while keeping enemies passive, a maximum of 100 HP, and a starting value of 50 HP to demonstrate potion use.
- The project owner selected health potion use on key 1, healing 50 HP, with no consumption when already at full health; current HP is restored to full when loading a save.
- The project owner selected a simple health bar in the HUD.
- Actors & Combat own current actor health under ADR-0002. Items & Loot own potion inventory state; Ability & Effects own ability execution; Input & Interaction maps keys to requests.
- Save & Load does not serialize current HP for this prototype; loading restores full health.

## Affected systems

- Input & Interaction
- Actors & Combat
- Abilities & Effects
- Items & Loot
- User Interface
- Save & Load

## Dependencies and constraints

- Depends on ARPG-003, ARPG-004, and ARPG-005.
- Must preserve the passive training enemy behavior and the system ownership boundaries in ADR-0002.
- Must use Godot 4.6 Stable and typed GDScript where practical.

## Acceptance criteria

- [x] Q fires the ability projectile toward the cursor; it damages an enemy on contact and is blocked by world obstacles (automated tests).
- [x] Ability damage is 2 and cooldown is 3 seconds; attempts during cooldown do not fire (automated test).
- [x] Key 1 uses one health potion, restores up to 50 HP, and consumes nothing when at full health or when no potion is available (automated tests).
- [x] Health is clamped between zero and maximum; no player defeat behavior or enemy damage source is added in this prototype.
- [x] Loading a save restores full health; current HP is not persisted (automated save/load test).
- [x] The HUD health bar reflects current/max health; automated tests verify that it updates when a potion is used.
- [x] Automated tests cover ability and potion behavior; existing combat, inventory, and save/load tests continue to pass.

## Verification plan and results

GdUnit4 full suite: 41 cases passed, 0 failures. Tests cover key mappings, projectile damage/cooldown/wall blocking, potion consumption and health caps, HUD updates, and full HP after save load. The project owner verified in Godot Editor that the HUD works, Q and 1 activate the expected actions, potions restore health, healing does not occur without a potion, the ability does not pass through walls, it deals 2 damage, and its cooldown is about 3 seconds.

## Documentation impact

- [x] Update `docs/PROJECT_CONTEXT.md` with the accepted ability, health, and input baseline.
- [x] Review ADR impact; no new lasting architectural decision required an ADR.
- [x] Update related specs and the specification index.
- [x] Update the backlog to mark ARPG-008 complete.

## Open questions

None.

## Implementation notes

The existing `BasicProjectile` is tied to one attack target, so the ability uses a separate `AbilityProjectile`. It detects bodies along its path, applies damage to enemies, and is removed when it hits a world obstacle or reaches its lifetime limit.

## Change record

| Date | Update |
| --- | --- |
| 2026-10-15 | Drafted after selecting ARPG-008. Project owner chose a cursor-directed projectile and adding player health. |
| 2026-10-15 | Project owner selected Q for the ability, key 1 for potions, 2 damage with a 3-second cooldown, 100 maximum HP, 50 starting HP, 50 HP per potion, a HUD health bar, and full health on save load. |
| 2026-10-15 | Implemented the selected ability and potion flow, player health, health HUD, and automated coverage; Editor verification was pending at that point. |
| 2026-10-15 | The project owner confirmed the health HUD, Q ability and key 1 potion in Godot Editor, including healing/no-potion behavior, wall blocking, 2 damage, and the approximately 3-second cooldown. ARPG-008 is complete. |
