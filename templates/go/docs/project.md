# Project

- Name: projectname
- Purpose: TODO one line
- Stack: Go, cobra CLI, nix flake (dev shell + package)
- Entry point: main.go -> internal/cli (cli.Main)
- Version: flake.nix (`version = "0.1.0";`). ldflags inject it into main.version; `nix build` is the only build that sets it.
- Constraints: none yet

## Layout
| Path | Content |
|---|---|
| main.go | calls cli.Main, nothing else |
| internal/cli/ | cobra commands, one file per command. root.go registers them, output.go handles --json |
| internal/<pkg>/ | logic, free of cobra and of printing |
| e2e/ | testscript harness. testdata/smoke/*.txtar runs in `task test`, testdata/full/*.txtar in `task e2e` |

## Language rules
- New command: write e2e/testdata/.../<name>.txtar first, then internal/cli/<name>.go, then register it in root.go.
- Commands return errors, they never call os.Exit or print errors themselves. Results go through emit().
- After a go.mod or go.sum change: `task hash` (updates vendorHash in flake.nix). Commit all three files together.
- Format and lint only through `task fmt` and `task lint` (golangci-lint v2, config in .golangci.yml).
- `task build` is `nix build`: it also runs every test, including the full e2e suite.
