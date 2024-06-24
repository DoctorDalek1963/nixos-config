{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;

  mkProxy = service: haproxyPort: servicePort: ''
    frontend ${service}
        bind :${toString haproxyPort}
        bind :${toString haproxyPort} ssl crt /etc/tailscale-certificates/${cfg.domainName}/combined.pem
        http-request redirect scheme https unless { ssl_fc }
        default_backend ${service}-backend

    backend ${service}-backend
        server ${service}_server 127.0.0.1:${toString servicePort}
  '';

  optProxy = cond: service: haproxyPort: servicePort:
    if cond
    then mkProxy service haproxyPort servicePort
    else "";
in {
  config = lib.mkIf (cfg.enable && (cfgMs.books || cfgMs.movies || cfgMs.telly)) {
    services.haproxy = {
      enable = true;
      group = "certs";

      config = ''
        defaults
            mode http
            timeout client 10s
            timeout connect 5s
            timeout server 10s
            timeout http-request 10s

        ${
          optProxy
          cfgMs.books
          "audiobookshelf"
          cfg.ports.haproxy.mediaServer.audiobookshelf
          cfg.ports.mediaServer.audiobookshelf
        }

        ${
          optProxy
          (cfgMs.movies || cfgMs.telly)
          "jellyseerr"
          cfg.ports.haproxy.mediaServer.jellyseerr
          cfg.ports.mediaServer.jellyseerr
        }
      '';
    };

    systemd.services.haproxy = {
      after = ["network.target" "tailscale-certificates.service"];
      requires = ["tailscale-certificates.service"];
    };
  };
}
