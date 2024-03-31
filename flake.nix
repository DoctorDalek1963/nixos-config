{
  description = "DoctorDalek1963's NixOS flake";

  inputs = {
    # TODO: I'm using unstable here to get better drivers for Alex-NixOS, which
    # uses a Radeon RX 7800 XT card and needs newer Mesa drivers. Once these
    # drivers are stable (hopefully 24.05 or 24.11?), then this should be
    # switched back to stable
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

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

              openRGB.enable = true;

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
