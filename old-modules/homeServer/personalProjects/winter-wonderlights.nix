{
  pkgs,
  lib,
  config,
  inputs,
  system,
  ...
}:
let
  cfg = config.setup.homeServer;
  cfgPp = cfg.personalProjects;

  env = rec {
    DATA_DIR = "/var/lib/winter-wonderlights";
    COORDS_FILENAME = "2023-small-tree.gift";
    SERVER_SSL_CERT_PATH = "/etc/tailscale-certificates/${cfg.domainName}/cert.pem";
    SERVER_SSL_KEY_PATH = "/etc/tailscale-certificates/${cfg.domainName}/key.pem";
    PORT = toString cfg.ports.winter-wonderlights.normal;
    LIGHTS_NUM = "250";
    SERVER_URL = "wss://${cfg.domainName}:${PORT}";
    SCANNER_PORT = toString cfg.ports.winter-wonderlights.scanner;
    SCANNER_SERVER_URL = "wss://${cfg.domainName}:${SCANNER_PORT}";
  };

  winter-wonderlights-web =
    (inputs.winter-wonderlights.packages.${system}.client-web.override env).overrideAttrs
      {
        TRUNK_BUILD_PUBLIC_URL = "/winter-wonderlights/";
      };
  winter-wonderlights-doc = inputs.winter-wonderlights.packages.${system}.doc;

  winter-wonderlights-server =
    inputs.winter-wonderlights.packages.${system}.server-raspi-ws2811.override
      env;
in
{
  config = lib.mkIf (cfg.enable && cfgPp.enable && cfgPp.winter-wonderlights) {
    setup.impermanence.keepDirs = env.DATA_DIR;

    services.nginx.virtualHosts."${cfg.domainName}".locations = {
      "/winter-wonderlights/" = {
        alias = "${winter-wonderlights-web}/";
        index = "index.html";
      };
      "/winter-wonderlights/docs/".alias = "${winter-wonderlights-doc}/share/doc/";

      "/winter-wonderlights".return = "301 /winter-wonderlights/";
      "/winter-wonderlights/docs".return = "301 /winter-wonderlights/docs/ww_effects/index.html";
    };

    systemd.tmpfiles.settings.winterWonderlights."${env.DATA_DIR}".d = {
      user = "winter-wonderlights";
      group = "winter-wonderlights";
      mode = "755";
    };

    # The tailscale-certificates.service can take a few seconds to get the
    # certificates initially, but the server requires them. The --require-tls
    # flag will cause the server to exit if it can't establish a TLS
    # connection, so this service will keep restarting until we've got proper
    # certificates.
    systemd.services.winter-wonderlights-server = {
      serviceConfig = {
        Type = "simple";

        User = "winter-wonderlights";
        Group = "winter-wonderlights";

        Restart = "on-failure";
        RestartSec = "10s";

        ExecStartPre = pkgs.writeShellScript "copy-winter-wonderlights-data-if-empty" ''
          # If empty
          if [ -z "$(ls -A ${env.DATA_DIR})" ]; then
              cp -rv ${inputs.winter-wonderlights}/data/* ${env.DATA_DIR}/
          fi
        '';

        ExecStart = "${winter-wonderlights-server}/bin/ww-server --require-tls";
      };
      wantedBy = [
        "network-online.target"
        "tailscale-certificates.service"
      ];
    };

    users.users.winter-wonderlights = {
      isSystemUser = true;
      group = "winter-wonderlights";
    };
  };
}
