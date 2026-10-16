# Hide Exhausted Vendor Offers

- **Status:** Complete
- **Created:** 2026-10-16
- **Related:** [ARPG-016](limited-daily-vendor.md)

## Scope and rules

The project owner requested that exhausted regular offers disappear from the vendor grid after purchase, replacing ARPG-016's crossed-out sold-out presentation. Do not append a sold-out message. At the next 06:00 replenishment the offer appears again; existing deferral until trading closes still applies. Keep unlimited offers, buyback, transaction validation, and persistence unchanged. Hidden offers must not receive clicks or show tooltips, and visible offers must retain their original transaction indices.

## Acceptance criteria

- [x] Purchasing the final unit removes its offer, tooltip, and click target without a sold-out status message.
- [x] Reopening keeps exhausted stock hidden; daily replenishment makes it visible again.
- [x] Hiding an earlier offer does not change the purchase index of a later offer.
- [x] The panel and close/buyback buttons remain within the viewport after purchase.

## Verification

Display-mode GdUnit4: 23/23 vendor tests passed (reports/report_79). Checks include removal from hit testing, reopening, deferred 06:00 replenishment, preserved later-offer indices, and panel bounds after purchase. Inspected reports/limited-vendor.png: the exhausted offer is absent and the close/buyback controls remain on screen.
