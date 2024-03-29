{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.openRGB;
  with-all-plugins = import ./with-all-plugins.nix {inherit pkgs;};
  package =
    #
    if cfg.usePlugins
    then with-all-plugins
    else pkgs.openrgb;
in {
  # Config taken mostly from
  # https://github.com/nix-community/nur-combined/blob/4d7247933c41d143d56a01af3da606c1e72eb865/repos/misterio/modules/nixos/openrgb.nix
  config = lib.mkIf (cfg.enable && cfg.usePlugins) {
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
