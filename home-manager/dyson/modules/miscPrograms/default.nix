{
  pkgs,
  config,
  ...
}: let
  inherit (config.consts.lib) optItemList;
  mp = config.setup.miscPrograms;
in {
  imports = [./discord.nix ./hexchat.nix ./xremap.nix];

  home.packages =
    optItemList mp.handbrake pkgs.handbrake
    ++ optItemList mp.obsidian pkgs.obsidian
    # 23.11 doesn't copy the .desktop file properly
    # TODO: FIXME when 24.05 is stable
    ++ optItemList mp.rustdesk pkgs.unstable.rustdesk
    ++ optItemList mp.vlc pkgs.vlc
    ++ optItemList mp.zoom pkgs.zoom-us;
}
