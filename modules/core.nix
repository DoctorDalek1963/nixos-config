{
  pkgs,
  lib,
  config,
  inputs,
  system,
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

      trusted-users = ["root" "@wheel"];
    };

    # Garbage collect old packages every week
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  nixpkgs = {
    overlays = [
      # Access unstable packages through pkgs.unstable
      (_final: _prev: {
        unstable = inputs.nixpkgs-unstable.legacyPackages.${system};
      })
      inputs.nur.overlays.default
    ];

    config = {
      # These are lists of allowed unfree and insecure packages respectively.
      # They are allowed on any host (since this is core.nix), but they're
      # only actually installed by certain modules.
      allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          # === System-wide
          # Gaming
          "steam"
          "steam-unwrapped"
          "xow_dongle-firmware" # Needed for xone driver

          # Printing
          "cnijfilter" # Canon Pixma driver

          # === home-manager
          "discord"
          "libsciter" # For RustDesk
          "obsidian"

          # Firefox extensions
          "dashlane"
          "enhancer-for-youtube"

          # Microsoft fonts
          "corefonts"
          "vista-fonts"
        ];

      permittedInsecurePackages = [
        # HTTP proxy used on home server. It's okay because it's only
        # accessible to devices on my tailnet and not the public internet
        "squid-6.10"
      ];
    };
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
