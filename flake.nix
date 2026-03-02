{
  description = "callme is an iroh demo.";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    rust-overlay = { url = "github:oxalica/rust-overlay"; };
  };
  outputs = { nixpkgs, rust-overlay, ... }:
    let
      system = "x86_64-linux";
    in {
      packages.${system}.default =
        let
          pkgs = import nixpkgs { inherit system; };
            in pkgs.rustPlatform.buildRustPackage {
              pname = "callme";
              buildInputs = [ ];
              version = "0.1.0";
              cargoLock.lockFile = ./Cargo.lock;
              src = pkgs.lib.cleanSource ./.;
            };
            devShells.${system}.default =
              let pkgs = import nixpkgs {
                    inherit system;
                    overlays = [ (import rust-overlay) ];
                    config.allowUnfree = true;
                  };
              in
                pkgs.mkShell rec {
                  packages = with pkgs; [
                    alsa-lib
                    autoconf
                    automake
                    dbus
                    egl-wayland
                    libGL
                    libtool
                    libxkbcommon
                    pkg-config
                    pkgs.rustPlatform.bindgenHook
                    (rust-bin.stable.latest.default.override {
                      extensions = [ "rust-analyzer" "rust-src" "llvm-tools-preview" ];
                    })
                    wayland
                    wayland.dev
                  ];
                  shellHook = ''
                  export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath packages}
                  '';
                };
    };
}
