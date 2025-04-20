{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
in {
  config = lib.mkIf (cfg.enable && cfg.ntfy.enable) {
    setup.impermanence.keepDirs = ["/var/lib/ntfy-sh"];

    services.ntfy-sh = {
      enable = true;

      settings = {
        base-url = "https://${cfg.domainName}:${toString cfg.ports.ntfy.https}";

        listen-http = ":${toString cfg.ports.ntfy.http}";
        listen-https = ":${toString cfg.ports.ntfy.https}";

        cert-file = "/etc/tailscale-certificates/${cfg.domainName}/cert.pem";
        key-file = "/etc/tailscale-certificates/${cfg.domainName}/key.pem";

        enable-signup = true;
        enable-login = true;

        # Only needed for iOS notifications because Apple is awkward
        upstream-base-url = "https://ntfy.sh";
      };
    };

    systemd.services.ntfy-sh = {
      after = ["network.target" "tailscale-certificates.service"];
      requires = ["tailscale-certificates.service"];

      serviceConfig = {
        DynamicUser = lib.mkForce false;

        User = "ntfy-sh";
        Group = "certs";
      };
    };
  };
}
