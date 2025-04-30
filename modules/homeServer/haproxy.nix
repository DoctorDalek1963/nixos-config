{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;

  mkProxy = service: haproxyPort: servicePort: extraBackendOpts: ''
    frontend ${service}
        bind :${toString haproxyPort}
        bind :${toString haproxyPort} ssl crt /etc/tailscale-certificates/${cfg.domainName}/combined.pem
        http-request redirect scheme https code 301 unless { ssl_fc }
        default_backend ${service}-backend
        option logasap

    backend ${service}-backend
        server ${service}_server 127.0.0.1:${toString servicePort}
        ${extraBackendOpts}
  '';

  optProxy = cond: service: haproxyPort: servicePort: extraBackendOpts:
    if cond
    then mkProxy service haproxyPort servicePort extraBackendOpts
    else "";
in {
  config = lib.mkIf (cfg.enable && (cfg.myspeed.enable || cfgMs.books || cfgMs.movies || cfgMs.telly)) {
    services.haproxy = {
      enable = true;
      group = "certs";

      config = ''
        global
            log stdout format raw local0 info

        defaults
            mode http
            timeout client 10s
            timeout connect 5s
            timeout server 10s
            timeout http-request 10s
            timeout tunnel 1h
            log global

        ${
          optProxy
          cfg.myspeed.enable
          "myspeed"
          cfg.ports.haproxy.myspeed
          cfg.ports.myspeed
          ""
        }

        ${
          optProxy
          cfgMs.books
          "audiobookshelf"
          cfg.ports.haproxy.mediaServer.audiobookshelf
          cfg.ports.mediaServer.audiobookshelf
          "option http-server-close" # No Keep-Alive, hopefully makes websockets better
        }

        ${
          optProxy
          (cfgMs.movies || cfgMs.telly)
          "jellyseerr"
          cfg.ports.haproxy.mediaServer.jellyseerr
          cfg.ports.mediaServer.jellyseerr
          ""
        }

        ${
          optProxy
          cfgMs.enable
          "fileflows"
          cfg.ports.haproxy.mediaServer.fileflows
          cfg.ports.mediaServer.fileflows
          ""
        }
      '';
    };

    systemd.services.haproxy = {
      after = ["network.target" "tailscale-certificates.service"];
      requires = ["tailscale-certificates.service"];

      serviceConfig = {
        Restart = "always";
        RestartSec = 5;
      };
    };
  };
}
