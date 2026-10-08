{
  description = "projectname";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      # The Android SDK and emulator are used on x86_64-linux hosts.
      systems = [ "x86_64-linux" ];
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          f (
            import nixpkgs {
              inherit system;
              config = {
                allowUnfree = true;
                android_sdk.accept_license = true;
              };
            }
          )
        );

      # These must match what the pinned Flutter release expects
      # (flutter_tools: FlutterExtension.kt, checked against Flutter 3.47).
      # When moving to a newer Flutter attribute below, check these four values again.
      # The SDK lives in the read-only nix store. If Gradle reports that it cannot
      # install an SDK component, add that version here instead.
      platformVersion = "36";
      buildToolsVersion = "36.0.0";
      ndkVersion = "28.2.13676358";
      cmakeVersion = "3.22.1";
    in
    {
      # Android app: dev shell only, no nix package.
      # Every tool the project needs. Nothing is installed globally, no Android Studio SDK manager.
      devShells = forAllSystems (
        pkgs:
        let
          android = pkgs.androidenv.composeAndroidPackages {
            platformVersions = [ platformVersion ];
            buildToolsVersions = [
              buildToolsVersion
              "35.0.0"
            ];
            includeNDK = true;
            ndkVersions = [ ndkVersion ];
            cmakeVersions = [ cmakeVersion ];

            # Emulator and one system image, needed for `task e2e`.
            includeEmulator = true;
            includeSystemImages = true;
            systemImageTypes = [ "google_apis" ];
            abiVersions = [ "x86_64" ];
          };
          sdk = "${android.androidsdk}/libexec/android-sdk";
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              flutter347
              android.androidsdk
              jdk17

              go-task
              git-cliff
              lefthook

              ripgrep
              fd
              jq
            ];

            env = {
              ANDROID_HOME = sdk;
              ANDROID_SDK_ROOT = sdk;
              JAVA_HOME = pkgs.jdk17.home;
              # Gradle downloads its own aapt2 binary, which does not run on NixOS. Use the one from the SDK.
              GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${sdk}/build-tools/${buildToolsVersion}/aapt2";
            };
          };
        }
      );
    };
}
