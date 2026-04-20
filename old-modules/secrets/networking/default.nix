{
  lib,
  config,
  ...
}:
{
  imports = [
    ./vpn.nix
    ./wifi
  ];

  config = {
    setup.impermanence.keepDirs = lib.optional (
      !(config.setup.secrets.networking.enable || config.setup.secrets.vpn.enable)
    ) "/etc/NetworkManager/system-connections";
  };
}
