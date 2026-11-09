{
  lib,
  fetchFromGitHub,
  installShellFiles,
  rustPlatform,
  stdenv,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rmrfrs";
  version = "0.8.8";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "trinhminhtriet";
    repo = "rmrfrs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1QF1l6V6YmKDPqlbXpMeWg3Pt5AonBHelD63mJkSWNM=";
  };

  cargoHash = "sha256-mPQN/JN6b9/1xo1JSj0LpVjb7rGTwrfU0PY7pbENdg4=";

  nativeBuildInputs = [
    installShellFiles
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    for shell in bash zsh fish; do
      installShellCompletion --cmd ${finalAttrs.meta.mainProgram} "--$shell" <("$out/bin/${finalAttrs.meta.mainProgram}" --completions "$shell")
    done
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Powerful filesystem cleaning tool designed to optimize storage by identifying and removing unnecessary files within known project structures";
    homepage = "https://github.com/trinhminhtriet/rmrfrs";
    downloadPage = "https://github.com/trinhminhtriet/rmrfrs";
    changelog = "https://github.com/trinhminhtriet/rmrfrs/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      adda
    ];
    mainProgram = "rmrfrs";
  };
})
