{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.openRGB;

  with-all-plugins = import ./with-all-plugins.nix {inherit pkgs;};

  package =
    if cfg.usePlugins
    then with-all-plugins
    else pkgs.openrgb;
in {
  config = lib.mkIf cfg.enable {
    services.hardware.openrgb = {
      enable = true;
      inherit package;
    };

    setup.impermanence.keepDirs = ["/var/lib/OpenRGB"];

    systemd = lib.mkIf cfg.simpleDaytimeRainbow {
      services.openrgb-daytime-rainbow = {
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.writeShellScript "set-openrgb-daytime-rainbow" ''
            current=$(date +'%s')
            start=$(date -d '7:30' +'%s')
            end=$(date -d '22:30' +'%s')

            if [ $current -ge $start -a $current -lt $end ]; then
              ${lib.getExe package} --mode rainbow
            else
              ${lib.getExe package} --mode off
            fi
          ''}";
        };
      };

      timers.openrgb-daytime-rainbow = {
        wantedBy = ["timers.target"];
        timerConfig = {
          OnCalendar = "07,22:30";
          Unit = "openrgb-daytime-rainbow.service";
        };
      };
    };
  };
}
