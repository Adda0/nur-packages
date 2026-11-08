{
  fetchFromGitHub,
  fetchpatch,
  lib,
  rustPlatform,
}:
let
  # gemm 0.19.0 dispatches to its AVX2 kernels wherever the CPU merely reports `fma`, then panics in
  # `V3::try_new().unwrap()` on CPUs with FMA but no AVX2 (https://github.com/sarah-quinones/gemm/issues/54).
  # Upstream fix, unmerged and unreleased: https://github.com/sarah-quinones/gemm/pull/55
  # Drop once the locked gemm crates dispatch on the full SIMD feature set.
  gemmSimdDispatchPatch = fetchpatch {
    name = "gemm-x86-dispatch-full-simd-feature-set.patch";
    url = "https://github.com/sarah-quinones/gemm/commit/2561bf91f032bb611e380a2ee47bf8490a90fb4d.patch";
    hash = "sha256-Ei5+FQN4NV052mSnc0VKxGUylDN27465wVvtw6qtuPI=";
  };
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ai-memory";
  version = "3.4.4";

  src = fetchFromGitHub {
    owner = "akitaonrails";
    repo = "ai-memory";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dP+3cdgUrTcerI0VRIdqub0YwQr0RUnmPVOOmWaLkHA=";
  };

  cargoHash = "sha256-zackdEqEDnd6Cmwnu2cHxp2uGRPRMFMo3xms5k+Z66Q=";

  # The crate sources sit under source-registry-0/<crate>-<version>/ in the vendored deps, while the
  # upstream patch carries the repository layout.
  postPatch = ''
    sed \
      -e 's|a/gemm-common/|a/source-registry-0/gemm-common-0.19.0/|g' \
      -e 's|b/gemm-common/|b/source-registry-0/gemm-common-0.19.0/|g' \
      -e 's|a/gemm-f16/|a/source-registry-0/gemm-f16-0.19.0/|g' \
      -e 's|b/gemm-f16/|b/source-registry-0/gemm-f16-0.19.0/|g' \
      ${gemmSimdDispatchPatch} | patch -d "$cargoDepsCopy" -p1
  '';

  cargoBuildFeatures = [ "management-ui" ];

  # Use the vendored CSS instead of downloading the Tailwind CLI in the sandbox.
  TAILWIND_SKIP = "1";

  buildType = "release";

  # Upstream's packaging tests require Docker or Podman on PATH.
  doCheck = false;

  # Install the native binary's runtime assets, not upstream's Docker wrapper.
  postInstall = ''
    mkdir -p $out/share/ai-memory
    cp -a hooks $out/share/ai-memory/

    mkdir -p $out/etc/ai-memory
    cp crates/ai-memory-cli/templates/config.default.toml \
       $out/etc/ai-memory/config.default.toml
  '';

  meta = {
    description = "Long-term memory for AI coding agents";
    homepage = "https://aimemory.sh";
    license = lib.licenses.mit;
    mainProgram = "ai-memory";
  };
})
