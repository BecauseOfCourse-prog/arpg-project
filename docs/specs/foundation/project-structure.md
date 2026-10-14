# ARPG-002: Godot Project Structure and Scene Conventions

- **Status:** Accepted
- **Owner:** Project owner
- **Created:** 2026-10-14
- **Related specifications:** [ARPG-001: First Playable Vertical Slice](first-playable-vertical-slice.md)
- **Related ADRs:** [ADR-0001: Initial Technology Stack](../../decisions/ADR-0001-initial-technology-stack.md); [ADR-0002: Game System Boundaries](../../decisions/ADR-0002-game-system-boundaries.md)

## Summary

Define the project root, high-level scene composition, reusable scene boundaries, and authored gameplay data format for the first playable slice.

## Motivation

The first slice has several interacting systems. A small, consistent Godot project structure lets implementation proceed without mixing the continuous world, reusable actors, authored content, and project documentation.

## Scope

### In scope

- Keep the Godot project at the Git repository root, alongside the `docs/` directory.
- Use one continuous game-world scene containing the hub and its connected exploration area.
- Use a main game scene and separate reusable scenes for the player, enemy, and item.
- Author static gameplay definitions such as player configurations, enemies, items, and areas as Godot Resources.
- Use GDScript, with static typing for declared variables, parameters, and return values where practical.

### Out of scope

- Exact scene trees, node types, folder taxonomy, or code-level system interfaces.
- Runtime save data formats and save/load behavior.
- A general-purpose plugin or modding content pipeline.
- Additional scenes or content beyond what the first slice requires.

## User-facing behavior

The project opens in Godot from the Git repository root. Running the main game scene starts the player directly in the hub. The hub and exploration area are part of one continuous world scene. Reusable player, enemy, and item scenes are composed into that world as needed. Authored content definitions use Godot Resources and are kept separate from runtime behavior.

## Rules and data

- The Git repository root is also the Godot project root; `project.godot` is at the repository root.
- `docs/` remains at repository root and contains project context, decisions, specifications, and backlog.
- One continuous world scene contains the safe hub and connected exploration area; the hub is not a separate game mode.
- The project has a main game scene and reusable scenes for the player, enemy, and item.
- Static authored gameplay data is represented with Godot Resources. Runtime state remains owned by the appropriate gameplay systems, following ADR-0002.
- Exact folder names and scene/node hierarchy are **Open** implementation choices.

## Affected systems

- Session & Flow
- World & Areas
- Player Character & Progression
- Actors & Combat
- Items & Loot
- Project configuration and documentation layout

## Dependencies and constraints

- Depends on ARPG-001 and must support its continuous hub-to-exploration loop.
- Must use Godot 4.6 Stable and preserve the fixed-oblique 2D presentation.
- Must keep gameplay data separate from gameplay logic and follow the ownership boundaries in ADR-0002.

## Acceptance criteria

- [ ] Godot opens the project from the Git repository root.
- [ ] The main game scene starts the player directly in the hub.
- [ ] The hub and exploration area are represented in one continuous game-world scene.
- [ ] The player, enemy, and item have reusable scenes.
- [ ] Static authored gameplay definitions use Godot Resources.
- [ ] GDScript uses static typing for declared variables, parameters, and return values where practical.

## Verification plan and results

After implementation, open the repository root as a Godot project, run the main game scene, inspect the relevant reusable scenes and authored Resources, and review GDScript declarations. No implementation or verification has been performed.

## Documentation impact

- [ ] Update `docs/PROJECT_CONTEXT.md` when the structure is accepted as the lasting project baseline.
- [ ] Add or update an ADR if a lasting architectural decision is made.
- [x] Update related specs and the index.
- [x] Link this specification from the backlog.

## Open questions

- What folder taxonomy and exact scene/node hierarchy should implementation use?

## Implementation notes

Keep folder and node choices simple and scoped to the first playable slice. Do not create a separate scene for every logical system solely to mirror the architecture table.

## Change record

| Date | Update |
| --- | --- |
| 2026-10-14 | Initial draft from the project owner's project-root, continuous-world, reusable-scene, and Godot Resource decisions. |
| 2026-10-14 | Accepted by the project owner; moved the Godot project files from `arpg/` to the repository root. |
