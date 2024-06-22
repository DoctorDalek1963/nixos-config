{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;
in {
  config = lib.mkIf (cfg.enable && cfgMs.enable && (cfgMs.movies || cfgMs.telly)) {
    services = {
      nginx.virtualHosts."${cfg.domainName}".locations = {
        "^~ /jellyseerr" = {
          proxyPass = "http://localhost:${toString cfg.ports.mediaServer.jellyseerr}";
          # This config was taken almost entirely from
          # https://docs.overseerr.dev/extending-overseerr/reverse-proxy
          # Overseerr and Jellyseerr don't currently support base URLs, so we
          # have to bodge it like this. This setup is not officially supported
          # and if Jellyseerr gets an update, I should update this proxy config
          # as well.
          extraConfig = ''
            set $app 'jellyseerr';
            rewrite ^/jellyseerr/?(.*)$ /$1 break;

            # Redirect location headers
            proxy_redirect ^ /$app;
            proxy_redirect /setup /$app/setup;
            proxy_redirect /login /$app/login;

            # Sub filters to replace hardcoded paths
            proxy_set_header Accept-Encoding "";
            sub_filter_once off;
            sub_filter_types *;
            sub_filter 'href="/"' 'href="/$app"';
            sub_filter 'href="/login"' 'href="/$app/login"';
            sub_filter 'href:"/"' 'href:"/$app"';
            sub_filter '\/_next' '\/$app\/_next';
            sub_filter '/_next' '/$app/_next';
            sub_filter '/api/v1' '/$app/api/v1';
            sub_filter '/login/plex/loading' '/$app/login/plex/loading';
            sub_filter '/images/' '/$app/images/';
            sub_filter '/android-' '/$app/android-';
            sub_filter '/apple-' '/$app/apple-';
            sub_filter '/favicon' '/$app/favicon';
            sub_filter '/logo_' '/$app/logo_';
            sub_filter '/site.webmanifest' '/$app/site.webmanifest';
          '';
        };
      };

      jellyseerr = {
        enable = true;
        # group = "media";
        port = cfg.ports.mediaServer.jellyseerr;
      };
    };
  };
}
