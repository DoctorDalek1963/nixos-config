{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
in {
  config = lib.mkIf cfg.enable {
    services.nginx = {
      enable = true;
      group = "certs";

      logError = "stderr debug";

      recommendedProxySettings = true;

      virtualHosts."${cfg.domainName}" = {
        kTLS = true;
        forceSSL = true;
        sslCertificate = "/etc/tailscale-certificates/${cfg.domainName}/cert.pem";
        sslCertificateKey = "/etc/tailscale-certificates/${cfg.domainName}/key.pem";
      };
    };

    systemd.services.nginx = {
      after = ["network.target" "tailscale-certificates.service"];
      requires = ["tailscale-certificates.service"];
    };

    networking.firewall.allowedTCPPorts = [80 443];
  };
}
