# NUR entry point: plain Nix, no flake inputs. NUR imports this with its own `pkgs`.
{
  pkgs ? import <nixpkgs> { },
}:
{
  overlays.default = import ./overlay.nix;

  atuin-desktop = pkgs.callPackage ./pkgs/atuin-desktop/package.nix { };
  pinepods = pkgs.callPackage ./pkgs/pinepods/package.nix { };
  pinepods-firewood = pkgs.callPackage ./pkgs/pinepods-firewood/package.nix { };
  rimstack = pkgs.callPackage ./pkgs/rimstack/package.nix { };
  telescope = pkgs.callPackage ./pkgs/telescope/package.nix { };
  workshop-walker = pkgs.callPackage ./pkgs/workshop-walker/package.nix {
    # nixpkgs' source-built rustc 1.98 links LLVM 21, whose AVX-512 VNNI intrinsic signatures mismatch its
    # stdarch ("intrinsic signature mismatch" in `diskann-vector`). The upstream binaries bundle their own LLVM.
    rustPlatform = pkgs.makeRustPlatform { inherit (pkgs.rust.packages.prebuilt) cargo rustc; };
  };
  zonetimeline-tui = pkgs.callPackage ./pkgs/zonetimeline-tui/package.nix { };
}
