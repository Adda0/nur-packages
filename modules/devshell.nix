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
          # Nix 2.35 no longer copies the flake on `nix flake metadata`; drop after nix-update > 1.16.0.
          (nix-update.overridePythonAttrs (old: {
            patches = (old.patches or [ ]) ++ [
              (fetchpatch {
                url = "https://github.com/Mic92/nix-update/commit/dcef4fdd7edbd9ef83c701e5d92a3df81fbd0e33.patch";
                hash = "sha256-uNOfiYbLAm/0Ret2nUQ3Wxd1IoOsclRbF11z2gGx0vM=";
              })
            ];
          }))
          nixd
          nixfmt
        ];
      };
    };
}
