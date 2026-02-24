{
  lib,
  config,
  ...
}:
let
  cfg = config.setup.homeServer;
in
{
  config = lib.mkIf (cfg.enable && cfg.mealie.enable) {
    setup = {
      impermanence.keepDirs = [ "/var/lib/mealie" ];
      backup.paths = [ "/var/lib/mealie" ];
    };

    services.mealie = {
      enable = true;
      port = cfg.ports.mealie;
    };

    services.mealie.serviceConfig = {
      DynamicUser = lib.mkForce false;

      StateDirectory = "mealie";
      WorkingDirectory = lib.mkForce "/var/lib/mealie";
    };
  };
}
