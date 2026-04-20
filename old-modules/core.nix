{
  pkgs,
  lib,
  config,
  inputs,
  # system,
  self,
  ...
}:
let
  cfg = config.setup;
in
{
  nix = {
    buildMachines = lib.mkIf (cfg.hostname != "Alex-NixOS") [
      {
        hostName = "alex";
        system = "x86_64-linux";
        protocol = "ssh-ng";

        maxJobs = 6;
        speedFactor = 2;

        supportedFeatures = [
          "nixos-test"
          "big-parallel"
          "kvm"
        ];
        mandatoryFeatures = [ ];
      }
    ];

    distributedBuilds = lib.mkIf (cfg.hostname != "Alex-NixOS") true;
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

  environment.systemPackages = with pkgs; [
    coreutils
    file
    git
    vim
    wget
  ];

  # Show asterisks when typing password
  security.sudo.extraConfig = "Defaults pwfeedback";

  # This is a very weird quirk that really should be fixed upstream but I don't
  # understand the root cause. See https://github.com/NixOS/nixpkgs/issues/296953
  systemd.services.NetworkManager-wait-online = {
    serviceConfig.ExecStart = [
      ""
      "${pkgs.networkmanager}/bin/nm-online -q"
    ];
  };

  system =
    let
      cfg = config.system.nixos;

      nixosVersion = builtins.concatStringsSep "." [
        cfg.release
        (builtins.substring 0 8 inputs.nixpkgs.sourceInfo.lastModifiedDate)
        inputs.nixpkgs.sourceInfo.shortRev
      ];

      configurationRevision = self.sourceInfo.shortRev or self.sourceInfo.dirtyShortRev;

      buildVersion = builtins.concatStringsSep "." [
        (builtins.substring 0 8 self.sourceInfo.lastModifiedDate)
        configurationRevision
      ];
    in
    {
      inherit configurationRevision;

      stateVersion = "25.11";

      nixos.label = builtins.concatStringsSep "-" (
        cfg.tags
        ++ [ nixosVersion ]
        ++ [
          "build"
          buildVersion
        ]
      );
    };
}
