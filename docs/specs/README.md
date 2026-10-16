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
| [ARPG-012: Game Time and Day Cycle](foundation/game-time-day-cycle.md) | Complete | Implements 24-minute days, four periods, smooth lighting, HUD time, persistence, and daily vendor refresh events; verified automatically and by the owner. |
| [ARPG-016: Limited Daily Test Vendor](foundation/limited-daily-vendor.md) | Accepted | Adds a visually distinct second vendor with one enhanced potion replenished at 06:00; stock persistence and key-2 enhanced potion use are specified. |
| [ARPG-001: First Playable Vertical Slice](foundation/first-playable-vertical-slice.md) | Complete | Delivers the hub-to-exploration combat and loot loop, with automated and editor verification. |
| [ARPG-002: Godot Project Structure and Scene Conventions](foundation/project-structure.md) | Complete | Defines the repository-root project, continuous world scene, reusable actor/item scenes, and Godot Resources. |
| [ARPG-003: Player Movement and Navigation](foundation/player-movement-navigation.md) | Complete | Implements mouse-led movement, obstacle navigation, actor collision, and the sole passage between connected zones for the first slice. |
| [ARPG-004: Basic Combat](foundation/basic-combat.md) | Complete | Implements a ranged attack against one stationary, passive enemy for the first slice. |
| [ARPG-005: Equipment Drop and Minimal Inventory](foundation/loot-and-inventory.md) | Complete | Implements one guaranteed equipment drop, contact pickup, and minimal inventory display. |
| [ARPG-007: Hub Vendor](foundation/hub-vendor.md) | Complete | Implements safe-hub trading, player gold, item sales, grid capacity, and fixed stock; ARPG-012 supplies daily events; finite test stock is specified in ARPG-016. |
| [ARPG-008: Keyboard Ability and Potion Use](foundation/keyboard-ability-and-potion-use.md) | Complete | Adds a cursor-directed projectile ability and health-potion use with player health and a HUD health bar. |
| [ARPG-009: Save and Load](foundation/save-load.md) | In Progress | Implements versioned slots, menu flow, and current gold/inventory persistence; future progression/quest data and event hooks remain. |
| [ARPG-011: Cache Interaction and Gold Pickup](foundation/cache-interaction-and-gold-pickup.md) | Complete | Implements verified approach-to-open map caches and clickable gold rewards with load reset; draw-order follow-up is tracked in ARPG-014. |
| [ARPG-014: World Interaction and Inventory Feedback](foundation/world-interaction-and-inventory-feedback.md) | Complete | Corrects world draw order, displays inventory gold, and requires approaching vendors before opening trading. |
| [ARPG-013: Procedural Exploration Zone Generation](foundation/procedural-exploration-zones.md) | Complete | Generates two variable-size rectangular exploration zones with randomized content and a randomized inter-zone passage; layouts reset on load. |
| [ARPG-015: Click and Hold Input](foundation/click-and-hold-input.md) | Complete | Uses explicit clicks for attacks/interactions and mouse holds only for movement, preserving targets with a following camera. |

## Naming and placement



Use `docs/specs/<topic>/<short-change-name>.md`, with lowercase kebab-case filenames. Add every specification to this index. Preserve completed specifications as history.
