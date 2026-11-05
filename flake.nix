{
  description = "Adda's NUR packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.treefmt-nix.flakeModule ];

      systems = [ "x86_64-linux" ];

      flake.overlays.default = import ./overlay.nix;

      perSystem =
        { pkgs, lib, ... }:
        let
          all = import ./default.nix { inherit pkgs; };
          packages = lib.filterAttrs (_: lib.isDerivation) all;
        in
        {
          legacyPackages = all;
          inherit packages;
          checks = packages;

          treefmt.programs = {
            nixfmt.enable = true;
            deadnix.enable = true;
            statix.enable = true;
            actionlint.enable = true;
          };

          devShells.default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              jq
              nix-update
              nixd
            ];
          };
        };
    };
}
