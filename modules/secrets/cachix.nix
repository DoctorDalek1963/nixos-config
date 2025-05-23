{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.secrets;
in {
  config = lib.mkIf cfg.cachix.enable {
    environment.systemPackages = [pkgs.cachix];

    sops.secrets = {
      "cachix/tokens/doctordalek1963" = {mode = "0400";};
    };

    # services.cachix-watch-store = {
    #   enable = true;
    #   cacheName = "doctordalek1963";
    #   cachixTokenFile = config.sops.secrets."cachix/tokens/doctordalek1963".path;
    #   compressionLevel = 5;
    # };

    # Don't forget to update these in iso/default.nix and .github/workflows/ as well!
    nix.settings = {
      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.lix.systems"
        "https://doctordalek1963.cachix.org"
      ];
      trusted-public-keys = [
        "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
        "doctordalek1963.cachix.org-1:ide2OUuSBdJY4mSTyIanZaafJhcHNA5fFh6P633b8EI="
      ];
    };
  };
}
