{
  description = "Basic Go Project with Nix Flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};

  in {
    packages.${system}.default = pkgs.buildGoModule {
      pname = "put-name-here";  # Set the name of your package
      version = "0.0.1";

      src = pkgs.lib.cleanSource ./.;

      env.CGO_ENABLED = 1;  # Disable CGO for Static Compilation

      ldflags = [
        "-s" "-w" "-extldflags '-static'"
      ];  # Strip Binary and Disable Debug Information, static linking

      vendorHash = null;  # Falls vendor/ nicht benutzt wird

      buildInputs = [
        pkgs.musl
        pkgs.go
      ];
    };

    devShells.${system}.default = pkgs.mkShell {
      nativeBuildInputs = [
        pkgs.go
        pkgs.musl
        pkgs.go-task
        pkgs.gopls
        pkgs.golangci-lint
      ];
      shellHook = ''
        if [ "$SHELL" = "$(which fish)" ]; then
          source .dev-fish-setup.fish
        fi
      '';
    };
  };
}⏎