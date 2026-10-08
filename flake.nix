{
  description = "Project templates for Claude Code on NixOS";

  outputs =
    { self }:
    let
      # Shown by `nix flake init` after the files are copied.
      welcome = extra: ''
        # Next steps

        1. `nix develop -c task init NAME=<name>${extra}`
        2. `direnv allow`
        3. Fill in `docs/project.md`, then `task check` and make the first commit.

        The rules for Claude Code are in `CLAUDE.md`.
      '';
    in
    {
      templates = {
        default = self.templates.go;

        go = {
          path = ./templates/go;
          description = "Go CLI or service (default stack): cobra, testscript e2e, nix package";
          welcomeText = welcome " [MODULE=<go module path>]";
        };
        rust = {
          path = ./templates/rust;
          description = "Rust CLI (low level or performance critical): clap, assert_cmd e2e, nix package";
          welcomeText = welcome "";
        };
        python = {
          path = ./templates/python;
          description = "Python prototype: uv, ruff, pyright, pytest e2e, dev shell only";
          welcomeText = welcome "";
        };
        typescript = {
          path = ./templates/typescript;
          description = "TypeScript prototype on bun: biome, tsc, bun test e2e, dev shell only";
          welcomeText = welcome "";
        };
        flutter = {
          path = ./templates/flutter;
          description = "Flutter Android app: Android SDK from nixpkgs, integration_test e2e, dev shell only";
          welcomeText = welcome " [ORG=<reverse domain>]";
        };

        micropython = {
          path = ./templates/micropython;
          description = "MicroPython project setup with Nix";
        };
      };
    };
}
