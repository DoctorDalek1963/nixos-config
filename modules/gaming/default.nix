{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./emulators.nix
    ./lutris.nix
    ./minecraft.nix
    ./steam.nix
  ];

  config = lib.mkIf config.setup.gaming.enable {
    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_xanmod_stable;

    hardware.xone.enable = true;
    programs.gamemode.enable = true;

    environment.systemPackages = with pkgs; [
      ludusavi
      mangohud
    ];

    systemd.settings.Manager.DefaultLimitNOFILE = "${toString (2048 * 64)}:${toString (2048 * 256)}";
  };
}
