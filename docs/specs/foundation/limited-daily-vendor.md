# ARPG-016: Limited Daily Test Vendor

- **Status:** Complete
- **Owner:** Project owner
- **Created:** 2026-10-16
- **Related specifications:** [Hub Vendor](hub-vendor.md); [Game Time and Day Cycle](game-time-day-cycle.md); [Save and Load](save-load.md)

## Summary

Add a second, visually distinct vendor to the test world's safe hub. This vendor sells one enhanced health potion per trading day and replenishes that offer daily. Implementation selected by the project owner on 2026-10-16.

## Scope

In scope: a separate test vendor, recognizable visual difference, a distinct enhanced health potion definition, finite offer quantity, sold-out feedback, daily replenishment, and integration with existing trading and buyback flows.

Out of scope: random catalogs, broader economy balancing, additional vendor types, and implementation of the game clock (ARPG-012).

## User-facing behavior and rules

- Keep the existing unlimited-stock vendor and add another vendor in the safe hub. The new vendor must be distinguishable in the world without opening the trading window. Exact appearance and placement are authored presentation choices.
- The new vendor's regular Buy catalog contains only an enhanced health potion, with a stock quantity of one. It costs 50 gold and restores 100 HP, capped at maximum health. It is a distinct item from the existing 50-HP health potion.
- Key 2 consumes one enhanced potion from inventory; key 1 remains assigned to the ordinary potion. Neither key substitutes the other potion type when its assigned type is unavailable. Existing potion-use conditions remain applicable.
- Save/load restores remaining regular stock and its trading-day refresh identity alongside game time. Loading a sold-out vendor keeps it sold out until the next due 06:00 refresh; loading itself never grants extra stock. Persist any pending deferred refresh so saving while trading is open cannot lose or duplicate a due replenishment. This is the explicit persistence exception recorded in ADR-0005; buyback remains session-only.
- A successful purchase grants one potion, deducts its authored price, and reduces available stock to zero exactly once. Further purchases are unavailable until replenishment, with clear sold-out feedback.
- Insufficient gold or inventory space leaves gold, inventory, and stock unchanged.
- Closing/reopening trading does not replenish stock.
- Replenish at the ARPG-012 trading-day boundary, 06:00. Set quantity to one, rather than adding one: unsold stock never accumulates across days. The catalog remains the same potion; daily refresh does not imply random assortment.
- If trading is open when replenishment is due, apply it after trading closes, following ARPG-012. Multiple elapsed days still leave at most one potion in regular stock.
- Sales and buyback follow the existing vendor rules. Each vendor has its own buyback list. Selling to this vendor does not refill its regular Buy stock; buyback is separate from the one-per-day regular offer.
- A fresh New Game initializes this vendor with one potion.

## Affected systems and constraints

Hub Services owns vendor transaction and replenishment rules; Items & Loot owns potion/item and inventory state; Player Character & Progression owns gold. Integrates with User Interface, World & Areas, and ARPG-012 events. Use authored Godot Resources for content values and preserve the existing click-to-approach trading flow.

## Acceptance criteria

- [x] Both vendors exist in the test hub and are visually distinguishable.
- [x] The second vendor offers one enhanced potion; a successful purchase exhausts regular stock.
- [x] Failed purchases leave all owned state unchanged, and sold-out feedback is clear.
- [x] Closing/reopening trading and selling items do not refill regular stock.
- [x] Each 06:00 replenishment sets regular stock to one without accumulating unsold units; open trading safely defers refresh.
- [x] Vendor buyback lists are independent and preserve existing transaction rules.
- [x] The enhanced potion costs 50 gold and heals 100 HP capped at maximum health; key 2 consumes it, while key 1 consumes only the ordinary potion.
- [x] Saving/loading available and exhausted stock restores the same quantity and refresh identity; pending refresh is neither lost nor duplicated.

## Open questions

None for the selected scope. The project owner resolved stock persistence, price, healing, and key binding on 2026-10-16.

## Verification plan and results

Implemented and verified on 2026-10-16. Full display-mode GdUnit4 run: 74/74 passed (reports/report_76); expanded vendor suite: 7/7 passed (reports/report_77). Covers stock exhaustion, failed purchases, independent buyback, daily and deferred refresh, potion healing and key selection, stock/time snapshots, JSON file round trip, legacy initialization, invalid saves, and click-to-approach opening. Inspected the captured rendered frame reports/limited-vendor.png: both vendor shapes/colors are distinct, the alchemist window opens, and exhausted stock is crossed out. A human Editor playthrough has not been performed.

## Documentation impact

- [x] Add specification and index entry.
- [x] Record ARPG-016 in backlog and accepted pending behavior in project context.
- [x] Link the finite-stock follow-up from ARPG-012.
- [x] Resolve and document persistence and consumption-selection rules before implementing those parts.

## Change record

| Date | Update |
| --- | --- |
| 2026-10-16 | Project owner selected a visually different second test vendor, one enhanced potion in stock, and daily replenishment; recorded without implementation. |
| 2026-10-16 | Project owner selected persistent stock, a 50-gold price, 100-HP healing, and key 2 for enhanced potion use; recorded ADR-0005. |


Implementation uses optional schema-1 limited_vendor {day, quantities}; pending refresh remains in game_time. Legacy saves initialize one potion at the current trading day. Stock snapshots are validated against authored quantities and saved game time before loading.
