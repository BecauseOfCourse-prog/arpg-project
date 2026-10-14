# ADR-0004: Player Gold Balance Ownership

- **Status:** Accepted
- **Date:** 2026-10-14
- **Decision makers:** Project owner
- **Supersedes:** None
- **Superseded by:** None

## Context

The game needs a numeric player gold balance for vendor transactions and other future rewards. ADR-0002 assigns long-term character progression to Player Character & Progression and item instances/inventory to Items & Loot, but does not explicitly assign currency ownership. The vendor behavior is being specified in [ARPG-007: Hub Vendor](../specs/foundation/hub-vendor.md).

## Decision

Player Character & Progression owns the player's numeric gold balance. Hub Services and other systems request balance changes through that owning system rather than maintaining duplicate currency state. A character's starting gold amount is class-specific and will be authored with class data.

## Alternatives considered

- **Represent gold as an inventory item owned by Items & Loot:** Rejected because currency is a numeric balance and should not occupy or duplicate inventory state.
- **Create a separate Currency & Economy system:** Rejected for the current scope because one player balance does not require a new system boundary.
- **Keep the balance with Player Character & Progression:** Accepted because starting gold varies by character class and is part of the player's persistent progression state.

## Consequences

### Positive

- Currency has one clear owner and can be saved with character progression.
- Vendors cannot change gold independently of the owning system.

### Costs and constraints

- Player Character & Progression must expose transaction-safe operations for currency rewards and spending.
- Class specifications must define starting gold values.

## Follow-up work

- [x] Define the owning system's currency transaction contract and author starting gold for the current Adventurer definition (ARPG-007).
- [ ] Author starting gold values when additional character classes are introduced.
