# Change Specifications

Change specifications are durable records of requested behavior changes and their deltas from the prior project state. Read the relevant specification before implementing its scope.

## Statuses

- `Draft` — being prepared; not yet the implementation baseline.
- `Accepted` — scope and acceptance criteria are ready to guide implementation.
- `In Progress` — implementation has started.
- `Complete` — implementation, required verification, and documentation updates are complete.
- `Blocked` — work cannot continue; the reason and required resolution are recorded.
- `Superseded` — a later specification replaces this one; link to the replacement.

## Index

| Specification | Status | Summary |
| --- | --- | --- |
| [ARPG-001: First Playable Vertical Slice](foundation/first-playable-vertical-slice.md) | Complete | Delivers the hub-to-exploration combat and loot loop, with automated and editor verification. |
| [ARPG-002: Godot Project Structure and Scene Conventions](foundation/project-structure.md) | Complete | Defines the repository-root project, continuous world scene, reusable actor/item scenes, and Godot Resources. |
| [ARPG-003: Player Movement and Navigation](foundation/player-movement-navigation.md) | Complete | Implements mouse-led movement, obstacle navigation, actor collision, and the sole passage between connected zones for the first slice. |
| [ARPG-004: Basic Combat](foundation/basic-combat.md) | Complete | Implements a ranged attack against one stationary, passive enemy for the first slice. |
| [ARPG-005: Equipment Drop and Minimal Inventory](foundation/loot-and-inventory.md) | Complete | Implements one guaranteed equipment drop, contact pickup, and minimal inventory display. |
| [ARPG-007: Hub Vendor](foundation/hub-vendor.md) | In Progress | Implements safe-hub trading, player gold, item sales, grid capacity, and fixed stock; daily restock integration awaits the ARPG-012 game-day system. |
| [ARPG-009: Save and Load](foundation/save-load.md) | Accepted | Defines manual and automatic saves, persistence boundaries, slot behavior, and recovery across application sessions. |

## Naming and placement

Use `docs/specs/<topic>/<short-change-name>.md`, with lowercase kebab-case filenames. Add every specification to this index. Preserve completed specifications as history.
