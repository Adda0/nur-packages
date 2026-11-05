#!/usr/bin/env just --justfile

set shell := [ "nu", "--commands" ]

set positional-arguments
set unstable

alias h := help
[default]
help:
  just --list --justfile {{justfile()}}

alias g := generate
# Regenerate README.md and flake.nix from modules/.
generate *ARGS:
  nix run .#generate-files {{ARGS}}

alias f := fmt
fmt *ARGS:
  nix fmt {{ARGS}}

alias c := check
check *ARGS:
  nix flake check {{ARGS}}

alias b := build
build PACKAGE *ARGS:
  nix build .#{{PACKAGE}} {{ARGS}}

alias u := update
# Bump packages to their latest release: one (`just update pinepods`) or, with no name, all of them.
# Trailing flags go to nix-update.
[script("nu")]
update PACKAGE="" *ARGS:
  # Flags a package always needs: hashes nix-update would otherwise leave stale.
  let extra = {
    workshop-walker: [--subpackage ui]
    # Fork branch, untagged: nix-update names it `0-unstable-<date>`.
    rimstack: [--version=branch=ideas-tip]
  }
  let packages = if "{{PACKAGE}}" != "" { ["{{PACKAGE}}"] } else {
    let system = nix eval --raw --impure --expr builtins.currentSystem
    nix eval --json $".#legacyPackages.($system)" --apply 'ps: builtins.filter (n: (ps.${n}.type or null) == "derivation") (builtins.attrNames ps)'
      | from json
  }
  mut failed = []
  for package in $packages {
    print $"=== ($package)"
    let ok = try {
      nix develop --command nix-update --flake $package ...($extra | get --optional $package | default []) {{ARGS}}
      true
    } catch { false }
    if not $ok { $failed = $failed | append $package }
  }
  if ($failed | is-not-empty) {
    error make { msg: $"Failed to update: ($failed | str join ', ')" }
  }

alias fu := flake-update
# Update flake inputs (all, or the ones named).
flake-update *ARGS:
  nix flake update {{ARGS}}
