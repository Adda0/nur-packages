{
  flake.overlays.default = import ../overlay.nix;

  perSystem =
    { pkgs, lib, ... }:
    let
      all = import ../default.nix { inherit pkgs; };
      packages = lib.filterAttrs (_: lib.isDerivation) all;
    in
    {
      legacyPackages = all;
      inherit packages;
      checks = packages;
    };
}
