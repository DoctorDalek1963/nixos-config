{
  pkgs,
  lib,
  config,
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

  networking = {
    hostName = cfg.hostname;
    firewall.enable = true;
    networkmanager.enable = true;
  };

  # This is a very weird quirk that really should be fixed upstream but I don't
  # understand the root cause. See https://github.com/NixOS/nixpkgs/issues/296953
  systemd.services.NetworkManager-wait-online = {
    serviceConfig.ExecStart = [
      ""
      "${pkgs.networkmanager}/bin/nm-online -q"
    ];
  };
}
