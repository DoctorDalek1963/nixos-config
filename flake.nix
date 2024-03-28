{
  description = "DoctorDalek1963's NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {nixpkgs, ...} @ inputs: {
    nixosConfigurations = {
      "Alex-NixOS" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          ./setup.nix
          ./hardware/alex.nix
          {
            setup = {
              hostname = "Alex-NixOS";

              virtualBoxHost = true;

              secrets = {
                enable = true;
                userPasswords.enable = true;
                networking = {
                  enable = true;
                  simpleWifiNetworkNames = ["HOME"];
                };
              };

              uinput = {
                enable = true;
                users = ["dyson"];
              };

              openRGB = true;

              gaming.enable = true;

              desktopEnvironments.gnome.enable = true;
              displayManagers.gdm.enable = true;
            };
          }
        ];
      };
      "VirtualBox-NixOS" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          ./setup.nix
          ./hardware/vbox.nix
          {
            setup = {
              hostname = "VirtualBox-NixOS";
              virtualBoxGuest = true;
              desktopEnvironments.gnome.enable = true;
              displayManagers.gdm.enable = true;
              uinput = {
                enable = true;
                users = ["dyson"];
              };
            };
          }
        ];
      };
    };
  };
}
