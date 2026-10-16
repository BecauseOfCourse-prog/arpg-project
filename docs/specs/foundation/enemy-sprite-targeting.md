# ARPG-018: Enemy Sprite Attack Selection

- **Status:** Complete
- **Created:** 2026-10-16
- **Related:** [Basic Combat](basic-combat.md), [Click and Hold](click-and-hold-input.md)

## Scope and behavior

Fix enemy selection after the rendered flesh-orb sprite replaced the smaller placeholder. Enemy attack clicks use the sprite's opaque pixels, including its offset, scale, and transforms. Transparent sprite padding does not select the enemy. Retain the existing radius as a fallback for enemies without a sprite texture. Physical movement/projectile collision and combat range remain unchanged. Defeated enemies cannot be selected. Both press-time capture and release-time attack selection use the same enemy-owned hit test.

## Acceptance criteria and verification

- [x] Opaque sprite regions outside the old click radius select the enemy and request an attack.
- [x] Transparent padding, outside points, and defeated enemies are not selected.
- [x] Sprite transforms are respected; textureless enemies retain radius fallback.
- [x] Existing combat and click/hold tests pass.

Display-mode GdUnit4: 17/17 tests passed across enemy targeting, basic combat, and click/hold suites (reports/report_84). Production-texture checks reproduce selection of an opaque edge outside the previous radius, reject transparent padding, and exercise player attack dispatch, transformed sprites, defeated actors, and textureless fallback. Manual Editor playthrough has not been performed.
