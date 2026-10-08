# Project

- Name: projectname
- Purpose: TODO one line
- Stack: TypeScript on bun (prototype tier), biome + tsc, bun test, nix dev shell
- Entry point: src/main.ts -> src/cli.ts (main)
- Version: package.json (`version`). src/cli.ts imports it from there.
- Constraints: prototype. Move to Go or Rust before this becomes a product.

## Layout
| Path | Content |
|---|---|
| src/main.ts | calls main() from cli.ts, nothing else |
| src/cli.ts | command table, one function per command, emit() handles --json |
| src/<module>.ts | logic, free of argument parsing and of printing |
| e2e/smoke/ | e2e tests that run on every commit (`task test`) |
| e2e/full/ | e2e tests that run only in `task e2e` |
| e2e/run.ts | helper that runs the real program in a separate process |

## Language rules
- New command: write the test in e2e/ first, then the function, then add it to `commands` in src/cli.ts.
- Expected failures throw CliError. Commands never call process.exit and never print errors themselves.
- Dependencies: `bun add <pkg>` (dev: `bun add -d <pkg>`). Commit package.json and bun.lock together.
- NixOS: npm packages that ship prebuilt binaries may not run. Take such tools from the dev shell (as done for
  biome and tsc). Do not add `typescript` or `@biomejs/biome` to package.json.
- Web UI e2e, if a UI is added: Playwright with the browsers from nixpkgs (playwright-driver.browsers), never downloaded ones.
