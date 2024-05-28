{
  description = "DoctorDalek1963's home-manager flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    # unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/nur";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim-flake.url = "github:DoctorDalek1963/nixvim-config";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    xremap = {
      url = "github:xremap/nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    username = "dyson";

    # Access unstable packages through pkgs.unstable
    # unstable-overlay = _final: _prev: {
    #   unstable = inputs.unstable.legacyPackages.${system};
    # };

    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        # unstable-overlay
        inputs.nur.overlay
      ];
    };

    extraSpecialArgs = {
      inherit system inputs;
    };
  in {
    packages.${system}.default = home-manager.defaultPackage.${system};

    homeConfigurations = {
      "${username}@Alex-NixOS" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;
        modules = [
          ./setup.nix
          {
            setup = {
              inherit username;
              hostname = "Alex-NixOS";
              isNixOS = true;

              desktopEnvironments.gnome = {
                enable = true;
                theme = "catppuccin-adaptive-macchiato-mauve";
                background = {
                  light = ./files/desktop-backgrounds/outer-wilds-sun.jpg;
                  dark = ./files/desktop-backgrounds/outer-wilds.jpg;
                };
              };

              terminalTools = {
                theme = "catppuccin-macchiato";
                useThemeInTerminalItself = true;
              };

              firefox.enable = true;

              rclone = {
                enable = true;
                automounts = [
                  {
                    remote = "OneDrive";
                    mountpoint = "/home/${username}/OneDrive";
                  }
                ];
              };

              maths.enable = true;

              programming = {
                rust = true;
              };

              miscPrograms = {
                hexchat = true;
                obsidian = true;
                rustdesk = true;
                vlc = true;
                xremap = true;
              };
            };
          }
        ];
      };

      "${username}@Sasha-Ubuntu" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;
        modules = [
          ./setup.nix
          {
            setup = {
              inherit username;
              hostname = "Sasha-Ubuntu";
              isNixOS = false;
              hasDvdDrive = true;
            };
          }
        ];
      };

      "${username}@Harold-NixOS" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;
        modules = [
          ./setup.nix
          {
            setup = {
              inherit username;
              hostname = "Harold-NixOS";
              isNixOS = true;
              isLaptop = true;

              desktopEnvironments.gnome = {
                enable = true;
                theme = "catppuccin-adaptive-macchiato-mauve";
                background = {
                  light = ./files/desktop-backgrounds/outer-wilds-sun.jpg;
                  dark = ./files/desktop-backgrounds/outer-wilds.jpg;
                };
              };

              terminalTools = {
                theme = "catppuccin-macchiato";
                useThemeInTerminalItself = true;
              };

              firefox.enable = true;

              rclone = {
                enable = true;
                automounts = [
                  {
                    remote = "OneDrive";
                    mountpoint = "/home/${username}/OneDrive";
                  }
                ];
              };

              maths.enable = true;

              programming = {
                rust = true;
              };

              miscPrograms = {
                discord = true;
                hexchat = true;
                obsidian = true;
                rustdesk = true;
                vlc = true;
                xremap = true;
              };
            };
          }
        ];
      };

      "${username}@VirtualBox-NixOS" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;
        modules = [
          ./setup.nix
          {
            setup = {
              inherit username;
              hostname = "VirtualBox-NixOS";
              isNixOS = true;

              desktopEnvironments.gnome = {
                enable = true;
                theme = "vimix-amethyst";
                background = ./files/desktop-backgrounds/virtualbox.jpg;
              };
              # firefox.enable = true;
              # rclone = {
              #   enable = true;
              #   automounts = [
              #     {
              #       remote = "OneDrive";
              #       mountpoint = "/home/${username}/OneDrive";
              #       readonly = true;
              #     }
              #   ];
              # };
              terminalTools.nvim = "small"; # My custom themes and hotkeys, but no LSPs
              miscPrograms.xremap = true;
            };
          }
        ];
      };
    };
  };
}
