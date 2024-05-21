{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
in {
  imports = [./personalProjects];

  config = lib.mkIf cfg.personalProjects.enable {
    services.nginx = {
      enable = true;
      virtualHosts."${cfg.domainName}" = {
        enableACME = true;
        forceSSL = true;
      };
    };

    networking.firewall.allowedTCPPorts = [80 443];

    security.acme = {
      acceptTerms = true;
      defaults.email = "dyson.dyson@icloud.com";
    };
  };
}
