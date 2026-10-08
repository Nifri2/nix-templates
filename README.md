# Nix Project Templates

Project templates for working with Claude Code on NixOS. Every template ships the same
project standard (`CLAUDE.md`), a flake with a dev shell, a Taskfile, git hooks, a changelog
config, agent and skill definitions and a walking skeleton with one passing e2e test.

## Quick start

```sh
mkdir my-tool && cd my-tool
nix flake init --refresh -t github:Nifri2/nix-templates#go
nix develop -c task init NAME=my-tool MODULE=github.com/Nifri2/my-tool
direnv allow
```

`task init` renames the placeholder, resolves dependencies, installs the git hooks, stages
everything and then removes itself. After that: fill in `docs/project.md`, run `task check`
and make the first commit.

## Templates

| Template | Use for | Stack | E2E | Nix package |
|---|---|---|---|---|
| `go` (default) | CLI, services, tools | Go, cobra, golangci-lint v2 | testscript | yes |
| `rust` | low level, performance critical | Rust, clap, clippy, cargo-nextest | assert_cmd | yes |
| `python` | mock, prototype | uv, ruff, pyright, pytest | pytest on the installed CLI | no, dev shell only |
| `typescript` | mock, prototype | bun, biome, tsc | bun test on the real CLI | no, dev shell only |
| `flutter` | Android app | Flutter, Android SDK from nixpkgs | integration_test | no, dev shell only |
| `micropython` | MicroPython boards | older template, not part of the standard | none | no |

`init` options: `MODULE=<go module path>` for Go, `ORG=<reverse domain>` for Flutter.
Flutter names must use `_` instead of `-`.

## What every template contains

| Path | Purpose |
|---|---|
| `CLAUDE.md` | The standard. Same file in every project, replaced as a whole on updates |
| `docs/project.md` | Project facts: name, stack, layout, language rules. Imported by `CLAUDE.md` |
| `docs/architecture.md`, `docs/decisions/`, `docs/modules/` | Versioned project knowledge |
| `tasks/`, `handoffs/` | Task and handoff files for multi-agent work |
| `.claude/agents/` | architect, test-writer, worker, reviewer, scout, each with a fixed model |
| `.claude/skills/` | new-command, add-dependency, release: procedures Claude follows step by step |
| `.claude/settings.json` | Permissions: `task` allowed, secrets unreadable, push asks, force push denied |
| `flake.nix`, `.envrc` | Dev shell with every tool. Nothing is installed globally |
| `Taskfile.yml` | The only command interface: setup, dev, fmt, lint, test, e2e, check, build, ci, changelog |
| `lefthook.yml`, `scripts/check-commit-msg` | Hooks: commit message format, `task check` before every commit |
| `cliff.toml` | git-cliff config for `task changelog` |
| `.github/workflows/ci.yml` | Runs `nix develop -c task ci`, nothing else |
| `.ignore` | Keeps lockfiles and generated files out of `rg` and `fd` results |

Tasks print nothing on success and the full output on failure. To see everything:
`task --output interleaved <name>`.

Every CLI skeleton supports `--json` (result as one JSON document on stdout, errors as
`{"error": "..."}` on stderr) and the e2e tests assert on that form.

## Changing the standard

`common/` is the single source for all files that are identical across templates.

```sh
# edit files in common/, then:
task sync    # copies common/ into every template
task check   # fails if a template differs from common/
```

To update an existing project, copy the new `CLAUDE.md` over the old one. Project specific
content lives in `docs/project.md` and is not touched.

Agent models are set in `common/.claude/agents/*.md` (`opus`, `sonnet`, `haiku`). Change the
`model:` line there if you want a different tier for a role.

## Test status

Tested from a fresh `nix flake init` for go, rust, python and typescript: `task init`
(including a failed run followed by a second run), `task check`, `task e2e`, both git hooks
(a bad message is rejected, a failing check blocks the commit, also inside an agent worktree)
and `task changelog`. `task ci` ran completely for python and typescript. For each of the
four, a deliberately broken `--json` output made the e2e tests fail.

Not tested, because the environment the templates were built in had no access to the nix
binary cache:

- `nix develop` and `nix build`. All five flakes were only evaluated, against nixos-unstable
  at commit `151fa4e8ddfd` (2026-10-06): dev shells for every template, packages for go and
  rust. The tasks ran with the same tools installed outside of nix, in these versions:

  | Tool | Tested with | In that nixpkgs commit |
  |---|---|---|
  | go | 1.24.7 | 1.26.8 |
  | golangci-lint | 2.5.0 | 2.14.0 |
  | rustc / cargo | 1.97.0 | 1.98 |
  | cargo-nextest | 0.9.148 | 0.9.146 |
  | python | 3.13.16 | 3.14.7 |
  | uv | 0.11.32 | 0.12.22 |
  | ruff | 0.16.8 | 0.16.10 |
  | bun, biome, tsc | 1.4.2, 2.5.15, 7.0.2 | same |
  | task | 3.54.0 | 3.53.1 |
  | lefthook | 2.2.1 | 2.1.15 |
  | git-cliff | 2.14.2 | same |

- go: the Go module proxy was not reachable, so the tests ran with GitHub mirrors of the
  `golang.org/x` modules. `go.sum` is not shipped, `task init` creates it. `task hash` computes
  `vendorHash` the way nixpkgs does (NAR hash of the `go mod vendor` output), but the result
  was never checked against a real `nix build`.
- flutter: nothing was executed. The flake evaluates, including the Android SDK composition.
  `task init` (which runs `flutter create`), the Taskfile, the emulator task and
  `integration_test/app_test.dart` are unverified.
- `.github/workflows/ci.yml` has never run.

The three skills in `.claude/skills/` were written against the current skill format and the
task names of every template, but never exercised in a real project: no command was added,
no dependency installed and no release cut with them.

No `flake.lock` is shipped. The first `nix develop` in a new project creates it: commit it.
To start from the commit the flakes were evaluated against:

```sh
nix flake lock --override-input nixpkgs github:NixOS/nixpkgs/151fa4e8ddfdd8dd25d945ad94ed54a13de9f6e4
```

First real check on NixOS, per template: `nix flake init`, `nix develop -c task init NAME=<name>`,
then `task ci`.

## Notes

- The previous `go` and `python` templates were replaced. The VS Code helper
  `generate-settings.sh` is gone: with direnv, editors pick up `gopls` from the dev shell.
- `nix flake init` lost the executable bit of scripts in testing, so scripts are always called
  as `bash scripts/<name>`.
- The permission rules in `.claude/settings.json` guide Claude Code. They are not a security
  boundary. Protect `main` with a branch protection rule as well.
