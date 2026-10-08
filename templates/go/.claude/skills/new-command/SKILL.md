---
name: new-command
description: Add a CLI command or subcommand to this project, e2e test first. Use when the user asks for a new command, subcommand or flag group, or when a task file lists one as a deliverable.
---

One command per run. The e2e test exists and fails before the implementation starts.

Read docs/project.md first. It names, for this language: where commands live, how they are
registered, where the e2e tests live and how the full tier is marked.

1. Acceptance checks: command name, arguments, flags, exit codes, the `--json` result shape.
   Anything unclear: ask, do not guess.
2. Write the e2e test in the full tier (not the smoke tier). It drives the real entry point and
   asserts on the `--json` output, the exit code and stderr, never on internals.
3. `task e2e`. The new test must fail because the command is missing, not from a typo or a
   broken harness. If it passes, the test is wrong.
4. Implement. Logic goes in its own module, free of the CLI framework and of printing.
   The command returns errors; it never exits and never prints errors itself.
5. Register the command where docs/project.md says, and support `--json`: result as one JSON
   document on stdout, `{"error": "<message>"}` on stderr with a non-zero exit.
6. `task e2e`, then `task check`. Both must pass.
7. Docs in the same commit: new module -> docs/modules/<name>.md; changed layout or language
   rule -> docs/project.md; changed boundaries or data flow -> docs/architecture.md.
8. Commit in the format from CLAUDE.md.

- Never delete, skip, loosen or mock a test to get green. If the test is wrong, say so and ask.
- Move the test to the smoke tier only once it passes and is both fast and central.
