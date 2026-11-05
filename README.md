<!--
DO-NOT-EDIT. This file was auto-generated using github:sini/files.
Use `nix run .#generate-files` to regenerate it.
-->

# nur-packages

Adda's [NUR](https://github.com/nix-community/NUR) repository (`nur.repos.adda`).

## Packages

| Attribute | pname | Version | Description | Homepage |
| --- | --- | --- | --- | --- |
| [`atuin-desktop`](pkgs/atuin-desktop/package.nix) | atuin-desktop | 0.2.20 | Local-first, executable runbook editor | <https://atuin.sh> |
| [`pinepods`](pkgs/pinepods/package.nix) | pinepods | 0.9.0 | Desktop client for PinePods, a self-hosted podcast server | <https://www.pinepods.online/> |
| [`pinepods-firewood`](pkgs/pinepods-firewood/package.nix) | pinepods-firewood | 0.1.0 | Terminal client for PinePods, a self-hosted podcast sync server | <https://github.com/madeofpendletonwool/pinepods-firewood> |
| [`rimstack`](pkgs/rimstack/package.nix) | rimstack | 0-unstable-2026-10-31 | Fast RimWorld mod manager | <https://github.com/TheForgotten69/RimStack> |
| [`telescope`](pkgs/telescope/package.nix) | telescope | 5.0.1 | Use an Android phone's cameras as a webcam | <https://github.com/LunarKittyy/Telescope> |
| [`workshop-walker`](pkgs/workshop-walker/package.nix) | workshop-walker | 0.8.2 | Alternate Steam Workshop browser with dependants, language detection and properties | <https://github.com/disconsented/workshop-walker> |

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
  `nixfmt`, `nixd`, `jq`.
- `just fmt`: format.
- `just check`: formatting, generated files up to date, and building every package.
- `just generate`: regenerate `README.md`, `.envrc` and `flake.nix` (from `modules/`).
- `just build <attribute>`: build one package.
- `just update [attribute]`: bump one package, or every package when none is named, with `nix-update`
  and the per-package flags it needs; failures are listed at the end. CI runs it weekly for
  `pinepods`, `pinepods-firewood`, `rimstack` and `workshop-walker` and opens PRs; it needs an
  `UPDATE_TOKEN` secret (a PAT or GitHub App token with `contents` and `pull-requests` write), since
  PRs opened with `GITHUB_TOKEN` do not trigger the build workflow. `atuin-desktop` and `telescope`
  need manual hash/stamp fixes after an update.
- `just flake-update [input…]`: update flake inputs.
