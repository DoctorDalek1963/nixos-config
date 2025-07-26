{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.setup.misc.programs.discord {
    home.packages = [ pkgs.discord ];
    setup.impermanence.keepDirs = [ ".config/discord" ];

    xdg.configFile."discord/settings.json".text =
      # json
      ''
        {
          "OPEN_ON_STARTUP": false,
          "SKIP_HOST_UPDATE": true
        }
      '';
  };
}
