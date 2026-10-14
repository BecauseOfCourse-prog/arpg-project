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
| [ARPG-001: First Playable Vertical Slice](foundation/first-playable-vertical-slice.md) | Accepted | Defines the first end-to-end player loop; ready for implementation planning. |

## Naming and placement

Use `docs/specs/<topic>/<short-change-name>.md`, with lowercase kebab-case filenames. Add every specification to this index. Preserve completed specifications as history.
