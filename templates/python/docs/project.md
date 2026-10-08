# Project

- Name: projectname
- Purpose: TODO one line
- Stack: Python (prototype tier), argparse CLI, uv + ruff + pyright + pytest, nix dev shell
- Entry point: `projectname` console script -> src/projectname_pkg/cli.py (main)
- Constraints: prototype. Move to Go or Rust before this becomes a product.

## Layout
| Path | Content |
|---|---|
| src/projectname_pkg/cli.py | argparse command tree, one function per command, emit() handles --json |
| src/projectname_pkg/<module>.py | logic, free of argparse and of printing |
| tests/e2e/ | e2e tests on the installed program. `@pytest.mark.full` tests run only in `task e2e` |
| tests/unit/ | optional, only for pure logic |

## Language rules
- New command: write the test in tests/e2e/ first, then the function, then register it in build_parser().
- Expected failures raise CliError. Commands never call sys.exit and never print errors themselves.
- Dependencies: `uv add <pkg>` (dev tools: `uv add --dev <pkg>`). Commit pyproject.toml and uv.lock together.
- NixOS: wheels with native code may not load. Prefer pure Python packages, or add the library to the dev shell.
- ruff and pyright come from the dev shell, not from the virtual environment. Do not add them as dependencies.
