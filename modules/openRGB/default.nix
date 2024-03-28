{
  pkgs,
  lib,
  config,
  ...
}: let
  package = pkgs.openrgb-with-all-plugins;
in {
  # Config taken mostly from
  # https://github.com/nix-community/nur-combined/blob/4d7247933c41d143d56a01af3da606c1e72eb865/repos/misterio/modules/nixos/openrgb.nix
  config = lib.mkIf config.setup.openRGB {
    environment.systemPackages = [package];

    services.udev = {
      enable = true;
      packages = [package];
    };

    boot.kernelModules = ["v4l2loopback" "i2c-dev" "i2c-piix4"];

    systemd.services.openrgb = {
      description = "OpenRGB Daemon";
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        ExecStart = "${package}/bin/openrgb --server";
        Restart = "on-failure";
      };
    };
  };
}
