# ADR-0001: Initial Technology Stack

- **Status:** Accepted
- **Date:** 2026-10-14
- **Decision makers:** Project owner
- **Supersedes:** None
- **Superseded by:** None

## Context

The project is a single-player action RPG with classes, mouse-led movement and combat, keyboard-triggered abilities and potions, varied enemies, connected biome areas, affix-based loot, and a hub for vendors and companions. Development will use Claude, so the project needs a text-friendly codebase and durable documentation context.

The intended presentation is 2D sprites drawn for a fixed, oblique perspective similar to Diablo II. It is not a true isometric 3D scene with a movable camera.

## Decision

- Use **Godot 4.6 Stable** as the game engine.
- Use **GDScript with static typing** for gameplay code.
- Build the initial game as a **single-player Windows PC** title.
- Use **2D sprites authored for the fixed oblique perspective**.
- Use **Git** for version control.
- Keep authored gameplay data separate from gameplay logic; use Godot Resources for data such as items, affixes, enemies, abilities, and areas unless a later specification justifies a different format.

This decision does not yet define the save format, detailed project architecture, asset pipeline, test strategy, or release pipeline.

This stack was selected for the initial scope because Godot provides an integrated 2D workflow and GDScript supports text-based implementation and review.

## Consequences

### Positive

- The engine and scripting language provide a direct path to prototype 2D movement, combat, navigation, and UI.
- GDScript and project data remain readable as text for review and Claude-assisted changes.
- The chosen art direction avoids the need to build a fully 3D environment and camera pipeline.

### Costs and constraints

- Sprites, animation frames, collision shapes, and navigation geometry must be authored consistently for the fixed projection.
- A later shift to true 3D, multiplayer, or another platform may require revisiting this ADR and project architecture.
- The save format and detailed persistence behavior require a separate specification.

## Follow-up work

- [x] Record the current baseline in `docs/PROJECT_CONTEXT.md`.
- [x] Establish the SDD process and Claude context instructions.
- [ ] Specify coordinate conventions, sprite scale, navigation behavior, and save/load behavior before implementing those systems.
