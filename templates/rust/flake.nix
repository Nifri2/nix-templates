{
  description = "projectname";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
      cargoToml = nixpkgs.lib.importTOML ./Cargo.toml;
    in
    {
      # `nix build` produces the program and runs the tests (the fast ones, not the ignored full suite).
      packages = forAllSystems (pkgs: {
        default = pkgs.rustPlatform.buildRustPackage {
          pname = cargoToml.package.name;
          version = cargoToml.package.version;
          src = ./.;

          # Dependencies are pinned by Cargo.lock. No hash to maintain.
          cargoLock.lockFile = ./Cargo.lock;

          meta.mainProgram = cargoToml.package.name;
        };
      });

      # Every tool the project needs. Nothing is installed globally.
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            cargo
            rustc
            clippy
            rustfmt
            rust-analyzer
            cargo-nextest

            go-task
            git-cliff
            lefthook

            ripgrep
            fd
            jq
          ];

          # Lets rust-analyzer find the standard library sources.
          env.RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
        };
      });
    };
}
