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
        http-request redirect scheme https code 301 unless { ssl_fc }
        default_backend ${service}-backend

    backend ${service}-backend
        server ${service}_server 127.0.0.1:${toString servicePort}
  '';

  optProxy = cond: service: haproxyPort: servicePort:
    if cond
    then mkProxy service haproxyPort servicePort
    else "";
in {
  config = lib.mkIf (cfg.enable && (cfg.myspeed.enable || cfg.firefly-iii.enable || cfgMs.books || cfgMs.movies || cfgMs.telly)) {
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
            log global

        ${
          optProxy
          cfg.myspeed.enable
          "myspeed"
          cfg.ports.haproxy.myspeed
          cfg.ports.myspeed
        }

        ${
          if cfg.firefly-iii.enable
          then ''
            frontend firefly-iii
                bind :${toString cfg.ports.haproxy.firefly-iii}
                bind :${toString cfg.ports.haproxy.firefly-iii} ssl crt /etc/tailscale-certificates/${cfg.domainName}/combined.pem
                http-request redirect scheme https code 301 unless { ssl_fc }
                default_backend firefly-iii-backend

            backend firefly-iii-backend
                use-fcgi-app php-fpm-firefly-iii
                server firefly-iii_server ${config.services.phpfpm.pools.firefly-iii.socket} proto fcgi
                http-request set-header X-Forwarded-Proto https
                http-response set-header Content-Security-Policy upgrade-insecure-requests

            fcgi-app php-fpm-firefly-iii
                log-stderr global
                option keep-conn
                docroot ${config.services.firefly-iii.package}/public
                index index.php
                path-info ^(/.+\.php)(/.*)?$
          ''
          else ""
        }

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
