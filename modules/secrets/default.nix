{
  lib,
  config,
  inputs,
  ...
}: {
  imports = [inputs.sops-nix.nixosModules.sops ./users.nix ./wifi.nix];

  config = lib.mkIf config.setup.secrets.enable {
    sops = {
      defaultSopsFile = ../../sops-secrets/secrets.yaml;
      age = {
        keyFile = "/etc/nixos/sops-secrets/key.txt";
        generateKey = false;
      };
    };
  };
}
