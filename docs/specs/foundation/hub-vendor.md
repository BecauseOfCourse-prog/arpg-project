# ARPG-007: Hub Vendor

- **Status:** Done
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
- Implementing a game clock, day/night cycle, or timed world activities; these belong to ARPG-012.

## User-facing behavior

Clicking a vendor in the safe hub opens a vendor inventory window with two tabs: `Buy` displays the vendor's 10-by-10 stock grid, and `Buyback` displays items the player sold to that vendor. Clicking a vendor item buys it immediately. While the window is open, clicking an item in the player's own 10-by-4 inventory sells it immediately for 50% of its purchase price. A sold item can be bought back for exactly the amount the vendor paid for it. Buyback entries remain available while the current world session is active, including after closing and reopening the vendor window. No per-transaction confirmation is used. Fixed-stock vendors offer unlimited quantities; changing-stock vendors are planned to refresh each in-game day once a game-time system exists. A failed transaction is rejected with a visible reason and no state changes.

## Rules and data

- Hub Services own vendor rules and request item/currency operations from the systems that own those states, consistent with ADR-0002.
- Gold is a numeric balance owned by Player Character & Progression. A new character's starting balance depends on class; class-specific values will be defined with class data.
- Player gold can come from selling items, quest rewards, enemy drops, and map caches. Cache interaction and rewards are specified separately in [ARPG-011](cache-interaction-and-gold-pickup.md); the selected prototype interaction opens a cache after approach rather than attacking it.
- Support fixed-stock vendors with unlimited quantities and vendors whose limited assortment refreshes once per in-game day.
- Sellable categories include equipment and consumables such as identification scrolls, teleport scrolls, and upgrade orbs. Each item or vendor offer has an authored purchase price; selling it returns 50% of that price.
- Only unequipped items present in the player's inventory can be sold; equipped items must be unequipped first.
- Item definitions specify whether identical copies stack, with a maximum of 12 per stack in this prototype. The sample health potion is stackable and the Emberwood Bow is not. Buying, pickup, and buyback merge matching stackable items when space permits.
- Clicking a stack in the player's inventory while the vendor is open sells one unit; Shift+click sells the whole stack. Buyback restores the sold quantity for the exact total amount paid.
- Selling an item adds it to that vendor's buyback list with a repurchase price equal to the sale proceeds. A successful buyback removes that entry; a failed buyback leaves gold, inventory, and buyback entries unchanged.
- The inventory is a 10-by-4 rectangular grid. Each item occupies its authored width and height in adjacent slots; purchases and pickups are rejected if no fitting space exists.
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

- [x] The player can interact with the vendor in the safe hub and open and close the vendor inventory interface.
- [x] The player can sell unequipped equipment and consumables from inventory for 50% of their purchase price (automated service test; equipment slots are not yet implemented).
- [x] The player can buy an offered potion or item when the agreed purchase conditions are met (automated service test).
- [x] The inventory enforces a 10-by-4 grid and item dimensions for pickup and purchase (automated capacity rejection test).
- [x] New characters receive the starting gold amount authored for their class (scene wiring test; current Adventurer definition starts with 100).
- [x] The current prototype vendor offers unlimited fixed stock (automated test). Limited daily stock is designed but deferred until ARPG-012 provides a game-day event.
- [x] The vendor window presents a 10-by-10 item grid; clicking a vendor item buys it, and clicking a player inventory item while the vendor window is open sells it.
- [x] The vendor window has separate `Buy` and `Buyback` tabs; items sold to that vendor can be repurchased at the same price the player received, including stack quantity.
- [x] Stackable item copies merge into stacks of at most 12; potions stack and the bow remains non-stackable.
- [x] Clicking a stack sells one item, while Shift+click sells the whole stack.
- [x] Transactions update currency and inventory exactly once and preserve system ownership (automated transaction tests).
- [x] Insufficient funds, unavailable stock, or insufficient inventory capacity leave player and vendor state unchanged and provide visible feedback (verified in Godot Editor by the project owner).
- [x] Automated tests cover successful purchase and sale, transaction failure, and state consistency.

## Verification plan and results

GdUnit4 test suite: 28 cases passed, 0 failures. Tests cover purchasing, selling, exact-price buyback including stack quantity, failed buyback with full inventory, rejection when the 10-by-10 buyback grid is full, item stack limits and non-stackable equipment, single-item versus whole-stack sale, tab flow, and attack cadence independent of clicks. A headless main-scene launch completed without errors. The project owner verified both vendor tabs, buyback after closing/reopening the window, and visible rejection feedback in Godot Editor. Buyback entries last for the current world session. The active vendor uses fixed unlimited stock; daily restock remains a future integration with ARPG-012.

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
| 2026-10-14 | Project owner specified that equipment must be unequipped before it can be sold. |
| 2026-10-14 | Project owner specified a 10-by-4 inventory grid with item-specific rectangular dimensions. |
| 2026-10-14 | Project owner changed trading interaction: click player inventory items to sell while trading is open; show vendor stock in a 10-by-10 grid and buy by clicking vendor items. |
| 2026-10-14 | Project owner requested `Buy` and `Buyback` tabs; sold items remain available at the exact price paid to the player. |
| 2026-10-14 | Project owner set stack capacity to 12 items; clicks sell one unit and Shift+click sells the full stack. Health potions stack; the Emberwood Bow does not. |
| 2026-10-15 | Project owner verified visible rejection feedback in Godot Editor; all ARPG-007 acceptance criteria are complete. |
| 2026-10-15 | ARPG-011 clarifies map cache gold rewards as approach-to-open interactions rather than attacks on breakable objects. |
