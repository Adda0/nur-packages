# nur-packages

Adda's [NUR](https://github.com/nix-community/NUR) repository (`nur.repos.adda`).

| Package | Description |
| --- | --- |
| `atuin-desktop` | Local-first, executable runbook editor |
| `pinepods` | Desktop client for PinePods |
| `pinepods-firewood` | Terminal client for PinePods |
| `rimstack` | Fast RimWorld mod manager (fork branch `Adda0/RimStack` `ideas-tip`) |
| `telescope` | Use an Android phone's cameras as a webcam |
| `workshop-walker` | Alternate Steam Workshop browser |

## Usage

Via NUR: `pkgs.nur.repos.adda.<package>`.

As a flake input:

```nix
inputs.nur-packages = {
  url = "github:Adda0/nur-packages";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

then `inputs.nur-packages.packages.x86_64-linux.<package>` or `nixpkgs.overlays = [ inputs.nur-packages.overlays.default ];`.

## Development

`default.nix` is the source of truth NUR imports with its own `pkgs`; it must not use flake inputs or builtin fetchers.
`flake.nix` (flake-parts) wraps it.

- `nix develop`: shell with `nix-update`, `nixd`, `jq`.
- `nix fmt`: format.
- `nix flake check`: formatting and building every package.
- `nix-update --flake <package>`: bump a package. CI does this weekly and opens PRs; it needs an `UPDATE_TOKEN`
  secret (a PAT or GitHub App token with `contents` and `pull-requests` write), since PRs opened with `GITHUB_TOKEN`
  do not trigger the build workflow.
