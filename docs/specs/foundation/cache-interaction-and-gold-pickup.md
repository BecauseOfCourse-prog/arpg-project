# ARPG-011: Cache Interaction and Gold Pickup

- **Status:** Accepted
- **Owner:** Project owner
- **Created:** 2026-10-15
- **Related specifications:** [ARPG-003: Player Movement and Navigation](player-movement-navigation.md); [ARPG-007: Hub Vendor](hub-vendor.md); [ARPG-009: Save and Load](save-load.md)
- **Related ADRs:** [ADR-0002: Game System Boundaries](../../decisions/ADR-0002-game-system-boundaries.md); [ADR-0004: Player Gold Balance Ownership](../../decisions/ADR-0004-player-gold-balance-ownership.md)

## Summary

Add an interactable map cache that the player opens by clicking and approaching. Opening it creates a clickable gold pickup with a random value; the player approaches and collects the pile by clicking it.

## Motivation

Map caches provide a direct exploration reward and implement the map-cache gold source established by ARPG-007, with interaction behavior defined as opening rather than attacking.

## Scope

### In scope

- A map cache that responds to a left-click interaction command.
- One test cache placed at any accessible location within the exploration area.
- The player automatically approaches the cache and opens it upon reaching interaction range.
- Opening a cache once in the current world session creates one gold pile with a random integer value from 1 through 20, inclusive.
- Clicking the gold pile commands the player to approach it; the pile is collected when the player reaches it.
- Collected gold is added to the existing Player Character & Progression balance.
- The cache and gold pile use temporary visuals consistent with the current prototype.
- Cache state is not persisted. Loading a save restores the cache and allows its reward to be collected again; this repeat reward is accepted for the prototype.
- Uncollected gold piles on the ground are not persisted and disappear when a save is loaded.

### Out of scope

- Destroying caches with basic attacks, abilities, or damage.
- Persisting opened-cache state or preventing repeat rewards across loads.
- Multiple cache types, authored reward tables, or randomized loot beyond the gold amount.
- New currency ownership or inventory-item representations for gold.
- A game-time/day-cycle system, which remains tracked by ARPG-012.

## User-facing behavior

- A left click on a closed cache replaces the current movement goal with an approach to that cache. When the player reaches interaction range, the cache opens automatically.
- A cache opens and produces its reward at most once during the current world session. Clicking an already-open cache does not produce another reward.
- The reward appears as one gold pile on reachable traversable ground near the cache. Its integer value is randomly selected from 1 to 20 inclusive.
- A left click on the pile commands the player to approach it. On reaching it, the pile disappears and its value is added to the player's gold balance exactly once.
- If no route to a clicked cache or gold pile exists, the player does not teleport or collect it remotely; the target remains available for a later interaction.
- The cache remains open for the rest of the current world session. Loading a save restores it to the closed state and removes all uncollected gold piles. The player may reopen the cache and receive a new random reward; repeat rewards after load are accepted for the prototype.

## Rules and data

- Cache interaction is a movement-and-interaction action, not an attack request.
- The cache opens when the player reaches its authored interaction range.
- Each cache instance can generate one reward per world session.
- Each reward consists of one pile with an integer gold amount in the inclusive range `[1, 20]`.
- The gold pile must be positioned on valid traversable ground and remain reachable by the existing navigation system; it must not spawn outside the map or inside an impassable obstacle.
- Clicking the pile initiates approach; collection occurs when the player reaches pickup range.
- Player Character & Progression remains the sole owner of the numeric gold balance under ADR-0004.
- The cache-open state and uncollected gold pile are world state and are not serialized by the current save contract. A load creates the cache in its closed state.
- The first test instance must be located within the exploration area, at a point reachable by the existing navigation system.

## Affected systems

- Input & Interaction
- Player Character & Progression
- World & Areas
- Save & Load boundary
- User Interface and placeholder visuals

## Dependencies and constraints

- Depends on ARPG-003 click-to-move, navigation, and obstacle handling.
- Depends on ARPG-007's player gold balance and ADR-0004 ownership decision.
- Must use Godot 4.6 Stable and typed GDScript where practical.
- Reward placement must honor traversable-ground boundaries and avoid the previously observed out-of-map pickup failure mode.

## Acceptance criteria

- [ ] Clicking a closed cache issues an approach movement command; opening occurs automatically only after the player reaches interaction range.
- [ ] Opening a cache does not invoke basic attack or ability behavior.
- [ ] The cache produces exactly one gold pile per world session, with an integer value from 1 through 20 inclusive.
- [ ] Repeated clicks on an open cache do not create additional rewards during the same session.
- [ ] The gold pile spawns on traversable, reachable ground and never beyond the map boundary or inside an impassable obstacle.
- [ ] Clicking the pile approaches and collects it; the pile is removed and the player's balance increases by its value exactly once.
- [ ] An unreachable target does not cause teleportation, remote opening, or remote collection.
- [ ] Loading a save restores caches to closed state and permits a new reward, including when previously collected gold remains in the loaded balance.
- [ ] Loading a save removes any uncollected gold pile from the prior session.
- [ ] The test cache is placed at a reachable location within the exploration area.
- [ ] Automated tests cover interaction, one-time reward generation per session, reward bounds, reachable pickup placement, click-to-collect, gold balance updates, and load-reset behavior.
- [ ] The project owner verifies the temporary cache and gold visuals and the interaction flow in Godot Editor.

## Verification plan and results

Pending implementation. Automated tests will verify deterministic interaction and reward invariants, including the inclusive reward range and exactly-once gold transfer. Godot Editor verification will check approach, automatic opening, visible ground pile, and click-to-collect behavior.

## Documentation impact

- [ ] Update `docs/PROJECT_CONTEXT.md` when implementation establishes the current gameplay baseline.
- [ ] Add or update an ADR if implementation changes a lasting system boundary or persistence decision.
- [x] Add this specification to the index and link it from the backlog.
- [x] Update ARPG-007 to link the clarified cache interaction and reward behavior.

## Open questions

None. The project owner selected approach-and-open interaction, a random 1–20 gold reward, click-to-approach pickup, and cache restoration after load with repeat rewards accepted for the prototype.

## Implementation notes

Keep the cache interaction separate from combat targeting so clicks cannot accidentally issue an attack. Use the existing movement/navigation behavior for both cache and pile targets.

## Change record

| Date | Update |
| --- | --- |
| 2026-10-15 | Drafted from the project owner's decisions: click to approach and open caches, random 1–20 gold in a ground pile, click to approach and collect, and reset cache state on load with repeat rewards allowed for the prototype. |
| 2026-10-15 | Review clarifications: uncollected ground rewards disappear on load; place the test cache at any accessible point in the exploration area; Hub Services is not an affected system. |
