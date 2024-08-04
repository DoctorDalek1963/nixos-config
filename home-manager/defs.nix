{
  home-manager,
  username,
  mkPkgs,
  extraSpecialArgs,
}: {
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

            desktopEnvironments = {
              background = {
                light = ./files/desktop-backgrounds/outer-wilds-sun.jpg;
                dark = ./files/desktop-backgrounds/outer-wilds.jpg;
              };
              gnome = {
                enable = true;
                theme = "catppuccin-adaptive-macchiato-mauve";
              };
            };

            terminalTools = {
              theme = "catppuccin-macchiato";
              useThemeInTerminalItself = true;
              yt-dlp = true;
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
              supersonic = true;
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
            terminalTools = {
              theme = "catppuccin-macchiato";
              btop.gpuSupport = false;
            };
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

            desktopEnvironments = {
              background = {
                light = ./files/desktop-backgrounds/outer-wilds-sun.jpg;
                dark = ./files/desktop-backgrounds/outer-wilds.jpg;
              };
              gnome = {
                enable = true;
                theme = "catppuccin-adaptive-macchiato-mauve";
              };
            };

            terminalTools = {
              theme = "catppuccin-macchiato";
              useThemeInTerminalItself = true;
              yt-dlp = true;
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
              supersonic = true;
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

            desktopEnvironments = {
              background = ./files/desktop-backgrounds/virtualbox.jpg;
              gnome = {
                enable = true;
                theme = "catppuccin-adaptive-macchiato-mauve";
              };
            };

            firefox = {
              enable = true;
              minimal = true;
            };

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
}
