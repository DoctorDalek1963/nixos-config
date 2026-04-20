{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.setup.secrets;
in
{
  config = lib.mkIf cfg.cachix.enable {
    environment.systemPackages = [ pkgs.cachix ];

    sops.secrets = {
      "cachix/tokens/doctordalek1963" = {
        mode = "0400";
      };
    };

    # services.cachix-watch-store = {
    #   enable = true;
    #   cacheName = "doctordalek1963";
    #   cachixTokenFile = config.sops.secrets."cachix/tokens/doctordalek1963".path;
    #   compressionLevel = 5;
    # };
  };
}
