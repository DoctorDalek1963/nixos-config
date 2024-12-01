{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [./emulators.nix ./lutris.nix ./minecraft.nix ./steam.nix];

  config = lib.mkIf config.setup.gaming.enable {
    hardware.xone.enable = true;
    programs.gamemode.enable = true;

    environment.systemPackages = with pkgs; [ludusavi mangohud];
  };
}
