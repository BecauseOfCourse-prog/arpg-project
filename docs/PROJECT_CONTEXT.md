# Project Context

This document is the canonical, concise snapshot of the game's current product and technical decisions. Update it when a lasting decision is accepted. Proposed or undecided items must be labeled clearly and must not be treated as implementation requirements.

## Product vision

Create a single-player action RPG inspired by the broad genre conventions of Diablo II. The game is expected to feature character classes, mouse-driven movement and attacks, keyboard-bound abilities and potions, varied enemies, multiple connected open areas grouped into biome chains, randomized loot with affixes and rarity, and a safe hub within the continuous game world. The hub is traversed seamlessly like other areas; hostile enemies do not enter it. It provides services such as trading, storage, and companion management.

## Player view and presentation

- The game is 2D and uses hand-authored or rendered 2D sprites.
- The passive test enemy uses the transparent `assets/enemies/flesh_orb_idle_v3.png` floating one-eyed flesh orb sprite with a volumetric 3D-rendered appearance, rendered at a 56-world-unit canvas width with linear filtering. It remains a static sprite with the existing hit and defeat tint feedback.
- Characters and environments are drawn for a fixed, oblique, Diablo II-like perspective. This is not a true isometric 3D world with a rotatable camera.
- The following world camera uses 2x zoom so actors and environment are larger on screen; UI remains at its existing screen-space scale.
- Movement and combat are designed around this visual projection. Collision and navigation must be defined consistently with the projected world.

## Initial platform and mode

- Target platform: Windows PC for the initial development target.
- Initial game mode: single-player.
- Multiplayer, console support, and other platforms are not currently committed.

## Technical baseline

- Engine: Godot 4.6 Stable.
- Gameplay language: GDScript, using static typing for declared variables, parameters, and return values where practical.
- Version control: Git.
- The Git repository root is also the Godot project root; project settings and game assets live beside `docs/`.
- Use one continuous world scene for the safe hub and two connected exploration zones, with a main game scene and reusable player, enemy, and item scenes. The camera follows the player across the world.
- The hub and first exploration zone connect through a fixed marked passage; their remaining shared border is impassable. A randomized passage on the first zone's east side connects to the second zone's west side.
- ARPG-013 generates two rectangular exploration zones with independently selected widths and heights from `{384, 416, 448, 480, 512}` world units. One existing test wall, one training enemy, and one non-blocking cache have randomized valid positions; the enemy and cache occupy different zones. Generation validates full walkable connectivity with player clearance. The authored hub remains fixed. Navigation bounds are rebuilt from the ground polygons. Starting New Game or loading a save generates fresh exploration content; load restores the player in the hub and discards uncollected rewards and active projectiles. Layouts and random seeds are not serialized, and layouts remain stable during traversal. Automated verification is complete, and the project owner confirmed generation works in Godot Editor. See [ARPG-013](specs/foundation/procedural-exploration-zones.md).
- Keep gameplay content data (for example classes, items, affixes, enemies, abilities, and areas) separate from gameplay logic. Prefer Godot Resources for authored game data unless a specification establishes a justified alternative.
- Automated tests use GdUnit4 6.2.x. The Windows runner and test layout are documented in `docs/TESTING.md`.
- First-slice movement uses left-button click-to-move and hold-to-follow-cursor, with free directional movement and automatic navigation around walls and large environment obstacles.
- ARPG-015 separates object clicks from movement holds. A short press/release on an enemy starts the existing repeating attack; a short click on a cache, gold pile, or vendor starts approach and interaction. Holding or dragging only updates movement and never activates objects under the cursor. Object clicks dispatch on release; a 0.20-second hold or an 8-pixel drag starts movement instead. Pointer tracking uses viewport coordinates, and camera following does not reinterpret a released click. Automated verification is complete, and the project owner confirmed input and camera behavior in Godot Editor. See [ARPG-015](specs/foundation/click-and-hold-input.md).
- The game must support saving and loading. The accepted full-game behavior is specified in `docs/specs/foundation/save-load.md`: three manual slots, one autosave slot, persistent character progression/items/quests, and no persistence of location, position, or general world changes, with a specified finite-vendor-stock exception in ADR-0005 (implementation pending). Game time is persisted by ARPG-012. Player Character & Progression owns the numeric gold balance and saves it with character progression ([ADR-0004](decisions/ADR-0004-player-gold-balance-ownership.md)).
- The application now opens at a main menu with New Game and load selection for three manual slots plus autosave. Manual saves are available from the pause menu. Current versioned JSON saves under `user://saves/` persist game time, gold, and the inventory's item resources, stack counts, and grid positions; quest and broader progression fields are pending their owning systems. See [ARPG-009](specs/foundation/save-load.md).
- The ARPG-008 prototype ability fires a cursor-directed projectile on Q for 2 damage with a 3-second cooldown and is blocked by walls. Pressing 1 uses a health potion from inventory for 50 HP. Player health is 100 maximum, new games start at 50 HP, and the HUD shows a health bar; loading a save restores full health. Verified in automated tests and Godot Editor. See [ARPG-008](specs/foundation/keyboard-ability-and-potion-use.md).
- The safe hub supports vendor transactions through a click-to-open vendor inventory with `Buy` and `Buyback` tabs. Its 10-by-10 grid buys items by click; clicking an item in the player's 10-by-4 inventory sells it for half its purchase price while trading is open. Sold items remain in the vendor's buyback list for the exact sale proceeds during the current world session. The current prototype uses fixed unlimited stock. ARPG-012 now supplies daily refresh events; the finite-stock test vendor and its persistence are specified separately in ARPG-016. See `docs/specs/foundation/hub-vendor.md` for the accepted behavior.
- The inventory is a 10-by-4 grid; item definitions specify rectangular slot dimensions and whether copies stack (up to 12 per stack). The sample health potion stacks; the Emberwood Bow does not. During vendor trading, a click sells one unit and Shift+click sells the entire stack. Items must be unequipped before sale.
- The generated exploration zones contain one test cache. Clicking it approaches and opens it once per world session, spawning a reachable gold pile worth 1–20 gold. Clicking the pile approaches and collects it into Player Character & Progression's balance exactly once. Loading creates a closed cache in the new layout and discards uncollected gold piles. The project owner confirmed cache interaction in Godot Editor; see [ARPG-011](specs/foundation/cache-interaction-and-gold-pickup.md).
- World objects across the hub and exploration zones are sorted by ground position so the player can pass visibly in front of the cache and walk through its non-blocking footprint. The inventory displays current gold and updates after rewards, trading, and loading. Vendor clicks approach within 40 world units along traversable ground before opening trading; replacement commands cancel the approach. The project owner confirmed these ARPG-014 changes in Godot Editor. See [ARPG-014](specs/foundation/world-interaction-and-inventory-feedback.md).
- The asset pipeline and release pipeline will be specified as needed.

## Core gameplay pillars

Accepted, not yet implemented: [ARPG-016](specs/foundation/limited-daily-vendor.md) adds a second, visually distinct test vendor in the safe hub alongside the existing unlimited-stock vendor. Its regular catalog contains one enhanced health potion per trading day, costing 50 gold and restoring 100 HP capped at maximum health. Key 2 uses the enhanced potion; key 1 remains for ordinary potions. Purchases exhaust that stock; refresh at 06:00 restores quantity to one without accumulating unsold stock, deferred while trading is open. Regular stock and daily refresh state persist with game time under ADR-0005. Buyback remains separate, vendor-specific, and session-only.

Implemented and verified by the project owner: [ARPG-012](specs/foundation/game-time-day-cycle.md) introduces 24-real-minute days (one game minute per real second), starting Day 1 at 08:00. Morning is 06:00–10:00, day 10:00–18:00, evening 18:00–22:00, and night 22:00–06:00. Time stops in pause/main menus and while the application is closed, continues during inventory/trading, and is restored precisely from saves. Initial scope includes a day/time HUD, smooth readable lighting, and a vendor refresh event at 06:00 deferred until trading closes. Midnight increments the day counter; day changes do not regenerate world content. Finite vendor stock implementation remains ARPG-016; its persistence policy is accepted in ADR-0005. Clock data is saved as an additive schema-1 game_time field; legacy saves start Day 1 at 08:00. Valid calendar days are 1–100,000; advancement stops at the final day end and out-of-range saved days are rejected.

1. Responsive mouse-led movement and combat with keyboard-triggered abilities and consumables.
2. Distinct character classes and a broad, varied enemy roster.
3. Exploration through connected areas organized into several biome chains.
4. A deep loot loop using item rarity and affixes.
5. A hub that supports selling, purchasing, and hiring companions.
6. The game supports saving and loading player progress.

## Source of truth

The development workflow and documentation rules are defined in `docs/DEVELOPMENT_WORKFLOW.md`. Accepted system boundaries are defined in `docs/ARCHITECTURE.md` and recorded in `docs/decisions/`. Feature and system change specifications live in `docs/specs/`. When documents conflict, surface the conflict and resolve it explicitly; do not silently choose one.
