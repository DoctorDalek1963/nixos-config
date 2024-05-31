{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup;
  cfgHs = cfg.homeServer;

  bash-script = pkgs.writeShellScriptBin "tailscale-certificates" ''
    set -euo pipefail

    mkdir -p "/etc/tailscale-certificates/${cfgHs.domainName}"

    ${pkgs.tailscale}/bin/tailscale cert \
      --cert-file "/etc/tailscale-certificates/${cfgHs.domainName}/cert.pem" \
      --key-file "/etc/tailscale-certificates/${cfgHs.domainName}/key.pem" \
      "${cfgHs.domainName}"

    chown -R root:certs /etc/tailscale-certificates
    chmod -R g+r /etc/tailscale-certificates
  '';
in {
  # TODO: Remember to use (adguardhome || homeAutomation || mediaServer || personalProjects) here
  config = lib.mkIf (cfgHs.adguardhome.enable || cfgHs.personalProjects.enable) {
    assertions = [
      {
        assertion = cfg.secrets.tailscale.enable;
        message = "Certificates on a home server currently require setup.secrets.tailscale.enable";
      }
    ];

    users.groups.certs = {};

    systemd = {
      services.tailscale-certificates = {
        serviceConfig = {
          Type = "simple";
          Restart = "on-failure";
          RestartSec = "3s";
          ExecStart = "${bash-script}/bin/tailscale-certificates";
          Group = "certs";
        };
        after = ["network.target" "network-online.target"];
      };
      timers.tailscale-certificates = {
        timerConfig = {
          OnCalendar = "daily";
          Unit = "tailscale-certificates.service";
        };
        wantedBy = ["timers.target"];
      };
    };
  };
}
