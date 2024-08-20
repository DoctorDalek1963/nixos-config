{
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.setup;
in {
  imports = [
    inputs.sops-nix.nixosModules.sops
    ./cachix.nix
    ./networking
    ./tailscale.nix
    ./users.nix
  ];

  config = lib.mkIf cfg.secrets.enable {
    sops = {
      defaultSopsFile = ../../sops-secrets/secrets.yaml;
      age = {
        keyFile =
          if cfg.impermanence.enable
          then "/persist/etc/nixos/sops-secrets/key.txt"
          else "/etc/nixos/sops-secrets/key.txt";
        generateKey = false;
      };
    };
  };
}
