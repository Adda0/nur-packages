{
  alsa-lib,
  cacert,
  fetchFromGitHub,
  lib,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "pinepods-firewood";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "madeofpendletonwool";
    repo = "pinepods-firewood";
    tag = finalAttrs.version;
    hash = "sha256-AjDGg30pwB1URSXAr8bm+tMnxbNW7b1YIatatTMvhgQ=";
  };

  cargoHash = "sha256-W7dB4rhSnco+V+yqIgBJMynstIsxRFbOVd7el8T5/oM=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];
  buildInputs = [
    openssl
    alsa-lib
  ];

  SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  meta = {
    description = "Terminal client for PinePods, a self-hosted podcast sync server";
    homepage = "https://github.com/madeofpendletonwool/pinepods-firewood";
    license = lib.licenses.gpl3Only;
    mainProgram = "pinepods_firewood";
    platforms = lib.platforms.linux;
  };
})
