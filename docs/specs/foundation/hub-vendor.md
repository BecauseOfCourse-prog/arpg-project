# ARPG-007: Hub Vendor

- **Status:** Accepted
- **Owner:** Project owner
- **Created:** 2026-10-14
- **Related specifications:** [ARPG-001: First Playable Vertical Slice](first-playable-vertical-slice.md); [ARPG-003: Player Movement and Navigation](player-movement-navigation.md); [ARPG-005: Equipment Drop and Minimal Inventory](loot-and-inventory.md)
- **Related ADRs:** [ADR-0002: Game System Boundaries](../../decisions/ADR-0002-game-system-boundaries.md); [ADR-0004: Player Gold Balance Ownership](../../decisions/ADR-0004-player-gold-balance-ownership.md)

## Summary

Define a vendor flow in the safe hub that lets the player sell loot and buy a potion or other item. This is a full-game follow-up feature and is outside the first playable slice.

## Motivation

Trading gives collected loot a use beyond inventory accumulation and lets the player obtain useful items through hub services.

## Scope

### In scope

- Interacting with a vendor in the safe hub.
- Selling player-owned items and buying vendor-offered items, including at least one potion or item.
- Updating currency and inventory through the owning systems.
- Presenting enough information for the player to review and complete a transaction.

### Out of scope

- Multiplayer trading, player-to-player markets, crafting, or auction systems.
- Specialized vendor roles and reputation or faction-based pricing.
- Any behavior not needed for the initial vendor transaction flow.

## User-facing behavior

Clicking a vendor in the safe hub opens a window with buy and sell sections. The player can transact immediately, without a per-transaction confirmation. Fixed-stock vendors offer unlimited quantities; changing-stock vendors refresh their limited assortment each in-game day. Players can sell equipment and consumables such as identification scrolls, teleport scrolls, and upgrade orbs for 50% of an item's purchase price. A failed transaction is rejected with a visible reason and no state changes.

## Rules and data

- Hub Services own vendor rules and request item/currency operations from the systems that own those states, consistent with ADR-0002.
- Gold is a numeric balance owned by Player Character & Progression. A new character's starting balance depends on class; class-specific values will be defined with class data.
- Player gold can come from selling items, quest rewards, enemy drops, and small breakable objects on the map. The breakable-object behavior itself is outside this vendor specification and requires its own feature scope before implementation.
- Support fixed-stock vendors with unlimited quantities and vendors whose limited assortment refreshes once per in-game day.
- Sellable categories include equipment and consumables such as identification scrolls, teleport scrolls, and upgrade orbs. Each item or vendor offer has an authored purchase price; selling it returns 50% of that price.
- Reject failed transactions, visibly explain the reason, and leave player and vendor state unchanged.
- Vendor access is limited to the safe hub unless a later specification changes that rule.

## Affected systems

- Hub Services
- Items & Loot
- User Interface
- World & Areas
- Player Character & Progression

## Dependencies and constraints

- Depends on ARPG-005 inventory and item ownership, and ARPG-006 safe-hub/exploration-area behavior.
- Must use Godot 4.6 Stable, typed GDScript where practical, and preserve the system ownership boundaries in ADR-0002.
- Depends on ADR-0004 for gold ownership; class-specific starting gold values may be set with class data.

## Acceptance criteria

- [ ] The player can interact with the vendor in the safe hub and open and close the agreed transaction interface.
- [ ] The player can sell equipment and consumables (identification scrolls, teleport scrolls, and upgrade orbs) for 50% of their purchase price.
- [ ] The player can buy an offered potion or item when the agreed purchase conditions are met.
- [ ] New characters receive the starting gold amount authored for their class.
- [ ] Fixed-stock vendors offer unlimited quantities, while changing-stock vendors refresh their limited assortment once per in-game day.
- [ ] Transactions update currency and inventory exactly once and preserve system ownership.
- [ ] Insufficient funds, unavailable stock, or insufficient inventory capacity leave player and vendor state unchanged and provide visible feedback.
- [ ] Automated tests cover successful purchase and sale, transaction failure, and state consistency.

## Verification plan and results

Use automated tests for deterministic transaction rules and manually verify the vendor interaction and feedback in Godot Editor. No implementation or verification has been performed.

## Documentation impact

- [x] Update `docs/PROJECT_CONTEXT.md` with the accepted economy and hub-service baseline.
- [x] Record gold balance ownership in ADR-0004.
- [x] Update related specifications and the index.
- [x] Update the backlog when the specification is accepted.

## Open questions

None. Individual vendor catalogs, item prices, and class-specific starting balances are authored content values, not unresolved behavior rules.

## Implementation notes

Keep concrete item catalogs, purchase prices, and class-specific starting gold in authored game data. The implementation may choose suitable Godot resources and UI structures while preserving the accepted behavior and ownership boundaries.

## Change record

| Date | Update |
| --- | --- |
| 2026-10-14 | Initial draft based on the next selected full-game hub vendor feature; transaction and economy rules remain open. |
| 2026-10-14 | Project owner selected numeric player gold; income from sales, quests, enemy drops, and breakable map objects; fixed unlimited or changing vendor stock; sale of equipment and consumables; immediate transactions through buy/sell sections; and rejection of failed transactions without state changes. |
| 2026-10-14 | Project owner assigned gold balance ownership to Player Character & Progression, set starting gold to depend on class, chose 50% sale value, and chose limited changing stock that refreshes each in-game day. The vendor behavior specification was accepted. |
