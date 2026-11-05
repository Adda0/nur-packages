{
  alsa-lib,
  android-tools,
  copyDesktopItems,
  fetchFromGitHub,
  ffmpeg_8,
  fontconfig,
  freetype,
  lib,
  libGL,
  libX11,
  libXcursor,
  libXi,
  libXrandr,
  libxkbcommon,
  makeDesktopItem,
  makeWrapper,
  pkg-config,
  pulseaudio,
  rnnoise,
  rustPlatform,
  vulkan-loader,
  wayland,
}:

let
  # Opened with dlopen by winit, femtovg and wgpu, so the linker never records them.
  dlopenLibs = [
    libGL
    libX11
    libXcursor
    libXi
    libXrandr
    libxkbcommon
    vulkan-loader
    wayland
  ];
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "telescope";
  version = "5.0.5";

  src = fetchFromGitHub {
    owner = "LunarKittyy";
    repo = "Telescope";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UZVkh5ff/9QHjieHxUO58iQIpP+46ZP1KAQIRNXf3mo=";
  };

  cargoRoot = "rust";
  buildAndTestSubdir = finalAttrs.cargoRoot;

  cargoHash = "sha256-YlZeLaz2R1fXXOEKpKA5aWs72NV+j8PVKQtJNBcGla8=";

  # Menu and sign-in entries the app writes into ~/.local and ~/.config name its own executable, a store path that
  # garbage collection removes; point them at the wrapper on PATH instead.
  postPatch = ''
    substituteInPlace rust/crates/system/src/autostart.rs \
      --replace-fail 'let program = if !cfg!(windows) && start_sh.exists() {' \
                     'let program = if cfg!(target_os = "linux") { PathBuf::from("telescope") } else if !cfg!(windows) && start_sh.exists() {'
  '';

  # A release stamp: the "dev" default keeps settings in a throwaway profile. Build number from the release's manifest.json.
  env = {
    TELESCOPE_BUILD = "2595";
    TELESCOPE_CHANNEL = "stable";
    TELESCOPE_COMMIT = "f0d8ea937032700e4f09f5e3981cdd414cc8596b";
  };

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    alsa-lib
    ffmpeg_8
    fontconfig
    freetype
  ]
  ++ dlopenLibs;

  cargoBuildFlags = [
    "--package"
    "telescope-app"
  ];

  # The suite opens real windows and wants node and a v4l2loopback device.
  doCheck = false;

  # The app looks for ui-kit/ and librnnoise.so beside its executable.
  postInstall = ''
    app=$out/lib/telescope
    mkdir --parents $app
    mv $out/bin/telescope-rs $app/
    cp --recursive rust/crates/ui-kit/ui $app/ui-kit
    ln --symbolic ${rnnoise}/lib/librnnoise.so $app/librnnoise.so

    makeWrapper $app/telescope-rs $out/bin/telescope \
      --prefix PATH : ${
        lib.makeBinPath [
          android-tools
          pulseaudio
        ]
      }

    mkdir --parents $out/share/icons/hicolor/256x256/apps
    $app/telescope-rs app-icon $out/share/icons/hicolor/256x256/apps/telescope.png
  '';

  postFixup = ''
    patchelf --add-rpath ${lib.makeLibraryPath dlopenLibs} $out/lib/telescope/telescope-rs
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "telescope";
      desktopName = "Telescope";
      genericName = "Phone webcam";
      comment = "Phone camera as a webcam";
      exec = "telescope";
      icon = "telescope";
      startupWMClass = "telescope";
      categories = [
        "AudioVideo"
        "Video"
      ];
      keywords = [
        "webcam"
        "camera"
        "phone"
        "android"
      ];
    })
  ];

  meta = {
    description = "Use an Android phone's cameras as a webcam";
    homepage = "https://github.com/LunarKittyy/Telescope";
    license = lib.licenses.agpl3Only;
    mainProgram = "telescope";
    platforms = lib.platforms.linux;
  };
})
