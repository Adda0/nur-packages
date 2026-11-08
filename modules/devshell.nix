{
  perSystem =
    { pkgs, ... }:
    {
      files.file.".envrc".text = ''
        # DO-NOT-EDIT. This file was auto-generated using github:sini/files.
        # Use `just generate` to regenerate it.

        watch_file modules/*.nix
        use flake
      '';

      devShells.default = pkgs.mkShellNoCC {
        packages = with pkgs; [
          git
          jq
          just
          jujutsu
          nushell
          nix-update
          nixd
          nixfmt
        ];
      };
    };
}
