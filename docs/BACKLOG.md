# Project Backlog

This is the canonical, prioritized inventory of proposed and planned work. Entries stay brief; detailed scope and acceptance criteria belong in change specifications created when work is selected. Priorities are relative ordering, not estimates or promises.

## Statuses

- `Proposed` — captured idea; not yet prioritized for implementation.
- `Ready` — prioritized and sufficiently understood to be selected for specification.
- `Specified` — linked change specification is accepted and ready to implement.
- `In Progress` — implementation is underway.
- `Done` — the scoped work and required documentation are complete.
- `Blocked` — cannot proceed; the blocker and resolution needed are recorded.
- `Dropped` — intentionally cancelled; retain a brief reason.

## Priority

- `P0` — foundation or critical path for the first playable slice.
- `P1` — important for a usable vertical slice or core loop.
- `P2` — valuable follow-up after the first playable slice.
- `P3` — optional, exploratory, or later polish.

## Active backlog

| ID | Item / outcome | Priority | Status | Depends on | Specification |
| --- | --- | --- | --- | --- | --- |
| ARPG-001 | Define the first playable vertical slice and its measurable scope. | P0 | Done | — | [Completed specification](specs/foundation/first-playable-vertical-slice.md) |
| ARPG-002 | Establish project structure, scene conventions, and data-authoring approach. | P0 | Done | ARPG-001 | [Completed specification](specs/foundation/project-structure.md) |
| ARPG-003 | Implement player movement and mouse interaction for the fixed oblique 2D projection. | P0 | Done | ARPG-001, ARPG-002 | [Completed specification](specs/foundation/player-movement-navigation.md) |
| ARPG-004 | Implement a basic player attack and one enemy with health, damage, and defeat behavior. | P0 | Done | ARPG-001, ARPG-002, ARPG-003 | [Completed specification](specs/foundation/basic-combat.md) |
| ARPG-005 | Add a guaranteed equipment drop, pickup, and minimal inventory display. | P1 | Done | ARPG-001, ARPG-002, ARPG-004 | [Completed specification](specs/foundation/loot-and-inventory.md) |
| ARPG-006 | Add an explorable area seamlessly connected to a safe hub area in the same traversable world. | P1 | Done | ARPG-001, ARPG-002, ARPG-003 | [Completed specification](specs/foundation/player-movement-navigation.md) |
| ARPG-007 | Add a hub vendor flow for selling loot and buying a potion or item. | P1 | In Progress | ARPG-005, ARPG-006; currency and vendor rules | [In-progress specification](specs/foundation/hub-vendor.md) |
| ARPG-008 | Add a keyboard-triggered ability and potion use. | P1 | Proposed | ARPG-003, ARPG-004; input and resource rules | — |
| ARPG-009 | Define save/load behavior and persistence boundaries. | P1 | Specified | ARPG-001; progression and persistence rules | [Accepted specification](specs/foundation/save-load.md) |
| ARPG-011 | Add attackable breakable map objects that can drop gold. | P1 | Proposed | ARPG-004, ARPG-007; breakable-object and reward rules | — |
| ARPG-012 | Add a game-time and day-cycle system for future lighting/activity schedules and daily vendor restocks. | P1 | Proposed | ARPG-007; time progression and pause/save rules | — |
| ARPG-010 | Expand into multiple classes, enemy families, biome chains, affixes, and companion hiring. | P2 | Proposed | First playable slice; each subsystem requires its own specifications | — |

## Backlog maintenance

- Keep the list ordered by priority and current critical path; reorder rows when priorities change.
- Use stable IDs. Do not reuse an ID after an item is completed or dropped.
- Split an item when it contains work that can be specified, implemented, and completed independently.
- Add a specification link when an item reaches `Specified`; maintain both statuses as work progresses.
- Update dependencies when the plan changes. A dependency can be waived only with a recorded rationale in the relevant specification.
- Keep backlog entries aligned with accepted specifications and implementation status; revisit priorities and dependencies when project scope changes.
