{
  description = "projectname";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      version = "0.1.0";
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      # `nix build` produces the program and runs all tests, including the full e2e suite.
      packages = forAllSystems (pkgs: {
        default = pkgs.buildGoModule {
          pname = "projectname";
          inherit version;
          src = ./.;

          # Updated by `task hash`. Run it after every go.mod or go.sum change.
          vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

          env.CGO_ENABLED = 0;
          ldflags = [
            "-s"
            "-w"
            "-X main.version=${version}"
          ];

          meta.mainProgram = "projectname";
        };
      });

      # Every tool the project needs. Nothing is installed globally.
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            go
            gopls
            golangci-lint

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
