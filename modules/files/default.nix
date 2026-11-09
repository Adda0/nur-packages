{ inputs, ... }:
{
  imports = [ inputs.files.flakeModules.default ];

  perSystem.files.generateApp = true;
}
