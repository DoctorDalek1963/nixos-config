{
  self,
  nixpkgs,
  inputs,
}:
{
  iso =
    let
      system = "x86_64-linux";
    in
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit self inputs system; };
      modules = [
        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        ./iso

        # Include everything for certain machines so we don't have to download
        # tons from the cache at installation time
        {
          environment.systemPackages =
            let
              # deadnix: skip
              allPkgs =
                hostname: users:
                self.outputs.nixosConfigurations."${hostname}".config.environment.systemPackages
                ++ (nixpkgs.lib.lists.flatten (
                  builtins.map (
                    user:
                    self.outputs.nixosConfigurations."${hostname}".config.home-manager.users."${user}".home.packages
                  ) users
                ));
            in
            # allPkgs "VirtualBox-NixOS" ["dyson"];
            [ ];
        }
      ];
    };

  "Alex-NixOS" = nixpkgs.lib.nixosSystem rec {
    system = "x86_64-linux";
    specialArgs = { inherit self inputs system; };
    modules = [
      ./setup.nix
      ./machines/Alex-NixOS
      {
        setup = {
          hostname = "Alex-NixOS";

          impermanence = {
            enable = true;
            mainDriveDevice = "/dev/mapper/cryptroot";
          };

          backup = {
            enable = true;
            users = [ "dyson" ];
            startAt = [ ];
          };

          virtualBox.host = {
            # enable = true;
            asSpecialisation = true;
            users = [ "dyson" ];
          };

          profilePictures.dyson = ./files/profile-pictures/dyson.png;

          binfmt.aarch64 = true;

          # podman.enable = true;

          misc.services.foldingAtHome.enable = true;

          printing = {
            enable = true;
            users = [ "dyson" ];
            # specificPrinters.canonPixmaMG3250 = true;
          };

          secrets = {
            enable = true;
            userPasswords.enable = true;
            networking = {
              enable = true;
              simpleWifiNetworkNames = [ "HOME" ];
            };
            vpn.enable = true;
          };

          uinput = {
            enable = true;
            users = [ "dyson" ];
          };

          openRGB = {
            enable = true;
            simpleDaytimeRainbow = true;
          };

          gaming.enable = true;

          androidTools = {
            enable = true;
            users = [ "dyson" ];
          };

          desktopEnvironments.hyprland.enable = true;
          displayManagers.tuigreet.enable = true;
        };
      }
    ];
  };

  "Bert-NixOS" =
    let
      system = "aarch64-linux";
    in
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit self inputs system; };
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
              manager = "pi";

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
                simpleWifiNetworkNames = [ "HOME" ];
              };
              vpn.enable = false;
            };

            users = {
              dyson = false;
              pi = true;
            };
          };
        }
      ];
    };

  "Harold-NixOS" = nixpkgs.lib.nixosSystem rec {
    system = "x86_64-linux";
    specialArgs = { inherit self inputs system; };
    modules = [
      ./setup.nix
      ./machines/Harold-NixOS
      {
        setup = {
          hostname = "Harold-NixOS";
          isLaptop = true;

          impermanence = {
            enable = true;
            mainDriveDevice = "/dev/mapper/cryptroot";
          };

          backup = {
            enable = true;
            users = [ "dyson" ];
            startAt = [ ];
          };

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
            users = [ "dyson" ];
          };

          androidTools = {
            enable = true;
            users = [ "dyson" ];
          };

          desktopEnvironments.hyprland.enable = true;
          displayManagers.tuigreet.enable = true;
        };
      }
    ];
  };

  "Olivia-NixOS" = nixpkgs.lib.nixosSystem rec {
    system = "x86_64-linux";
    specialArgs = { inherit self inputs system; };
    modules = [
      ./setup.nix
      ./machines/Olivia-NixOS
      {
        setup = {
          hostname = "Olivia-NixOS";
          isLaptop = true;

          hasDedicatedGpu = false;

          users.rebecca = true;

          printing = {
            enable = true;
            users = [
              "dyson"
              "rebecca"
            ];
            specificPrinters.canonPixmaMG3250 = true;
          };

          secrets = {
            enable = true;
            userPasswords.enable = true;
            networking = {
              enable = true;
              simpleWifiNetworkNames = [ "HOME" ];
            };
          };

          desktopEnvironments.cinnamon.enable = true;
          displayManagers.sddm = {
            enable = true;
            theme = "sugar-light-nixos-simple-blue";
          };
        };
      }
    ];
  };

  "Sasha-NixOS" = nixpkgs.lib.nixosSystem rec {
    system = "x86_64-linux";
    specialArgs = { inherit self inputs system; };
    modules = [
      ./setup.nix
      ./machines/Sasha-NixOS
      {
        setup = {
          hostname = "Sasha-NixOS";
          isGraphical = false;

          impermanence = {
            enable = true;
            mainDriveDevice = "/dev/disk/by-partlabel/disk-sda-nixos";
          };

          backup = {
            enable = true;
            users = [ "dyson" ];
            startAt = "03:00";
            ntfy.url = "http://localhost:4000";
          };

          misc.services.foldingAtHome.enable = true;

          homeServer = {
            enable = true;
            domainName = "sasha-nixos.triceratops-egret.ts.net";
            dataRoot = "/data";
            manager = "dyson";

            adguardhome.enable = true;
            myspeed.enable = true;
            ntfy.enable = true;

            firefly-iii.enable = true;

            squid.enable = true;

            scrutiny.enable = true;

            kiwix = {
              enable = true;
              zimFilePrefixes = [
                "stack_exchange/math.stackexchange.com_en_all"
                "stack_exchange/superuser.com_en_all"
                "stack_exchange/tex.stackexchange.com_en_all"
                "stack_exchange/unix.stackexchange.com_en_all"
                "stack_exchange/vi.stackexchange.com_en_all"
                "wikipedia/wikipedia_en_computer_maxi"
                "wikipedia/wikipedia_en_geography_maxi"
                "wikipedia/wikipedia_en_history_maxi"
                "wikipedia/wikipedia_en_mathematics_maxi"
                "wiktionary/wiktionary_en_all_nopic"
              ];
            };

            mediaServer = {
              enable = true;
              porn = true;
              transmission.ovpnName = "eu_airvpn";
            };

            cloud.copyparty.enable = true;

            personalProjects = {
              enable = true;
              # This only works on a Raspberry Pi
              winter-wonderlights = false;
            };
          };

          secrets = {
            enable = true;
            userPasswords.enable = true;
            networking = {
              enable = true;
              simpleWifiNetworkNames = [ "HOME" ];
            };
            vpn = {
              enable = true;
              vpns = [
                {
                  vpnName = "eu_airvpn";
                  users = [
                    "dyson"
                    "transmission"
                  ];
                }
              ];
            };
          };
        };
      }
    ];
  };

  "VirtualBox-NixOS" = nixpkgs.lib.nixosSystem rec {
    system = "x86_64-linux";
    specialArgs = { inherit self inputs system; };
    modules = [
      ./setup.nix
      ./machines/VirtualBox-NixOS
      {
        setup = {
          hostname = "VirtualBox-NixOS";

          impermanence = {
            enable = true;
            debug = true;
            mainDriveDevice = "/dev/mapper/cryptroot";
          };

          virtualBox.guest.enable = true;

          profilePictures.dyson = ./files/profile-pictures/dyson.png;

          secrets = {
            enable = true;
            userPasswords.enable = true;
            tailscale.enable = false;
          };

          uinput = {
            enable = true;
            users = [ "dyson" ];
          };

          desktopEnvironments.gnome.enable = true;
          displayManagers.gdm.enable = true;
        };
      }
    ];
  };
}
