{
  pkgs,
  lib,
  config,
  inputs,
  system,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgPp = cfg.personalProjects;

  env = rec {
    DATA_DIR = "/var/lib/winter-wonderlights";
    COORDS_FILENAME = "2023-small-tree.gift";
    SERVER_SSL_CERT_PATH = "/etc/tailscale-certificates/${cfg.domainName}/cert.pem";
    SERVER_SSL_KEY_PATH = "/etc/tailscale-certificates/${cfg.domainName}/key.pem";
    PORT = "23120";
    LIGHTS_NUM = "250";
    SERVER_URL = "wss://${cfg.domainName}:${PORT}";
    SCANNER_PORT = "23121";
    SCANNER_SERVER_URL = "wss://${cfg.domainName}:${SCANNER_PORT}";
  };

  winter-wonderlights-nginx = let
    winter-wonderlights-web =
      (inputs.winter-wonderlights.packages.${system}.client-web.override env)
      .overrideAttrs {
        TRUNK_BUILD_PUBLIC_URL = "/winter-wonderlights/";
      };
    winter-wonderlights-doc = inputs.winter-wonderlights.packages.${system}.doc;
  in
    pkgs.stdenvNoCC.mkDerivation {
      name = "winter-wonderlights-nginx";
      dontUnpack = true;
      installPhase = ''
        mkdir -p $out/winter-wonderlights/docs
        cp -rv ${winter-wonderlights-web}/* $out/winter-wonderlights/
        cp -rv ${winter-wonderlights-doc}/share/doc/* $out/winter-wonderlights/docs/
      '';
    };

  winter-wonderlights-server = inputs.winter-wonderlights.packages.${system}.server-raspi-ws2811.override env;
in {
  config = lib.mkIf (cfgPp.enable && cfgPp.winter-wonderlights) {
    services.nginx.virtualHosts."${cfg.domainName}" = {
      locations."/winter-wonderlights".root = "${winter-wonderlights-nginx}";
    };

    boot.postBootCommands = ''
      if [ ! -d ${env.DATA_DIR} ]; then
        cp -rv ${inputs.winter-wonderlights}/data/* ${env.DATA_DIR}/
      fi
    '';

    systemd.services.winter-wonderlights-server = {
      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = "3s";
        ExecStart = "${winter-wonderlights-server}/bin/ww-server";
      };
      wantedBy = ["network-online.target"];
    };
  };
}
