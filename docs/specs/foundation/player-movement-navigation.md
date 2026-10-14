# ARPG-003: Player Movement and Navigation

- **Status:** Accepted
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
- A physical world landmark, such as a bridge or gate, communicates the transition between the hub and exploration area.

### Out of scope

- Attack targeting and combat input rules.
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
- The player cannot pass through the enemy. When approaching an enemy to attack, the player stops outside the enemy's collision area once within attack range.
- The hub and exploration area remain part of one continuously traversable world. A bridge, gate, or another suitable landmark communicates the location transition.

## Rules and data

- Walls and large environment objects are movement obstacles. Small environment objects are not obstacles for this slice.
- A click on non-traversable ground resolves to the nearest reachable point at its boundary; no movement occurs if there is no route to one.
- The player cannot overlap or pass through the enemy. Automatic approach stops at a position outside the enemy's collision area and inside attack range.
- Movement uses free directional motion, not discrete grid steps.
- Movement commands come from the left mouse button in click and hold modes.
- The player cannot overlap or pass through the enemy. When approaching an enemy to attack, stop outside its collision area once within attack range; see ARPG-004 for attack approach behavior.
- Clicking an enemy issues an attack command; attack behavior and its interaction with movement are defined in ARPG-004.
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

- [ ] A left click on traversable ground moves the player toward the selected point.
- [ ] A left click on a non-enemy world object moves the player toward it; for movement obstacles, the player stops at the reachable boundary.
- [ ] Holding the left mouse button moves the player toward the cursor's current ground position.
- [ ] A new movement command immediately replaces the current goal.
- [ ] The player can move freely in any direction without grid snapping or inertia.
- [ ] Walls and large environment objects block movement; small environment objects do not.
- [ ] Clicking outside traversable ground moves the player to the nearest reachable boundary point, or leaves the player still if no route exists.
- [ ] The player cannot pass through the enemy; attack approach stops outside its collision area when in range.
- [ ] The player navigates around a blocking object when a route exists and remains stationary when no route exists to the commanded goal.
- [ ] The hub and exploration area can be traversed as one continuous world, with a suitable landmark communicating their transition.

## Verification plan and results

After implementation, use automated tests for command resolution, movement, obstacle routing, and actor collision. Verify the visual feel of movement and continuous traversal between hub and exploration area in Godot Editor. No implementation or verification has been performed.

## Documentation impact

- [ ] Update `docs/PROJECT_CONTEXT.md` if the accepted baseline changes.
- [ ] Add or update an ADR if a lasting architectural decision is made.
- [x] Update related specs and the index.
- [x] Link this specification from the backlog.

## Open questions

None. Exact pathfinding and projection-to-world mapping remain implementation details.

## Implementation notes

Do not infer a pathfinding algorithm, node hierarchy, exact input event implementation, or movement tuning values from this behavior-level specification.

## Change record

| Date | Update |
| --- | --- |
| 2026-10-14 | Initial draft from the project owner's movement and navigation decisions. |
| 2026-10-14 | Defined left-click intent for enemies versus ground/world objects, including movement toward an obstacle boundary. |
| 2026-10-14 | Accepted movement rules for unreachable ground clicks and enemy collision; no gameplay decisions remain open. |
