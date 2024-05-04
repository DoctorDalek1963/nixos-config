{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.secrets;
in {
  config = lib.mkIf (cfg.enable && cfg.tailscale.enable) {
    environment.systemPackages = [pkgs.tailscale];

    sops.secrets = {
      "tailscale/Alex-NixOS" = {mode = "0400";};
      "tailscale/Harold-NixOS" = {mode = "0400";};
    };

    services.tailscale = {
      enable = true;
      authKeyFile = config.sops.secrets."tailscale/${config.setup.hostname}".path;
    };
  };
}
