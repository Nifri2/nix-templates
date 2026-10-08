---
name: release
description: Cut a release locally: pick the next version from the commits since the last tag, bump it, run CI, regenerate the changelog, commit and tag. Use when the user asks for a release, a version bump or a new tag.
---

Local only. Never push, never create a remote release. The user pushes.

1. Last tag: `git describe --tags --abbrev=0` (none yet: the first release is 0.1.0).
   Commits since it: `git log --format=%s <tag>..HEAD`.
2. Version from those Conventional Commits:
   - `!` after the scope or a `BREAKING CHANGE:` footer -> major, but while the version is 0.x
     a breaking change is a minor bump.
   - any `feat` -> minor.
   - only `fix`, `perf`, `refactor`, `docs`, `test`, `build`, `ci` -> patch.
   - nothing releasable (only `chore`) -> stop and say so.
   Report the chosen bump and the commits it came from before changing files.
3. Bump the version in the file docs/project.md names on its `Version:` line. That is the only
   place the version is written down. Do not add a second one.
4. `task ci`. It must pass before anything is committed. Failure: stop, do not tag.
5. `task changelog`. Never edit CHANGELOG.md by hand. Until the tag exists git-cliff files the
   new commits under `Unreleased`; rerun `task changelog` after step 6 if the heading matters,
   as a separate commit.
6. One commit with the version file and CHANGELOG.md: `chore(release): v<version>`, body in the
   format from CLAUDE.md. `chore` is excluded from the changelog, so it does not show up there.
7. Tag that commit: `git tag -a v<version> -m v<version>`. The tag pattern in cliff.toml is
   `v[0-9].*`, so the `v` prefix is required.
8. Stop. Final message: the version, why that bump, and the commands the user has to run:
   `git push && git push origin v<version>`.

Tag already exists, or HEAD is not on the main branch: stop and ask.
