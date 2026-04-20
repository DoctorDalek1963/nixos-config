{ inputs, ... }:
{
  flake-file.inputs = {
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.aspects.lanzaboote = {
    nixos =
      { pkgs, ... }:
      {
        imports = [
          inputs.lanzaboote.nixosModules.lanzaboote
        ];

        environment.systemPackages = [
          pkgs.sbctl
        ];

        # TODO: Design impermanence
        # setup.impermanence.keepDirs = [
        #   "/var/lib/sbctl"
        # ];

        boot = {
          lanzaboote = {
            enable = true;
            pkiBundle = "/var/lib/sbctl";

            autoGenerateKeys.enable = true;
            autoEnrollKeys = {
              enable = true;
              autoReboot = true;
            };
          };

          loader = {
            systemd-boot = {
              enable = false; # lanzaboote instead
              configurationLimit = 10;
            };
            efi.canTouchEfiVariables = true;
            timeout = 2;
          };
        };
      };
  };
}
