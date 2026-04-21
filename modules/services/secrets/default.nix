{ inputs, ... }:
{
  flake-file.inputs = {
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.aspects.secrets = {
    nixos =
      { config, ... }:
      {
        imports = [
          inputs.sops-nix.nixosModules.sops
        ];

        sops = {
          defaultSopsFile = ../../../sops-secrets/secrets.yaml;
          age = {
            keyFile =
              if config.impermanence.enable then
                "/persist/etc/nixos/sops-secrets/key.txt"
              else
                "/etc/nixos/sops-secrets/key.txt";
            generateKey = false;
          };
        };
      };

    homeManager =
      {
        lib,
        config,
        osConfig,
        ...
      }:
      {
        imports = [
          inputs.sops-nix.homeManagerModules.sops
        ];

        home.activation.restartSopsNix = lib.hm.dag.entryAfter [
          "writeBoundary"
        ] "run /run/current-system/sw/bin/systemctl restart --user sops-nix.service";

        impermanence.files = [
          ".config/sops/age/keys.txt"
        ];

        sops =
          let
            inherit (osConfig.users.users.${config.home.username}) uid;
          in
          {
            defaultSopsFile = ../../../sops-secrets/secrets.yaml;

            # This is suboptimal because we don't want to hardcode the UID, but
            # sops-nix seems to have no way of knowing where it will link things at
            # build time, so it can't reference paths to secrets which are not
            # symlinked elsewhere, like SSH key passphrases
            defaultSymlinkPath = "/run/user/${toString uid}/secrets";
            defaultSecretsMountPoint = "/run/user/${toString uid}/secrets.d";

            age.generateKey = false;
          };
      };
  };
}
