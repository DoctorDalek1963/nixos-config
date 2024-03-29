{
  lib,
  config,
  ...
}: {
  imports = [./steam.nix ./lutris.nix];

  config = lib.mkIf config.setup.gaming.enable {
    hardware.xone.enable = true;
    programs.gamemode.enable = true;
  };
}
