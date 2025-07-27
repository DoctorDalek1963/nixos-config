{
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.setup.homeServer;
  cfgCp = cfg.cloud.copyparty;
in
{
  imports = [ inputs.copyparty.nixosModules.default ];

  config = lib.mkIf (cfg.enable && cfgCp.enable) {
    nixpkgs.overlays = [ inputs.copyparty.overlays.default ];

    sops.secrets."home-server/copyparty/dyson/password".mode = "0444";

    services.copyparty = {
      enable = true;

      settings = {
        p = [ cfg.ports.cloud.copyparty ];

        zm = true; # zeroconf mDNS
        z-on = [ "100.0.0.0/8" ]; # Only do zeroconf for 100.*.*.* addresses

        e2dsa = true; # File indexing, scan all
        e2ts = true; # Metadata indexing, scan new
      };

      accounts.dyson.passwordFile = config.sops.secrets."home-server/copyparty/dyson/password".path;

      volumes."/" = {
        path = cfgCp.cloudRoot;
        access.A = [ "dyson" ];
        flags = { };
      };
    };
  };
}
