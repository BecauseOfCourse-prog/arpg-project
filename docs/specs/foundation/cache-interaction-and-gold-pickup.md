# ARPG-011: Cache Interaction and Gold Pickup

- **Status:** Complete
- **Owner:** Project owner
- **Created:** 2026-10-15
- **Related specifications:** [ARPG-003: Player Movement and Navigation](player-movement-navigation.md); [ARPG-007: Hub Vendor](hub-vendor.md); [ARPG-009: Save and Load](save-load.md); [ARPG-013: Procedural Exploration Zone Generation](procedural-exploration-zones.md)
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

- [x] Clicking a closed cache issues an approach movement command; opening occurs automatically only after the player reaches interaction range.
- [x] Opening a cache does not invoke basic attack or ability behavior.
- [x] The cache produces exactly one gold pile per world session, with an integer value from 1 through 20 inclusive.
- [x] Repeated clicks on an open cache do not create additional rewards during the same session.
- [x] The gold pile spawns on traversable, reachable ground and never beyond the map boundary or inside an impassable obstacle.
- [x] Clicking the pile approaches and collects it; the pile is removed and the player's balance increases by its value exactly once.
- [x] An unreachable target does not cause teleportation, remote opening, or remote collection.
- [x] Loading a save restores caches to closed state and permits a new reward, including when previously collected gold remains in the loaded balance.
- [x] Loading a save removes any uncollected gold pile from the prior session.
- [x] The test cache is placed at a reachable location within the exploration area.
- [x] Automated tests cover interaction, one-time reward generation per session, reward bounds, reachable pickup placement, click-to-collect, gold balance updates, and load-reset behavior.
- [x] The project owner verifies the temporary cache and gold visuals and the interaction flow in Godot Editor. The reported player/cache draw-order correction is tracked in ARPG-014.

## Verification plan and results

The initial eight GdUnit4 cases in `test/cache_interaction_test.gd` pass. They cover click-to-approach opening without combat, click-only gold collection, exactly-once reward and gold transfer, 64 reward rolls within the inclusive range, reachable placement near the map boundary, unreachable targets, nearby targets behind a wall, cancellation by ground/enemy commands, and load reset while preserving saved gold. The implementation's full suite passed in normal display mode (49 cases, 0 errors, 0 failures, 0 orphans); the report is `reports/report_61/index.html`. On 2026-10-16 the project owner confirmed the cache works in Godot Editor and reported a player/cache overlap issue. ARPG-014 corrects that draw order and adds a rendered overlap regression test, alongside inventory gold and vendor approach improvements.

## Documentation impact

- [x] Update `docs/PROJECT_CONTEXT.md` when implementation establishes the current gameplay baseline.
- [x] Review ADR impact; existing ownership and persistence decisions remain sufficient.
- [x] Add this specification to the index and link it from the backlog.
- [x] Update ARPG-007 to link the clarified cache interaction and reward behavior.

## Open questions

None. The project owner selected approach-and-open interaction, a random 1–20 gold reward, click-to-approach pickup, and cache restoration after load with repeat rewards accepted for the prototype.

## Implementation notes

Keep the cache interaction separate from combat targeting so clicks cannot accidentally issue an attack. Use the existing movement/navigation behavior for both cache and pile targets.

`WorldInteractable` provides shared click and interaction ranges. `PlayerActor` routes cache/gold clicks to `InteractionController` and cancels repeated combat. Ground or enemy commands cancel a pending interaction. The controller requires a valid navigation path and opens/collects only when its remaining length is within interaction range, preventing interaction through walls. The test cache is a non-blocking small object at `(110, -95)` in the exploration area, with a 22-unit click radius and a 24-unit interaction range. Gold uses an 18-unit click radius and a 16-unit pickup range.

`MapCache` tries four nearby 32-unit offsets and then its own footprint for a reachable, unobstructed reward position. If none is valid, it remains closed and produces no reward. Gold piles display their amount and give gold through `PlayerProgression.add_gold`; proximity alone does not collect them. A successful load cancels pending interaction, removes uncollected piles, and resets caches without changing the save schema. ARPG-013 will replace the fixed cache placement when procedural zones are implemented.

## Change record

| Date | Update |
| --- | --- |
| 2026-10-15 | Drafted from the project owner's decisions: click to approach and open caches, random 1–20 gold in a ground pile, click to approach and collect, and reset cache state on load with repeat rewards allowed for the prototype. |
| 2026-10-15 | Review clarifications: uncollected ground rewards disappear on load; place the test cache at any accessible point in the exploration area; Hub Services is not an affected system. |
| 2026-10-15 | ARPG-013 will provide the test cache's valid randomized placement in generated exploration zones. |
| 2026-10-16 | Implemented the test cache, approach-and-open interaction, reachable random gold reward, click-to-approach collection, command cancellation, and reset on successful load. Eight automated cache tests pass; Godot Editor visual verification remains pending. |
| 2026-10-16 | Project owner confirmed cache behavior in Godot Editor. Closed ARPG-011; the reported draw-order issue and additional inventory/vendor improvements are tracked by ARPG-014. |
| 2026-10-16 | ARPG-013 now supplies the cache's randomized reachable placement and recreates it closed when loading a fresh generated layout. The earlier fixed position remains only in deterministic gameplay test fixtures. |
