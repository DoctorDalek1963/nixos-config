{
  pkgs,
  lib,
  config,
  ...
}: let
  mp = config.setup.miscPrograms;
in {
  imports = [./discord.nix ./feishin.nix ./hexchat.nix ./xremap.nix];

  home.packages =
    lib.optional mp.handbrake pkgs.handbrake
    ++ lib.optional mp.obsidian pkgs.obsidian
    ++ lib.optional mp.rustdesk pkgs.rustdesk
    ++ lib.optional mp.vlc pkgs.vlc
    ++ lib.optional mp.zoom pkgs.zoom-us;

  setup.impermanence.keepDirs = lib.optionals mp.obsidian ["Obsidian" ".config/obsidian"];
}
