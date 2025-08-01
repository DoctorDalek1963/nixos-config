{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.setup;
  cfgHs = cfg.homeServer;

  certDir = "/etc/tailscale-certificates/${cfgHs.domainName}";

  bash-script = pkgs.writeShellApplication {
    name = "tailscale-certificates";
    runtimeInputs = with pkgs; [
      tailscale
      openssl
    ];

    text = ''
      set -euo pipefail

      sleep 3 # Make sure tailscaled is running

      mkdir -p "${certDir}"

      tailscale cert \
        --cert-file "${certDir}/cert.pem" \
        --key-file "${certDir}/key.pem" \
        "${cfgHs.domainName}"

      cat "${certDir}/cert.pem" "${certDir}/key.pem" > "${certDir}/combined.pem"

      openssl pkcs12 -export \
        -out "${certDir}/combined.p12" \
        -in "${certDir}/cert.pem" \
        -inkey "${certDir}/key.pem" \
        -passout pass:

      chown -R root:certs /etc/tailscale-certificates
      chmod -R g+r /etc/tailscale-certificates
    '';
  };
in
{
  config = lib.mkIf cfgHs.enable {
    assertions = [
      {
        assertion = cfg.secrets.tailscale.enable;
        message = "Certificates on a home server currently require setup.secrets.tailscale.enable";
      }
    ];

    setup.impermanence.keepDirs = [
      {
        directory = certDir;
        user = "root";
        group = "certs";
        mode = "0755";
      }
    ];

    users.groups.certs = { };

    systemd = {
      services.tailscale-certificates = {
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${bash-script}/bin/tailscale-certificates";
          Group = "certs";
        };

        after = [
          "network.target"
          "network-online.target"
          "tailscaled.service"
        ];
        wants = [
          "network-online.target"
          "tailscaled.service"
        ];
      };

      timers.tailscale-certificates = {
        timerConfig = {
          OnCalendar = "daily";
          Unit = "tailscale-certificates.service";
        };

        wantedBy = [ "timers.target" ];
      };
    };
  };
}
