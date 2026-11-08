{
  binaryen,
  buildWasmBindgenCli,
  cargo-tauri,
  fetchCrate,
  fetchFromGitHub,
  glib-networking,
  lib,
  libayatana-appindicator,
  libsoup_3,
  openssl,
  pkg-config,
  rustPlatform,
  rustc,
  tailwindcss_3,
  trunk,
  webkitgtk_4_1,
  wrapGAppsHook3,
}:

let
  # PinePods 0.9.2 locks wasm-bindgen 0.2.130; nixpkgs currently provides 0.2.129.
  wasm-bindgen-cli = buildWasmBindgenCli rec {
    src = fetchCrate {
      pname = "wasm-bindgen-cli";
      version = "0.2.130";
      hash = "sha256-9Og1O/6/VC3sc5hBjoIWBErmLW2UHGMsTQO+6+m/dng=";
    };

    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit src;
      inherit (src) pname version;
      hash = "sha256-j81sUf1m5yXU4FJfGj7GV+hdqVCV8mRmNb0QIsMCjqw=";
    };
  };
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "pinepods";
  version = "0.9.2";

  src = fetchFromGitHub {
    owner = "madeofpendletonwool";
    repo = "PinePods";
    tag = finalAttrs.version;
    hash = "sha256-+vSjP1V+GcmflieB0VcLeUTs4ZmN/zIq8/6GGBf6cwM=";
  };

  cargoRoot = "web/src-tauri";
  buildAndTestSubdir = finalAttrs.cargoRoot;

  cargoHash = "sha256-2HC3ZO/PcJtGW9V3sPVPtkJyQ3x+nSzqs9SkWz8FDrQ=";

  frontendCargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname src version;
    name = "pinepods-frontend-vendor";
    cargoRoot = "web";
    hash = "sha256-8dsJ5r2ersAI5Qpx3veYjCtOixFo6iLoxsykkGudejk=";
  };

  postPatch = ''
    substituteInPlace $cargoDepsCopy/*/libappindicator-sys-*/src/lib.rs \
      --replace-fail "libayatana-appindicator3.so.1" "${libayatana-appindicator}/lib/libayatana-appindicator3.so.1"

    mkdir -p web/.cargo
    frontendVendorCopy=$(mktemp -d)
    cp -r --no-preserve=mode -- "$frontendCargoDeps"/. "$frontendVendorCopy"
    substitute "$frontendVendorCopy/.cargo/config.toml" web/.cargo/config.toml \
      --subst-var-by vendor "$frontendVendorCopy"

    # Ensure the `config.toml` built above for the frontend is not used in `web/src-tauri.toml`.
    mkdir -p web/src-tauri/.cargo
    cp ../.cargo/config.toml web/src-tauri/.cargo/config.toml
  '';

  nativeBuildInputs = [
    cargo-tauri.hook
    pkg-config
    wrapGAppsHook3

    trunk
    wasm-bindgen-cli
    binaryen
    tailwindcss_3
    rustc.llvmPackages.lld
  ];

  buildInputs = [
    glib-networking
    libayatana-appindicator
    libsoup_3
    openssl
    webkitgtk_4_1
  ];

  preBuild = ''
    # Frontend built separately upstream with custom flags.
    pushd web
    RUSTFLAGS='--cfg=web_sys_unstable_apis --cfg getrandom_backend="wasm_js"' \
      trunk build --offline --frozen --features server_build
    popd
  '';

  doCheck = false;

  # Upstream names both its binary and .desktop Exec (and StartupWMClass and Icon) as `app`.
  # Enough to rename the binary and Exec.
  postInstall = ''
    mv $out/bin/app $out/bin/pinepods
    substituteInPlace $out/share/applications/Pinepods.desktop \
      --replace-fail "Exec=app" "Exec=pinepods"
  '';

  meta = {
    description = "Desktop client for PinePods, a self-hosted podcast server";
    homepage = "https://www.pinepods.online/";
    changelog = "https://github.com/madeofpendletonwool/PinePods/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    mainProgram = "pinepods";
    maintainers = with lib.maintainers; [ adda ];
    platforms = lib.platforms.linux;
  };
})
