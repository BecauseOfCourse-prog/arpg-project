# Architecture Decision Records

ADRs capture decisions with lasting technical or architectural consequences. They complement, but do not replace, feature specifications.

## Statuses

- `Proposed` — under consideration; not binding.
- `Accepted` — current decision and implementation guidance.
- `Rejected` — considered and declined, with rationale retained.
- `Superseded` — replaced by a later ADR; link to it.

## Index

| ADR | Status | Decision |
| --- | --- | --- |
| [ADR-0005: Finite Vendor Stock Persistence](ADR-0005-finite-vendor-stock-persistence.md) | Accepted | Persist finite regular vendor stock and daily refresh state as an explicit world-state persistence exception. |
| [ADR-0001: Initial technology stack](ADR-0001-initial-technology-stack.md) | Accepted | Godot 4.6 Stable, typed GDScript, 2D sprites drawn for a fixed oblique perspective, Windows PC, single-player, and Git. |
| [ADR-0002: Game system boundaries](ADR-0002-game-system-boundaries.md) | Accepted | Defines the high-level gameplay systems and treats the safe hub as part of the continuous traversable world. |
| [ADR-0003: Save Data Compatibility Policy](ADR-0003-save-data-compatibility-policy.md) | Accepted | Unusable or incompatible saves are marked unavailable without affecting other save slots. |
| [ADR-0004: Player Gold Balance Ownership](ADR-0004-player-gold-balance-ownership.md) | Accepted | Player Character & Progression owns the player's numeric gold balance. |

## Naming

Use `ADR-NNNN-short-title.md`, with sequential zero-padded numbers and lowercase kebab-case titles. Add every ADR to this index. Never silently edit the meaning of an accepted ADR; create a superseding ADR instead.
