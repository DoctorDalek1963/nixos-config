{
  lib,
  config,
  ...
}:
{
  imports = [
    ./adguardhome
    ./cloud
    ./kiwix
    ./mediaServer
    ./myspeed
    ./personalProjects

    ./haproxy.nix
    ./homepage.nix
    ./firefly-iii.nix
    ./mealie.nix
    ./nginx.nix
    ./ntfy.nix
    ./scrutiny.nix
    ./squid.nix
    ./tailscaleCerts.nix
  ];

  config = lib.mkIf config.setup.homeServer.enable {
    systemd.tmpfiles.settings = lib.mkIf config.setup.impermanence.enable {
      persistVarLibPrivate."/persist/var/lib/private".z.mode = "700";
    };
  };
}
