# ARPG-013: Procedural Exploration Zone Generation

- **Status:** Complete
- **Owner:** Project owner
- **Created:** 2026-10-15
- **Related specifications:** [ARPG-003: Player Movement and Navigation](player-movement-navigation.md) (also covers ARPG-006 area connection); [ARPG-009: Save and Load](save-load.md); [ARPG-011: Cache Interaction and Gold Pickup](cache-interaction-and-gold-pickup.md)
- **Related ADRs:** [ADR-0002: Game System Boundaries](../../decisions/ADR-0002-game-system-boundaries.md)

## Summary

Generate two rectangular exploration zones with randomized dimensions, object placement, and a connection between them at a randomized point along the first zone's fixed east side. Keep the safe hub authored and fixed, and regenerate exploration zones whenever a game world is initialized or loaded.

## Motivation

Procedural exploration areas provide replayable layouts while keeping the safe hub stable and preserving the continuous traversal model.

## Scope

### In scope

- Generate two exploration zones for the prototype; do not procedurally generate the hub.
- Keep each exploration zone rectangular, with width and height independently selected within configured bounds.
- Randomize placement of the existing environment obstacles and test content: a training enemy and the cache defined by ARPG-011.
- Place the passage connecting the two exploration zones on the east side of the first zone every time, while randomizing its position along that side and guaranteeing a traversable route.
- Preserve the existing fixed passage from the hub into the first exploration zone.
- Keep all zones in the current continuous world so transitions do not load a separate scene or teleport the player.
- Generate fresh exploration layouts when starting a new game and whenever a save is loaded. Spawn the player in the hub after loading.
- Keep the generated layout stable during the active world session; do not regenerate when the player traverses between zones.
- Do not serialize layouts, random seeds, or generated world state. Uncollected ground rewards disappear on load, consistent with ARPG-011.
- Ensure the whole traversable area is connected; generated obstacles must not isolate walkable regions.

### Out of scope

- Procedural generation of the hub.
- Random terrain shapes, non-rectangular zones, or terrain deformation; only zone dimensions and object placement vary.
- Saving or restoring generated zone layouts or random seeds.
- Adding new enemy, obstacle, cache, biome, or loot types.
- A game-time/day-cycle system (ARPG-012).

## User-facing behavior

- Starting a new game creates fresh layouts for two exploration zones and leaves the hub unchanged.
- Loading a save runs generation again rather than restoring a serialized layout, and places the player in the hub. Character progression and other data covered by ARPG-009 continue to load according to that specification; the generated layout may coincidentally match a previous one.
- The two exploration zones remain connected in the same traversable world. The passage always leaves the first zone through its east side and enters the second zone through the matching point on its west side; the point along the sides varies between generated layouts. The hub-to-exploration passage remains fixed.
- Obstacles, the training enemy, and the ARPG-011 cache appear at randomized valid positions in the exploration zones.
- The player can reach every traversable region and every generated transition, enemy, and cache through connected ground paths. No isolated walkable pockets are generated.
- A generated layout remains unchanged while the player moves between the hub and exploration zones during one active session.

## Rules and data

- Only exploration-zone dimensions and the positions of existing objects are randomized; the hub geometry and hub passage remain authored and fixed.
- Zone width and height are selected independently from 384, 416, 448, 480, or 512 world units. This is a provisional range of 384–512 in 32-unit steps, providing five choices on each axis.
- The previous authored triangular exploration ground has a 420-by-460 bounding box and an area of 96,600 square world units. Each generated rectangular zone has an area of 147,456–262,144 square world units, approximately 1.5–2.7 times the previous exploration area. Editor playtesting must assess content density and traversal time at this larger scale.
- Each generated world contains exactly two exploration zones for this prototype.
- The fixed hub passage connects the hub to the first exploration zone.
- One passage connects the first and second exploration zones: it is always on the first zone's east boundary and the second zone's west boundary, with its position along those boundaries selected randomly from valid points.
- All other shared boundary segments remain impassable, preserving the passage-only connection rule from ARPG-003.
- Random object placement must respect the rectangular zone boundaries, avoid invalid overlaps, and leave each generated object at a valid reachable position.
- The complete traversable area across the hub and both exploration zones must form one connected path network.
- Generation runs when a new game world is initialized and when a saved game is loaded. A fresh layout is retained in memory until that world session ends.
- The generator does not save or restore its random seed, layouts, cache-open state, or uncollected ground rewards. Loading resets generated world state while ARPG-009-owned character data remains restored.

## Affected systems

- World & Areas
- Input & Interaction
- Player Character & Progression (spawn placement only)
- Actors & Combat (test enemy placement)
- Items & Loot / ARPG-011 cache placement
- Save & Load boundary

## Dependencies and constraints

- Depends on ARPG-003 movement, navigation, and passage-only zone connections.
- Depends on ARPG-006's connected safe hub and exploration world.
- Depends on ARPG-011 for the cache test object and reward-reset contract.
- Must use Godot 4.6 Stable and typed GDScript where practical.
- Must preserve the hub-to-exploration connection, which remains fixed, and keep all other boundary segments blocked except designated passages.
- Generated dimensions and object placements must be testable against configured bounds and navigation connectivity.

## Acceptance criteria

- [x] New game initialization creates exactly two rectangular exploration zones and does not alter the authored hub layout.
- [x] Each exploration zone's generated width and height belong to the allowed set `{384, 416, 448, 480, 512}`; intermediate values are invalid, and generation can produce more than one valid size combination.
- [x] The current wall/obstacle test content, training enemy, and ARPG-011 cache are placed at valid, randomized positions within the exploration zones.
- [x] The hub-to-first-zone passage remains fixed; the inter-zone passage always uses the first zone's east side and the second zone's west side, while its position along those sides varies among valid locations.
- [x] Only designated passages connect zones; other shared boundary segments remain blocked.
- [x] The full traversable area remains connected, and the player can path to every generated transition and test object.
- [x] Loading a save runs generation rather than restoring a serialized layout, places the player in the hub, and restores character data covered by ARPG-009. The test verifies generation rather than requiring a unique result.
- [x] Generated layouts remain stable while traversing zones during a session and are not persisted across loads.
- [x] Uncollected ground rewards from the previous layout disappear on load.
- [x] Automated tests cover membership of each dimension in the allowed size set, object placement bounds/overlaps, connectivity, transition constraints, load regeneration, hub spawn, and session stability.
- [x] The project owner verifies varied generated layouts, fixed hub passage, randomized exploration connection, traversal, and content density at the larger zone scale in Godot Editor.

## Verification plan and results

Godot 4.6 headless project startup passes without script errors. GdUnit4 full suite in normal display mode: 57 cases passed, 0 errors, 0 failures, 0 orphans (`reports/report_67/index.html`). Five new procedural tests cover 64 deterministic size/placement samples, actual navigation connectivity across 32 generated worlds, passage-only boundary crossings, unchanged hub geometry/vendor/barriers, reachable cache and enemy, physical player traversal to the second zone and back, camera following, stable in-session layouts, fresh content on New Game/load, hub spawn, restored gold/inventory/health, and removal of uncollected rewards and projectiles. A deferred equipment drop from the previous layout is also discarded.

Two overview renders (`reports/procedural-preview-0.png` and `reports/procedural-preview-23.png`) were inspected for rectangular geometry, fixed hub entrance, boundary walls, passage alignment, and content placement. The project owner confirmed generation works without observed problems in Godot Editor. The code-review finding concerning pointer holds and camera following is addressed separately by [ARPG-015](click-and-hold-input.md).

## Documentation impact

- [x] Update `docs/PROJECT_CONTEXT.md` when procedural exploration generation becomes the implemented baseline.
- [x] Review ARPG-003: its fixed hub passage remains unchanged; this specification defines the new inter-exploration passage.
- [x] Add this specification to the index and link it from the backlog.
- [x] Update ARPG-011 to confirm cache placement is supplied by the generated exploration zones.
- [x] Review ADR impact; generation preserves the existing world, state ownership, and save boundaries, so no additional ADR is required.

## Open questions

- Revisit the provisional size range after Editor playtesting based on content density, traversal time, and camera framing.

## Implementation notes

Prefer generating object positions from valid navigation/ground space and validate connectivity after placement. If a candidate layout fragments the traversable region, retry or adjust placement rather than accepting a disconnected layout.

Implementation baseline: dimensions are measured along the existing Node2D world axes. The first rectangle starts at x = 0 and is centered vertically on the fixed hub passage. The second starts at the first rectangle's east edge and is centered vertically on the randomized passage. The 68-unit passage width matches the authored hub entrance. Preserve one existing test wall, one training enemy, and one non-blocking cache; place the enemy and cache in different randomly selected exploration zones. Placement uses 16-unit navigation cells with clearance from area boundaries, passages, and other objects. Validate the full walkable grid, including actor clearance and the enemy footprint, before accepting a layout. Retry candidates within a fixed limit and use a known connected fallback if needed. Rebuild navigation bounds from the ground polygons and follow the player with the camera so both zones remain accessible on screen.

Generation occurs on world initialization, New Game, and successful load. Reset pending commands, projectiles, and uncollected ground rewards before replacing exploration content; load places the player at the fixed hub spawn. A development-only authored layout fixture remains available to the existing deterministic movement/combat tests; generation tests exercise the enabled production path separately.

## Change record

| Date | Update |
| --- | --- |
| 2026-10-15 | Drafted from the project owner's decisions: generate two rectangular exploration zones with variable dimensions and randomized object positions; keep the hub and hub passage fixed; place the inter-zone passage on the first zone's east side at a randomized point while guaranteeing full traversable connectivity; regenerate on load and spawn the player in the hub without persisting generated world state. |
| 2026-10-16 | Set each zone's width and height independently to a provisional 384–512 world units in 32-unit steps (five possible values per axis). |
| 2026-10-16 | Documentation review: require each dimension to belong to the allowed size set and correct the scale comparison to account for the current triangular ground. Add Editor checks for content density and traversal time in the larger rectangular zones. |
| 2026-10-16 | Project owner authorized implementation after completing cache and interaction verification. Accepted the scope and began generation, dynamic navigation bounds, and load regeneration. |
| 2026-10-16 | Implemented the generator and scene builder, full-grid connectivity validation, dynamic navigation, camera following, world regeneration and transient cleanup. All 57 tests pass; owner Editor playtesting remains pending. |
| 2026-10-16 | Project owner confirmed generation works in Godot Editor. Completed ARPG-013; ARPG-015 corrects the camera/input review finding and separates object clicks from movement-only holds. |
