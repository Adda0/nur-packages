{ inputs, ... }:
{
  imports = [ inputs.flake-file.flakeModules.dendritic ];

  flake-file = {
    description = "Adda's NUR packages";
    inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
      files.url = "github:sini/files";
      treefmt-nix = {
        url = "github:numtide/treefmt-nix";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };
  };

  systems = [ "x86_64-linux" ];
}
