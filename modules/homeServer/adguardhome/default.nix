{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
in {
  config = lib.mkIf (cfg.enable && cfg.adguardhome.enable) {
    services.adguardhome = {
      enable = true;

      port = 3000;
      openFirewall = true;

      # Despite setting things declaratively, you MIGHT need to turn on
      # encryption and check the filter lists for updates before it works
      # properly. I don't know how to fix that, but it's trivially easy to do
      # it manually.
      mutableSettings = true;
      settings = {
        dns.bind_hosts = ["0.0.0.0"];
        filtering = {
          filtering_enabled = true;
          parental_enabled = false;
          safebrowsing_enabled = true;
          safe_search.enabled = false;
        };
        tls = {
          enabled = true;
          server_name = "${cfg.domainName}";

          force_https = true;
          port_https = 3001;
          port_dns_over_tls = 853;
          port_dns_over_quic = 853;

          certificate_path = "/etc/tailscale-certificates/${cfg.domainName}/cert.pem";
          private_key_path = "/etc/tailscale-certificates/${cfg.domainName}/key.pem";
        };

        filters = [
          {
            enabled = true;
            url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
            name = "AdGuard DNS filter";
            id = 1;
          }
          {
            enabled = true;
            url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt";
            name = "AdAway Default Blocklist";
            id = 2;
          }
        ];
      };
    };

    systemd.services.adguardhome = {
      after = ["network.target" "tailscale-certificates.service"];
      serviceConfig.Group = "certs";
    };

    networking.firewall = {
      allowedTCPPorts = [853 3001];
      allowedUDPPorts = [853]; # QUIC uses UDP
    };
  };
}
