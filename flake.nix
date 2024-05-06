{
  description = "DoctorDalek1963's NixOS flake";

  inputs = {
    # TODO: I'm using unstable here to get better drivers for Alex-NixOS, which
    # uses a Radeon RX 7800 XT card and needs newer Mesa drivers. Once these
    # drivers are stable (hopefully 24.05 or 24.11?), then this should be
    # switched back to stable
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      flake.nixosConfigurations = {
        iso = let
          system = "x86_64-linux";
        in
          nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {inherit self inputs system;};
            modules = ["${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix" ./iso];
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

        "VirtualBox-NixOS" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {inherit inputs;};
          modules = [
            ./setup.nix
            ./machines/VirtualBox-NixOS
            {
              setup = {
                hostname = "VirtualBox-NixOS";

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
      };

      imports = [
        inputs.pre-commit-hooks.flakeModule
      ];

      systems = ["x86_64-linux" "aarch64-linux"];
      perSystem = {
        config,
        system,
        ...
      }: let
        pkgs = import nixpkgs {inherit system;};
      in {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            # Secrets
            age
            sops

            # Build ISO with justfile
            just
            inputs.disko.packages."${system}".disko
            nix-output-monitor
          ];
          shellHook = ''
            ${config.pre-commit.installationScript}
          '';
        };

        # See https://flake.parts/options/pre-commit-hooks-nix and
        # https://github.com/cachix/git-hooks.nix/blob/master/modules/hooks.nix
        # for all the available hooks and options
        pre-commit = {
          # One of the hooks runs `nix flake check` on this flake, so we don't
          # want to recurse infinitely
          check.enable = false;

          settings.hooks = {
            check-added-large-files.enable = true;
            check-merge-conflicts.enable = true;
            check-toml.enable = true;
            check-vcs-permalinks.enable = true;
            check-yaml.enable = true;
            end-of-file-fixer.enable = true;
            trim-trailing-whitespace.enable = true;

            alejandra.enable = true;
            deadnix.enable = true;
            statix.enable = true;

            nixos-flake-check = {
              enable = true;
              name = "nixos flake check";
              entry = "nix flake check";
              files = ''.*\.(nix|lock)$'';
              pass_filenames = false;
              stages = ["pre-push"];
            };
            hm-flake-check = {
              enable = true;
              name = "home-manager flake check";
              entry = ''${pkgs.bash}/bin/bash -c 'for user in ./home-manager/*; do nix flake check "$user"; done' '';
              files = ''.*\.(nix|lock)$'';
              pass_filenames = false;
              stages = ["pre-push"];
            };
          };
        };
      };
    };
}
