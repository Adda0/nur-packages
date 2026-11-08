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
# Bump packages to their latest release, one commit per package as `<name>: <old> -> <new>`: one
# (`just update pinepods`) or, with no name, all of them. Trailing flags go to nix-update.
[script("nu")]
update PACKAGE="" *ARGS:
  # Flags a package always needs: hashes nix-update would otherwise leave stale.
  let extra = {
    # Separate frontend and Tauri Cargo.lock files need separate vendor hashes.
    pinepods: [--subpackage frontendCargoDeps.vendorStaging --override-filename pkgs/pinepods/package.nix]
    workshop-walker: [--subpackage ui]
    # Fork branch, untagged: nix-update names it `0-unstable-<date>`; normalize it below.
    rimstack: [--version=branch=ideas-tip]
  }
  let packages = if "{{PACKAGE}}" != "" { ["{{PACKAGE}}"] } else {
    let system = nix eval --raw --impure --expr builtins.currentSystem
    nix eval --json $".#legacyPackages.($system)" --apply 'ps: builtins.filter (n: (ps.${n}.type or null) == "derivation") (builtins.attrNames ps)'
      | from json
  }
  # Commit through jj in a jj checkout, plain git otherwise (CI runs a git clone).
  let jj = (".jj" | path exists)
  mut failed = []
  for package in $packages {
    print $"=== ($package)"
    let path = $"pkgs/($package)"
    let package_file = $"($path)/package.nix"
    let old_digest = if $package == "rimstack" { open --raw $package_file | hash sha256 } else { "" }
    # nix-update's own commit message, written only when it actually changed something.
    let message_file = (mktemp --suffix .txt)
    let ok = try {
      nix develop --command nix-update --flake --use-update-script --write-commit-message $message_file $package ...($extra | get --optional $package | default []) {{ARGS}}
      true
    } catch { false }
    if $package == "rimstack" {
      # No tags means nix-update supplies `0`; use the upstream Cargo workspace's base version instead.
      open --raw $package_file | str replace --all 'version = "0-unstable-' 'version = "1.1.0-unstable-' | save --force $package_file
      if ($message_file | path exists) {
        open --raw $message_file | str replace --all "0-unstable-" "1.1.0-unstable-" | save --force $message_file
        if (open --raw $package_file | hash sha256) == $old_digest { rm --force $message_file }
      }
    }
    let message = if ($message_file | path exists) { open --raw $message_file | str trim } else { "" }
    rm --force $message_file
    if not $ok { $failed = $failed | append $package } else if ($message | is-not-empty) {
      if $jj { jj commit --message $message $path } else {
        git add --all -- $path
        git commit --message $message -- $path
      }
      print $message
    }
  }
  if ($failed | is-not-empty) {
    error make { msg: $"Failed to update: ($failed | str join ', ')" }
  }

alias fu := flake-update
# Update flake inputs (all, or the ones named).
flake-update *ARGS:
  nix flake update {{ARGS}}
