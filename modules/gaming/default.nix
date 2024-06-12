{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [./emulators.nix ./steam.nix ./lutris.nix];

  config = lib.mkIf config.setup.gaming.enable {
    hardware.xone.enable = true;
    programs.gamemode.enable = true;

    environment.systemPackages = with pkgs; [ludusavi mangohud];

    # Gaming is still broken on Wayland
    services.xserver.displayManager.gdm.wayland = false;
  };
}
