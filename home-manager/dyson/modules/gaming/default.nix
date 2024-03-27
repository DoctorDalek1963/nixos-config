{
  # pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.gaming;
in {
  config = lib.mkIf cfg.enable {
    # TODO: Add Steam and stuff
  };
}
