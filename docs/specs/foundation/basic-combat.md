# ARPG-004: Basic Combat

- **Status:** Complete
- **Owner:** Project owner
- **Created:** 2026-10-14
- **Related specifications:** [ARPG-001: First Playable Vertical Slice](first-playable-vertical-slice.md); [ARPG-003: Player Movement and Navigation](player-movement-navigation.md)
- **Related ADRs:** [ADR-0002: Game System Boundaries](../../decisions/ADR-0002-game-system-boundaries.md)

## Summary

Define the first-slice basic ranged attack against one passive enemy encounter, including attack input, approach behavior, and the boundary between movement and repeated attacks.

## Motivation

The first playable loop requires the player to use a basic attack to defeat one enemy. The input and encounter behavior must be clear before implementation.

## Scope

### In scope

- One basic ranged attack for the initial player character.
- Left-clicking an enemy issues an attack command.
- The player automatically approaches an enemy that is outside attack range, then attacks.
- An attack command repeats attacks until the player issues a movement command.
- The single enemy encounter in the first slice remains stationary and does not attack the player.
- The enemy can be defeated; its defeat and the one authored equipment drop follow ARPG-001.

### Out of scope

- Enemy attacks, pursuit, or other active combat behavior in the first slice.
- Player death, defeat, or restart flows.
- Additional attack types, abilities, potions, or enemy types.
- Full-game enemy behavior; the stationary enemy is a prototype-only choice.
- Additional balance work beyond the initial attack interval, damage, and enemy health values.

## User-facing behavior

- Left-clicking an enemy selects it as the attack target.
- If the target is outside attack range, the player automatically moves toward it and attacks when in range.
- The basic attack repeats after an attack command. Issuing a movement command cancels the repeated attack command.
- The prototype enemy waits in place and does not damage the player. The player can defeat it with the basic ranged attack.
- Hits and defeat have temporary visual feedback; no enemy health bar is shown.
- The ranged attack is shown as a visible temporary projectile. Walls and large environment objects block it; small objects do not.

## Rules and data

- Left-click intent: enemy target means attack; ground or non-enemy world object means movement, as specified in ARPG-003.
- A movement command takes precedence over a repeating attack command and ends that repeated attack command.
- The first-slice enemy is passive and stationary. This does not establish behavior for enemies in the full game.
- The basic attack fires once per second and deals one point of damage. The enemy has five health and is defeated after five successful hits.
- Attack cadence is determined by character and weapon combat stats and is independent of how often the player clicks the selected enemy.
- Attack range is tuned against the authored scene scale during the first playtest; the player automatically approaches until inside that range without overlapping the enemy.
- The ranged attack is represented by a visible temporary projectile. Walls and large environment objects block the projectile; small objects do not.
- Hit and defeat feedback are visual only; the enemy does not need a health bar.
- The enemy's defeat produces the one predefined equipment item required by ARPG-001.

## Affected systems

- Input & Interaction
- Player Character & Progression
- Actors & Combat
- World & Areas
- Items & Loot

## Dependencies and constraints

- Depends on ARPG-001, ARPG-002, and ARPG-003.
- Must use Godot 4.6 Stable and typed GDScript where practical.
- Must preserve the fixed-oblique 2D presentation.

## Acceptance criteria

- [x] Left-clicking an enemy issues an attack command.
- [x] The player approaches an enemy outside attack range and attacks once in range.
- [x] An attack command repeats attacks until a movement command is issued.
- [x] The first-slice enemy remains stationary and does not attack the player.
- [x] The attack fires once per second, deals one damage, and defeats the enemy after five successful hits.
- [x] Repeated clicks on the selected enemy do not reset or accelerate the attack cadence.
- [x] A visible projectile is blocked by walls and large environment objects but not by small objects.
- [x] Hits have visual feedback without a health bar. (Confirmed by the project owner in Godot Editor.)
- [x] Defeat has visual feedback without a health bar. (Confirmed by the project owner in Godot Editor.)
- [x] The enemy can be defeated, triggering the equipment drop defined by ARPG-001.

## Verification plan and results

Automated verification: the cadence regression test repeatedly issues target clicks while checking that the configured attack interval remains authoritative. The full current test run is recorded in ARPG-007 verification. Coverage includes target selection and approach, repeated attacks and movement cancellation, passive enemy behavior, projectile damage, wall blocking, the default one-second attack cadence, five-hit defeat and one equipment drop, pickup and inventory behavior, authored combat tuning, and existing navigation/project structure behavior. Headless project import and main-scene startup pass. The project owner confirmed hit and defeat feedback in Godot Editor.

## Documentation impact

- [ ] Update `docs/PROJECT_CONTEXT.md` if the accepted baseline changes.
- [ ] Add or update an ADR if a lasting architectural decision is made.
- [x] Update related specs and the index.
- [x] Link this specification from the backlog.

## Open questions

None. Tune attack range against the scene scale during the first playtest.

## Implementation notes

Do not infer a projectile node structure or full-game enemy behavior from this behavior-level specification.

`CombatController` connects the player's attack and movement intent signals, commands approach movement, and spawns a collision-aware `BasicProjectile`. The projectile collides with physics layer 1, which contains walls and large environment objects. `EnemyActor` owns its health, hit flash, defeat state, and collision/group removal. Defeat spawns the authored Emberwood Bow `WorldItem`; pickup and inventory remain in ARPG-005. The passive Training Sentinel is authored in the exploration area.

## Change record

| Date | Update |
| --- | --- |
| 2026-10-14 | Initial draft from the project owner's basic combat decisions. |
| 2026-10-14 | Accepted passive enemy, projectile blocking, five-hit defeat baseline, and visual feedback rules. |
| 2026-10-14 | Implementation started after completion of ARPG-003. |
| 2026-10-14 | Added the passive exploration enemy, repeatable ranged projectile combat, approach targeting, hit/defeat behavior, and the guaranteed authored equipment drop. Added automated combat tests; interactive visual confirmation remains. |
| 2026-10-14 | Fixed the guaranteed drop location after a playtest found it outside the ground boundary; loot pickup and inventory are being implemented under ARPG-005. |
| 2026-10-14 | The project owner confirmed hit feedback in Godot Editor. |
| 2026-10-14 | The project owner confirmed defeat feedback in Godot Editor; ARPG-004 is complete. |
| 2026-10-14 | Fixed attack cadence so repeated target clicks no longer reset the character/weapon attack timer; added a regression test. |
