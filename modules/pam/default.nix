{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.setup;

  shortenFailDelay = {
    nodelay = true;
    failDelay = {
      enable = true;
      delay = cfg.pamShortenFailDelay.microseconds;
    };
  };
in
{
  # Shorten delay when getting password wrong
  security.pam.services = mkIf cfg.pamShortenFailDelay.enable {
    gdm-password = mkIf cfg.displayManagers.gdm.enable shortenFailDelay;
    greetd = mkIf cfg.displayManagers.tuigreet.enable shortenFailDelay;
    hyprlock = mkIf cfg.desktopEnvironments.hyprland.enable shortenFailDelay;
    login = shortenFailDelay;
    sudo = mkIf config.security.sudo.enable shortenFailDelay;
  };
}
