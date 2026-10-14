# ARPG-003: Player Movement and Navigation

- **Status:** Complete
- **Owner:** Project owner
- **Created:** 2026-10-14
- **Related specifications:** [ARPG-001: First Playable Vertical Slice](first-playable-vertical-slice.md)
- **Related ADRs:** [ADR-0002: Game System Boundaries](../../decisions/ADR-0002-game-system-boundaries.md)

## Summary

Define the first-slice player movement controls, movement response, and navigation around major environment obstacles in the fixed-oblique 2D world.

## Motivation

Mouse-led movement and traversable connections between the hub and exploration area are required for the first playable loop. Their behavior needs a shared baseline before implementation.

## Scope

### In scope

- Free movement across the traversable ground plane, without a movement grid.
- Both click-to-move and hold-to-follow-cursor movement using the left mouse button.
- A click on ground or a non-enemy world object issues a movement command; clicking a movement obstacle moves toward its reachable boundary.
- Immediate replacement of the current movement goal when a new movement command is issued.
- Pathfinding around walls and large environment objects when a route exists.
- No movement when no route to the commanded destination exists.
- Sending an attack request when the player clicks an enemy; combat resolution remains a later system.
- The hub and exploration area connect only through the marked central passage; all other parts of their shared border are impassable.

### Out of scope

- Attack resolution and approach behavior beyond emitting an attack request.
- Movement abilities, keyboard movement, and multiplayer movement.
- Grid-based movement and momentum or inertia.
- Detailed world geometry, art assets, pathfinding implementation, and tuning values.

## User-facing behavior

- A left click on the ground issues a movement command toward that point.
- A left click on a non-enemy world object issues a movement command toward it. If it is a movement obstacle, the character moves toward its reachable boundary and stops there.
- Holding the left mouse button continuously updates the movement goal from the cursor position.
- A new movement command replaces the current goal immediately.
- The character moves freely in any direction on traversable ground, without grid snapping or inertia.
- Walls and large environment objects block movement. The character automatically follows a path around them when a route to the goal exists. If no route exists, the character does not move toward that goal.
- A click outside traversable ground moves the character toward the nearest reachable point at the boundary. If no route to a reachable point exists, the character remains still.
- The player cannot overlap or pass through the enemy. Attack approach and range behavior are implemented by ARPG-004.
- The hub and exploration area remain part of one continuously traversable world, but crossing between them is possible only through the central passage.

## Rules and data

- Walls and large environment objects are movement obstacles. Small environment objects are not obstacles for this slice.
- A click on non-traversable ground resolves to the nearest reachable point at its boundary; no movement occurs if there is no route to one.
- Movement uses free directional motion, not discrete grid steps.
- Movement commands come from the left mouse button in click and hold modes.
- Clicking an enemy clears the current movement path and emits `attack_requested`; attack behavior and approach are defined in ARPG-004.
- The shared border between the hub and exploration area is blocked everywhere except the marked central passage. A route to the other zone may path to that passage.
- Exact projection-to-world mapping and pathfinding implementation remain implementation details consistent with the accepted fixed-oblique presentation.

## Affected systems

- Input & Interaction
- Player Character & Progression
- World & Areas
- Actors & Combat

## Dependencies and constraints

- Depends on ARPG-001 and the project structure established by ARPG-002.
- Must use Godot 4.6 Stable, typed GDScript where practical, and the accepted fixed-oblique 2D presentation.
- Must preserve continuous traversal between the safe hub and exploration area.

## Acceptance criteria

- [x] A left click on traversable ground moves the player toward the selected point.
- [x] A left click on a non-enemy world object moves the player toward it; for movement obstacles, the player stops at the reachable boundary.
- [x] Holding the left mouse button moves the player toward the cursor's current ground position.
- [x] A new movement command immediately replaces the current goal.
- [x] The player can move freely in any direction without grid snapping or inertia.
- [x] Walls and large environment objects block movement; small environment objects do not.
- [x] Clicking outside traversable ground moves the player to the nearest reachable boundary point, or leaves the player still if no route exists.
- [x] Clicking an enemy emits an attack request and clears the current movement path; combat approach and enemy collision interaction are completed in ARPG-004.
- [x] The player navigates around a blocking object when a route exists and remains stationary when no route exists to the commanded goal.
- [x] The hub and exploration area can be traversed as one continuous world, with a suitable landmark communicating their transition.
- [x] Zone-to-zone paths cross the shared border only through the marked passage; the remaining border is physically blocked.
- [x] Verify click-to-move, hold-to-follow, obstacle avoidance, visibility across the zone boundary, and passage-only zone crossing interactively in Godot Editor.

## Verification plan and results

Automated verification: six GdUnit4 cases pass, including routing around the test wall, destination replacement, active player movement, enemy attack request, off-ground boundary resolution, ground/player draw order, and zone-boundary passage behavior. Boundary resolution uses a single breadth-first traversal of reachable navigation cells. Headless project import and main-scene launch pass. The project owner confirmed the movement, obstacle behavior, visibility, and passage-only zone crossing in Godot Editor.

## Documentation impact

- [x] Update `docs/PROJECT_CONTEXT.md` if the accepted baseline changes.
- [ ] Add or update an ADR if a lasting architectural decision is made.
- [x] Update related specs and the index.
- [x] Link this specification from the backlog.

## Open questions

None. Exact pathfinding and projection-to-world mapping remain implementation details.

## Implementation notes

Do not infer a pathfinding algorithm, node hierarchy, exact input event implementation, or movement tuning values from this behavior-level specification.

The player is a floating `CharacterBody2D` that follows a smoothed path generated by an internal `AStarGrid2D`. Navigation cells are 16 pixels; obstacle clearance is sampled using a circle shape query. The graph is refreshed when the movement-obstacle set or transforms change. Ground polygons bound valid navigation, and out-of-ground or blocked targets resolve to the nearest reachable cell. Enemy clicks emit `attack_requested` and clear the movement path; combat behavior is deliberately left to ARPG-004.

## Change record

| Date | Update |
| --- | --- |
| 2026-10-14 | Initial draft from the project owner's movement and navigation decisions. |
| 2026-10-14 | Defined left-click intent for enemies versus ground/world objects, including movement toward an obstacle boundary. |
| 2026-10-14 | Accepted movement rules for unreachable ground clicks and enemy collision; no gameplay decisions remain open. |
| 2026-10-14 | Implemented continuous click and hold movement, AStarGrid2D route planning with smoothed free movement, obstacle boundary resolution, and an attack request signal. Added a blocking test wall and automated navigation tests. |
| 2026-10-14 | Drew both ground polygons behind the player so the exploration floor cannot cover the character; added a regression assertion. Replaced repeated path queries across every grid cell with one reachable-cell traversal for boundary resolution. |
| 2026-10-14 | Added collision barriers along the shared zone boundary, leaving only the central marked passage open; added automated path and collision coverage. |
| 2026-10-14 | The project owner confirmed the interactive movement and transition checks; ARPG-003 is complete. |
| 2026-10-14 | The project owner reconfirmed that the shared zone boundary works as intended: only the designated passage is traversable. |
