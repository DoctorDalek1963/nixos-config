{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.setup.secrets;

  substituters = [
    {
      url = "https://cache.nixos.org";
      publicKey = "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
      priority = 1;
    }
    {
      url = "https://nix-community.cachix.org";
      publicKey = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
      priority = 2;
    }
    {
      url = "https://numtide.cachix.org";
      publicKey = "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE=";
      priority = 3;
    }
    {
      url = "https://doctordalek1963.cachix.org";
      publicKey = "doctordalek1963.cachix.org-1:ide2OUuSBdJY4mSTyIanZaafJhcHNA5fFh6P633b8EI=";
      priority = 4;
    }
  ];
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

    # Don't forget to update these in iso/default.nix and .github/workflows/ as well!
    nix.settings = {
      substituters = map (def: "${def.url}?priority=${toString def.priority}") substituters;

      trusted-public-keys = builtins.catAttrs "publicKey" substituters;
    };
  };
}
