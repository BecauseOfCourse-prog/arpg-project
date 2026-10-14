# Architecture Overview

- **Status:** Accepted high-level system boundaries; detailed implementation proposals remain draft
- **Scope:** High-level logical architecture for the initial single-player game
- **Source of accepted decisions:** `docs/PROJECT_CONTEXT.md` and accepted ADRs

The high-level system boundaries in this document are accepted and recorded in `docs/decisions/ADR-0002-game-system-boundaries.md`. Sections explicitly labeled as proposals are not binding until accepted in a later decision or system specification.

## Architectural goals

- Support the agreed 2D sprite game with a fixed oblique perspective.
- Keep gameplay content data separate from runtime behavior.
- Let Claude work on a subsystem with explicit responsibilities and relevant specifications.
- Keep the design small enough for a single-player Windows game and allow systems to grow as content is added.
- Support saving and loading player progress; exact persistence behavior is specified separately.

## Confirmed technical constraints

- Engine: Godot 4.6 Stable.
- Gameplay language: statically typed GDScript where practical.
- Initial target: Windows PC, single-player.
- Presentation: 2D sprites authored for a fixed oblique view.
- Authored gameplay content should be separate from gameplay logic; Godot Resources are the current preferred format.
- The initial scene convention uses one continuous world scene containing the hub and connected exploration area, with a main game scene and reusable player, enemy, and item scenes. See the accepted ARPG-002 specification for the agreed scope.
- The game must support saving and loading.

See `docs/PROJECT_CONTEXT.md` and `docs/decisions/ADR-0001-initial-technology-stack.md` for the full accepted baseline.

## Confirmed world and hub rules

- The hub is part of the traversable game world, not a separate mode or disconnected destination.
- Movement between the hub and other areas is seamless.
- Hostile enemies do not enter the hub.
- Trading, storage, hiring companions, and configuring companions are services available in the hub area.

## Accepted logical system map

The following groupings define the accepted system responsibilities. They do not mandate one class, scene, or folder per system.

| System area | Responsibility |
| --- | --- |
| Application and session flow | Start, resume, pause, and end a game session. It does not treat the hub as a separate mode or transition. |
| Player character and progression | Own the selected class and progression state, including level and ability access. |
| Input and interaction | Translate mouse and keyboard actions into movement, attacks, ability use, potion use, and world interactions. |
| World and areas | Represent all traversable areas, including the hub, and their connections within biome chains. The hub is part of the continuous world and is traversed seamlessly. Area rules mark the hub as safe so hostile enemies do not enter it. |
| Actors and combat | Own character runtime state such as position, current health, and active behavior; resolve attacks, damage, effects, and defeat behavior. |
| Abilities and effects | Represent active abilities, passive abilities, and temporary effects when those rules are specified. |
| Items and loot | Own item definitions and instances, affixes, rarity, drops, inventory, storage, and equipment. |
| Hub services | Provide trading, access to storage, companion hiring, and companion configuration while the player is in the hub area. They request item operations from Items and Loot rather than owning duplicate item state. |
| User interface | Present player state, inventory, abilities, interactions, and hub services. |
| Save and load | Coordinate persistence by collecting and restoring state through explicit contracts with the systems that own it. |

## Accepted state ownership

- Actors and Combat own current in-world actor state, including position, current health, and active behavior. Combat resolves attacks and effects that change that state.
- Player Character and Progression own the player's selected class and long-term progression, including level and ability access. They do not own current actor health or equipment.
- Items and Loot own item instances, item rolls, inventory, storage, and equipment.
- Hub Services own hub-specific service rules, such as vendor transactions and companion hiring/configuration. They use other systems' operations rather than storing duplicate copies of their state.
- World and Areas own area identity, connections, and area-specific rules, including the safe-hub rule.
- Save and Load coordinate save/restore through explicit data contracts with the systems that own the state. The save schema and versioning rules are not defined here.

Godot Resources remain the preferred format for authored gameplay definitions. Exact resource schemas and system contracts belong in feature/system specifications before implementation.

## Proposed implementation principles

- Systems should expose behavior through clear responsibilities rather than reaching into unrelated systems' internal state.
- Reusable content definitions should not be mutated to store per-session values.
- Player input should request gameplay actions; the responsible gameplay system should validate and apply them.

These principles remain proposals and may be refined in system specifications. They do not prescribe a particular Godot node hierarchy, autoload layout, event bus, or software pattern.

## Specification boundaries

Use separate change specifications for systems when their rules or interfaces are substantial enough to review independently. Initial likely topics are:

- Movement, targeting, and navigation.
- Combat, enemies, and damage.
- Classes, abilities, and progression.
- Items, affixes, loot generation, inventory, and equipment.
- Area transitions and biome organization.
- Hub vendors, economy, and companions.
- Save/load behavior and persistence boundaries.

The backlog tracks when these topics are selected. This overview does not define their detailed rules or implementation plans.

## Architecture change process

- Treat this document as a proposed overview until the system boundaries and principles are reviewed.
- Record lasting technical choices in accepted ADRs; do not use this draft as evidence that a proposal was approved.
- Update this map when an accepted specification or ADR changes system boundaries or data ownership.
- Keep feature-specific behavior and acceptance criteria in `docs/specs/`, not duplicated here.
