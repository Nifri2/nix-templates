---
name: add-dependency
description: Decide on and add a third party dependency, with the lockfile and any follow-up task. Use when the user asks for a library, or when an implementation needs a package that is not in the manifest yet.
---

A dependency is permanent cost. The default answer is no.

1. Check first: does the standard library cover it, or a package already in the manifest?
   If the code is obvious and under about 100 lines, write it instead and stop here.
2. Still needed: pick the current maintained option. Compare at most three, on maintenance,
   size, transitive dependencies and whether it works on NixOS (no downloaded prebuilt
   binaries, no native code unless the dev shell provides the library).
3. Non-obvious case (two real candidates, a second language, or a deviation from the Stack
   table in CLAUDE.md): propose it with the reason and wait for user approval.
4. Add it with the tool docs/project.md names under Language rules. Never edit the manifest
   by hand, never vendor the source. Development-only tools belong in the dev shell in
   flake.nix, not in the manifest.
5. Run the follow-up task docs/project.md names after a manifest change (Go: `task hash`).
   No follow-up task named: none is needed.
6. `task check`. If the dependency affects runtime behavior, `task e2e` as well.
7. Non-obvious choice: write docs/decisions/NNN-title.md with decision, reason and rejected
   options, from docs/decisions/000-template.md.
8. One commit with manifest, lockfile, every file the follow-up task changed and the decision
   file. Format from CLAUDE.md, `Refs:` pointing at the decision file.

Removing a dependency is the same procedure: drop it, run the follow-up task, commit together.
