{
  lib,
  config,
  ...
}:
let
  cfg = config.setup.binfmt;
in
{
  boot.binfmt.emulatedSystems = lib.optional cfg.aarch64 "aarch64-linux";
}
