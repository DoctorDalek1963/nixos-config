{
  lib,
  config,
  ...
}: let
  cfg = config.setup.backup;
in {
  config = lib.mkIf cfg.enable {};
}
