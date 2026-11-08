{ inputs, ... }:
{
  imports = [ inputs.files.flakeModules.default ];

  perSystem =
    {
      config,
      lib,
      pkgs,
      self',
      ...
    }:
    let
      escape = lib.replaceStrings [ "|" ] [ "\\|" ];
      # Rows straight from each package's pname and meta, so the table cannot drift from the packages.
      row =
        attr: pkg:
        "| [`${attr}`](pkgs/${attr}/package.nix) | ${pkg.pname} | ${pkg.version} | ${
          escape (pkg.meta.description or "")
        } | ${lib.optionalString (pkg.meta ? homepage) "<${pkg.meta.homepage}>"} |";
    in
    {
      files = {
        generateApp = true;
        file."README.md".text = ''
          <!--
          DO-NOT-EDIT. This file was auto-generated using github:sini/files.
          Use `just generate` to regenerate it.
          -->

          # nur-packages

          Adda's [NUR](https://github.com/nix-community/NUR) repository (`nur.repos.adda`).

          ## Packages

          | Attribute | pname | Version | Description | Homepage |
          | --- | --- | --- | --- | --- |
          ${lib.concatStringsSep "\n" (
            lib.mapAttrsToList row (lib.filterAttrs (_: lib.isDerivation) config.legacyPackages)
          )}

          ## Usage

          Via NUR: `pkgs.nur.repos.adda.<attribute>`.

          As a flake input:

          ```nix
          inputs.nur-packages = {
            url = "github:Adda0/nur-packages";
            inputs.nixpkgs.follows = "nixpkgs";
          };
          ```

          then `inputs.nur-packages.packages.x86_64-linux.<attribute>`, or
          `nixpkgs.overlays = [ inputs.nur-packages.overlays.default ];`.

          ## Development

          `default.nix` is the entry point NUR imports with its own `pkgs`; it and `pkgs/` must not use flake
          inputs or builtin fetchers. The flake (`modules/`, flake-parts via `import-tree`) wraps it.

          Recipes run via [`just`](https://github.com/casey/just) (Nushell); `just` lists them, trailing flags
          are forwarded.

          - `nix develop` (or direnv, via the generated `.envrc`): shell with `just`, `nushell`, `nix-update`,
            `nixfmt`, `nixd`, `jq`, `git` and `jj`.
          - `just fmt`: format.
          - `just check`: formatting, generated files up to date, and building every package.
          - `just generate`: regenerate `README.md`, `.envrc` and `flake.nix` (from `modules/`).
          - `just build <attribute>`: build one package.
          - `just update [attribute]`: bump one package, or every package when none is named, with `nix-update`
            and the per-package flags it needs; every changed package becomes its own commit,
            `<name>: <old> -> <new>` (through `jj` in a jj checkout, `git` otherwise), and failures are listed at
            the end. CI runs it weekly for `pinepods`, `pinepods-firewood`, `rimstack`, `workshop-walker` and
            `zonetimeline-tui` and opens PRs; it needs an `UPDATE_TOKEN` secret (a PAT or GitHub App token with
            `contents` and `pull-requests` write), since PRs opened with `GITHUB_TOKEN` do not trigger the build
            workflow. `atuin-desktop` and `telescope` need manual hash/stamp fixes after an update.
          - `just flake-update [input…]`: update flake inputs.
        '';
      };

      apps.generate-files.program = pkgs.writeShellApplication {
        name = "generate-files";
        text = ''
          ${self'.apps.write-files.program}
          ${lib.getExe self'.packages.write-flake}
        '';
      };
    };
}
