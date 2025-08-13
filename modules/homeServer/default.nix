{
  lib,
  config,
  ...
}:
{
  imports = [
    ./cloud
    ./dns
    ./mediaServer
    ./myspeed
    ./personalProjects

    ./haproxy.nix
    ./homepage.nix
    ./firefly-iii.nix
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
