{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup;
in {
  system.stateVersion = "23.11";

  nix = {
    settings = {
      # Keep the nix store optimised
      auto-optimise-store = true;

      # Enable flakes
      experimental-features = ["nix-command" "flakes"];
    };

    # Garbage collect old packages every two weeks
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  nixpkgs.config = {
    allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        # Gaming
        "steam"
        "steam-original"
        "steam-run"
        "xow_dongle-firmware" # Needed for xone driver

        # Printing
        "cnijfilter" # Canon Pixma driver
      ];

    permittedInsecurePackages = ["squid-6.8"];
  };

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      icu
      libz
      stdenv.cc.cc.lib
    ];
  };

  networking = {
    hostName = cfg.hostname;
    firewall.enable = true;
    networkmanager.enable = true;
  };

  time.timeZone = "Europe/London";

  i18n = {
    defaultLocale = "en_GB.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_GB.UTF-8";
      LC_IDENTIFICATION = "en_GB.UTF-8";
      LC_MEASUREMENT = "en_GB.UTF-8";
      LC_MONETARY = "en_GB.UTF-8";
      LC_NAME = "en_GB.UTF-8";
      LC_NUMERIC = "en_GB.UTF-8";
      LC_PAPER = "en_GB.UTF-8";
      LC_TELEPHONE = "en_GB.UTF-8";
      LC_TIME = "en_GB.UTF-8";
    };
  };

  programs.mosh.enable = cfg.ssh.mosh;

  services.openssh = {
    inherit (cfg.ssh) enable;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # Use British keyboard in TTYs
  console.keyMap = "uk";

  environment.systemPackages =
    (with pkgs; [
      busybox
      coreutils
      file
      git
      screen
      vim
      wget
    ])
    ++ lib.optional cfg.ssh.enable pkgs.sshfs;

  # This is a very weird quirk that really should be fixed upstream but I don't
  # understand the root cause. See https://github.com/NixOS/nixpkgs/issues/296953
  systemd.services.NetworkManager-wait-online = {
    serviceConfig.ExecStart = ["" "${pkgs.networkmanager}/bin/nm-online -q"];
  };
}
