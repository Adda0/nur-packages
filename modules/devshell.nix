{
  perSystem =
    { pkgs, ... }:
    {
      devShells.default = pkgs.mkShellNoCC {
        packages = with pkgs; [
          jq
          just
          nushell
          nix-update
          nixd
          nixfmt
        ];
      };
    };
}
