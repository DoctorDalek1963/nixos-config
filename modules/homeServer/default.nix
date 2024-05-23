{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
in {
  imports = [./personalProjects ./tailscaleCerts.nix];

  config = lib.mkIf cfg.personalProjects.enable {
    services.nginx = {
      enable = true;
      group = "certs";
      virtualHosts."${cfg.domainName}" = {
        forceSSL = true;
        sslCertificate = "/etc/tailscale-certificates/${cfg.domainName}/cert.pem";
        sslCertificateKey = "/etc/tailscale-certificates/${cfg.domainName}/key.pem";
      };
    };

    networking.firewall.allowedTCPPorts = [80 443];
  };
}
