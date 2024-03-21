{
  pkgs,
  config,
  ...
}: let
  inherit (config.consts.lib) optItemList;
  mp = config.setup.miscPrograms;
in {
  imports = [./discord.nix];

  home.packages =
    optItemList mp.handbrake pkgs.handbrake
    ++ optItemList mp.obsidian pkgs.obsidian
    ++ optItemList mp.vlc pkgs.vlc
    ++ optItemList mp.zoom pkgs.zoom-us;
}
