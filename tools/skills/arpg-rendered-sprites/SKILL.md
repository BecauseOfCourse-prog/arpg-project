---
name: arpg-rendered-sprites
description: Create or refine enemy, character, and environment sprites for the user's fixed-oblique dark fantasy ARPG, with the volumetric pre-rendered 3D appearance of Diablo II. Use for game sprite art and its requested Godot integration, not for actual 3D mesh creation or unrelated illustrations.
---

# ARPG Rendered Sprites

## Visual target

The user wants sprites that LOOK like rendered 3D objects, as in Diablo II, even though the project uses 2D assets. Do not interpret a request for Diablo II style as a request for flat pixel art, artificial pixelation, dithering, or drawn outlines. The earlier pixelated flesh-orb version was rejected for looking flat.

Use an elevated fixed oblique camera, approximately 30–35 degrees, and a three-quarter view appropriate to the object's direction. Convey volume with broad light-to-shadow gradients, occlusion in cavities, foreshortening, overlapping geometry, and visible top/side surfaces. Use a consistent upper-left key light and muted earthy dark fantasy materials. Avoid excessive glossy highlights, illustration-like contour lines, and tiny decorative details that vanish at gameplay scale.

Preserve the requested anatomy and identity. The project's example is a floating fleshy sphere with exactly one eye and a tooth-filled mouth, no limbs or wings. This is an example, not a requirement for other sprites.

## Creation workflow

- Inspect the relevant existing scene, asset, and project instructions before selecting camera, anchor, and dimensions. Prefer existing accepted assets as style references. In D:/Game, `assets/enemies/flesh_orb_idle_v3.png` is the latest flesh-orb reference; v2 is the rejected pixel-art direction.
- Use the available imagegen skill and built-in image generation tool for raster generation or edits. Inspect local edit targets before submitting them. Ask for genuine transparent alpha for isolated sprites and preserve it. A generated 3D-looking image is not an actual mesh or evidence that a 3D modeling pipeline was used.
- Request one complete silhouette, unclipped, with useful transparent margin. Specify a single frame unless animation or directional variants were requested. Keep eye, weapon, teeth, and major forms readable at the actual screen size.
- For characters and enemies, use the ground contact point as the anchor; floating bodies sit above that point. For props and structures, align the base to the ground plane. For terrain tiles, prioritize seamless edges and consistent projection instead of isolated-object margins. Do not bake a ground plane or cast shadow into a transparent actor asset unless requested; separate shadows can be integrated when in scope.
- Inspect the generated result for volume, projection, anatomy, alpha, and readability. Correct the specific mismatch if needed. Do not substitute increased detail for stronger volume.
- Save project assets inside the workspace with descriptive versioned names; preserve previous versions. Save the final prompt beside the asset and report the generation method.

## Prompt starting point

Adapt this to the requested subject, preserving explicit user choices:

> A single [subject] for a fixed-oblique dark fantasy ARPG, with the convincing volumetric appearance of a pre-rendered 3D game model in the visual spirit of Diablo II. Orthographic camera elevated about 35 degrees, three-quarter view, visible top and side, foreshortened features wrapping around solid geometry. Broad upper-left lighting, soft continuous shading, deep cavity occlusion, muted earthy materials. Clear silhouette and large readable forms at gameplay scale. Full object with transparent margins, genuine transparent alpha. No drawn outlines, artificial pixelation, dithering, scenery, labels, or frame.

## Godot integration when requested

Preparing art alone does not automatically require replacing scene assets. When the user asks to add it to the game, update the consuming scene and any typed sprite references. Preserve collision geometry, targeting, combat, and hit/defeat feedback unless changes were requested. Prefer linear filtering for this smooth rendered appearance; do not reintroduce pixelation through nearest filtering without a deliberate reason.

Choose world size against the player and existing environment, then check on-screen size with camera zoom. The current D:/Game baseline uses 2x camera zoom and a 56-world-unit enemy image canvas; these are project settings, not universal sprite dimensions. Keep screen-space UI independent of world zoom.

Verify import and relevant existing tests after integration. Visually inspect in-game scale when possible, and clearly report when only import or automated checks were performed. Do not claim animations, directional consistency, or visual verification from a single generated still.
