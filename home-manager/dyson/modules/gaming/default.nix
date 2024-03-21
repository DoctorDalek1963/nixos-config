{
  # pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.gaming {
    # TODO: Add Steam and stuff
  };
}
