{
  Alex-NixOS.dyson.setup = {
    username = "dyson";

    desktopEnvironments = {
      background = {
        light = ./files/desktop-backgrounds/nixos-catppuccin-latte-gay.png;
        dark = ./files/desktop-backgrounds/nixos-catppuccin-macchiato-gay.png;
      };
      gnome.theme = "catppuccin-adaptive-macchiato-mauve";
      hyprland.theme = "catppuccin-macchiato-mauve";
    };

    terminal.tools.yt-dlp = true;

    librewolf.enable = true;

    rclone = {
      enable = true;
      automounts = [
        # STFP, don't set pub_key_file, just set key_file and key_file_pass and
        # it will find the public key automatically
        {
          remote = "sasha-ssh";
          remotePath = "/";
          mountpoint = "/home/dyson/sasha";
        }
      ];
    };

    maths.enable = true;

    programming = {
      haskell = true;
      python = true;
      rust = true;

      jetbrains = true;
      misc = true;
    };

    misc = {
      programs = {
        anki = true;
        discord = true;
        feishin = true;
        ms-teams = true;
        obsidian = true;
        rustdesk = true;
        vlc = true;
        zoom = true;
      };
      services.easyeffects = true;
    };

    office.onlyoffice = true;
  };

  Bert-NixOS.pi.setup = {
    username = "pi";

    terminal = {
      tools = {
        btop.gpuSupport = false;
        git-all = false;
        nvim = "tiny";
      };
    };
  };

  Olivia-NixOS = {
    dyson.setup = {
      username = "dyson";

      desktopEnvironments = {
        background = {
          light = ./files/desktop-backgrounds/nixos-catppuccin-latte-gay.png;
          dark = ./files/desktop-backgrounds/nixos-catppuccin-macchiato-gay.png;
        };
        cinnamon = {
          menuIcon = ./files/icons/nix-snowflake-black.svg;
          theme = {
            gtk = "Mint-Y-Orange";
            cursor = "Bibata-Original-Classic";
          };
        };
      };

      terminal.tools.nvim = "small";

      librewolf = {
        enable = true;
        minimal = true;
      };

      misc.programs = {
        rustdesk = true;
        vlc = true;
      };
    };

    rebecca.setup = {
      username = "rebecca";

      desktopEnvironments = {
        background-slideshow-path = "/home/rebecca/Pictures/Wallpaper Slideshow";
        cinnamon = {
          menuIcon = ./files/icons/tux-black.svg;
          theme = {
            gtk = "Mint-Y-Orange";
            cursor = "Bibata-Original-Classic";
          };
        };
      };

      terminal.tools = {
        nvim = "small";
        # Nemo is much better for her and Yazi has a .desktop file so it gets
        # all up in yo face
        yazi = false;
      };

      librewolf = {
        enable = true;
        minimal = true;
      };

      misc.programs = {
        evince = true;
        rustdesk = true;
        vlc = true;
        zathura = false;
      };

      office.onlyoffice = true;
    };
  };

  Sasha-NixOS.dyson.setup = {
    username = "dyson";

    terminal = {
      tools = {
        git-all = false;
        nvim = "small";
      };
    };
  };

  Harold-NixOS.dyson.setup = {
    username = "dyson";

    desktopEnvironments = {
      background = {
        light = ./files/desktop-backgrounds/nixos-catppuccin-latte-gay.png;
        dark = ./files/desktop-backgrounds/nixos-catppuccin-macchiato-gay.png;
      };
      gnome.theme = "catppuccin-adaptive-macchiato-mauve";
      hyprland.theme = "catppuccin-macchiato-mauve";
    };

    terminal.tools.yt-dlp = true;

    librewolf.enable = true;

    rclone = {
      enable = true;
      automounts = [
        # STFP, don't set pub_key_file, just set key_file and key_file_pass and
        # it will find the public key automatically
        {
          remote = "sasha-ssh";
          remotePath = "/";
          mountpoint = "/home/dyson/sasha";
        }
      ];
    };

    maths.enable = true;

    programming = {
      haskell = true;
      python = true;
      rust = true;

      misc = true;
    };

    misc = {
      programs = {
        anki = true;
        feishin = true;
        ms-teams = true;
        obsidian = true;
        rustdesk = true;
        vlc = true;
      };
      services.easyeffects = true;
    };

    office.onlyoffice = true;
  };

  VirtualBox-NixOS.dyson.setup = {
    username = "dyson";

    desktopEnvironments = {
      background = ./files/desktop-backgrounds/virtualbox.jpg;
      gnome.theme = "catppuccin-adaptive-macchiato-mauve";
    };

    librewolf = {
      enable = true;
      minimal = true;
    };
  };
}
