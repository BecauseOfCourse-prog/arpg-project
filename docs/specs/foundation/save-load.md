# ARPG-009: Save and Load

- **Status:** In Progress
- **Owner:** Project owner
- **Created:** 2026-10-14
- **Related specifications:** [ARPG-001: First Playable Vertical Slice](first-playable-vertical-slice.md); [ARPG-005: Equipment Drop and Minimal Inventory](loot-and-inventory.md)
- **Related ADRs:** [ADR-0002: Game System Boundaries](../../decisions/ADR-0002-game-system-boundaries.md); [ADR-0003: Save Data Compatibility Policy](../../decisions/ADR-0003-save-data-compatibility-policy.md); [ADR-0004: Player Gold Balance Ownership](../../decisions/ADR-0004-player-gold-balance-ownership.md)

## Summary

Implement the first save/load slice for current player-owned state and establish the contracts for persistence systems still to come. Save/load remains a full-game requirement beyond the first playable slice.

## Motivation

The project must preserve player progress across sessions while keeping each system's state owned by the system identified in ADR-0002.

## Scope

### In scope

- Persisting an in-progress single-player game and restoring it in a later application session.
- Defining which systems contribute state to a save and how they restore it.
- Defining how the game handles unavailable, incompatible, or invalid save data.

### Out of scope

- Save/load implementation in the first playable slice.
- Multiplayer synchronization, cloud saves, or cross-device account services.
- Character death and restart behavior, which require separate gameplay decisions.

## User-facing behavior

The player can save manually to one of three manual slots from the pause menu, and choose among those slots from the main menu when loading. The game also saves automatically on application exit, quest completion, level-up, and important story milestones, using a dedicated autosave slot. If no save is available, the main menu offers New Game and disables loading. A corrupted or version-incompatible save is marked as unavailable; other slots remain usable.

## Rules and data

- Save data must respect system ownership in ADR-0002; the Save & Load system coordinates serialization and restoration through explicit contracts.
- Save data must be durable across application shutdown and restart.
- Character progression must persist across sessions, including level, experience, attributes and allocated points, unlocked and upgraded skills, selected abilities, equipped items, and the numeric gold balance owned by Player Character & Progression. Inventory/items and quest progress must also persist.
- Do not persist the current location, character position, or general world changes. ARPG-012 adds persisted game time; ARPG-016 and ADR-0005 establish a narrow exception for finite regular vendor stock and its daily refresh state. Game time is implemented; finite vendor stock persistence awaits ARPG-016 implementation.
- Current actor health is owned by Actors & Combat and is reset to full when loading; current HP is not included in the prototype save payload.
- Provide three manual save slots and one separate autosave slot.
- Allow manual saving to a selected slot from the pause menu only.
- Autosave on application exit, quest completion, level-up, and important story milestones.
- Provide save-slot selection from the main menu.
- If no save is available, offer New Game and disable loading.
- Mark a corrupted or version-incompatible save as unavailable and preserve access to all other slots.
- Store saves as versioned JSON files under Godot's `user://saves/` directory; each slot has its own file.
- The current prototype serializes the owned state that exists today: game time, player gold, and inventory item resource paths, stack quantities, and grid positions. Quest state remains an empty placeholder until a quest system exists; future progression systems must add their owned fields through this save contract.
- The first playable slice does not save or load game state, as specified by ARPG-001.

## Affected systems

- Save & Load
- Session & Flow
- Player Character & Progression
- Actors & Combat
- Items & Loot
- World & Areas
- User Interface

## Dependencies and constraints

- Must use Godot 4.6 Stable and typed GDScript where practical.
- Must respect state ownership and contracts in ADR-0002.
- Save/load is a full-game requirement and must remain outside the first playable slice.

## Acceptance criteria

- [ ] The player can save and restore all future progression and quest state across application sessions using the agreed save triggers; current gold and inventory round-trip successfully.
- [ ] Character level, experience, attributes and allocated points, unlocked and upgraded skills, selected abilities, equipped items, gold balance, inventory/items, and quest progress are restored consistently without duplicate or lost owned state; location, position, and world changes are not restored. (Gold, inventory, and game time exist today; finite vendor-stock persistence is specified separately in ARPG-016.)
- [ ] The player can use three manual slots and a separate autosave slot; autosave occurs on exit and is exposed for quest completion, level-up, and important story milestones. (Quest and level-up event sources do not exist yet.)
- [x] The player can manually save to a selected slot from the pause menu only, and select a save slot for loading from the main menu.
- [x] If no save is available, the main menu offers New Game and disables loading.
- [x] A corrupted or version-incompatible save is marked unavailable while other slots remain usable.
- [x] Automated tests verify serialization, restoration, compatibility handling, and failure recovery.

## Verification plan and results

GdUnit4 verifies save/load round trips for gold and inventory, three independent manual slots and a separate autosave slot, main-menu load selection, malformed/incompatible data handling, invalid snapshots, and recovery from missing or corrupt primary files when a valid backup exists. The full suite passes (35 cases, 0 failures), including a viewport-input regression test that confirms world clicks reach the player after leaving the menu. A visual Godot Editor playthrough of the new menu and pause flow remains to be performed.

## Documentation impact

- [x] Update `docs/PROJECT_CONTEXT.md` with the accepted save/load baseline.
- [x] Record the save compatibility policy in ADR-0003.
- [x] Update related specifications and the index.
- [x] Update the backlog when the specification is accepted.
- [x] Record the initial JSON schema and storage location selected during implementation.

## Implementation notes

ARPG-012 adds optional schema-1 `game_time` containing day, fractional minute, and pending vendor refresh day. Legacy saves lacking this field start at Day 1, 08:00. Present but invalid time data rejects the slot before player state restoration. Time restoration does not simulate offline progression. ARPG-016 finite-stock persistence is accepted but not implemented yet.

Each save file contains a schema version, UTC save timestamp, and payload. Writes use a temporary file and a backup rename before replacing an existing slot. If startup finds a missing or corrupt primary file with a valid backup, it restores that backup; a valid save from an incompatible newer schema is preserved and never silently rolled back. Slot validation completes before any player state is restored. Item entries currently reference authored item Resources; randomized per-instance item data will need an explicit serialization contract when that system is introduced.

The main-menu controls render on a viewport CanvasLayer so the world Camera2D cannot move them. After gameplay starts, the full-screen menu root ignores mouse input so it cannot block player movement or attack commands.

## Change record

| Date | Update |
| --- | --- |
| 2026-10-14 | Initial draft for the full-game save/load requirement, explicitly outside the first playable slice. |
| 2026-10-14 | Project owner selected manual and automatic saving, character/inventory/quest persistence, and multiple save slots. |
| 2026-10-14 | Project owner specified autosaves on exit and key events, excluded location/position/world changes, and selected three manual slots plus a separate autosave slot; corrupted saves are marked unavailable without affecting other slots. |
| 2026-10-14 | Project owner chose autosaving on important events, save-slot selection from the main menu, and marking version-incompatible saves unavailable while preserving other slots. |
| 2026-10-14 | Project owner confirmed all listed character progression data: level, experience, attributes and allocated points, unlocked and upgraded skills, selected abilities, and equipped items. |
| 2026-10-14 | Project owner selected quest completion, level-up, and important story milestones as autosave events; if no save is available, the main menu offers New Game and disables loading. |
| 2026-10-14 | Project owner initially selected manual saving from both the pause menu and main menu; all product behavior questions were resolved and the specification was accepted. |
| 2026-10-14 | Project owner corrected the manual save entry point: manual saving is available from the pause menu only; the main menu is for selecting and loading saves. |
| 2026-10-14 | Gold balance ownership was assigned to Player Character & Progression and added to the persisted character state. |
| 2026-10-14 | Implemented versioned JSON slot files, main-menu New Game/load selection, pause-menu manual saves, application-exit and milestone autosave entry points, and transactional restoration of current gold/inventory state. Full progression and quest persistence await those systems. |
| 2026-10-15 | Added recovery from a valid backup when a slot's primary file is missing or corrupted, without replacing incompatible newer-version saves. |
| 2026-10-15 | ARPG-008 adds player health; saves continue to omit current HP and restore the player to full health on load, as selected by the project owner. |
