# Automated Testing

- Framework: GdUnit4 6.2.x. The project currently vendors v6.2.2 under `addons/gdUnit4/`.
- Test suites live in `test/` and use GDScript.
- Generated HTML and JUnit reports go under `reports/`, which is ignored by Git.

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
