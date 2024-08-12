{
  self,
  nixpkgs,
  inputs,
}: rec {
  iso = let
    system = "x86_64-linux";
  in
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {inherit self inputs system;};
      modules = [
        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        ./iso

        # Include everything for VirtualBox so it doesn't have to
        # download tons from the cache every time I test an install
        # {environment.systemPackages = VirtualBox-NixOS.config.environment.systemPackages;}
      ];
    };

  "Alex-NixOS" = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {inherit inputs;};
    modules = [
      ./setup.nix
      ./machines/Alex-NixOS
      {
        setup = {
          hostname = "Alex-NixOS";

          virtualBox.host = {
            enable = true;
            users = ["dyson"];
          };

          profilePictures.dyson = ./files/profile-pictures/dyson.png;

          binfmt.aarch64 = true;

          printing = {
            enable = true;
            users = ["dyson"];
            specificPrinters.canonPixmaMG3250 = true;
          };

          secrets = {
            enable = true;
            userPasswords.enable = true;
            networking = {
              enable = true;
              simpleWifiNetworkNames = ["HOME"];
            };
            vpn.enable = true;
          };

          uinput = {
            enable = true;
            users = ["dyson"];
          };

          openRGB.enable = true;

          gaming.enable = true;

          androidTools = {
            enable = true;
            users = ["dyson"];
          };

          desktopEnvironments.gnome.enable = true;
          displayManagers.gdm.enable = true;
        };
      }
    ];
  };

  "Bert-NixOS" = let
    system = "aarch64-linux";
  in
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {inherit inputs system;};
      modules = [
        inputs.nixos-hardware.nixosModules.raspberry-pi-4
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        ./setup.nix
        ./machines/Bert-NixOS
        {
          setup = {
            hostname = "Bert-NixOS";
            isGraphical = false;

            homeServer = {
              enable = true;
              domainName = "bert-nixos.triceratops-egret.ts.net";
              dataRoot = "/data";

              adguardhome.enable = true;
              myspeed.enable = true;
              ntfy.enable = true;

              firefly-iii.enable = true;

              squid.enable = true;

              mediaServer = {
                enable = true;
                movies = false;
                telly = false;
                transmission.ovpnName = "ch_airvpn";
              };

              personalProjects = {
                enable = true;
                # I only need to enable this around Christmas, when I'm
                # actually using the lights
                winter-wonderlights = false;
              };
            };

            secrets = {
              enable = true;
              userPasswords = {
                enable = true;
                users = {
                  dyson = false;
                  pi = true;
                };
              };
              networking = {
                enable = true;
                simpleWifiNetworkNames = ["HOME"];
              };
              vpn = {
                enable = true;
                vpns = [
                  {
                    vpnName = "ch_airvpn";
                    users = ["pi"];
                  }
                ];
              };
            };

            users = {
              dyson = false;
              pi = true;
            };
          };
        }
      ];
    };

  "Harold-NixOS" = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {inherit inputs;};
    modules = [
      ./setup.nix
      ./machines/Harold-NixOS
      {
        setup = {
          hostname = "Harold-NixOS";
          isLaptop = true;

          profilePictures.dyson = ./files/profile-pictures/dyson.png;

          secrets = {
            enable = true;
            userPasswords.enable = true;
            networking = {
              enable = true;
              simpleWifiNetworkNames = [
                "HOME"
                "IZZY_LINEAGE"
                "FRIEND_1"
                "FRIEND_2"
              ];
            };
            vpn.enable = true;
          };

          uinput = {
            enable = true;
            users = ["dyson"];
          };

          androidTools = {
            enable = true;
            users = ["dyson"];
          };

          desktopEnvironments.gnome.enable = true;
          displayManagers.gdm.enable = true;
        };
      }
    ];
  };

  "Sasha-NixOS" = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {inherit inputs;};
    modules = [
      ./setup.nix
      ./machines/Sasha-NixOS
      {
        boot.plymouth.enable = true;

        setup = {
          hostname = "Sasha-NixOS";

          users.rebecca = true;

          printing = {
            enable = true;
            users = ["dyson" "rebecca"];
            specificPrinters.canonPixmaMG3250 = true;
          };

          secrets = {
            enable = true;
            userPasswords.enable = true;
            networking = {
              enable = true;
              simpleWifiNetworkNames = ["HOME"];
            };
          };

          desktopEnvironments.cinnamon.enable = true;
          displayManagers.sddm = {
            enable = true;
            theme = (nixpkgs.legacyPackages."x86_64-linux".callPackage
              ./modules/displayManagers/sddm/themes/sugar-light.nix {})
            {background = ./home-manager/files/desktop-backgrounds/nixos-catppuccin-latte.png;};
          };
        };
      }
    ];
  };

  "VirtualBox-NixOS" = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {inherit inputs;};
    modules = [
      ./setup.nix
      ./machines/VirtualBox-NixOS
      {
        # boot.plymouth.enable = true;

        setup = {
          hostname = "VirtualBox-NixOS";

          impermanence.enable = true;

          virtualBox.guest.enable = true;

          profilePictures.dyson = ./files/profile-pictures/dyson.png;

          secrets = {
            enable = true;
            userPasswords.enable = true;
            tailscale.enable = false;
          };

          uinput = {
            enable = true;
            users = ["dyson"];
          };

          desktopEnvironments.gnome.enable = true;
          displayManagers.gdm.enable = true;
        };
      }
    ];
  };
}
