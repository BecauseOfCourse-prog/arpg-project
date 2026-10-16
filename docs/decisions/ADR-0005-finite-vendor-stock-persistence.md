# ADR-0005: Finite Vendor Stock Persistence

- **Status:** Accepted
- **Date:** 2026-10-16
- **Decision makers:** Project owner
- **Supersedes:** The vendor-stock portion of the general no-world-changes persistence rule in ARPG-009.

## Context and decision

ARPG-016 introduces a daily finite offer. The project owner requires its remaining stock to survive loading. Hub Services owns the regular stock and daily refresh state; Save & Load serializes them through its explicit contract alongside ARPG-012 game time. Preserve refresh identity and pending deferred refresh so loading neither duplicates nor loses replenishment.

This is a narrow exception to the previous blanket exclusion of world changes. Location, actor position, generated layouts, enemies, caches, uncollected rewards, and session-only buyback remain outside persistence. Loading an earlier save restores that snapshot, not a global purchase history.

## Consequences

Update and validate the save schema under ADR-0003 during implementation. Test exhausted/available stock and pending-refresh round trips. Do not implement this documentation decision until the related feature is selected for implementation.
