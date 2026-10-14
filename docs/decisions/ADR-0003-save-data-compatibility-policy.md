# ADR-0003: Save Data Compatibility Policy

- **Status:** Accepted
- **Date:** 2026-10-14
- **Decision makers:** Project owner
- **Supersedes:** None
- **Superseded by:** None

## Context

The full game must preserve player progress across application sessions. Save files may be corrupted or created by an incompatible game version. The save/load behavior is defined in [ARPG-009: Save and Load](../specs/foundation/save-load.md); the concrete file format and schema versioning mechanism remain deferred to implementation planning.

## Decision

Treat a corrupted or version-incompatible save as unavailable. Preserve all other manual and automatic save slots so they can still be selected and loaded if valid. Do not attempt to load incompatible data as if it were current data.

## Alternatives considered

- **Attempt best-effort loading:** Rejected because it may restore inconsistent or lost player-owned state.
- **Invalidate all save slots when one is unusable:** Rejected because one damaged or incompatible save must not make independent valid slots inaccessible.
- **Mark only the affected slot unavailable:** Accepted because it preserves valid progress and gives the player a clear recovery path through other slots.

## Consequences

### Positive

- A damaged or incompatible slot does not prevent access to other valid progress.
- The game avoids silently interpreting data with an incompatible schema.

### Costs and constraints

- The implementation must detect whether a save is corrupted or incompatible before restoring its owned state.
- The unavailable-slot presentation and concrete compatibility metadata must be defined during implementation planning.

## Follow-up work

- [ ] Implement compatibility detection and unavailable-slot behavior under ARPG-009.
