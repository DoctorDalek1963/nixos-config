let
  subs = [
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
  flake.aspects.substituters.generic = {
    nix.settings = {
      substituters = map (def: "${def.url}?priority=${toString def.priority}") subs;

      trusted-public-keys = builtins.catAttrs "publicKey" subs;
    };
  };
}
