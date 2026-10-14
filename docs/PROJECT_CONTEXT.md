# Project Context

This document is the canonical, concise snapshot of the game's current product and technical decisions. Update it when a lasting decision is accepted. Proposed or undecided items must be labeled clearly and must not be treated as implementation requirements.

## Product vision

Create a single-player action RPG inspired by the broad genre conventions of Diablo II. The game is expected to feature character classes, mouse-driven movement and attacks, keyboard-bound abilities and potions, varied enemies, multiple connected open areas grouped into biome chains, randomized loot with affixes and rarity, and a safe hub within the continuous game world. The hub is traversed seamlessly like other areas; hostile enemies do not enter it. It provides services such as trading, storage, and companion management.

## Player view and presentation

- The game is 2D and uses hand-authored or rendered 2D sprites.
- Characters and environments are drawn for a fixed, oblique, Diablo II-like perspective. This is not a true isometric 3D world with a rotatable camera.
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
- Use one continuous world scene for the safe hub and connected exploration area, with a main game scene and reusable player, enemy, and item scenes.
- The hub and exploration area connect through a marked passage; their remaining shared border is impassable.
- Keep gameplay content data (for example classes, items, affixes, enemies, abilities, and areas) separate from gameplay logic. Prefer Godot Resources for authored game data unless a specification establishes a justified alternative.
- Automated tests use GdUnit4 6.2.x. The Windows runner and test layout are documented in `docs/TESTING.md`.
- First-slice movement uses left-button click-to-move and hold-to-follow-cursor, with free directional movement and automatic navigation around walls and large environment obstacles.
- The game must support saving and loading. The accepted full-game behavior is specified in `docs/specs/foundation/save-load.md`: three manual slots, one autosave slot, persistent character progression/items/quests, and no persistence of location, position, or world changes. Player Character & Progression owns the numeric gold balance and saves it with character progression ([ADR-0004](decisions/ADR-0004-player-gold-balance-ownership.md)). The save format is deferred to implementation planning.
- The safe hub supports vendor transactions through a click-to-open vendor inventory with `Buy` and `Buyback` tabs. Its 10-by-10 grid buys items by click; clicking an item in the player's 10-by-4 inventory sells it for half its purchase price while trading is open. Sold items remain in the vendor's buyback list for the exact sale proceeds during the current world session. The current prototype uses fixed unlimited stock. Daily changing-stock vendors depend on the future game-time/day-cycle system tracked as ARPG-012. See `docs/specs/foundation/hub-vendor.md` for the accepted behavior.
- The inventory is a 10-by-4 grid; item definitions specify rectangular slot dimensions and whether copies stack (up to 12 per stack). The sample health potion stacks; the Emberwood Bow does not. During vendor trading, a click sells one unit and Shift+click sells the entire stack. Items must be unequipped before sale.
- The asset pipeline and release pipeline will be specified as needed.

## Core gameplay pillars

1. Responsive mouse-led movement and combat with keyboard-triggered abilities and consumables.
2. Distinct character classes and a broad, varied enemy roster.
3. Exploration through connected areas organized into several biome chains.
4. A deep loot loop using item rarity and affixes.
5. A hub that supports selling, purchasing, and hiring companions.
6. The game supports saving and loading player progress.

## Source of truth

The development workflow and documentation rules are defined in `docs/DEVELOPMENT_WORKFLOW.md`. Accepted system boundaries are defined in `docs/ARCHITECTURE.md` and recorded in `docs/decisions/`. Feature and system change specifications live in `docs/specs/`. When documents conflict, surface the conflict and resolve it explicitly; do not silently choose one.
