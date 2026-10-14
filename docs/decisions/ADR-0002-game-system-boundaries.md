# ADR-0002: Game System Boundaries

- **Status:** Accepted
- **Date:** 2026-10-14
- **Decision makers:** Project owner
- **Supersedes:** None
- **Superseded by:** None

## Context

The project needs stable high-level system responsibilities so feature specifications and Claude-assisted implementation share the same architecture context. The game is a single-player action RPG in one Godot project.

The player hub must be part of the game world and traversed seamlessly. It is safe from hostile enemies and provides services such as trading, storage, and companion management.

## Decision

Use the following high-level logical system boundaries:

- **Session & Flow:** start, resume, pause, and end the game session.
- **Player Character & Progression:** selected class, player progression, and access to abilities.
- **Input & Interaction:** translate mouse and keyboard actions into gameplay and world-interaction requests.
- **World & Areas:** all traversable areas and their biome connections, including the hub; enforce area rules such as hostile enemies not entering the hub.
- **Actors & Combat:** runtime player, enemy, and companion state such as position, current health, and active behavior; resolve attacks, damage, effects, and defeat behavior.
- **Abilities & Effects:** active/passive abilities, their execution, and temporary effects.
- **Items & Loot:** item definitions and instances, rarity, affixes, drops, inventory, storage, and equipment.
- **Hub Services:** trading, access to storage, companion hiring, and companion configuration available within the hub area; request item operations from Items & Loot rather than keeping duplicate item state.
- **User Interface:** display player/game state and interaction surfaces.
- **Save & Load:** coordinate persistence by collecting and restoring state through explicit contracts with the owning systems.

The hub is a safe area within the continuous traversable world, not a separate game mode or disconnected destination. Hub services are interactions available in that area. This decision defines logical responsibilities only; it does not require one Godot scene, node, class, or folder for every system.

### State ownership

- Actors & Combat own current in-world actor state, including position and current health. Combat resolves changes to that state.
- Player Character & Progression own the selected class and long-term progression, including level and ability access; they do not own current actor health or equipment.
- Items & Loot own item instances, generated item rolls, carried inventory, storage, and equipment.
- Hub Services own hub-specific service rules, such as vendor transactions and companion hiring/configuration, while using other systems' operations for their state.
- World & Areas own area identity, connections, and area-specific rules, including the safe-hub rule.
- Save & Load coordinate serialization/restoration through explicit data contracts with each state-owning system. Save schema and versioning are deferred to a specification.

## Consequences

### Positive

- Feature specifications have stable ownership boundaries to reference.
- The hub can provide services without being architecturally separated from the world traversal model.
- The map remains suitable for one project and one game process while the game grows.

### Costs and constraints

- Individual feature specifications must define the detailed rules and interfaces between these systems.
- The exact node hierarchy, folder layout, data schemas, and runtime ownership details remain implementation decisions.

## Follow-up work

- [x] Record the system map in `docs/ARCHITECTURE.md`.
- [x] Record the safe, seamlessly traversable hub rule in `docs/PROJECT_CONTEXT.md`.
- [ ] Define detailed system contracts in specifications when each system is selected for implementation.
