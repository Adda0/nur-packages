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
# Bump one package to its latest release, e.g. `just update pinepods`; trailing flags go to nix-update.
[script("nu")]
update PACKAGE *ARGS:
  # Flags a package always needs: hashes nix-update would otherwise leave stale.
  let extra = {
    workshop-walker: [--subpackage ui]
  } | get --optional {{PACKAGE}} | default []
  nix develop --command nix-update --flake {{PACKAGE}} ...$extra {{ARGS}}

alias fu := flake-update
# Update flake inputs (all, or the ones named).
flake-update *ARGS:
  nix flake update {{ARGS}}
