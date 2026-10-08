# Project

- Name: projectname
- Purpose: TODO one line
- Stack: Rust (edition 2024), clap CLI, nix flake (dev shell + package)
- Entry point: src/main.rs -> src/cli.rs (cli::run)
- Version: Cargo.toml (`[package] version`). flake.nix and `env!("CARGO_PKG_VERSION")` read it from there.
- Constraints: none yet

## Layout
| Path | Content |
|---|---|
| src/main.rs | calls cli::run, nothing else |
| src/cli.rs | clap command tree, one function per command, emit() handles --json |
| src/<module>.rs | logic, free of clap and of printing |
| tests/e2e.rs | e2e tests on the real binary. Tests marked `#[ignore = "full"]` run only in `task e2e` |

## Language rules
- New command: write the test in tests/e2e.rs first, then add the variant to `Command` and its function.
- Commands return `CmdResult`. They never call `std::process::exit` and never print errors themselves.
- Dependency change: commit Cargo.toml and Cargo.lock together. The nix build reads Cargo.lock, there is no hash to update.
- Clippy runs with pedantic lints and `-D warnings`. Fix the cause, do not add `#[allow]` without a comment why.
- `unsafe` is forbidden (Cargo.toml lints). Needing it is a decision for docs/decisions/.
