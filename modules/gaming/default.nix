{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [./emulators.nix ./lutris.nix ./minecraft.nix ./steam.nix];

  config = lib.mkIf config.setup.gaming.enable {
    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

    hardware.xone.enable = true;
    programs.gamemode.enable = true;

    environment.systemPackages = with pkgs; [ludusavi mangohud];

    systemd.extraConfig = "DefaultLimitNOFILE=${toString (2048 * 64)}:${toString (2048 * 256)}";
  };
}
