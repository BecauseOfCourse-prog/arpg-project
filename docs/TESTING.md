# Automated Testing

- Framework: GdUnit4 6.2.x. The project currently vendors v6.2.2 under `addons/gdUnit4/`.
- Test suites live in `test/` and use GDScript.
- Generated HTML and JUnit reports go under `reports/`, which is ignored by Git.
- Procedural-world tests in `test/procedural_exploration_test.gd` use the enabled production generator, sample seeded layouts, validate the runtime navigation grid, traverse both zones, and verify load regeneration. `WorldTestFixture` disables generation for the older movement, combat, ability/potion, and cache tests that require authored wall and enemy coordinates. Menu, vendor, and save/load integration tests continue to use the production world.
- `test/click_and_hold_test.gd` exercises short clicks, movement-only holds and drags, camera-relative pointer tracking, and gesture cancellation with the production world. The cache suite includes an offscreen rendered-image check for player/cache overlap and boundary visibility. Run the full suite in normal display mode so viewport input and rendering checks are meaningful.

## Run tests on Windows

From the repository root in PowerShell, either set `GODOT_BIN` and run the wrapper:

```powershell
$env:GODOT_BIN = (Get-Command godot).Source
.\addons\gdUnit4\runtest.cmd -a test
```

Or pass the Godot executable directly:

```powershell
$godotExe = (Get-Command godot).Source
.\addons\gdUnit4\runtest.cmd -a test --godot_binary $godotExe
```

The test runner is provided by GdUnit4. See its included license at `addons/gdUnit4/LICENSE`.
