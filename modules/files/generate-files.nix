{ lib, ... }:
{
  perSystem =
    { pkgs, self', ... }:
    {
      apps.generate-files.program = pkgs.writeShellApplication {
        name = "generate-files";
        text = ''
          ${self'.apps.write-files.program}
          ${lib.getExe self'.packages.write-flake}
        '';
      };
    };
}
