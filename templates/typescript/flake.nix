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
    in
    {
      # Prototype stack: dev shell only, no nix package.
      # Every tool the project needs. Nothing is installed globally.
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            bun
            # Tools with native binaries come from nixpkgs, not from npm.
            biome
            typescript

            go-task
            git-cliff
            lefthook

            ripgrep
            fd
            jq
          ];
        };
      });
    };
}
