# ARPG-009: Save and Load

- **Status:** Accepted
- **Owner:** Project owner
- **Created:** 2026-10-14
- **Related specifications:** [ARPG-001: First Playable Vertical Slice](first-playable-vertical-slice.md); [ARPG-005: Equipment Drop and Minimal Inventory](loot-and-inventory.md)
- **Related ADRs:** [ADR-0002: Game System Boundaries](../../decisions/ADR-0002-game-system-boundaries.md); [ADR-0003: Save Data Compatibility Policy](../../decisions/ADR-0003-save-data-compatibility-policy.md); [ADR-0004: Player Gold Balance Ownership](../../decisions/ADR-0004-player-gold-balance-ownership.md)

## Summary

Define how a single-player session stores and restores player progress between application runs. Save/load is required for the full game but explicitly excluded from the first playable slice.

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
- Do not persist the current location, character position, or world changes; loading restores character and progression data only.
- Provide three manual save slots and one separate autosave slot.
- Allow manual saving to a selected slot from the pause menu only.
- Autosave on application exit, quest completion, level-up, and important story milestones.
- Provide save-slot selection from the main menu.
- If no save is available, offer New Game and disable loading.
- Mark a corrupted or version-incompatible save as unavailable and preserve access to all other slots.
- Save format remains open.
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

- [ ] The player can save and restore progress across application sessions using the agreed save trigger and resume flow.
- [ ] Character level, experience, attributes and allocated points, unlocked and upgraded skills, selected abilities, equipped items, gold balance, inventory/items, and quest progress are restored consistently without duplicate or lost owned state; location, position, and world changes are not restored.
- [ ] The player can use three manual slots and a separate autosave slot; autosave occurs on exit, quest completion, level-up, and important story milestones.
- [ ] The player can manually save to a selected slot from the pause menu only, and select a save slot for loading from the main menu.
- [ ] If no save is available, the main menu offers New Game and disables loading.
- [ ] A corrupted or version-incompatible save is marked unavailable while other slots remain usable.
- [ ] Automated tests verify serialization, restoration, compatibility handling, and failure recovery.

## Verification plan and results

After decisions are accepted, use automated tests for save/load round trips, system-owned state restoration, and the agreed error cases. Manually verify the save and resume flow in Godot Editor. No implementation or verification has been performed.

## Documentation impact

- [x] Update `docs/PROJECT_CONTEXT.md` with the accepted save/load baseline.
- [x] Record the save compatibility policy in ADR-0003.
- [x] Update related specifications and the index.
- [x] Update the backlog when the specification is accepted.

## Implementation notes

Do not assume a save format, storage path, or system serialization API before implementation planning.

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
