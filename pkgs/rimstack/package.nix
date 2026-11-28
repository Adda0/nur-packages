{
  fetchFromGitHub,
  fontconfig,
  freetype,
  git,
  lib,
  libGL,
  libx11,
  libxcb,
  libxext,
  libxkbcommon,
  makeWrapper,
  pkg-config,
  rustPlatform,
  sqlite,
  vulkan-loader,
  wayland,
}:
rustPlatform.buildRustPackage {
  pname = "rimstack";
  version = "1.1.0-unstable-2026-11-17";

  # Fork branch `ideas-tip`; upstream is TheForgotten69/RimStack.
  src = fetchFromGitHub {
    owner = "Adda0";
    repo = "RimStack";
    rev = "1b624898d2b52cb044a9b624b3031bd7cdaac95b";
    hash = "sha256-5NLP3tLGBMTAEJoiMbG5T/opvDaoCGwFS1T30N5qZ9A=";
  };

  cargoHash = "sha256-L8Hf4UxgrmdgorvEmKUahV3ifg+wdrUsCNuVdVMirj8=";

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];

  # What gpui-fast links against on Linux; mirrors upstream's nix/gpui-libs.nix.
  buildInputs = [
    fontconfig
    freetype
    libGL
    libx11
    libxcb
    libxext
    libxkbcommon
    # rusqlite via zed-font-kit links the system SQLite (not the bundled copy).
    sqlite
    wayland
  ];

  # Upstream's default branch declares a rust-version newer than nixpkgs' rustc.
  cargoBuildFlags = [
    "--ignore-rust-version"
    "--package"
    "rimstack-app"
  ];
  # The tests of the app crate need a display; core has the logic.
  cargoTestFlags = [
    "--ignore-rust-version"
    "--package"
    "rimstack-core"
  ];

  nativeCheckInputs = [ git ];
  checkFlags = [
    # Copies /bin/sleep, absent in the sandbox.
    "--skip=sources::maintenance::tests::a_game_started_now_is_seen_running_and_not_once_it_ended"
  ];

  postInstall = ''
    install -Dm644 crates/app/assets/rimstack.desktop -t $out/share/applications
    install -Dm644 crates/app/assets/rimstack.svg -t $out/share/icons/hicolor/scalable/apps
  '';

  # gpui-fast dlopens Vulkan, GL and Wayland at run time; Git-sourced mods need Git for cloning and updating.
  postFixup = ''
    wrapProgram $out/bin/rimstack \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          libGL
          vulkan-loader
          wayland
        ]
      } \
      --prefix PATH : ${lib.makeBinPath [ git ]}
  '';

  meta = {
    description = "Fast RimWorld mod manager";
    homepage = "https://github.com/TheForgotten69/RimStack";
    license = lib.licenses.gpl3Plus;
    mainProgram = "rimstack";
  };
}
