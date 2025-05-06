{
  pkgs,
  lib,
  config,
  inputs,
  system,
  self,
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

    # Use unstable packages on the command line with `nix shell unstable#pkgName`
    registry.unstable = {
      from = {
        type = "indirect";
        id = "unstable";
      };
      flake = inputs.nixpkgs-unstable;
      exact = true;
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

          # Proprietary Nvidia drivers
          "nvidia-x11"
          "nvidia-settings"

          # Automated transcoding on home server
          "fileflows"

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

        "electron-33.4.11" # TODO (25.05): Remove this once Feishin 1.12.4 is in nixpkgs
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

  # Use British keyboard in TTYs
  console.keyMap = "uk";

  environment.systemPackages =
    (with pkgs; [
      coreutils
      file
      git
      vim
      wget
    ])
    ++ lib.optional cfg.ssh.enable pkgs.sshfs;

  # This is a very weird quirk that really should be fixed upstream but I don't
  # understand the root cause. See https://github.com/NixOS/nixpkgs/issues/296953
  systemd.services.NetworkManager-wait-online = {
    serviceConfig.ExecStart = ["" "${pkgs.networkmanager}/bin/nm-online -q"];
  };

  system.nixos.label = let
    cfg = config.system.nixos;

    nixosVersion = builtins.concatStringsSep "." [
      cfg.release
      (builtins.substring 0 8 inputs.nixpkgs.sourceInfo.lastModifiedDate)
      inputs.nixpkgs.sourceInfo.shortRev
    ];

    buildVersion = builtins.concatStringsSep "." [
      (builtins.substring 0 8 self.sourceInfo.lastModifiedDate)
      (self.sourceInfo.shortRev or self.sourceInfo.dirtyShortRev)
    ];
  in
    builtins.concatStringsSep "-" (cfg.tags ++ [nixosVersion] ++ ["build" buildVersion]);
}
