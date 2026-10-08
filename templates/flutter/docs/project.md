# Project

- Name: projectname
- Purpose: TODO one line
- Stack: Dart + Flutter (Android), nix dev shell with the Android SDK from nixpkgs
- Entry point: lib/main.dart (main)
- Constraints: Android only. SDK versions are pinned in flake.nix.

## Layout
| Path | Content |
|---|---|
| lib/main.dart | app entry point |
| lib/<feature>/ | one folder per feature: widgets, state, data |
| test/ | unit and widget tests, no device needed. Run in `task test` |
| integration_test/ | e2e tests on a device. Run in `task e2e` |
| android/ | generated Android project. Edit only for manifest, permissions, signing |

## Language rules
- Testing deviates from the standard here: e2e needs an emulator, so `task test` (every commit) runs only
  test/. Every feature still gets an integration test, run with `task e2e` before merge.
- `task e2e` needs a device: start `task emulator` in the background and wait for boot.
- New screen or flow: write the integration test first, then the widgets.
- Native dialogs (permissions, system pickers) cannot be driven by integration_test: propose Patrol first.
- Android SDK: Gradle must never download SDK parts. If it tries, add the version in flake.nix.
- Dependencies: `flutter pub add <pkg>`. Commit pubspec.yaml and pubspec.lock together.
- CI deviates too: `task ci` runs check + build only, because e2e needs an emulator with KVM.
  Run `task e2e` locally before every merge.
