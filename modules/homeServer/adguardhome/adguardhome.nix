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

      port = cfg.ports.adguardhome.http;
      openFirewall = true;

      # Despite setting things declaratively, you MIGHT need to turn on
      # encryption and check the filter lists for updates before it works
      # properly. I don't know how to fix that, but it's trivially easy to do
      # it manually.
      mutableSettings = true;
      settings = {
        dns = rec {
          bind_hosts = ["0.0.0.0"];

          enable_dnssec = true;
          cache_optimistic = true;

          ratelimit = 50;

          upstream_dns =
            ["127.0.0.1:${toString cfg.ports.unbound}"]
            ++ lib.optional config.networking.enableIPv6 "[::1]:${toString cfg.ports.unbound}";
          bootstrap_dns = upstream_dns;
        };

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
          port_https = cfg.ports.adguardhome.https;
          port_dns_over_tls = cfg.ports.adguardhome.dnsOverTls;
          port_dns_over_quic = cfg.ports.adguardhome.dnsOverQuic;

          certificate_path = "/etc/tailscale-certificates/${cfg.domainName}/cert.pem";
          private_key_path = "/etc/tailscale-certificates/${cfg.domainName}/key.pem";
        };

        statistics = {
          enabled = true;
          interval = "168h"; # 7 days
        };

        querylog = {
          enabled = true;
          interval = "720h"; # 30 days
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
      allowedTCPPorts = [cfg.ports.adguardhome.dnsOverTls cfg.ports.adguardhome.https];
      allowedUDPPorts = [cfg.ports.adguardhome.dnsOverQuic]; # QUIC uses UDP
    };
  };
}
