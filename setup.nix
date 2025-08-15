{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkOption types;

  defaultTrue = mkOption {
    default = true;
    type = types.bool;
  };
  defaultFalse = mkOption {
    default = false;
    type = types.bool;
  };
in
{
  imports = [
    ./modules/core.nix
    ./modules/home-manager.nix

    ./modules/graphical
    ./modules/laptop

    ./modules/androidTools
    ./modules/backup
    ./modules/bluetooth
    ./modules/desktopEnvironments
    ./modules/displayManagers
    ./modules/development
    ./modules/gaming
    ./modules/gpu
    ./modules/openRGB
    ./modules/impermanence
    ./modules/homeServer
    ./modules/misc
    ./modules/pam
    ./modules/printing
    ./modules/secrets
    ./modules/ssh
    ./modules/uinput
    ./modules/users
    ./modules/virtualBox
  ];

  options.setup = {
    hostname = mkOption {
      type = types.nonEmptyStr;
    };
    isGraphical = defaultTrue;
    isLaptop = defaultFalse;

    hasBluetooth = mkOption {
      type = types.bool;
      default = config.setup.isLaptop;
    };
    hasDedicatedGpu = mkOption {
      type = types.bool;
      default = config.hardware.graphics.enable;
    };

    # === Basic system config
    ssh = {
      enable = defaultTrue;
      mosh = defaultTrue;
    };

    # === Android dev
    androidTools = {
      enable = defaultFalse;
      droidcam = defaultTrue;
      users = mkOption {
        type = types.listOf types.nonEmptyStr;
        default = [ ];
      };
    };

    # === Desktop stuff
    profilePictures = mkOption {
      type = types.submodule {
        freeformType = types.attrsOf types.path;
      };
      default = { };
    };

    desktopEnvironments = {
      cinnamon = {
        enable = defaultFalse;
      };
      gnome = {
        enable = defaultFalse;
        minimal = defaultTrue;
      };
      hyprland.enable = defaultFalse;
    };

    displayManagers = {
      gdm = {
        enable = defaultFalse;
      };

      sddm = {
        enable = defaultFalse;
        theme = mkOption {
          type = types.enum [
            "catppuccin-macchiato"
            "sugar-light-nixos-simple-blue"
          ];
        };
      };

      tuigreet.enable = defaultFalse;
    };

    # === Development
    binfmt = {
      aarch64 = defaultFalse;
    };

    podman.enable = defaultFalse;

    # === Gaming
    gaming = {
      enable = defaultFalse;
      emulators = {
        ps3 = defaultTrue;
      };
      lutris = defaultTrue;
      minecraft = defaultTrue;
      steam = {
        enable = defaultTrue;
        enableProtonGE = defaultTrue;
      };
    };

    openRGB = {
      enable = defaultFalse;
      usePlugins = defaultTrue;
      simpleDaytimeRainbow = defaultFalse;
    };

    # === Home server
    homeServer = {
      enable = defaultFalse;

      domainName = mkOption {
        type = types.nonEmptyStr;
      };

      # NOTE: When using impermanence, we intentionally do not persist dataRoot
      # or any directories that default to being inside it. This is because
      # dataRoot is expected to be mapped to a different drive than normal /,
      # such as an external hard drive or RAID array. As such, it doesn't make
      # sense to have things on dataRoot persist using the normal mechanism,
      # since the whole drive should be persistent anyway.
      dataRoot = mkOption {
        type = types.nonEmptyStr;
      };

      manager = mkOption {
        type = types.nonEmptyStr;
        description = "The primary user account on the server. This user will be added to groups like `media` and `nextcloud`.";
      };

      # All the ports used by different services
      ports =
        let
          port =
            num:
            mkOption {
              type = types.port;
              default = num;
            };
        in
        {
          haproxy = {
            myspeed = port 5217;

            mediaServer = {
              audiobookshelf = port 8001;
              jellyseerr = port 5056;
              fileflows = port 19201;
            };
          };

          homepage = port 42731;

          adguardhome = {
            http = port 3000;
            https = port 3001;
            dnsOverTls = port 853; # TCP
            dnsOverQuic = port 853; # UDP
          };
          unbound = port 5335;
          myspeed = port 5216;
          ntfy = {
            http = port 4000;
            https = port 4001;
          };
          squid = port 3128;
          scrutiny = port 29517;

          kiwix = port 46217;

          mediaServer = {
            audiobookshelf = port 8000;
            calibre = {
              server = port 8082;
              web = port 8083;
            };
            jellyfin = {
              http = port 8096;
              https = port 8920;
            };
            jellyseerr = port 5055;
            navidrome = port 4533;
            stash = port 9999;

            bazarr = port 6767;
            lidarr = port 8686;
            radarr = port 7878;
            readarr = port 8787;
            speakarr = port 8282;
            sonarr = port 8989;
            whisparr = port 6969;

            prowlarr = port 9696;
            transmission = port 9091;

            fileflows = port 19200;
            whisper-asr = port 9000;
          };

          cloud = {
            copyparty = port 8426;
            nextcloud = port 38260;
          };

          personalProjects = {
            winter-wonderlights = {
              normal = port 23120;
              scanner = port 23121;
            };
          };
        };

      adguardhome.enable = defaultFalse;
      myspeed.enable = defaultFalse;
      ntfy.enable = defaultFalse;

      firefly-iii.enable = defaultFalse;

      squid.enable = defaultFalse;

      scrutiny.enable = defaultFalse;

      kiwix = {
        enable = defaultFalse;

        zimFilePrefixes = mkOption {
          type = types.nonEmptyListOf types.nonEmptyStr;
          description = ''
            The prefixes of the ZIM files to download. Do not include the date and extension.

            For example, `[ "wikipedia_en_all_maxi" ]` would download
            `wikipedia_en_all_maxi_YYYY-DD.zim` for the most recent available month.
          '';
        };
      };

      homeAutomation = { };

      mediaServer = {
        enable = defaultFalse;

        directoryMap = mkOption {
          type = types.attrsOf (types.listOf types.nonEmptyStr);
          default = { };
          example = lib.literalExample {
            radarr = "/data/media/movies";
            sonarr = "/data/media/tv";
          };
        };

        # See dataRoot for note about persisting on impermanent setups
        mediaRoot = mkOption {
          type = types.nonEmptyStr;
          default = "${config.setup.homeServer.dataRoot}/media";
        };

        books = defaultTrue;
        music = defaultTrue;
        movies = defaultTrue;
        telly = defaultTrue;
        porn = defaultFalse;

        transmission = {
          ovpnName = mkOption {
            type = types.nonEmptyStr;
            description = ''
              The unqualified name of the OpenVPN config file to be used for transmission.

              All files are expected to be /etc/openvpn/something.ovpn, so if this option was set to "gh_airvpn", then the relevant systemd service would expect to find /etc/openvpn/gb_airvpn.ovpn".
            '';
          };
          thirdOctet = mkOption {
            type = types.ints.between 1 255;
            default = 5;
            description = ''
              We use a veth system to connect the normal internet to the network namespace used to keep transmission in a VPN. The veth interfaces have the IP addresses 192.168.X.1 and 192.168.X.2, where X is this thirdOctet option.
            '';
          };
        };
      };

      cloud = {
        basic = {
          enable = defaultFalse;

          # See dataRoot for note about persisting on impermanent setups
          cloudRoot = mkOption {
            type = types.nonEmptyStr;
            default = "${config.setup.homeServer.dataRoot}/cloud";
          };
        };

        copyparty = {
          enable = defaultFalse;

          # See dataRoot for note about persisting on impermanent setups
          cloudRoot = mkOption {
            type = types.nonEmptyStr;
            default = "${config.setup.homeServer.dataRoot}/cloud";
          };
        };

        nextcloud = {
          enable = defaultFalse;

          # See dataRoot for note about persisting on impermanent setups
          cloudRoot = mkOption {
            type = types.nonEmptyStr;
            default = "${config.setup.homeServer.dataRoot}/nextcloud";
          };
        };
      };

      personalProjects = {
        enable = defaultFalse;

        tictactoe = defaultTrue;
        winter-wonderlights = defaultTrue;
        wordle = defaultTrue;
      };
    };

    # === Misc
    misc = {
      services = {
        foldingAtHome.enable = defaultFalse;
      };
    };

    # === Backup
    backup = {
      enable = defaultFalse;

      users = mkOption {
        type = types.listOf types.nonEmptyStr;
        default = [ ];
        description = "The users who are allowed to access the backup server directly.";
      };

      paths = mkOption {
        type = types.listOf types.nonEmptyStr;
        default = [ ];
        description = "The paths that will be included in the backup.";
      };

      exclude = mkOption {
        type = types.listOf types.nonEmptyStr;
        default = [ ];
        description = "Paths to exclude from the backup.";
      };

      startAt = mkOption {
        type = types.either types.str (types.listOf types.str);
        default = "00:00";
        description = "When or how often the automatic backup should run.";
      };

      ntfy = {
        url = mkOption {
          type = types.nullOr types.nonEmptyStr;
          default = null;
          description = "The URL of the ntfy.sh server to use for sending notifications.";
        };
        topic = mkOption {
          type = types.nonEmptyStr;
          default = "nixos-backups";
        };
      };
    };

    # === Impermanence
    impermanence =
      let
        keepList = mkOption {
          type = types.listOf (types.either types.nonEmptyStr types.attrs);
          default = [ ];
        };
      in
      {
        enable = defaultFalse;
        debug = defaultFalse;

        isEncrypted = mkOption {
          type = types.bool;
          default = config.setup.impermanence.mainDriveDevice == "/dev/mapper/cryptroot";
        };

        mainDriveDevice = mkOption {
          type = types.nonEmptyStr;
        };

        keepDirs = keepList;
        keepFiles = keepList;
      };

    # === Passwords
    pamShortenFailDelay = {
      enable = defaultTrue;
      microseconds = mkOption {
        type = types.ints.unsigned;
        default = 150000; # 150 ms
      };
    };

    # === Printing
    printing = {
      enable = defaultFalse;
      networkAutoDiscovery = defaultTrue;
      scanning = defaultTrue;

      users = mkOption {
        type = types.listOf types.nonEmptyStr;
        default = [ ];
      };

      specificPrinters = {
        canonPixmaMG3250 = defaultFalse;
      };
    };

    # === Secrets
    secrets = {
      enable = defaultTrue;
      userPasswords = {
        enable = defaultTrue;

        # Note that enabling any of these DOES NOT enable the user. Use
        # `setup.users` to enable users.
        users = {
          dyson = defaultTrue;
          pi = defaultTrue;
          rebecca = defaultTrue;
        };
      };
      networking = {
        enable = defaultFalse;
        simpleWifiNetworkNames = mkOption {
          type = types.listOf types.nonEmptyStr;
          default = [ "HOME" ];
          description = ''The names of the simple WiFi networks to use. Each name here should have entries of the form "<name>_SSID" and "<name>_PSK" in the secret networking.env file.'';
        };
        complex = {
          eduroam = defaultTrue;
        };
      };
      vpn = {
        enable = defaultFalse;
        vpns = mkOption {
          type = types.listOf (
            types.submodule {
              options = {
                vpnName = mkOption {
                  type = types.nonEmptyStr;
                };
                users = mkOption {
                  type = types.listOf types.nonEmptyStr;
                };
              };
            }
          );
          default = [
            {
              vpnName = "ch_airvpn";
              users = [ "dyson" ];
            }
            {
              vpnName = "gb_airvpn";
              users = [ "dyson" ];
            }
            {
              vpnName = "us_airvpn";
              users = [ "dyson" ];
            }
          ];
        };
      };
      tailscale.enable = defaultTrue;
      cachix.enable = defaultTrue;
    };

    # === uinput
    # We need uinput for xremap and weylus
    uinput = {
      enable = defaultFalse;
      users = mkOption {
        type = types.listOf types.nonEmptyStr;
        default = [ ];
      };
    };

    # === Users
    users = {
      dyson = defaultTrue;
      pi = defaultFalse;
      rebecca = defaultFalse;
    };

    # === VirtualBox
    virtualBox = {
      guest.enable = defaultFalse;
      host = {
        enable = defaultFalse;
        users = mkOption {
          type = types.listOf types.nonEmptyStr;
          default = [ ];
        };
        asSpecialisation = defaultFalse;
      };
    };
  };
}
