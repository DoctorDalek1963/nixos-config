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

    nix.settings = {
      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
        "https://doctordalek1963.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "doctordalek1963.cachix.org-1:ide2OUuSBdJY4mSTyIanZaafJhcHNA5fFh6P633b8EI="
      ];
    };
  };
}
