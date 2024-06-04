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
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs";
      };
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
    username = "dyson";

    # Access unstable packages through pkgs.unstable
    # unstable-overlay = _final: _prev: {
    #   unstable = inputs.unstable.legacyPackages.${system};
    # };

    mkPkgs = system:
      import nixpkgs {
        inherit system;
        overlays = [
          # unstable-overlay
          inputs.nur.overlay
        ];
      };

    extraSpecialArgs = {inherit inputs;};
  in {
    packages = {
      "x86_64-linux".default = home-manager.defaultPackage."x86_64-linux";
      "aarch64-linux".default = home-manager.defaultPackage."aarch64-linux";
    };

    homeConfigurations = {
      "${username}@Alex-NixOS" = let
        system = "x86_64-linux";
      in
        home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs system;
          extraSpecialArgs = extraSpecialArgs // {inherit system;};
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

      "pi@Bert-NixOS" = let
        system = "aarch64-linux";
      in
        home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs system;
          extraSpecialArgs = extraSpecialArgs // {inherit system;};
          modules = [
            ./setup.nix
            {
              setup = {
                username = "pi";
                hostname = "Bert-NixOS";
                isNixOS = true;
                terminalTools.btop.enable = false;
                programming.miscTools.git-all = false;
              };
            }
          ];
        };

      "${username}@Sasha-Ubuntu" = let
        system = "x86_64-linux";
      in
        home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs system;
          extraSpecialArgs = extraSpecialArgs // {inherit system;};
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

      "${username}@Harold-NixOS" = let
        system = "x86_64-linux";
      in
        home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs system;
          extraSpecialArgs = extraSpecialArgs // {inherit system;};
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

      "${username}@VirtualBox-NixOS" = let
        system = "x86_64-linux";
      in
        home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs system;
          extraSpecialArgs = extraSpecialArgs // {inherit system;};
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
                miscPrograms.xremap = false;
              };
            }
          ];
        };
    };
  };
}
