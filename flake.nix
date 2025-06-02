{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs @ {...}:
    inputs.flake-utils.lib.eachDefaultSystem (
      system: let
        user-shell = builtins.getEnv "SHELL";
        shell-reexport =
          if user-shell == ""
          then ""
          else ''
            export SHELL=${user-shell}
            exec "${user-shell}" "$@"
          '';

        overlays = [(import inputs.rust-overlay)];
        pkgs = import inputs.nixpkgs {
          inherit system overlays;
        };

        rust-bin = pkgs.rust-bin.stable.latest.default.override {
          extensions = [
            "cargo"
            "clippy"
            "rust-src"
            "rustc"
            "rustfmt"
            "rust-analyzer"
          ];
        };
      in {
        devShells.default = pkgs.mkShell rec {
          name = "hmi-slint-stack";
          buildInputs = with pkgs; [
            bashInteractive
            pkg-config
            rust-bin

            cargo-expand
          ];

          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;
          RUST_SRC_PATH = "${rust-bin}/lib/rustlib/src/rust/library";
          RUST_TOOLCHAIN_PATH = "${rust-bin}/bin";

          shellHook = ''
            ${shell-reexport}
          '';
        };
      }
    );
}
