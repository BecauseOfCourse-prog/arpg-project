# ARPG-001: First Playable Vertical Slice

- **Status:** Accepted
- **Owner:** Project owner
- **Created:** 2026-10-14
- **Related specifications:** [ARPG-002: Godot Project Structure and Scene Conventions](project-structure.md); [ARPG-003: Player Movement and Navigation](player-movement-navigation.md); [ARPG-004: Basic Combat](basic-combat.md); [ARPG-005: Equipment Drop and Minimal Inventory](loot-and-inventory.md)
- **Related ADRs:** [ADR-0001: Initial technology stack](../../decisions/ADR-0001-initial-technology-stack.md); [ADR-0002: Game system boundaries](../../decisions/ADR-0002-game-system-boundaries.md)

## Summary

Define the smallest playable segment that demonstrates the game's fixed-oblique 2D presentation and its core exploration, combat, and loot loop. The player starts in the safe hub, traverses seamlessly into one nearby exploration area, defeats one enemy, collects an equipment drop, and returns to the hub.

This specification defines the accepted slice scope. Detailed movement, combat, and item rules are defined in the linked focused specifications.

## Motivation

The project has multiple connected systems. A small end-to-end slice will validate how movement, combat, areas, loot, and the safe hub work together before the project expands to more classes, enemies, areas, and content.

## Scope

### In scope

- One playable character in a single initial class configuration.
- The game starts directly in the hub; a main menu is deferred to future work.
- A safe hub area and one connected exploration area in the same continuously traversable world.
- The hub is a simple safe area; buildings and service locations are deferred.
- Mouse-led player movement and one basic attack.
- One encounter with one enemy instance of a single enemy type; repeat encounters are not required.
- A defeated enemy can drop one simple equipment item with a predefined rarity and affix example; a broad pool of randomized affixes is not part of this slice.
- The player can collect the dropped item and see it in a minimal inventory interface; equipping the item is not required.
- The player can return to the hub through the connected world; hostile enemies do not enter the hub.
- Temporary 2D art may be used, but it must communicate the agreed fixed oblique perspective.
- The project can be launched and the slice verified from the Godot Editor; a packaged Windows build is not required.
- Automated tests cover deterministic gameplay behavior in the slice.

The selected automated test framework is GdUnit4 v6.2.x, compatible with the project's Godot 4.6 baseline. The project vendors GdUnit4 v6.2.2, enables it as an editor plugin, and keeps test suites under `test/`. Its Windows command-line runner is `addons/gdUnit4/runtest.cmd`; configure `GODOT_BIN` or pass `--godot_binary` when running tests from a terminal. See `docs/TESTING.md` for the commands.

### Out of scope

- Additional character classes, enemy types, or exploration areas/biomes.
- Vendor buying/selling, storage access, companion hiring, or companion configuration.
- Keyboard-triggered abilities and potion use.
- Production-quality art, a complete UI, extensive balance, and large content catalogs.
- Multiplayer and non-Windows platforms.
- Player death/defeat and restart flows.
- A main menu, buildings, and hub services.
- Save/load implementation in this slice. Saving and loading remain required for the full game and are handled separately under ARPG-009.


## User-facing behavior

In the slice, the game starts directly in a simple safe hub. The player moves into one connected exploration area, fights one enemy encounter with a basic attack, collects an equipment drop into a minimal inventory, and returns to the hub without entering a separate hub mode. The hub remains safe throughout play. Player death/defeat and restart flows are not part of this slice.

The movement, combat, and loot behaviors are detailed in ARPG-003, ARPG-004, and ARPG-005. Exact scene geometry, tuning of attack range to character scale, and final visual assets remain implementation and playtest decisions.

## Rules and data

- The player and enemy exist as runtime actors in the same world model.
- The hub is part of the traversable world and excludes hostile enemies, as accepted in the project architecture.
- Item definitions and runtime item instances follow the ownership boundaries in ADR-0002.
- The slice needs a minimal authored set of content: one player configuration, one enemy definition, one exploration area connected to the hub, and one equipment item with a predefined rarity and affix example.
- Movement, combat, and loot rules are defined in ARPG-003, ARPG-004, and ARPG-005. Broad rarity and affix variation remains out of scope for this slice.

## Affected systems

- Session & Flow
- Player Character & Progression
- Input & Interaction
- World & Areas
- Actors & Combat
- Items & Loot
- User Interface

## Dependencies and constraints

- Must follow Godot 4.6 Stable, typed GDScript where practical, and the 2D fixed-oblique presentation.
- Must follow the accepted system boundaries and the seamless safe-hub rule.
- Depends on creating the Godot project and selecting the detailed movement, navigation, combat, and item rules in follow-up specifications.

## Acceptance criteria

Detailed input, combat, and drop rules are defined in ARPG-003 through ARPG-005.

- [ ] The player can move from the hub into the connected exploration area and back without a separate hub mode or a visible interruption that breaks the seamless-world experience.
- [ ] Hostile enemies do not enter the hub.
- [ ] The player can use mouse input to move and perform a basic attack in the exploration area.
- [ ] The enemy can be defeated, and defeat produces one equipment item with the specified example rarity and affix.
- [ ] The player can collect the equipment drop and see it in the minimal inventory interface.
- [ ] The player can return to the hub with the collected item still in inventory.
- [ ] The slice uses 2D visuals composed for the agreed fixed oblique perspective.
- [ ] The project launches from the Godot Editor directly into the hub.
- [ ] Automated tests cover movement and obstacle navigation, attack targeting/approach/repetition/cancellation, enemy defeat and drop, and item pickup and inventory retention after returning to the hub.

## Verification plan and results

Run the GdUnit4 tests for deterministic gameplay behavior and run the game in Godot Editor to follow the full loop from hub to exploration area, through combat and item pickup, and back to the hub. Use the editor playthrough to assess fixed-oblique presentation and whether traversal feels continuous. Each implementation task records the checks relevant to its scope. Feature specifications define additional test coverage as those features are implemented.

## Documentation impact

- [ ] Update `docs/PROJECT_CONTEXT.md` if the accepted baseline changes.
- [ ] Add or update an ADR if a lasting architectural decision is made.
- [x] Add this specification to `docs/specs/README.md` and link it from `docs/BACKLOG.md`.
- [x] Select and document the automated test framework and base Windows test runner before gameplay implementation.
- [x] Create focused follow-up specifications for movement/navigation, combat, and loot rules before implementation of those systems.

## Open questions

No gameplay design questions remain open for this slice. The shared test directory is `test/`; relevant feature specifications define the required suites and cases.

## Implementation notes

This remains a behavior-level specification. Do not infer exact scene trees, node classes, folder structure, input bindings, formulas, or save schema from it.

## Change record

| Date | Update |
| --- | --- |
| 2026-10-14 | Initial draft created from the accepted project context and system boundaries. |
| 2026-10-14 | Kept save/load in ARPG-009; deferred abilities and potions to ARPG-008; set the slice loop to one simple equipment drop and a return to the hub. |
| 2026-10-14 | Scope accepted by the project owner. |
| 2026-10-14 | Clarified slice boundaries: direct hub start, simple hub, one enemy encounter, inventory display without equipping, temporary art, Editor launch, and no menu, death/restart, or save/load. |
| 2026-10-14 | Selected GdUnit4 v6.2.x and required automated coverage for deterministic movement, combat, defeat/drop, pickup, and inventory-retention behavior; visual presentation remains manually checked. |
| 2026-10-14 | Closed movement, combat, and loot behavior through accepted ARPG-003, ARPG-004, and ARPG-005 specifications. |
