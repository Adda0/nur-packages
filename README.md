<!--
DO-NOT-EDIT. This file was auto-generated using github:sini/files.
Use `just generate` to regenerate it.
-->

# nur-packages

Adda's [NUR](https://github.com/nix-community/NUR) repository (`nur.repos.adda`).

## Packages

- **`ai-memory`**
  - version: 3.4.4
  - description: Long-term memory for AI coding agents
  - homepage: <https://aimemory.sh>
  - license: MIT
  - main program: `ai-memory`
  - source: [pkgs/ai-memory/package.nix](pkgs/ai-memory/package.nix)
- **`atuin-desktop`**
  - version: 0.2.20
  - description: Local-first, executable runbook editor
  - homepage: <https://atuin.sh>
  - license: Apache-2.0
  - maintainers: `adda` ([@adda0](https://github.com/adda0))
  - main program: `atuin-desktop`
  - source: [pkgs/atuin-desktop/package.nix](pkgs/atuin-desktop/package.nix)
- **`pinepods`**
  - version: 0.9.2
  - description: Desktop client for PinePods, a self-hosted podcast server
  - homepage: <https://www.pinepods.online/>
  - license: GPL-3.0-only
  - maintainers: `adda` ([@adda0](https://github.com/adda0))
  - main program: `pinepods`
  - source: [pkgs/pinepods/package.nix](pkgs/pinepods/package.nix)
- **`pinepods-firewood`**
  - version: 0.2.0
  - description: Terminal client for PinePods, a self-hosted podcast sync server
  - homepage: <https://github.com/madeofpendletonwool/pinepods-firewood>
  - license: GPL-3.0-only
  - main program: `pinepods_firewood`
  - source: [pkgs/pinepods-firewood/package.nix](pkgs/pinepods-firewood/package.nix)
- **`rimstack`**
  - version: 0-unstable-2026-11-07
  - description: Fast RimWorld mod manager
  - homepage: <https://github.com/TheForgotten69/RimStack>
  - license: GPL-3.0-or-later
  - main program: `rimstack`
  - source: [pkgs/rimstack/package.nix](pkgs/rimstack/package.nix)
- **`rmrfrs`**
  - version: 0.8.8
  - description: Powerful filesystem cleaning tool designed to optimize storage by identifying and removing unnecessary files within known project structures
  - homepage: <https://github.com/trinhminhtriet/rmrfrs>
  - license: MIT
  - maintainers: `adda` ([@adda0](https://github.com/adda0))
  - main program: `rmrfrs`
  - source: [pkgs/rmrfrs/package.nix](pkgs/rmrfrs/package.nix)
- **`telescope`**
  - version: 5.0.5
  - description: Use an Android phone's cameras as a webcam
  - homepage: <https://github.com/LunarKittyy/Telescope>
  - license: AGPL-3.0-only
  - main program: `telescope`
  - source: [pkgs/telescope/package.nix](pkgs/telescope/package.nix)
- **`workshop-walker`**
  - version: 0.8.2
  - description: Alternate Steam Workshop browser with dependants, language detection and properties
  - homepage: <https://github.com/disconsented/workshop-walker>
  - license: MPL-2.0
  - main program: `workshop-walker`
  - source: [pkgs/workshop-walker/package.nix](pkgs/workshop-walker/package.nix)
- **`zonetimeline-tui`**
  - version: 0.4.1
  - description: A terminal tool for visually comparing time zones — built for distributed teams
  - homepage: <https://github.com/findyourexit/zonetimeline-tui>
  - license: MIT
  - maintainers: `adda` ([@adda0](https://github.com/adda0))
  - main program: `ztl`
  - source: [pkgs/zonetimeline-tui/package.nix](pkgs/zonetimeline-tui/package.nix)

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
  the end. CI runs it weekly for `pinepods`, `pinepods-firewood`, `rimstack`, `rmrfrs`, `workshop-walker` and
  `zonetimeline-tui` and opens PRs; it needs an `UPDATE_TOKEN` secret (a PAT or GitHub App token with
  `contents` and `pull-requests` write), since PRs opened with `GITHUB_TOKEN` do not trigger the build
  workflow. `atuin-desktop` and `telescope` need manual hash/stamp fixes after an update.
- `just flake-update [input…]`: update flake inputs manually. Dependabot also opens weekly PRs
  for `flake.lock` and GitHub Actions.
