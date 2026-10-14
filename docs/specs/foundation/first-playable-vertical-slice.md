# ARPG-001: First Playable Vertical Slice

- **Status:** Accepted
- **Owner:** Project owner
- **Created:** 2026-10-14
- **Related specifications:** None
- **Related ADRs:** [ADR-0001: Initial technology stack](../../decisions/ADR-0001-initial-technology-stack.md); [ADR-0002: Game system boundaries](../../decisions/ADR-0002-game-system-boundaries.md)

## Summary

Define the smallest playable segment that demonstrates the game's fixed-oblique 2D presentation and its core exploration, combat, and loot loop. The player starts in the safe hub, traverses seamlessly into one nearby exploration area, defeats one enemy, collects an equipment drop, and returns to the hub.

This specification defines the accepted slice scope. Detailed movement, combat, and item rules are covered by focused specifications before their implementation.

## Motivation

The project has multiple connected systems. A small end-to-end slice will validate how movement, combat, areas, loot, and the safe hub work together before the project expands to more classes, enemies, areas, and content.

## Scope

### In scope

- One playable character in a single initial class configuration.
- A safe hub area and one connected exploration area in the same continuously traversable world.
- Mouse-led player movement and one basic attack.
- One enemy type that can be fought and defeated.
- A defeated enemy can drop one simple equipment item with a predefined rarity and affix example; a broad pool of randomized affixes is not part of this slice.
- The player can collect the dropped item and see it in a minimal inventory/equipment interface.
- The player can return to the hub through the connected world; hostile enemies do not enter the hub.
- Temporary 2D art may be used, but it must communicate the agreed fixed oblique perspective.

### Out of scope

- Additional character classes, enemy types, or exploration areas/biomes.
- Vendor buying/selling, storage access, companion hiring, or companion configuration.
- Keyboard-triggered abilities and potion use.
- Production-quality art, a complete UI, extensive balance, and large content catalogs.
- Multiplayer and non-Windows platforms.
- Save/load implementation. Saving and loading remain required for the full game and are handled separately under ARPG-009.


## User-facing behavior

In the slice, the player begins in a safe hub, moves into a connected exploration area, fights one enemy with a basic attack, collects an equipment drop, and returns to the hub without entering a separate hub mode. The hub remains safe throughout play.

Exact input bindings, combat rules, item statistics, and visual asset requirements are not defined by this draft.

## Rules and data

- The player and enemy exist as runtime actors in the same world model.
- The hub is part of the traversable world and excludes hostile enemies, as accepted in the project architecture.
- Item definitions and runtime item instances follow the ownership boundaries in ADR-0002.
- The slice needs a minimal authored set of content: one player configuration, one enemy definition, one exploration area connected to the hub, and one equipment item with a predefined rarity and affix example.
- Exact input bindings, combat rules, item stats, player/enemy stats, and drop rules belong in their focused follow-up specifications; broad rarity and affix variation is out of scope for this slice.

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

Detailed input, combat, and drop rules belong in follow-up specifications.

- [ ] The player can move from the hub into the connected exploration area and back without a separate hub mode or a visible interruption that breaks the seamless-world experience.
- [ ] Hostile enemies do not enter the hub.
- [ ] The player can use mouse input to move and perform a basic attack in the exploration area.
- [ ] The enemy can be defeated, and defeat produces one equipment item with the specified example rarity and affix.
- [ ] The player can collect the equipment drop and see it in the inventory/equipment interface.
- [ ] The player can return to the hub with the collected item still in inventory.
- [ ] The slice uses 2D visuals composed for the agreed fixed oblique perspective.

## Verification plan and results

After implementation is authorized, verify the acceptance criteria by running the game and following the player loop from hub to exploration area, through combat and item pickup, and back to the hub. Record actual checks and results here. No implementation or verification has been performed for this draft.

## Documentation impact

- [ ] Update `docs/PROJECT_CONTEXT.md` if the accepted baseline changes.
- [ ] Add or update an ADR if a lasting architectural decision is made.
- [x] Add this specification to `docs/specs/README.md` and link it from `docs/BACKLOG.md`.
- [ ] Create focused follow-up specifications for movement/navigation, combat, and loot rules before implementation of those systems.

## Open questions

None remain that affect the proposed slice boundary. Detailed input, combat, and drop rules are deferred to focused follow-up specifications.

## Implementation notes

This remains a behavior-level specification. Do not infer exact scene trees, node classes, folder structure, input bindings, formulas, or save schema from it.

## Change record

| Date | Update |
| --- | --- |
| 2026-10-14 | Initial draft created from the accepted project context and system boundaries. |
| 2026-10-14 | Kept save/load in ARPG-009; deferred abilities and potions to ARPG-008; set the slice loop to one simple equipment drop and a return to the hub. |
| 2026-10-14 | Scope accepted by the project owner. |
