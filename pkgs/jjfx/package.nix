{
  bash,
  coreutils,
  fetchFromGitHub,
  git,
  jujutsu,
  lib,
  nix-update-script,
  procps,
  rustPlatform,
  symlinkJoin,
  versionCheckHook,
}:
let
  # Upstream tests wrap fixture binaries in a restricted PATH of /usr/bin:/bin, which the Nix
  # sandbox lacks; their scripts call ps/tr/sleep and use #!/bin/bash shebangs (EPOCHREALTIME).
  # jj and git stay off it so tests asserting those tools' absence keep their meaning.
  testPathTools = symlinkJoin {
    name = "jjfx-test-path-tools";
    paths = [
      bash
      coreutils
      procps
    ];
  };
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "jjfx";
  version = "0.56.0";

  src = fetchFromGitHub {
    owner = "Jarvvski";
    repo = "jjfx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1TxIiF/MIgnu2VHjs54agLbJb4FPaY6vLGFhEqTcyf4=";
  };

  cargoHash = "sha256-Z90bHOQ4Q+aa4UcPUPHz/5CUerJ2I0rTzAJaaNtOig0=";

  nativeCheckInputs = [
    git
    jujutsu
    procps
  ];
  # Integration tests compile the crate without cfg(test), so they would sign throwaway commits.
  JJFX_TEST_SIGNING_OFF = "1";

  postPatch = ''
        # Upstream warns on any jj != the jj-lib target; a *newer* jj with an unchanged
        # store format is safe (jj-lib reads forward-compatible), so only warn when the
        # probed jj is older than the target. jj 0.47 changes templates/CLI but not the
        # store format, and jjfx's full suite passes against it.
        substituteInPlace src/engine/workspace.rs \
          --replace-fail '#[derive(Debug, Clone, Copy, PartialEq, Eq)]
    struct JjVersion {' '#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
    struct JjVersion {' \
          --replace-fail '(found != JJ_LIB_TARGET).then(|| {' '(found < JJ_LIB_TARGET).then(|| {'

        # The unit test pinned "any mismatch must warn"; now an older jj warns while a
        # newer one is silent.
        substituteInPlace src/engine/workspace.rs \
          --replace-fail 'fn jj_lib_compat_notice_fires_only_on_a_mismatch() {' 'fn jj_lib_compat_notice_fires_only_on_an_older_jj() {' \
          --replace-fail '// A match, and a jj that cannot be probed, are both silent.' '// A match, a newer jj, and a jj that cannot be probed are all silent.' \
          --replace-fail 'let mismatched = JjVersion {
                major: JJ_LIB_TARGET.major,
                minor: JJ_LIB_TARGET.minor + 1,
            };
            let notice = compat_notice(Some(mismatched)).expect("a mismatch must warn");' 'let newer = JjVersion {
                major: JJ_LIB_TARGET.major,
                minor: JJ_LIB_TARGET.minor + 1,
            };
            assert_eq!(compat_notice(Some(newer)), None, "a newer jj must not warn");

            let mismatched = JjVersion {
                major: JJ_LIB_TARGET.major,
                minor: JJ_LIB_TARGET.minor.checked_sub(1).expect("fixture needs minor >= 1"),
            };
            let notice = compat_notice(Some(mismatched)).expect("an older jj must warn");'

        substituteInPlace tests/agent_runtime.rs tests/worker_actions.rs \
          --replace-fail 'PathBuf::from("/usr/bin").as_os_str(),' \
                        'PathBuf::from("${testPathTools}/bin").as_os_str(),'
        substituteInPlace tests/agent_runtime.rs \
          --replace-fail '#!/bin/bash' '#!${testPathTools}/bin/bash'
        # The failed-launch fixture removes itself through the absolute /bin/rm, absent in the sandbox.
        substituteInPlace tests/direct_dispatch.rs \
          --replace-fail 'then /bin/rm' 'then ${testPathTools}/bin/rm'
  '';

  # jj resolves its per-repo secure config beneath HOME, unwritable in the sandbox.
  preCheck = ''
    export HOME="$TMPDIR"
  '';
  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A terminal UI for working with Jujutsu (jj) workspaces and the coding agents editing them";
    longDescription = ''
      One surface for every Jujutsu workspace: a list grouped by what needs you, the commit graph,
      per-workspace diffs, and a Worker pool that dispatches tickets to background agents.
    '';
    homepage = "https://github.com/Jarvvski/jjfx";
    changelog = "https://github.com/Jarvvski/jjfx/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [
      adda
    ];
    mainProgram = "jjfx";
  };
})
