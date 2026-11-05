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
update PACKAGE *ARGS:
  let extra = {{extra-update-args}} | get --optional {{PACKAGE}} | default []; nix develop --command nix-update --flake {{PACKAGE}} ...$extra {{ARGS}}

alias fu := flake-update
# Update flake inputs (all, or the ones named).
flake-update *ARGS:
  nix flake update {{ARGS}}

# Flags `update` always passes for a package: hashes nix-update would otherwise leave stale.
extra-update-args := "{ workshop-walker: [--subpackage ui] }"
